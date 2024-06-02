import 'dart:async';

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
                      'Settings'.tr(),
                      style: Theme.of(context).textTheme.titleLarge, // Стиль заголовка согласно текущей теме
                    ),
                  ],
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.label_important),
                  title: Text('Project label in side bar'.tr()),
                  subtitle: Text(
                      'show_labels_settings'.tr()),
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
                          hint: Text("Choose label type".tr()),
                          items: [
                            DropdownMenuItem(
                              value: NavigationRailLabelType.all,
                              child: Text('All'.tr()),
                            ),
                            DropdownMenuItem(
                              value: NavigationRailLabelType.selected,
                              child: Text('Selected'.tr()),
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
                    ListTile(
                      leading: Icon(Icons.color_lens),
                      title: Text('Color of the app'.tr()),
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
                                  message: 'M3 Baseline'.tr(),
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
                                  message: 'Indigo'.tr(),
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
                                  message: 'Blue'.tr(),
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
                                  message: 'Teal'.tr(),
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
                                  message: 'Green'.tr(),
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
                                  message: 'Yellow'.tr(),
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
                                  message: 'Orange'.tr(),
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
                                  message: 'Deep Orange'.tr(),
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
                                  message: 'Pink'.tr(),
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
                  title: Text('App Theme'.tr()),
                  subtitle: Text(
                      'Left - light theme; Right - dark theme'.tr()),
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
                    subtitle: Text('Choose your language'.tr()),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          child: const Text('Russian'),
                          onPressed: () async {
                            await saveLanguage(const Locale('ru', 'RU')); // Сохранение выбранного языка
                            context.setLocale(const Locale('ru', 'RU')); // Применение выбранного языка
                          },
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          child: const Text('English'),
                          onPressed: () async {
                            await saveLanguage(const Locale('en', 'US')); // Сохранение выбранного языка
                            context.setLocale(const Locale('en', 'US')); // Применение выбранного языка
                          },
                        ),
                      ],
                    )
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text('Account settings'.tr()),
                  subtitle: Text('Manage your account settings'.tr()),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        child: Text('Delete Account'.tr()),
                        onPressed: () async {
                          deleteAccount();
                        },
                      ),
                      const SizedBox(width: 2,),
                      ElevatedButton(
                        child: Text('Sign out'.tr()),
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          currentUser = null;
                          selectedProjectIdNotifier.value = '-1';
                          navRailDestinations.value = [];
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
                        child: Text('Verify email'.tr())
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
                    child: Text("Close".tr()),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Timer? _resendTimer;
  int _resendTimeout = 0; // Начальное значение таймаута

  void verifyEmail() async {
    int localResendTimeout = _resendTimeout; // Локальная копия для использования в диалоге
    bool localIsVerifyLoading = _isVerifyLoading; // Локальная копия состояния загрузки

    _isVerifyLoading = true;
    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setDialogState) {
              void startResendTimer() {
                localResendTimeout = 60; // Задаем начальное время таймера
                _resendTimer?.cancel(); // Отменяем текущий таймер, если он активен

                _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
                  if (localResendTimeout <= 0) {
                    timer.cancel();
                  } else {
                    setDialogState(() {
                      localResendTimeout--;
                    });
                  }
                });
              }

              return AlertDialog(
              title: Text('Verify Your Email'.tr()),
              content: Text('Your email: '.tr() + currentUser!.email.toString() + '\n' + 'After verification reload this page'.tr()),
              actions: <Widget>[
                TextButton(
                  child: Text('Close'.tr()),
                  onPressed: () {
                    Navigator.of(dialogContext).pop(); // Закрывает диалоговое окно, используя dialogContext
                  },
                ),
                FilledButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: localResendTimeout > 0 ? Text('Send link'.tr() + ' ($localResendTimeout)') : Text('Send link'.tr()),
                  onPressed: !localIsVerifyLoading && localResendTimeout <= 0 && !currentUser!.emailVerified ?  () async {
                    setDialogState(() => localIsVerifyLoading = true);
                    // Обновите информацию о пользователе, чтобы проверить, верифицирован ли email
                    currentUser?.sendEmailVerification();
                    print('emailVerified' + currentUser!.emailVerified.toString());
                    setDialogState(() => localIsVerifyLoading = false);
                    startResendTimer(); // Запускаем таймер повторно
                  } : null,
                ),
              ],
             );
            }
          );
      },
    );
  }
  


  void deleteAccount() async {
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('Delete Account'.tr()),
        content: Text('delete_account_confirm'.tr()),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text('Delete'.tr()),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      // Удаляем все документы пользователя
      print('users/${currentUser?.uid}');
      //await fireStore.collection('users').doc(currentUser?.uid).delete();

      final documentReferenceToDelete = fireStore.collection('users').doc(currentUser?.uid);

      await fireStore.runTransaction((transaction) async {
        await transaction.delete(documentReferenceToDelete);
      });


      // Удаляем аккаунт пользователя из FirebaseAuth
      //await FirebaseAuth.instance.currentUser?.delete();

      // Переходим на страницу входа
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => LoginPage(),
        ),
      );

      // Сбрасываем состояние приложения
      setState(() {
        currentUser = null;
      });
      selectedProjectIdNotifier.value = '-1';
      navRailDestinations.value = [];
    }
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    super.dispose();
  }

}
