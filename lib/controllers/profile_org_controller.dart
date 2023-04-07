

import 'dart:io';

import 'package:conduit/conduit.dart';
import 'package:dcs/models/organization.dart';
import 'package:dcs/utils/app_const.dart';
import 'package:dcs/utils/app_response.dart';
import 'package:dcs/utils/app_utils.dart';

class AppProfileOrgController extends ResourceController{

  final ManagedContext managedContext;

  AppProfileOrgController(this.managedContext);

  //Метод для отображения ЛК с данными (без отбражения токенов)
  @Operation.get()
  Future<Response> getProfile(@Bind.header(HttpHeaders.authorizationHeader) String header) async {
  //В header передем token - а в нем хранится id
    try{

      final idOrg = AppUtils.getIdFromHeader(header);
      //По сути это запрос на получение Организации по ID
      final org = await managedContext.fetchObjectWithID<Organization>(idOrg);
      //Удаляем токен с формы ЛК
      org?.removePropertiesFromBackingMap([
        AppConst.accessToken,
        AppConst.refreshToken
      ]);
      
      return MyAppResponse.ok(message: "Успешное получение профиля!", body: org?.backing.contents);

    }catch (error) {
      return MyAppResponse.serverError(error, message: "Ошибка получения профиля!");
    }
  }

  //Метод для изменения данных в ЛК
  @Operation.post()
  Future<Response> updateProfile(@Bind.header(HttpHeaders.authorizationHeader) String header, 
                                 @Bind.body() Organization org) async {

    try{
      //Получаем id
      final idOrg = AppUtils.getIdFromHeader(header);
      //Находим организацию по этому id и получаем её данные
      final fOrg = await managedContext.fetchObjectWithID<Organization>(idOrg);
      
      //Сам запрос для изменения данных
      final qUpdateOrg = Query<Organization>(managedContext)
        ..where((x) => x.id).equalTo(idOrg)
        ..values.name = org.name ?? fOrg?.name
        ..values.fullName = org.fullName ?? fOrg?.fullName
        ..values.email = org.email ?? fOrg?.email
        ..values.city = org.city ?? fOrg?.city
        ..values.address = org.address ?? fOrg?.address
        ..values.inn = org.inn ?? fOrg?.inn
        ..values.kpp = org.kpp ?? fOrg?.kpp
        ..values.ogrn = org.ogrn ?? fOrg?.ogrn;
      await qUpdateOrg.updateOne();
      
      //Получаем уже обновленные\измененные данные из БД 
      final uOrg = await qUpdateOrg.updateOne();
      
      //Удаляем токены с формы ЛК
      uOrg?.removePropertiesFromBackingMap([
        AppConst.accessToken,
        AppConst.refreshToken
      ]);

      return MyAppResponse.ok(message: "Данные были успешно изменены!", body: uOrg?.backing.contents);

    }catch (error) {
      return MyAppResponse.serverError(error, message: "Ошибка! Данные не изменены.");
    }
  }


  //Метод для изменения пароля
  @Operation.put()
  Future<Response> updatePassword(@Bind.header(HttpHeaders.authorizationHeader) String header,
                                  @Bind.query("oldPassword") String oldPassword,
                                  @Bind.query("newPassword") String newPassword) async {

    try{

      final id = AppUtils.getIdFromHeader(header);

      final qFindOrg = Query<Organization>(managedContext)
        ..where((table) => table.id).equalTo(id)
        ..returningProperties((table) => [table.salt, table.hashPassword]);
      
      //Получить одну организацию из таблицы
      final findOrg = await qFindOrg.fetchOne();

      final salt = findOrg?.salt ?? "";
      
      final oldPasswordHash = generatePasswordHash(oldPassword, salt);

      if (oldPasswordHash != findOrg?.hashPassword){
        return MyAppResponse.badRequest(message: "Неверный пароль. Попробуйте еще раз.");
      }

      //Генерируем хэш для нового пароля
      final newPasswordHash = generatePasswordHash(newPassword, salt);

      //Запрос для добавления в БД нового хэш-пароля
      final qUpdateOrg = Query<Organization>(managedContext)
        ..where((x) => x.id).equalTo(id)
        ..values.hashPassword = newPasswordHash;
      await qUpdateOrg.updateOne();

      return MyAppResponse.ok(message: "Вы успешно изменили пароль!");

    }catch (error) {
      return MyAppResponse.serverError(error, message: "Ошибка изменения пароля!");
    }
  }


}