import 'package:diplom/pages/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:diplom/main.dart';
import 'main_navigation_scaffold.dart';

class SettingsDialog extends StatefulWidget {
  @override
  _SettingsDialogState createState() => _SettingsDialogState();
}

const List<NavigationRailLabelType> navRailLabelTypeList = <NavigationRailLabelType>[NavigationRailLabelType.all, NavigationRailLabelType.selected, NavigationRailLabelType.none];

class _SettingsDialogState extends State<SettingsDialog> {
  bool isDarkTheme = true;
  bool _isSigningOut = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(
                    12.0), // Отступ от заголовка до следующего элемента
                child: Row(
                  children: [
                    Icon(Icons.settings,
                        color: Theme.of(context)
                            .iconTheme
                            .color), // Иконка настроек
                    const SizedBox(width: 8), // Отступ между иконкой и текстом
                    Text(
                      'Settings',
                      style: Theme.of(context).textTheme.titleLarge, // Стиль заголовка согласно текущей теме
                    ),
                  ],
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.label_important),
                  title: const Text('Project label in side bar'),
                  subtitle: const Text(
                      'All - show labels always; selected - show label only of selected project'),
                  trailing: DropdownButtonHideUnderline(
                    child: ValueListenableBuilder<NavigationRailLabelType>(
                      valueListenable: labelTypeNotifier,
                      builder: (context, value, child) {
                        return DropdownButton<NavigationRailLabelType>(
                          focusColor: Colors.transparent,
                          padding: const EdgeInsets.all(5),
                          borderRadius: BorderRadius.circular(12.0),
                          value: value,
                          onChanged: (NavigationRailLabelType? newValue) {
                            if (newValue != null) {
                              labelTypeNotifier.value = newValue;
                            }
                          },
                          hint: const Text("Choose label type"),
                          items: const [
                            DropdownMenuItem(
                              value: NavigationRailLabelType.all,
                              child: Text('All'),
                            ),
                            DropdownMenuItem(
                              value: NavigationRailLabelType.selected,
                              child: Text('Selected'),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
              Card(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const ListTile(
                      leading: Icon(Icons.color_lens),
                      title: Text('Color of the app'),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 40),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                                child: Tooltip(
                                  message: 'M3 Baseline',
                                  child: Radio<Color>(
                                    value: const Color(0xFF6750A4),
                                    groupValue: mainThemeColorNotifier.value,
                                    fillColor: MaterialStateColor.resolveWith((states) => const Color(0xFF6750A4)),
                                    onChanged: (value) {
                                      setState(() {
                                        mainThemeColorNotifier.value = value as Color;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                                child: Tooltip(
                                  message: 'Indigo',
                                  child: Radio<Color>(
                                    value: Colors.indigo,
                                    groupValue: mainThemeColorNotifier.value,
                                    fillColor: MaterialStateColor.resolveWith((states) => Colors.indigo),
                                    onChanged: (value) {
                                      setState(() {
                                        mainThemeColorNotifier.value = value as Color;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                                child: Tooltip(
                                  message: 'Blue',
                                  child: Radio<Color>(
                                    value: Colors.blue,
                                    groupValue: mainThemeColorNotifier.value,
                                    fillColor: MaterialStateColor.resolveWith((states) => Colors.blue),
                                    onChanged: (value) {
                                      setState(() {
                                        mainThemeColorNotifier.value = value as Color;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                                child: Tooltip(
                                  message: 'Teal',
                                  child: Radio<Color>(
                                    value: Colors.teal,
                                    groupValue: mainThemeColorNotifier.value,
                                    fillColor: MaterialStateColor.resolveWith((states) => Colors.teal),
                                    onChanged: (value) {
                                      setState(() {
                                        mainThemeColorNotifier.value = value as Color;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                                child: Tooltip(
                                  message: 'Green',
                                  child: Radio<Color>(
                                    value: Colors.green,
                                    groupValue: mainThemeColorNotifier.value,
                                    fillColor: MaterialStateColor.resolveWith((states) => Colors.green),
                                    onChanged: (value) {
                                      setState(() {
                                        mainThemeColorNotifier.value = value as Color;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                                child: Tooltip(
                                  message: 'Yellow',
                                  child: Radio<Color>(
                                    value: Colors.yellow,
                                    groupValue: mainThemeColorNotifier.value,
                                    fillColor: MaterialStateColor.resolveWith((states) => Colors.yellow),
                                    onChanged: (value) {
                                      setState(() {
                                        mainThemeColorNotifier.value = value as Color;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                                child: Tooltip(
                                  message: 'Orange',
                                  child: Radio<Color>(
                                    value: Colors.orange,
                                    groupValue: mainThemeColorNotifier.value,
                                    fillColor: MaterialStateColor.resolveWith((states) => Colors.orange),
                                    onChanged: (value) {
                                      setState(() {
                                        mainThemeColorNotifier.value = value as Color;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                                child: Tooltip(
                                  message: 'Deep Orange',
                                  child: Radio<Color>(
                                    value: Colors.deepOrange,
                                    groupValue: mainThemeColorNotifier.value,
                                    fillColor: MaterialStateColor.resolveWith((states) => Colors.deepOrange),
                                    onChanged: (value) {
                                      setState(() {
                                        mainThemeColorNotifier.value = value as Color;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                                child: Tooltip(
                                  message: 'Pink',
                                  child: Radio<Color>(
                                    value: Colors.pink,
                                    groupValue: mainThemeColorNotifier.value,
                                    fillColor: MaterialStateColor.resolveWith((states) => Colors.pink),
                                    onChanged: (value) {
                                      setState(() {
                                        mainThemeColorNotifier.value = value as Color;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.sunny),
                  title: const Text('App Theme'),
                  subtitle: const Text(
                      'Left - light theme; Right - dark theme'),
                  trailing: Switch(
                    value: isDarkThemeNotifier.value,
                    onChanged: (bool value) {
                      isDarkThemeNotifier.value = value;
                    },
                  ),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.sunny),
                  title: const Text('Account settings'),
                  subtitle: const Text(
                      'Manage your account settings'),
                  trailing: _isSigningOut
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        _isSigningOut = true;
                      });
                      await FirebaseAuth.instance.signOut();
                      setState(() {
                        _isSigningOut = false;
                      });
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => LoginPage(),
                        ),
                      );
                    },
                    child: Text('Sign out'),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Close"),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
