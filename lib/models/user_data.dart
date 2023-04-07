
import 'package:conduit/conduit.dart';
import 'package:dcs/models/access_to_user_data.dart';
import 'package:dcs/models/fields.dart';
import 'package:dcs/models/org_to_user_data.dart';
import 'package:dcs/models/user.dart';

class UserData extends ManagedObject<_UserData> implements _UserData {}

class _UserData {
  @primaryKey
  int? id;

  @Column(nullable: true)
  String? value;

  //Поле для связи с таблицей _Users [ManyToOne]
  @Relate(#userData, isRequired: true, onDelete: DeleteRule.cascade)
  User? userId;

  //Поле для связи с таблицей _Fields [ManyToOne]
  @Relate(#userData, isRequired: true, onDelete: DeleteRule.cascade)
  Field? fieldId;

  //Поле для связи с таблицей _OrgToUserData [OneToMany]
  ManagedSet<OrgToUserData>? orgToUserData;

  //Поле для связи с таблицей _AccessToUserData [OneToMany]
  ManagedSet<AccessToUserData>? accessToUserData;

}