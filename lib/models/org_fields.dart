

import 'package:conduit/conduit.dart';
import 'package:dcs/models/fields.dart';
import 'package:dcs/models/organization.dart';

class OrgField extends ManagedObject<_OrgFields> implements _OrgFields {}

class _OrgFields {
  @primaryKey
  int? id;

  //Поле для связи с таблицей _Organizations [ManyToOne]
  @Relate(#orgField, isRequired: true, onDelete: DeleteRule.cascade)
  Organization? orgId;

  //Поле для связи с таблицей _Fields [ManyToOne]
  @Relate(#orgField, isRequired: true, onDelete: DeleteRule.cascade)
  Field? fieldId;

  //Bool? required;

}