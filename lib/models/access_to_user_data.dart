
import 'package:conduit/conduit.dart';
import 'package:dcs/models/access.dart';
import 'package:dcs/models/user_data.dart';

class AccessToUserData extends ManagedObject<_AccessToUserData> implements _AccessToUserData {}

class _AccessToUserData {

  @primaryKey
  int? id;

  //Поле для связи с таблицей _Access [ManyToOne]
  @Relate(#accessToUserData, isRequired: true, onDelete: DeleteRule.cascade)
  Access? accessId;

  //Поле для связи с таблицей _UserData [ManyToOne]
  @Relate(#accessToUserData, isRequired: true, onDelete: DeleteRule.cascade)
  UserData? userDataId;

}