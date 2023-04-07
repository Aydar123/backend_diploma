

import 'package:conduit/conduit.dart';
import 'package:dcs/models/access_to_user_data.dart';
import 'package:dcs/models/organization.dart';
import 'package:dcs/models/user.dart';

class Access extends ManagedObject<_Access> implements _Access {
  @override
  void willInsert(){
    final now = DateTime.now();
    createdAt =  now.toUtc();
  }
}

class _Access {

  @primaryKey
  int? id;

  //Поле для связи с таблицей _Organizations [ManyToOne]
  @Relate(#access, isRequired: true, onDelete: DeleteRule.cascade)
  Organization? orgId;

  //Поле для связи с таблицей _Users [ManyToOne]
  @Relate(#access, isRequired: true, onDelete: DeleteRule.cascade)
  User? userId;

  @Column(nullable: false)
  DateTime? createdAt;

  //Поле для связи с таблицей _AccessToUserData [OneToMany]
  ManagedSet<AccessToUserData>? accessToUserData;
  
}