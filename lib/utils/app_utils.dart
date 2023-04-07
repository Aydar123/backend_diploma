
import 'package:conduit/conduit.dart';
import 'package:dcs/utils/app_env.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';

abstract class AppUtils{

  //Пустой конструктор
  const AppUtils._();
  
  //Метод получения id_user из токена
  static int getIdFromToken(String token) {
    try{
      final jwtClaim = verifyJwtHS256Signature(token, AppEnv.secretKey);
      return int.parse(jwtClaim["id"].toString());
    } catch(_){
      rethrow;
    }
  }

  //Метод получения id_user из Header
  static int getIdFromHeader(String header) {
    try{
      final token = AuthorizationBearerParser().parse(header);
      return getIdFromToken(token ?? "");
    } catch(_){
      rethrow;
    }
  }

}