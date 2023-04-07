import 'dart:async';
import 'package:conduit/conduit.dart';   

class Migration2 extends Migration { 
  @override
  Future upgrade() async {
   		database.createTable(SchemaTable("_Access", [SchemaColumn("id", ManagedPropertyType.bigInteger, isPrimaryKey: true, autoincrement: true, isIndexed: false, isNullable: false, isUnique: false),SchemaColumn("createdAt", ManagedPropertyType.datetime, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: false, isUnique: false)]));
		database.createTable(SchemaTable("_AccessToUserData", [SchemaColumn("id", ManagedPropertyType.bigInteger, isPrimaryKey: true, autoincrement: true, isIndexed: false, isNullable: false, isUnique: false)]));
		database.addColumn("_Access", SchemaColumn.relationship("orgId", ManagedPropertyType.bigInteger, relatedTableName: "_Organizations", relatedColumnName: "id", rule: DeleteRule.cascade, isNullable: false, isUnique: false));
		database.addColumn("_Access", SchemaColumn.relationship("userId", ManagedPropertyType.bigInteger, relatedTableName: "_Users", relatedColumnName: "id", rule: DeleteRule.cascade, isNullable: false, isUnique: false));
		database.addColumn("_AccessToUserData", SchemaColumn.relationship("accessId", ManagedPropertyType.bigInteger, relatedTableName: "_Access", relatedColumnName: "id", rule: DeleteRule.cascade, isNullable: false, isUnique: false));
		database.addColumn("_AccessToUserData", SchemaColumn.relationship("userDataId", ManagedPropertyType.bigInteger, relatedTableName: "_UserData", relatedColumnName: "id", rule: DeleteRule.cascade, isNullable: false, isUnique: false));
		database.addColumn("_Users", SchemaColumn("surname", ManagedPropertyType.string, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: true, isUnique: false));
		database.addColumn("_Users", SchemaColumn("name", ManagedPropertyType.string, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: true, isUnique: false));
		database.addColumn("_Users", SchemaColumn("otchestvo", ManagedPropertyType.string, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: true, isUnique: false));
		database.addColumn("_Users", SchemaColumn("gender", ManagedPropertyType.string, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: true, isUnique: false));
		database.addColumn("_Users", SchemaColumn("dob", ManagedPropertyType.datetime, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: true, isUnique: false));
		database.addColumn("_Users", SchemaColumn("phoneNumber", ManagedPropertyType.string, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: true, isUnique: false));
		database.addColumn("_Users", SchemaColumn("series", ManagedPropertyType.string, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: true, isUnique: false));
		database.addColumn("_Users", SchemaColumn("number", ManagedPropertyType.string, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: true, isUnique: false));
		database.addColumn("_Users", SchemaColumn("dateOfIssue", ManagedPropertyType.datetime, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: true, isUnique: false));
		database.addColumn("_Users", SchemaColumn("codePodrazdel", ManagedPropertyType.string, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: true, isUnique: false));
		database.addColumn("_Users", SchemaColumn("issuedBy", ManagedPropertyType.string, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: true, isUnique: false));
		database.addColumn("_Users", SchemaColumn("snils", ManagedPropertyType.string, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: true, isUnique: false));
		database.addColumn("_Users", SchemaColumn("inn", ManagedPropertyType.string, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: true, isUnique: false));
		database.addColumn("_Users", SchemaColumn("addressReg", ManagedPropertyType.string, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: true, isUnique: false));
		database.addColumn("_Users", SchemaColumn("cityReg", ManagedPropertyType.string, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: true, isUnique: false));
		database.addColumn("_Users", SchemaColumn("addressActual", ManagedPropertyType.string, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: true, isUnique: false));
		database.addColumn("_Users", SchemaColumn("cityActual", ManagedPropertyType.string, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: true, isUnique: false));
  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    