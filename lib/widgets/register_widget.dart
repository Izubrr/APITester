import 'package:diplom/main.dart';
import 'package:diplom/pages/main_navigation_scaffold.dart';
import 'package:diplom/utils/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:diplom/utils/validator.dart';
import 'package:flutter/services.dart';

class Register_Widget extends StatefulWidget {
  const Register_Widget({super.key, required this.color});
  final Color color;

  @override
  _Register_WidgetState createState() => _Register_WidgetState();
}

class _Register_WidgetState extends State<Register_Widget> {
  final _registerFormKey = GlobalKey<FormState>();

  final _nameTextController = TextEditingController();
  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();
  final _passwordConfirmTextController = TextEditingController();

  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _registerFormKey,
      child: Column(
        mainAxisSize: MainAxisSize.min, // Минимальный размер по высоте
        children: <Widget>[
          TextFormField(
            controller: _nameTextController,
            validator: (value) => Validator.validateName(
              name: value,
            ),
            style: const TextStyle(
              color: Colors.white, // Цвет текста
            ),
            decoration: InputDecoration(
              filled:
                  true, // Необходимо установить true для использования fillColor
              fillColor: Colors.transparent, // Прозрачный цвет фона
              hintText: 'Username', // Ваш текст подсказки
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
          const SizedBox(height: 8),
          TextFormField(
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
              hintText: 'Password', // Ваш текст подсказки
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
            controller: _passwordConfirmTextController,
            obscureText: true,
            validator: (value) => Validator.validatePassword2(
                password: value, password2: _passwordTextController.text),
            style: const TextStyle(
              color: Colors.white, // Цвет текста
            ),
            decoration: InputDecoration(
              filled:
                  true, // Необходимо установить true для использования fillColor
              fillColor: Colors.transparent, // Прозрачный цвет фона
              hintText: 'Repeat Password', // Ваш текст подсказки
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
          if (_isProcessing)
            const CircularProgressIndicator()
          else
            ElevatedButton(
              onPressed: () async {
                if (_registerFormKey.currentState!.validate()) {
                  setState(() {
                    _isProcessing = true;
                  });

                  if (_registerFormKey.currentState!.validate()) {
                    currentUser = await Auth.registerUsingEmailPassword(
                      name: _nameTextController.text,
                      email: _emailTextController.text,
                      password: _passwordTextController.text,
                    );

                    setState(() {
                      _isProcessing = false;
                    });

                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => MainNavigationScaffold(),
                      ),
                    );
                    print('REGISTERED');
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                minimumSize:
                    const Size(double.infinity, 36), // Ширина во весь контейнер
              ),
              child: const Text('Sign up'),
            ),
        ],
      ),
    );
  }
}
