
import 'dart:io';

import 'package:conduit/conduit.dart';
import 'package:dcs/models/user.dart';
import 'package:dcs/utils/app_const.dart';
import 'package:dcs/utils/app_response.dart';
import 'package:dcs/utils/app_utils.dart';


//Класс для Личного Кабинета клиента
class AppProfileClientController extends ResourceController{

  final ManagedContext managedContext;

  AppProfileClientController(this.managedContext);

  
  //Метод для отображения ЛК с данными (без отбражения токенов)
  @Operation.get()
  Future<Response> getProfile(@Bind.header(HttpHeaders.authorizationHeader) String header) async {
  //В header передем token - а в нем хранится id_user
    try{

      final idUser = AppUtils.getIdFromHeader(header);
      final user = await managedContext.fetchObjectWithID<User>(idUser);
      //Удаляем токен с формы ЛК
      user?.removePropertiesFromBackingMap([
        AppConst.accessToken,
        AppConst.refreshToken
      ]);
      
      return MyAppResponse.ok(message: "Успешное получение профиля!", body: user?.backing.contents);

    }catch (error) {
      return MyAppResponse.serverError(error, message: "Ошибка получения профиля!");
    }
  }

  //Метод для изменения данных в ЛК
  @Operation.post()
  Future<Response> updateProfile(@Bind.header(HttpHeaders.authorizationHeader) String header, 
                                 @Bind.body() User user) async {

    try{
      //Получаем id_user
      final idUser = AppUtils.getIdFromHeader(header);
      //Находим пользователя по этому id_user и получаем его данные
      final fUser = await managedContext.fetchObjectWithID<User>(idUser);
      //Сам запрос для изменения данных
      final qUpdateUser = Query<User>(managedContext)
        ..where((x) => x.id).equalTo(idUser)
        ..values.username = user.username ?? fUser?.username
        ..values.email = user.email ?? fUser?.email
        ..values.surname = user.surname ?? fUser?.surname
        ..values.name = user.name ?? fUser?.name
        ..values.otchestvo = user.otchestvo ?? fUser?.otchestvo
        ..values.gender = user.gender ?? fUser?.gender
        ..values.dob = user.dob ?? fUser?.dob
        ..values.phoneNumber = user.phoneNumber ?? fUser?.phoneNumber
        ..values.series = user.series ?? fUser?.series
        ..values.number = user.number ?? fUser?.number
        ..values.dateOfIssue = user.dateOfIssue ?? fUser?.dateOfIssue
        ..values.codePodrazdel = user.codePodrazdel ?? fUser?.codePodrazdel
        ..values.issuedBy = user.issuedBy ?? fUser?.issuedBy
        ..values.snils = user.snils ?? fUser?.snils
        ..values.inn = user.inn ?? fUser?.inn
        ..values.addressReg = user.addressReg ?? fUser?.addressReg
        ..values.cityReg = user.cityReg ?? fUser?.cityReg
        ..values.addressActual = user.addressActual ?? fUser?.addressActual
        ..values.cityActual = user.cityActual ?? fUser?.cityActual;
      await qUpdateUser.updateOne();
      
      //Получаем уже обновленные\измененные данные из БД 
      final uUser = await qUpdateUser.updateOne();
      
      //Удаляем токены с формы ЛК
      uUser?.removePropertiesFromBackingMap([
        AppConst.accessToken,
        AppConst.refreshToken
      ]);

      return MyAppResponse.ok(message: "Данные были успешно изменены!", body: uUser?.backing.contents);

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

      final qFindUser = Query<User>(managedContext)
        ..where((table) => table.id).equalTo(id)
        ..returningProperties((table) => [table.salt, table.hashPassword]);
      
      //Получить одного user'a из таблицы
      final findUser = await qFindUser.fetchOne();

      final salt = findUser?.salt ?? "";
      
      final oldPasswordHash = generatePasswordHash(oldPassword, salt);

      if (oldPasswordHash != findUser?.hashPassword){
        return MyAppResponse.badRequest(message: "Неверный пароль. Попробуйте еще раз.");
      }

      //Генерируем хэш для нового пароля
      final newPasswordHash = generatePasswordHash(newPassword, salt);

      //Запрос для добавления в БД нового хэш-пароля
      final qUpdateUser = Query<User>(managedContext)
        ..where((x) => x.id).equalTo(id)
        ..values.hashPassword = newPasswordHash;
      await qUpdateUser.updateOne();

      return MyAppResponse.ok(message: "Вы успешно изменили пароль!");

    }catch (error) {
      return MyAppResponse.serverError(error, message: "Ошибка изменения пароля!");
    }
  }




}