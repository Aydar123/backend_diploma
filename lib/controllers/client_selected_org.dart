

import 'dart:io';

import 'package:conduit/conduit.dart';
import 'package:dcs/models/fields.dart';
import 'package:dcs/models/org_fields.dart';
import 'package:dcs/models/org_to_user_data.dart';
import 'package:dcs/models/organization.dart';
import 'package:dcs/models/user_data.dart';
import 'package:dcs/utils/app_response.dart';
import 'package:dcs/utils/app_utils.dart';

class AppClientSelectedOrg extends ResourceController {

  ManagedContext managedContext;

  AppClientSelectedOrg(this.managedContext);


  //Основные методы:
  // 1. Отобразить все организаци ✔
  // 2. Отобразить уникальные поля Организации ✔
  // 3. Заполнить их ✔

 
  // 1. Метод для отображения всех Организаций 888
  @Operation.get()
  Future<Response> getAllOrganization() async {
    try{
      final qGetAllOrganization = Query<Organization>(managedContext)
        ..returningProperties((x) => [x.id, x.fullName]);
      final List<Organization> listAllFields = await qGetAllOrganization.fetch();

      if(listAllFields.isEmpty) { return MyAppResponse.ok(message: "Пока тут пусто."); }

      return Response.ok(listAllFields);

    }catch(error) {
      return MyAppResponse.serverError(error, message: "Ошибка получения списка организаций!");
    }
  }

  // 2. Метод для отображения всех полей. Именно те поля, которые необходимы Организации 888
  @Operation.get("orgId")
  Future<Response> getUniqFieldsCurOrg(@Bind.path("orgId") int idOrg) async {
    try{
      final org = await managedContext.fetchObjectWithID<Organization>(idOrg);

      if (org == null) {
        return MyAppResponse.ok(message: "Такой Организации нет!");
      }

      //Возможно нужен join, чтобы вывести название Организации и ее уникальные поля, а не просто id!

      // final qGetUniqFieldsCurOrg = Query<OrgField>(managedContext)
      //   ..where((x) => x.orgId?.id).equalTo(idOrg);
      //final List<OrgField> listAllFields = await qGetUniqFieldsCurOrg.fetch();

      //По красоте выводим список полей (с названием поля!). Но результат - join таблица, а не List. Возможно это не правильно.
      final newQ = Query<Field>(managedContext)
        ..returningProperties((x) => [x.name]);
      final subNewQ =  newQ.join(set: (x) => x.orgField)
        ..where((x) => x.orgId?.id).equalTo(idOrg)
        ..returningProperties((x) => [x.orgId]);
        
      final listAllFields = await newQ.fetch();

      listAllFields.removeWhere((element) => element.orgField!.isEmpty);

      if(listAllFields.isEmpty) { return MyAppResponse.ok(message: "Пока тут пусто."); }

      return Response.ok(listAllFields);

    }catch(error) {
      return MyAppResponse.serverError(error, message: "Ошибка получения всех полей!");
    }
  }

  // 3. Метод для заполнения уникальных данных
  @Operation.post("orgId", "fieldId")
  Future<Response> insertData(@Bind.header(HttpHeaders.authorizationHeader) String header,
                              @Bind.body() UserData userData, @Bind.path("orgId") int pathOrgId, 
                              @Bind.path("fieldId") int pathFieldId) async {
    try{
      final idClient = AppUtils.getIdFromHeader(header);
      final org = await managedContext.fetchObjectWithID<Organization>(pathOrgId);
      final field = await managedContext.fetchObjectWithID<Field>(pathFieldId);

      //Пока не рабатает field.name == null
      if (userData.value == null || userData.value?.isEmpty == true) {
        return MyAppResponse.badRequest(message: "Поле value не должно быть пустым!");
      }

      if (field == null) {
        return MyAppResponse.ok(message: "Такого поля не существует!");
      }

      if (org == null) {
        return MyAppResponse.ok(message: "Такой организации не существует!");
      }

      //Заполняем таблицу UserData
      final qInsertData = Query<UserData>(managedContext)
        ..values.userId?.id = idClient
        ..values.fieldId?.id = pathFieldId
        ..values.value = userData.value;
      final wqw = await qInsertData.insert();

      final udObject = await managedContext.fetchObjectWithID<UserData>(wqw.id);

      //Заполняем таблицу OrgToUSerData
      final qInsertMtoM = Query<OrgToUserData>(managedContext)
        ..values.userDataId?.id = udObject?.id
        ..values.orgId?.id = pathOrgId;
      await qInsertMtoM.insert();

      return MyAppResponse.ok(message: "Текущее поле заполнено. Данные введены верно!");
    }catch(error) {
      return MyAppResponse.serverError(error, message: "Ошибка заполнения поля!");
    }

  }

  // 4. Видимо отдельная кнопка Save - переделать
  @Operation.post()
  Future<Response> insertMtoMData(@Bind.query("orgId") int orgId, @Bind.query("userDataId") int userDataId) async {
    try{
      final qInsertData = Query<OrgToUserData>(managedContext)
        ..values.userDataId?.id = userDataId
        ..values.orgId?.id = orgId;
      await qInsertData.insert();

      return MyAppResponse.ok(message: "Текущее поле заполнено. Данные введены верно!");
    }catch(error) {
      return MyAppResponse.serverError(error, message: "Ошибка заполнения поля!");
    }

  }

  // Future<Response> joinTable(){
  //   try{

  //   }catch(error){}
  // }









}