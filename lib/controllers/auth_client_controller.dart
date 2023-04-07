
import 'package:conduit/conduit.dart';
import 'package:dcs/models/response_model.dart';
import 'package:dcs/models/user.dart';
import 'package:dcs/utils/app_env.dart';
import 'package:dcs/utils/app_response.dart';
import 'package:dcs/utils/app_utils.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';
import 'package:dcs/models/access.dart';
import 'package:dcs/models/access_to_user_data.dart';

//Класс для авторизации
class AppAuthClientController extends ResourceController {
  final ManagedContext managedContext;

  AppAuthClientController(this.managedContext);

  //Вход - авторизация
  @Operation.post()
  Future<Response> signIn(@Bind.body() User user) async {

    if (user.password == null || user.username == null) {
      return Response.badRequest(body: AppResponseModel(message: "Поля password и username должны быть заполнены!"));
    }

    try{
      final qFindUser = Query<User>(managedContext)
        ..where((table) => table.username).equalTo(user.username)
        ..returningProperties((table) => [table.id, table.salt, table.hashPassword]);

      //Получить user'a из одной таблицы
      final findUser = await qFindUser.fetchOne();

      if (findUser == null){
        throw QueryException.input("Такого пользователя не существует!", []);
      }

      final requestHashPassword = generatePasswordHash(user.password ?? "", findUser.salt ?? "");
      if(requestHashPassword == findUser.hashPassword){

        await _updateTokens(findUser.id ?? -1, managedContext);
        final newUser = await managedContext.fetchObjectWithID<User>(findUser.id);
        return MyAppResponse.ok(body: newUser?.backing.contents, message: "Вы успешно вошли в систему!");

      }else {
        throw QueryException.input("Неверный пароль!", []);
      }

    } catch(error) {
      return MyAppResponse.serverError(error, message: "Ошибка авторизации!");
    }

  }

  //Регистрация
  @Operation.put()
  Future<Response> signUp(@Bind.body() User user) async {
    if (user.password == null || user.username == null || user.email == null) {
      return Response.badRequest(body: AppResponseModel(message: "Поля password, username и email должны быть заполнены!"));
    }

    //Дополнительная рандомная строка, с помощью которой будет хэшироваться пароль
    final salt = generateRandomSalt();
    final hashPassword = generatePasswordHash(user.password ?? "", salt);

    try{
      late final int id; //Отложенная инициализация
      await managedContext.transaction((transaction) async {

        //Запрос, который добавляет пользователя в БД
        final qCreateUser = Query<User>(transaction)
          ..values.username = user.username
          ..values.email = user.email
          ..values.salt = salt
          ..values.hashPassword = hashPassword;
        final createdUser = await qCreateUser.insert();
        id = createdUser.asMap()["id"];

        //Метод, котрый по id_user присваивает/генерирует токены
        await _updateTokens(id, transaction);

      });

      final userData = await managedContext.fetchObjectWithID<User>(id);
      return MyAppResponse.ok(body: userData?.backing.contents, message: "Вы успешно зарегистрировались!");

    } catch(error) {
      return MyAppResponse.serverError(error, message: "Ошибка регистрации!");
    }

    // connect to DB
    // create User
    // get/fetch User account

  }

  //Метод, который по id_user присваивает/генерирует токены
  Future<void> _updateTokens(int id, ManagedContext transaction) async {
    final Map<String,dynamic> tokens = _getTokens(id);
    
    //Запрос, котрый по id_user присваивает/генерирует токены
    final qUpdateTokens = Query<User>(transaction)
      ..where((user) => user.id).equalTo(id)
      ..values.accessToken = tokens["access"]
      ..values.refreshToken = tokens["refresh"];
    await qUpdateTokens.updateOne();
  }

  @Operation.post("refresh")
  Future<Response> refreshToken(@Bind.path("refresh") String refreshToken) async {

    try{

      final id = AppUtils.getIdFromToken(refreshToken);

      final user = await managedContext.fetchObjectWithID<User>(id);
      if (user?.refreshToken != refreshToken) {
        return Response.unauthorized(body: AppResponseModel(message: "Token is not valid!"));
      } 
      else {
        await _updateTokens(id, managedContext);
        final user = await managedContext.fetchObjectWithID<User>(id);
        return MyAppResponse.ok(body: user?.backing.contents, message: "Успешное обновление токенов!");
      }
    } catch(error) {
      return MyAppResponse.serverError(error, message: "Ошибка обновления токенов!");
    }

  }
  
  //Генерация токенов
  Map<String, dynamic> _getTokens(int id) {
    
    final key = AppEnv.secretKey;
    //продолжительность жизни access токена 1 минута
    final accessClaimSet = JwtClaim(maxAge: Duration(minutes: AppEnv.time), otherClaims: {"id": id});
    final refreshClaimSet = JwtClaim(otherClaims: {"id": id});

    final tokens = <String, dynamic>{};
    tokens["access"] = issueJwtHS256(accessClaimSet, key);
    tokens["refresh"] = issueJwtHS256(refreshClaimSet, key);

    return tokens;
  }


}