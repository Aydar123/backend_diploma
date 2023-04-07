
import 'package:conduit/conduit.dart';
import 'package:dcs/controllers/auth_client_controller.dart';
import 'package:dcs/controllers/auth_org_controller.dart';
import 'package:dcs/controllers/client_selected_org.dart';
import 'package:dcs/controllers/profile_client_controller.dart';
import 'package:dcs/controllers/profile_org_controller.dart';
import 'package:dcs/controllers/qr_code_controller.dart';
import 'package:dcs/controllers/token_controller.dart';
import 'package:dcs/controllers/uniq_additional_org_controller.dart';
import 'package:dcs/controllers/uniq_all_org_fileds_controller.dart';
import 'package:dcs/controllers/uniq_fields_org_controller.dart';
import 'package:dcs/utils/app_env.dart';

class AppDCS extends ApplicationChannel{
  
  //Для работы с БД
  late final ManagedContext managedContext;

  //Метод для подключения к БД
  @override
  Future prepare() {
    final persistentStore = _initDatabase();
    
    managedContext = ManagedContext(ManagedDataModel.fromCurrentMirrorSystem(), persistentStore);    
    return super.prepare();
  }

  //Дополнительный метод для подключения к БД - вспомогательные данные или данные для подключения
  PostgreSQLPersistentStore _initDatabase(){
    
    return PostgreSQLPersistentStore(
      AppEnv.dbUsername, 
      AppEnv.dbPassword, 
      AppEnv.dbHost, 
      int.tryParse(AppEnv.dbPort), 
      AppEnv.dbDatabaseName);

  }

  //Если мы точно уверены, что эта переменная в процессе работы программы не получит значение null,
  //то в этом случае мы можем принимать оператор !
  @override
  Controller get entryPoint => Router()
  ..route("/clientAuth")
          .link(() => AppAuthClientController(managedContext))
  ..route("/clientProfile")
          .link(() => AppTokenController())!
          .link(() => AppProfileClientController(managedContext))
  ..route("/orgAuth").link(() => AppAuthOrgController(managedContext))
  ..route("/orgProfile")
          .link(() => AppTokenController())!
          .link(() => AppProfileOrgController(managedContext))
  ..route("/fieldSelection/[:id]")
          .link(() => AppTokenController())!
          .link(() => AppUniqFieldsOrgController(managedContext))
  ..route("/additionalFieldSelection/[:id]")
          .link(() => AppUniqAdditionalOrgController(managedContext))
  ..route("/allOrgField/[:id]")
          .link(() => AppUniqAllOrgFieldsController(managedContext))
  ..route("/clientOrgSelection/[:orgId/[:fieldId]]")
          .link(() => AppClientSelectedOrg(managedContext))
  ..route("/qrCode/[:userId]")
          .link(() => AppQrCodeController(managedContext))
  ;

}
