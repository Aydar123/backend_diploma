
import 'package:conduit/conduit.dart';
import 'package:dcs/models/access.dart';
import 'package:dcs/models/fields.dart';
import 'package:dcs/models/org_fields.dart';
import 'package:dcs/models/org_to_user_data.dart';

//ManagedObject - для сопоставления таблиц в БД
class Organization extends ManagedObject<_Organizations> implements _Organizations {}

class _Organizations {
  @primaryKey
  int? id;

  @Column(unique: true, indexed: true)
  String? fullName;

  @Column(unique: true, indexed: true)
  String? name;

  @Column(unique: true, indexed: true)
  String? email;

  //В БД не отображается
  @Serialize(input: true, output: false)
  String? password;

  @Column(nullable: true)
  String? accessToken;

  @Column(nullable: true)
  String? refreshToken;

  //Рандомное значение для формирования хэш-пароля
  //Эти данные записываются в БД, но при запросе они не возвращаются
  @Column(omitByDefault: true)
  String? salt;

  @Column(omitByDefault: true)
  String? hashPassword;

  //<=25
  @Column(nullable: true)
  @Validate.length(lessThanEqualTo: 25)
  String? city;

  //<=25
  @Column(nullable: true)
  @Validate.length(lessThanEqualTo: 25)
  String? address;

  //inn = 10
  @Column(nullable: true)
  @Validate.length(equalTo: 10)
  String? inn;

  //kpp = 9
  @Column(nullable: true)
  @Validate.length(equalTo: 9)
  String? kpp;

  //ogrn = 13
  @Column(nullable: true)
  @Validate.length(equalTo: 13)
  String? ogrn;


  //Поле для связи с таблицей _Fields [OneToMany]
  ManagedSet<Field>? field;

  //Поле для связи с таблицей _OrgFields [OneToMany]
  ManagedSet<OrgField>? orgField;

  //Поле для связи с таблицей _OrgToUserData [OneToMany]
  ManagedSet<OrgToUserData>? orgToUserData;

  //Поле для связи с таблицей _Access [OneToMany]
  ManagedSet<Access>? access;


}