import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:diplom/pages/login_page.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_html/html.dart' as html;


final ValueNotifier<Color> mainThemeColorNotifier = ValueNotifier<Color>(Colors.green);
final ValueNotifier<bool> isDarkThemeNotifier = ValueNotifier(true);
final ValueNotifier<NavigationRailLabelType> labelTypeNotifier = ValueNotifier(NavigationRailLabelType.all);


final ValueNotifier<String?> selectedProjectIdNotifier = ValueNotifier(null);
final scaffoldKey = GlobalKey<ScaffoldMessengerState>();
User? currentUser = FirebaseAuth.instance.currentUser;
final FirebaseFirestore fireStore = FirebaseFirestore.instance;
String currentApi = "";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  final browserLanguage = html.window.navigator.language;
  final fallbackLocale = Locale.fromSubtags(languageCode: browserLanguage.split('-').first, countryCode: browserLanguage.split('-').last.toUpperCase());

  SharedPreferences prefs = await SharedPreferences.getInstance();

  Locale? savedLocale;
  String? savedLanguageCode = prefs.getString('languageCode');
  String? savedCountryCode = prefs.getString('countryCode');
  if (savedLanguageCode != null) {
    savedLocale = Locale(savedLanguageCode, savedCountryCode ?? savedLanguageCode.toUpperCase());
  }

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en', 'US'), Locale('ru', 'RU')],
      path: 'assets/translations',
      fallbackLocale: fallbackLocale ,
      startLocale: savedLocale, // Установка сохраненной локали как начальной
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    loadSettings();
    BrowserContextMenu.disableContextMenu();
    return ValueListenableBuilder<Color>(
      valueListenable: mainThemeColorNotifier,
      builder: (context, currentColor, child) {
        return ValueListenableBuilder<bool>(
          valueListenable: isDarkThemeNotifier,
          builder: (context, isDarkTheme, child) {
            return MaterialApp(
              title: 'Flutter Authentication',
              debugShowCheckedModeBanner: false,
              scaffoldMessengerKey: scaffoldKey,
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
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


Future<void> saveLanguage(Locale locale) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('languageCode', locale.languageCode);
  if (locale.countryCode != null) {
    await prefs.setString('countryCode', locale.countryCode!);
  }
}

Future<void> loadSettings() async {
  final prefs = await SharedPreferences.getInstance();
  final themeColorValue = prefs.getInt('themeColor') ?? Colors.green.value;
  final isDarkThemeValue = prefs.getBool('isDarkTheme') ?? true;
  final labelTypeIndex = prefs.getInt('labelType') ?? NavigationRailLabelType.all.index;

  mainThemeColorNotifier.value = Color(themeColorValue);
  isDarkThemeNotifier.value = isDarkThemeValue;
  labelTypeNotifier.value = NavigationRailLabelType.values[labelTypeIndex];
}

Future<void> saveSettings() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('themeColor', mainThemeColorNotifier.value.value); // Сохраняем основной цвет темы
  await prefs.setBool('isDarkTheme', isDarkThemeNotifier.value); // Сохраняем, темная тема или нет
  await prefs.setInt('labelType', labelTypeNotifier.value.index); // Сохраняем тип метки
}