import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:diplom/utils/auth.dart';
import 'package:diplom/utils/validator.dart';

import '../main.dart';

class Forgot_Widget extends StatefulWidget {
  const Forgot_Widget({super.key});

  @override
  State<Forgot_Widget> createState() => _Forgot_WidgetState();
}

class _Forgot_WidgetState extends State<Forgot_Widget> {
  final _formKey = GlobalKey<FormState>();

  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();

  @override
  void dispose() {
    _emailTextController.dispose();
    super.dispose();
  }

  bool _isProcessing = false;

  Future passwordReset() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
          email: _emailTextController.text.trim());
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text('Password reset link sent! Check your email'),
            );
          });
    } on FirebaseAuthException catch (e) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(e.message.toString()),
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min, // Минимальный размер по высоте
        children: <Widget>[
          const Text(
              'Enter your email and we will send you a password reset link',
              style: TextStyle(color: Color(0xFFE1E1E8)),
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailTextController,
            validator: (value) => Validator.validateEmail(
              email: value,
            ),
            style: const TextStyle(
              color: Colors.white, // Цвет текста
            ),
            decoration: InputDecoration(
              filled:
                  true, // Необходимо установить true для использования fillColor
              fillColor: Colors.transparent, // Прозрачный цвет фона
              hintText: 'Email', // Ваш текст подсказки
              hintStyle: const TextStyle(
                color: Color(0xFFB9BABE), // Цвет текста подсказки
              ),
              enabledBorder: OutlineInputBorder(
                // Граница при доступном для ввода состоянии
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(
                  color: Color(0xFF2F2F35),
                  width: 1.3,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                // Граница при фокусе
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(
                  color: Colors.white,
                  width: 1.3,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _isProcessing
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        _isProcessing = true;
                      });
                      currentUser = await Auth.signInUsingEmailPassword(
                        email: _emailTextController.text,
                        password: _passwordTextController.text,
                      );
                      setState(() {
                        _isProcessing = false;
                      });
                      passwordReset();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    minimumSize: const Size(
                        double.infinity, 36), // Ширина во весь контейнер
                  ),
                  child: const Text('Reset Password'),
                ),
        ],
      ),
    );
  }
}
