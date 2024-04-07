import 'package:easy_localization/easy_localization.dart';

class Validator {
  static String? validateName({required String? name}) {
    if (name == null) {
      return null;
    }

    if (name.isEmpty) {
      return 'Name cant be empty'.tr();
    }

    return null;
  }

  static String? validateEmail({required String? email}) {
    if (email == null) {
      return null;
    }

    RegExp emailRegExp = RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");

    if (email.isEmpty) {
      return 'Email cant be empty'.tr();
    } else if (!emailRegExp.hasMatch(email)) {
      return 'Enter a correct email'.tr();
    }

    return null;
  }

  static String? validatePassword({required String? password}) {
    if (password == null) {
      return null;
    }

    if (password.isEmpty) {
      return 'Password cant be empty'.tr();
    } else if (password.length < 6) {
      return 'Enter a password with length at least 6'.tr();
    }

    return null;
  }

  static String? validatePassword2({required String? password, required String? password2}) {
    if (password == null) {
      return null;
    }

    if (password.isEmpty) {
      return 'Password cant be empty'.tr();
    } else if (password.length < 6) {
      return 'Enter a password with length at least 6'.tr();
    } else if (password != password2) {
      return 'Password mismatch. Try again'.tr();
    }
    return null;
  }
}