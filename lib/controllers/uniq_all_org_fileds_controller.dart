

import 'dart:io';

import 'package:conduit/conduit.dart';
import 'package:dcs/models/fields.dart';
import 'package:dcs/models/org_fields.dart';
import 'package:dcs/utils/app_response.dart';
import 'package:dcs/utils/app_utils.dart';

class AppUniqAllOrgFieldsController extends ResourceController {

  ManagedContext managedContext;

  AppUniqAllOrgFieldsController(this.managedContext);

  // 2. Метод для отображения всех полей
  @Operation.get()
  Future<Response> getAllSelectedFields(@Bind.header(HttpHeaders.authorizationHeader) String header) async {
    try{
      final idOrg = AppUtils.getIdFromHeader(header);

      final qGetAllSelectedFields = Query<OrgField>(managedContext)
        ..where((x) => x.orgId?.id).equalTo(idOrg);
        // ..returningProperties((x) => [x.orgId?, x.fieldId?.name]);

      final List<OrgField> listAllFields = await qGetAllSelectedFields.fetch();

      if(listAllFields.isEmpty) { return MyAppResponse.ok(message: "B случае необходимости добавьте новое поле. Пока тут пусто."); }

      return Response.ok(listAllFields);

    }catch(error) {
      return MyAppResponse.serverError(error, message: "Ошибка получения уникальных полей!");
    }
  }

  // 3. Добавить выбранное поле в таблицу OrgFields
  @Operation.post("id")
  Future<Response> addFieldById(@Bind.header(HttpHeaders.authorizationHeader) String header,
                               @Bind.path("id") int idField) async {
    try{
      final idOrg = AppUtils.getIdFromHeader(header);
      //final organization = await managedContext.fetchObjectWithID<Organization>(idOrg);
      final field = await managedContext.fetchObjectWithID<Field>(idField);

      if (field == null) { 
        return MyAppResponse.ok(message: "Поле не найдено!");
      }

      final qInsertData = Query<OrgField>(managedContext)
        ..values.orgId?.id = idOrg
        ..values.fieldId?.id = idField;
      await qInsertData.insert();

      //Проверка на уже добавленные поля
      //Если у данной организации выбранное поле уже добавленно в БД, то return MyAppResponse.badRequest(message: "Такое поле
      //уже добавленно в БД!!!!")
      //Такая запись в системе уже сущетствует!

      return MyAppResponse.ok(message: "Success");

    }catch(error){
      return MyAppResponse.serverError(error, message: "upps, Error");
    }

  }

  // 4. Удалить выбранное поле из таблицы OrgFields
  @Operation.delete("id")
  Future<Response> deleteAdditionalFieldById(@Bind.header(HttpHeaders.authorizationHeader) String header,
                               @Bind.path("id") int idField) async {
    try{
      final idOrg = AppUtils.getIdFromHeader(header);
      final orgField = await managedContext.fetchObjectWithID<OrgField>(idOrg);
      final field = await managedContext.fetchObjectWithID<Field>(idField);

      if (field == null || orgField?.orgId?.id != idOrg) { 
        return MyAppResponse.ok(message: "Поле не найдено! Вообще-то лично у вас такого поля нет!");
      }

      final qDeleteData = Query<OrgField>(managedContext)
        ..where((x) => x.orgId?.id).equalTo(idOrg)
        ..where((x) => x.fieldId?.id).equalTo(idField);
      await qDeleteData.delete();

      return MyAppResponse.ok(message: "Success");

    }catch(error){
      return MyAppResponse.serverError(error, message: "upps, Error");
    }

  }

}