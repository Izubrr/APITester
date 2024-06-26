import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:diplom/utils/auth.dart';
import 'package:diplom/utils/validator.dart';
import 'package:diplom/pages/main_navigation_scaffold.dart';

import '../main.dart';

class Login_Widget extends StatefulWidget {
  const Login_Widget({super.key});

  @override
  _Login_WidgetState createState() => _Login_WidgetState();
}

class _Login_WidgetState extends State<Login_Widget> {
  final _formKey = GlobalKey<FormState>();

  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();

  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min, // Минимальный размер по высоте
        children: <Widget>[
          TextFormField(
            autofillHints: const [AutofillHints.email],
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
              hintText: 'hint_Email'.tr(), // Ваш текст подсказки
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
          const SizedBox(height: 8),
          TextFormField(
            autofillHints: const [AutofillHints.password],
            controller: _passwordTextController,
            obscureText: true,
            validator: (value) => Validator.validatePassword(
              password: value,
            ),
            style: const TextStyle(
              color: Colors.white, // Цвет текста
            ),
            decoration: InputDecoration(
              filled:
                  true, // Необходимо установить true для использования fillColor
              fillColor: Colors.transparent, // Прозрачный цвет фона
              hintText: 'hint_Password'.tr(), // Ваш текст подсказки
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

                      if (currentUser != null) {
                        print(currentUser!.uid);
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => MainNavigationScaffold(),
                          ),
                        );
                      }
                      setState(() {
                        _isProcessing = false;
                      });
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
                  child: Text('Login'.tr()),
                ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
