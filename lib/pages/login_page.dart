import 'package:diplom/widgets/switch_text.dart';
import 'package:diplom/widgets/register_widget.dart';
import 'package:diplom/widgets/login_widget.dart';
import 'package:diplom/widgets/forgot_widget.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:diplom/firebase_options.dart';
import 'package:diplom/pages/profile_page.dart';
import 'main_navigation_scaffold.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

enum SignInState {
  logIn,
  signUp,
  resetPassword,
}

class _LoginPageState extends State<LoginPage> {
  late Future<FirebaseApp> FirebaseFuture;

  Future<FirebaseApp> _initializeFirebase() async {
    FirebaseApp firebaseApp = await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => MainNavigationScaffold(),
        ),
      );
    }

    return firebaseApp;
  }

  @override
  void initState() {
    super.initState();
    FirebaseFuture = _initializeFirebase();
  }

  SignInState _signInState = SignInState.logIn;

  Widget get signWidget {
    switch (_signInState) {
      case SignInState.logIn:
        return const Login_Widget();
      case SignInState.signUp:
        return const Register_Widget(color: Colors.blueAccent);
      case SignInState.resetPassword:
        return const Forgot_Widget();
      default:
        return const Login_Widget();
    }
  }

  String get signTitle {
    switch (_signInState) {
      case SignInState.logIn:
        return 'Log in MyApp';
      case SignInState.signUp:
        return 'Sign up MyApp';
      case SignInState.resetPassword:
        return 'Reset Password';
      default:
        return 'Log in MyApp';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder(
      future: FirebaseFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/images/mountains.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: Container(
                  padding: const EdgeInsets.all(16.0),
                  width: 300,
                  decoration: BoxDecoration(
                    color: const Color(0xFF131317),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_signInState == SignInState.resetPassword)
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  _signInState = SignInState.logIn;
                                });
                              },
                            ),
                            Text(
                              signTitle,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 24),
                            ),
                          ],
                        )
                      else
                        Column(
                          children: [
                            Text(
                              signTitle,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 24),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: SwitchText(
                                    color: Colors.blueAccent,
                                    onTap: () {
                                      setState(() {
                                        _signInState =
                                            _signInState == SignInState.logIn
                                                ? SignInState.signUp
                                                : SignInState.logIn;
                                      });
                                    },
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      const SizedBox(height: 16),
                      signWidget,
                      const SizedBox(height: 10),
                      if (_signInState != SignInState.resetPassword)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _signInState = SignInState.resetPassword;
                            });
                          },
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: Colors.blueAccent),
                          ),
                        )
                    ],
                  )),
            ),
          );
        }

        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    ));
  }
}
