
import 'dart:io';

import 'package:conduit/conduit.dart';
import 'package:dcs/models/fields.dart';
import 'package:dcs/models/org_fields.dart';
import 'package:dcs/utils/app_response.dart';
import 'package:dcs/utils/app_utils.dart';

class AppUniqFieldsOrgController extends ResourceController {

  final ManagedContext managedContext;

  AppUniqFieldsOrgController(this.managedContext);

  //Основные методы:
  // 1. Отобразить список полей из таблицы Fields
  // 2. Добавить поле в таблицу OrgFields
  // 3. Удалить, выбранное ранее, поле из таблицы OrgFields

  //Метод для отображения всех полей, у которых createdOrgId == null
  @Operation.get()
  Future<Response> getAllNullFields(@Bind.header(HttpHeaders.authorizationHeader) String header) async {
    try{

      final qGetAllFields = Query<Field>(managedContext)
        ..where((x) => x.createdOrgId).isNull();

      final List<Field> listAllFields = await qGetAllFields.fetch();

      //final myselect = await managedContext.persistentStore.execute("select id, name, createdOrgId from _fields where createdOrgId=null createdOrgId = $idOrg");

      if(listAllFields.isEmpty) {return Response.notFound();}

      return Response.ok(listAllFields);

    }catch(error) {
      return MyAppResponse.serverError(error, message: "Ошибка получения всех полей!");
    }
  }

  //Метод, каторый по id_field должен добавлять поля в один список/таблицу [OrgFields]
  @Operation.post("id")
  Future<Response> addFieldById(@Bind.header(HttpHeaders.authorizationHeader) String header,
                               @Bind.path("id") int idField) async {
    try{
      final idOrg = AppUtils.getIdFromHeader(header);
      final field = await managedContext.fetchObjectWithID<Field>(idField);

      if (field == null) { 
        return MyAppResponse.ok(message: "Поле не найдено!");
      }

      final qInsertData = Query<OrgField>(managedContext)
        ..values.orgId?.id = idOrg
        ..values.fieldId?.id = idField;
      await qInsertData.insert();

      //if (field?.id == null) {return MyAppResponse.ok(message: "Поле не найдено!");}
      //Проверка на уже добавленные поля
      //Если у данной организации выбранное поле уже добавленно в БД, то return MyAppResponse.badRequest(message: "Такое поле
      //уже добавленно в БД!!!!")
      //Такая запись в системе уже сущетствует!

      return MyAppResponse.ok(message: "Выбранное поле успешно добавлено!");

    }catch(error){
      return MyAppResponse.serverError(error, message: "Ошибка добавления!");
    }

  }

  //Метод, каторый по id_field должен удалить поле из таблицы [OrgFields]
  @Operation.delete("id")
  Future<Response> deleteFieldById(@Bind.header(HttpHeaders.authorizationHeader) String header,
                               @Bind.path("id") int idField) async {
    try{
      final idOrg = AppUtils.getIdFromHeader(header);
      final orgField = await managedContext.fetchObjectWithID<OrgField>(idOrg);
      final fieldId = await managedContext.fetchObjectWithID<Field>(idField);

      if (fieldId == null || orgField?.orgId?.id != idOrg) {
        return MyAppResponse.ok(message: "Такого поля не сущетсвует! Поле не найдено! Чужое удалять нельзя.");
      }

      final qDeleteData = Query<OrgField>(managedContext)
        ..where((x) => x.orgId?.id).equalTo(idOrg)
        ..where((x) => x.fieldId?.id).equalTo(idField);
      await qDeleteData.delete();

      return MyAppResponse.ok(message: "Поле успешно удалено!");

    }catch(error){
      return MyAppResponse.serverError(error, message: "Поле не удалено.");
    }

  }



}