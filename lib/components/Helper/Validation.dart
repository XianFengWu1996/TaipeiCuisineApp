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

  static String firstNameValidation(value){
    if(value.isEmpty){
      return 'First name cannot be empty';
    }
    return null;
  }

  static String lastNameValidation(value){
    if(value.isEmpty){
      return 'Last name cannot be empty';
    }
    return null;
  }

  static String phoneValidation(value){
    if(value.length < 10){
      return 'Enter a valid 10 digit phone number';
    }
    return null;
  }

  static String streetValidation(value){
    if(value.isEmpty){
      return 'Street cannot be empty';
    }
    return null;
  }

  static String cityValidation(value){
    if(value.isEmpty){
      return 'City cannot be empty';
    }
    return null;
  }

  static String zipValidation(value){
    if(value.isEmpty){
      return 'Zip code cannot be empty';
    }
    return null;
  }
}