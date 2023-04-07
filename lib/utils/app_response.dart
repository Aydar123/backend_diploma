
import 'package:conduit/conduit.dart';
import 'package:dcs/models/response_model.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';

//Класс обертка - класс для обработки ошибок
class MyAppResponse extends Response {

  MyAppResponse.serverError(dynamic error, {String? message}): super.serverError(body: _getResponseModel(error, message));

  static AppResponseModel _getResponseModel(error, String? message) {

    if(error is QueryException){
      return AppResponseModel(error: error.toString(), message: message ?? error.message);
    }

    if(error is JwtException){
      return AppResponseModel(error: error.toString(), message: message ?? error.message);
    }

    if(error is AuthorizationParserException){
      return AppResponseModel(error: error.toString(), message: message ?? "Сработала обработка исключения! (Tmp) Добавь access токен!");
    }

    return AppResponseModel(error: error.toString(), message: message ?? "Неизвестная ошибка!");

  }
  
  MyAppResponse.ok({dynamic body, String? message}): super.ok(AppResponseModel(data: body, message: message));

  MyAppResponse.badRequest({String? message}): super.badRequest(body: AppResponseModel( message: message ?? "Ошибка запроса!"));

  MyAppResponse.unauthorized(dynamic error, {String? message}): super.unauthorized(body: _getResponseModel(error, message));
  
  
  }