import 'package:flutter/material.dart';
import 'package:diplom/pages/login_page.dart';

final ValueNotifier<Color> mainThemeColorNotifier = ValueNotifier<Color>(Colors.green);
final ValueNotifier<bool> isDarkThemeNotifier = ValueNotifier(true);

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Color>(
      valueListenable: mainThemeColorNotifier,
      builder: (context, currentColor, child) {
        return ValueListenableBuilder<bool>(
          valueListenable: isDarkThemeNotifier,
          builder: (context, isDarkTheme, child) {
            return MaterialApp(
              title: 'Flutter Authentication',
              debugShowCheckedModeBanner: false,
              home: LoginPage(),
              theme: ThemeData(
                useMaterial3: true,
                brightness: isDarkTheme ? Brightness.dark : Brightness.light,
                colorSchemeSeed: currentColor,
              ),
            );
          },
        );
      },
    );
  }
}