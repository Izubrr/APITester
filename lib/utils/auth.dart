import 'package:diplom/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final ScaffoldMessengerState? scaffoldMessengerState = scaffoldKey.currentState;

String getStringAfterFirstSpace(String input) {
  // Находим индекс первого пробела в строке
  int spaceIndex = input.indexOf(' ');
  // Если пробел найден, возвращаем подстроку, начиная с символа после пробела
  if (spaceIndex != -1) {
    return input.substring(spaceIndex + 1);
  }
  // Если пробел не найден, возвращаем исходную строку
  return input;
}

class Auth {
  // For registering a new user
  static Future<User?> registerUsingEmailPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    FirebaseAuth auth = FirebaseAuth.instance;

    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      currentUser = userCredential.user;
      await currentUser!.updateDisplayName(name);
      await currentUser?.reload();
      currentUser = auth.currentUser;
    } on FirebaseAuthException catch (e) {
      scaffoldMessengerState?.showSnackBar(SnackBar(content: Text(getStringAfterFirstSpace(e.toString()))));
    }

    return currentUser;
  }

  // For signing in an user (have already registered)
  static Future<User?> signInUsingEmailPassword({
    required String email,
    required String password,
  }) async {
    FirebaseAuth auth = FirebaseAuth.instance;

    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      currentUser = userCredential.user;
    } on FirebaseAuthException catch (e) {
      scaffoldMessengerState?.showSnackBar(SnackBar(content: Text(getStringAfterFirstSpace(e.toString()))));
    }

    return currentUser;
  }

  static Future<User?> refreshUser(User user) async {
    FirebaseAuth auth = FirebaseAuth.instance;

    await user.reload();
    User? refreshedUser = auth.currentUser;

    return refreshedUser;
  }
}