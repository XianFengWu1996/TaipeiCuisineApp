import 'package:email_validator/email_validator.dart';

class Validation{

  static String emailValidation(value){
    if (value.isEmpty) {
      return 'Email cannot be empty';
    }
    if (!EmailValidator.validate(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  static String passwordValidation(value){
    if(value.isEmpty){
      return 'Password cannot be empty';
    }
    if(value.length < 6){
      return 'Password must be 6 or more character';
    }
    return null;
  }
}