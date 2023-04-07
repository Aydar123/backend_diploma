
import 'package:conduit/conduit.dart';
import 'package:dcs/models/organization.dart';
import 'package:dcs/models/user_data.dart';

class OrgToUserData extends ManagedObject<_OrgToUserData> implements _OrgToUserData {}

class _OrgToUserData {

  @primaryKey
  int? id;
  
  //Поле для связи с таблицей _Organizations [ManyToOne]
  @Relate(#orgToUserData, isRequired: true, onDelete: DeleteRule.cascade)
  Organization? orgId;

  //Поле для связи с таблицей _UserData [ManyToOne]
  @Relate(#orgToUserData, isRequired: true, onDelete: DeleteRule.cascade)
  UserData? userDataId;

}