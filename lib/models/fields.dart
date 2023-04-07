

import 'package:conduit/conduit.dart';
import 'package:dcs/models/org_fields.dart';
import 'package:dcs/models/organization.dart';
import 'package:dcs/models/user_data.dart';

class Field extends ManagedObject<_Fields> implements _Fields {}

class _Fields {
  @primaryKey
  int? id;

  @Column(nullable: false)
  String? name;

  //Поле для связи с таблицей _Organizations [ManyToOne]
  //«isRequired» означает, что столбец не может быть нулевым
  //Т.е. в данном случае столбец может быть пустым
  @Relate(#field, isRequired: false, onDelete: DeleteRule.nullify)
  Organization? createdOrgId;

  //Поле для связи с таблицей _UserData [OneToMany]
  ManagedSet<UserData>? userData;

  //Поле для связи с таблицей _OrgFields [OneToMany]
  ManagedSet<OrgField>? orgField;

}