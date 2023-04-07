
import 'package:conduit/conduit.dart';
import 'package:dcs/dcs.dart';
import 'package:dcs/utils/app_env.dart';

void main(List<String> arguments) async {

  //Создаем порт
  final int port = int.tryParse(AppEnv.port) ?? 0;
  //Создаем сервис
  final service = Application<AppDCS>()..options.port = port;

  //Создали временно 3 изолята (isolate), т.е. три процесса
  await service.start(numberOfInstances: 3, consoleLogging: true);

}
