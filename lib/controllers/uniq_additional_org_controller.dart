

import 'dart:io';

import 'package:conduit/conduit.dart';
import 'package:dcs/models/fields.dart';
import 'package:dcs/utils/app_response.dart';
import 'package:dcs/utils/app_utils.dart';

class AppUniqAdditionalOrgController extends ResourceController {

  final ManagedContext managedContext;

  AppUniqAdditionalOrgController(this.managedContext);

  //Основные методы:
  // 1. Добавить новое поле в таблицу Fields ✔
  // 2. Отобразить добавленные поля (из табл Fields) ✔
  // 3. Добавить выбранное поле в таблицу OrgFields
  // 4. Удалить выбранное поле из таблицы OrgFields
  // 5. Изменить ранее добавленное поле в таблице Fields ✔
  // 6. Удалить поле из таблицы Fields ✔


  // 1. Метод для добавления нового поля в таблицу Fields
  @Operation.post()
  Future<Response> createField(@Bind.header(HttpHeaders.authorizationHeader) String header,
                               @Bind.body() Field field) async {

    //Пока не рабатает field.name == null
    if (field.name == null || field.name?.isEmpty == true) {
      return MyAppResponse.badRequest(message: "Поле name не должно быть пустым!");
    }

    try{
      final idOrg = AppUtils.getIdFromHeader(header);

      final qCreateField = Query<Field>(managedContext)
        ..values.createdOrgId?.id = idOrg
        ..values.name = field.name;
      await qCreateField.insert();

      return MyAppResponse.ok(message: "Успешное создание нового поля!");
    }catch(error) {
      return MyAppResponse.serverError(error, message: "Ошибка создания нового поля!");
    }

  }

  // 2. Метод для отображения всех полей
  @Operation.get()
  Future<Response> getAllFields(@Bind.header(HttpHeaders.authorizationHeader) String header) async {
    try{
      final idOrg = AppUtils.getIdFromHeader(header);

      final qGetAllFields = Query<Field>(managedContext)
        ..where((x) => x.createdOrgId?.id).equalTo(idOrg);

      final List<Field> listAllFields = await qGetAllFields.fetch();

      if(listAllFields.isEmpty) { return MyAppResponse.ok(message: "B случае необходимости добавьте новое поле. Пока тут пусто."); }

      return Response.ok(listAllFields);

    }catch(error) {
      return MyAppResponse.serverError(error, message: "Ошибка получения всех полей!");
    }
  }

  // 5. Изменить, ранее добавленное, поле в таблице Fields
  @Operation.post("id")
  Future<Response> updateFieldByID(@Bind.header(HttpHeaders.authorizationHeader) String header, 
                                   @Bind.path("id") int idField, @Bind.body() Field fieldT) async {
    
    //Пока не рабатает fieldT.name == null
    if (fieldT.name == null || fieldT.name?.isEmpty == true) {
      return MyAppResponse.badRequest(message: "Поле name не должно быть пустым!");
    }

    try{
      //Получаем id организации
      final idOrg = AppUtils.getIdFromHeader(header);

      final fff = await managedContext.fetchObjectWithID<Field>(idField);

      if(fff == null) { 
        return MyAppResponse.ok(message: "Поле не найдено!");
      }

      if(fff.createdOrgId?.id != idOrg) {
        return MyAppResponse.ok(message: "Вы не можете изменять поля других Организаций!");
      }
      
      final qEditData = Query<Field>(managedContext)
        ..where((x) => x.id).equalTo(idField)
        ..values.name = fieldT.name
        ..values.createdOrgId?.id = idOrg;
      await qEditData.updateOne();

      return MyAppResponse.ok(message: "Название поля успешно изменено!");

    }catch(error) {
      return MyAppResponse.serverError(error, message: "upps, Error");
    }

  }

  // 5. Удалить ранее добавленное поле в таблице Fields
  @Operation.delete("id")
  Future<Response> deleteFieldByID(@Bind.header(HttpHeaders.authorizationHeader) String header, 
                                   @Bind.path("id") int idField) async {
    try{
      //Получаем id организации
      final idOrg = AppUtils.getIdFromHeader(header);

      final fff = await managedContext.fetchObjectWithID<Field>(idField);

      if(fff == null) { 
        return MyAppResponse.ok(message: "Поле не найдено!");
      }

      if(fff.createdOrgId?.id != idOrg) {
        return MyAppResponse.ok(message: "Вы не можете удалять поля других Организаций!");
      }
      
      final qDeleteData = Query<Field>(managedContext)
        ..where((x) => x.id).equalTo(idField);
      await qDeleteData.delete();

      return MyAppResponse.ok(message: "Поле успешно удалено!");

    }catch(error) {
      return MyAppResponse.serverError(error, message: "upps, Error");
    }

  }
 



  

}