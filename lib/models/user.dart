
import 'package:conduit/conduit.dart';
import 'package:dcs/models/access.dart';
import 'package:dcs/models/user_data.dart';

//ManagedObject - для сопоставления таблиц в БД
class User extends ManagedObject<_Users> implements _Users {}

class _Users {
  @primaryKey
  int? id;

  @Column(unique: true, indexed: true)
  String? username;

  @Column(unique: true, indexed: true)
  String? email;

  //В БД не отображается
  @Serialize(input: true, output: false)
  String? password;

  //Фамилия
  @Column(nullable: true)
  @Validate.length(lessThanEqualTo: 20)
  String? surname;

  //Имя
  @Column(nullable: true)
  @Validate.length(lessThanEqualTo: 20)
  String? name;

  //Отчество
  @Column(nullable: true)
  @Validate.length(lessThanEqualTo: 20)
  String? otchestvo;

  //Пол
  @Column(nullable: true)
  @Validate.oneOf(["Муж", "Жен"])
  String? gender;

  //Дата рождения
  @Column(nullable: true)
  DateTime? dob;

  //Номер телефона
  @Column(nullable: true)
  @Validate.length(equalTo: 11)
  String? phoneNumber;

  //Серия паспорта
  @Column(nullable: true)
  @Validate.length(equalTo: 4)
  String? series;

  //Номер паспорта
  @Column(nullable: true)
  @Validate.length(equalTo: 6)
  String? number;

  //Дата выдачи паспорта
  @Column(nullable: true)
  DateTime? dateOfIssue;

  //Код подразделения в паспорте
  @Column(nullable: true)
  @Validate.length(equalTo: 7)
  String? codePodrazdel;

  //Кем выдан
  @Column(nullable: true)
  @Validate.length(lessThanEqualTo: 35)
  String? issuedBy;

  //СНИЛС
  @Column(nullable: true)
  @Validate.length(equalTo: 14)
  String? snils;

  //ИНН
  @Column(nullable: true)
  @Validate.length(equalTo: 12)
  String? inn;

  //Адрес регистрации
  @Column(nullable: true)
  @Validate.length(lessThanEqualTo: 35)
  String? addressReg;

  //Город регистрации
  @Column(nullable: true)
  @Validate.length(lessThanEqualTo: 25)
  String? cityReg;

  //Адрес фактический
  @Column(nullable: true)
  @Validate.length(lessThanEqualTo: 35)
  String? addressActual;

  //Город фактический
  @Column(nullable: true)
  @Validate.length(lessThanEqualTo: 25)
  String? cityActual;



  @Column(nullable: true)
  String? accessToken;

  @Column(nullable: true)
  String? refreshToken;

  //Salt - это рандомное значение для формирования хэш-пароля
  //Эти данные записываются в БД, но при запросе они не возвращаются
  //По умолчанию omitByDefault = false, т.е. fetch column value (дает возможность получить знаение столбца),
  //но мне это не нужно, поэтому omitByDefault = true
  @Column(omitByDefault: true)
  String? salt;

  @Column(omitByDefault: true)
  String? hashPassword;

  //Поле для связи с таблицей _UserData [OneToMany]
  ManagedSet<UserData>? userData;

  //Поле для связи с таблицей _Access [OneToMany]
  ManagedSet<Access>? access; 

}