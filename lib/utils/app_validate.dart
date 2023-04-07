
import 'package:conduit/conduit.dart';

//Позже доделать - пока лень
//Библиотека для этого класса: https://pub.dev/packages/string_validator/install
//string_validator: ^1.0.0
class AppValidate extends Validate {

  AppValidate({bool onUpdate = true, bool onInsert = true}) :
    super(onUpdate: onUpdate, onInsert: onInsert);

  @override
  void validate(ValidationContext context, dynamic value) {  
    if (value.length != 11) {
      context.addError("must be 11 digits");      
    }

    
    // if (containsNonNumericValues(value)) {
    //   context.addError("must contain characters 0-9 only.");      
    // }
  }




}