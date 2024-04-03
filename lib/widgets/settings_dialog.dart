import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diplom/pages/login_page.dart';
import 'package:diplom/utils/auth.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:diplom/main.dart';
import '../pages/main_navigation_scaffold.dart';
import 'dart:html' as html;

class SettingsDialog extends StatefulWidget {
  @override
  _SettingsDialogState createState() => _SettingsDialogState();
}

const List<NavigationRailLabelType> navRailLabelTypeList = <NavigationRailLabelType>[NavigationRailLabelType.all, NavigationRailLabelType.selected, NavigationRailLabelType.none];

bool isEmailVerified = false;
bool _isVerifyLoading = false;

class _SettingsDialogState extends State<SettingsDialog> {
  bool isDarkTheme = true;

  @override
  Widget build(BuildContext context) {
    return Dialog(
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
                          value: value,
                          onChanged: (NavigationRailLabelType? newValue) {
                            if (newValue != null) {
                              labelTypeNotifier.value = newValue;
                              saveSettings();
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
                                        saveSettings();
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
                                        saveSettings();
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
                                        saveSettings();
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
                                        saveSettings();
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
                                        saveSettings();
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
                                        saveSettings();
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
                                        saveSettings();
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
                                        saveSettings();
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
                                        saveSettings();
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
                      saveSettings();
                    },
                  ),
                ),
              ),
              Card(
                child: ListTile(
                    leading: const Icon(Icons.translate),
                    title: Text('App_language'.tr()),
                    subtitle: const Text('Choose your language'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          child: const Text('Russian'),
                          onPressed: () {
                            context.setLocale(const Locale('ru', 'RU'));
                          },
                        ),
                        const SizedBox(width: 2,),
                        ElevatedButton(
                          child: const Text('English'),
                          onPressed: () {
                            context.setLocale(const Locale('en', 'US'));
                          },
                        ),
                      ],
                    )
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Account settings'),
                  subtitle: const Text('Manage your account settings'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        child: const Text('Delete Account'),
                        onPressed: () async {
                          deleteAccount();
                        },
                      ),
                      const SizedBox(width: 2,),
                      ElevatedButton(
                        child: const Text('Sign out'),
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          currentUser = null;
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => LoginPage(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 2,),
                      FilledButton(
                        onPressed: !currentUser!.emailVerified ? () async {
                          verifyEmail();
                        } : null,
                        child: const Text('Verify email')
                      ),
                    ],
                  )
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

  void verifyEmail() async {
    // Используйте Builder для получения правильного контекста
    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Verify Your Email'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('A verification link has been sent to your email account —'
                '\nPlease check your email and click on the link to verify your email address.'),
            Card(
              child: ListTile(
                leading: isEmailVerified ? const Icon( Icons.check, color: Colors.green,) : const Icon(Icons.close),
                title: Text('Verification Status: ${isEmailVerified ? 'done - Now refresh this page' : 'not done'}'),
              ),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Close'),
            onPressed: () {
              Navigator.of(dialogContext).pop(); // Закрывает диалоговое окно, используя dialogContext
            },
          ),
          if (!isEmailVerified) ...[
            _isVerifyLoading
                ? const CircularProgressIndicator()
                : FilledButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Update'),
                    onPressed: () async {
                      setState(() => _isVerifyLoading = true);
                      await Auth.refreshUser(currentUser!);
                      // Обновите информацию о пользователе, чтобы проверить, верифицирован ли email
                      await currentUser!.reload();
                      if (currentUser!.emailVerified) {
                        setState(() {
                          isEmailVerified = true;
                          _isVerifyLoading = false;
                        });
                      } else {
                        setState(() => _isVerifyLoading = false);
                      }
                    },
                  ),
          ] else ...[
            const Text('Your Email is verified'),
          ],
        ],
      ),
    );
  }


  void deleteAccount() async {
    // Показываем диалоговое окно для подтверждения удаления
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text('Are you sure you want to delete your account? This action cannot be undone.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red, // Make delete text red to indicate a destructive action
            ),
          ),
        ],
      ),
    );

    // Если пользователь подтвердил удаление
    if (confirmDelete == true) {
      try {
        // Удаляем документ пользователя из Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser?.uid)
            .delete();

        // Удаляем аккаунт пользователя
        await FirebaseAuth.instance.currentUser?.delete();

        // Переходим на страницу входа после удаления аккаунта
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => LoginPage(), // LoginPage должен быть вашим виджетом страницы входа
          ),
        );
      } catch (e) {
        print('Error deleting account: $e');
        // Здесь может быть дополнительная обработка ошибок, например, показ сообщения об ошибке
      }
    }
  }
}
