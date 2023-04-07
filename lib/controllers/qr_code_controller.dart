
import 'dart:io';

import 'package:conduit/conduit.dart';
import 'package:dcs/models/access.dart';
import 'package:dcs/models/access_to_user_data.dart';
import 'package:dcs/models/user.dart';
import 'package:dcs/models/user_data.dart';
import 'package:dcs/utils/app_response.dart';
import 'package:dcs/utils/app_utils.dart';
import 'package:qr/qr.dart';

class AppQrCodeController extends ResourceController {

  ManagedContext managedContext;

  AppQrCodeController(this.managedContext);

  /*
  @Operation.get()
  Future<Response> getIdFieldForQrForm(@Bind.header(HttpHeaders.authorizationHeader) String header) async {
    try {
      //Получаем id_user
      final idUser = AppUtils.getIdFromHeader(header);
      final idString = idUser.toString();

      final qr = QrCode(4, QrErrorCorrectLevel.L)
        ..addData(idString);
      final qrImage = QrImage(qr);

      final count = qr.moduleCount;
      final edge = [-1, count];
      const white = '\u{2588}\u{2588}}';
      const black = '   ';

      for (var row = -1; row <= count; row++) {
        for (var col = -1; col <= count; col++) {
          if (edge.contains(row) || edge.contains(col) || !qrImage.isDark(row, col)) {
            stdout.write(white);
          } else {
            stdout.write(black);
          }
        }
        stdout.writeln(); 
      }
      return MyAppResponse.ok(message: "Got Job!", body: qrImage);

    }catch (error){
      return MyAppResponse.serverError(error, message: "Ошибка!");
    }

  }
  */

  //Для qr кода
  /*
  @Operation.get()
  Future<Response> getID(@Bind.header(HttpHeaders.authorizationHeader) String header) async{

    try {
      final idUser = AppUtils.getIdFromHeader(header);

      final user = Query<User>(managedContext)
        ..where((x) => x.id).equalTo(idUser)
        ..returningProperties((x) => [x.id, x.username]);

      final jniho = await user.fetchOne();

      return MyAppResponse.ok(body: jniho?.backing.contents);

    }catch(error){
      return MyAppResponse.serverError(error, message: "Ошибка!");
    }

  }
  */

  //Все вместе - для integration controller
  @Operation.get("userId")
  Future<Response> findUserByID(@Bind.header(HttpHeaders.authorizationHeader) String header, @Bind.path("userId") int userId,
                                @Bind.query("access") String tf ) async{
    try {
      final orgId = AppUtils.getIdFromHeader(header);
      final user = await managedContext.fetchObjectWithID<User>(userId);
      //final org = await managedContext.fetchObjectWithID<OrgToUserData>(orgId);
      
      if (user == null) {
        return MyAppResponse.ok(message: "Такого пользователя не существует.");
      }

      if (tf == "true") {

        //Заполняем таблицу Access
        final accessQ = Query<Access>(managedContext)
          ..values.orgId?.id = orgId
          ..values.userId?.id = userId
          ..values.createdAt = DateTime.now();
        final resAccessQ = await accessQ.insert();

        final accessObject = await managedContext.fetchObjectWithID<Access>(resAccessQ.id);

        //Формируем Join таблицу
        final query1 = Query<UserData>(managedContext)
          ..where((x) => x.userId?.id).equalTo(userId)
          ..returningProperties((x) => [x.value, x.userId]);
        final subquery1 = query1.join(set: (x) => x.orgToUserData)
          ..where((x) => x.orgId?.id).equalTo(orgId)
          ..returningProperties((x) => [x.orgId]);
      
        final res = await query1.fetch();

        res.removeWhere((element) => element.orgToUserData!.isEmpty);

        for(int i = 0; i < res.length; i++) {
          //Заполняем таблицу AccessToUserData
          final accessToUserDataQ = Query<AccessToUserData>(managedContext)
            ..values.accessId?.id = accessObject?.id
            ..values.userDataId?.id = res[i].id;
          await accessToUserDataQ.insert();
        }

        return Response.ok(res);       

      }
      else {
        return MyAppResponse.ok(message: "Пользователь запретил передачу данных.");
      }

    }catch(error){
      return MyAppResponse.serverError(error, message: "Ошибка!");
    }

  }
  

}