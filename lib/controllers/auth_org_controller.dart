

import 'package:conduit/conduit.dart';
import 'package:dcs/models/organization.dart';
import 'package:dcs/models/response_model.dart';
import 'package:dcs/utils/app_env.dart';
import 'package:dcs/utils/app_response.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';

import 'package:dcs/models/user_data.dart';
import 'package:dcs/models/org_to_user_data.dart';
import 'package:dcs/models/org_fields.dart';
import 'package:dcs/models/fields.dart';
import 'package:dcs/models/user.dart';

class AppAuthOrgController extends ResourceController {

  final ManagedContext managedContext;

  AppAuthOrgController(this.managedContext);

  //Вход - авторизация
  @Operation.post()
  Future<Response> signIn(@Bind.body() Organization org) async {

    if (org.password == null || org.email == null) {
      return Response.badRequest(body: AppResponseModel(message: "Поля password и email должны быть заполнены!"));
    }

    try{
      final qFindOrg = Query<Organization>(managedContext)
        ..where((table) => table.email).equalTo(org.email)
        ..returningProperties((table) => [table.id, table.salt, table.hashPassword]);

      //Получить организацию из одной таблицы
      final findOrg = await qFindOrg.fetchOne();

      if (findOrg == null){
        throw QueryException.input("Такой организации не существует!", []);
      }

      final requestHashPassword = generatePasswordHash(org.password ?? "", findOrg.salt ?? "");
      if(requestHashPassword == findOrg.hashPassword){

        await _updateTokens(findOrg.id ?? -1, managedContext);
        final newOrg = await managedContext.fetchObjectWithID<Organization>(findOrg.id);
        return MyAppResponse.ok(body: newOrg?.backing.contents, message: "Вы успешно вошли в систему!");

      }else {
        throw QueryException.input("Неверный пароль!", []);
      }

    } catch(error) {
      return MyAppResponse.serverError(error, message: "Ошибка авторизации!");
    }

  }

  //Регистрация
  @Operation.put()
  Future<Response> signUp(@Bind.body() Organization org) async {
    if (org.name == null || org.fullName == null || org.email == null || org.password == null) {
      return Response.badRequest(body: AppResponseModel(message:
      "Поля name, fullName, email и password должны быть заполнены!"));
    }

    //Дополнительная рандомная строка, с помощью которой будет хэшироваться пароль
    final salt = generateRandomSalt();
    final hashPassword = generatePasswordHash(org.password ?? "", salt);

    try{
      late final int id; //Отложенная инициализация
      await managedContext.transaction((transaction) async {

        //Запрос, который добавляет пользователя в БД
        final qCreateOrg = Query<Organization>(transaction)
          ..values.name = org.name
          ..values.fullName = org.fullName
          ..values.email = org.email
          ..values.salt = salt
          ..values.hashPassword = hashPassword;
        final createdOrg = await qCreateOrg.insert();
        id = createdOrg.asMap()["id"];

        //Метод, котрый по id присваивает/генерирует токены
        await _updateTokens(id, transaction);

      });

      final orgData = await managedContext.fetchObjectWithID<Organization>(id);
      return MyAppResponse.ok(body: orgData?.backing.contents, message: "Вы успешно зарегистрировались!");

    } catch(error) {
      return MyAppResponse.serverError(error, message: "Ошибка регистрации!");
    }

  }

  //Метод, который по id присваивает/генерирует токены
  Future<void> _updateTokens(int id, ManagedContext transaction) async {
    final Map<String,dynamic> tokens = _getTokens(id);
    
    //Запрос, котрый по id присваивает/генерирует токены
    final qUpdateTokens = Query<Organization>(transaction)
      ..where((org) => org.id).equalTo(id)
      ..values.accessToken = tokens["access"]
      ..values.refreshToken = tokens["refresh"];
    await qUpdateTokens.updateOne();
  }

  //Генерация токенов
  Map<String, dynamic> _getTokens(int id) {
    
    final key = AppEnv.secretKey;
    //продолжительность жизни access токена - 1 минута
    final accessClaimSet = JwtClaim(maxAge: Duration(minutes: AppEnv.time), otherClaims: {"id": id});
    final refreshClaimSet = JwtClaim(otherClaims: {"id": id});

    final tokens = <String, dynamic>{};
    tokens["access"] = issueJwtHS256(accessClaimSet, key);
    tokens["refresh"] = issueJwtHS256(refreshClaimSet, key);

    return tokens;
  }






}