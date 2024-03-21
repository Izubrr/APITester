import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diplom/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;

import 'package:yaml/yaml.dart';

class CreateProjectDialog extends StatefulWidget {
  @override
  _CreateProjectDialogState createState() => _CreateProjectDialogState();
}

enum IconLabel {
  chart('Chart', Icons.add_chart),
  api('API', Icons.api,),
  update('Update', Icons.browser_updated_sharp),
  bug('Bug', Icons.bug_report),
  bank('Bank', Icons.account_balance),
  newLabel('Label', Icons.new_label),
  person('Person', Icons.person),
  hourGlass('Hourglass', Icons.hourglass_bottom),
  widgets('Widgets', Icons.widgets);

  const IconLabel(this.label, this.icon);
  final String label;
  final IconData icon;
}

class _CreateProjectDialogState extends State<CreateProjectDialog> {
  TextEditingController _projectNameController = TextEditingController();

  final FirebaseFirestore fireStore = FirebaseFirestore.instance;
  late Map<String, dynamic> _yamlMap;
  String _fileName = '';

  String getFileNameWithoutExtension(String fileName) {
    var parts = fileName.split('.');
    parts.removeLast();
    return parts.join('.');
  }

  // void _getData() async {
  //   try {
  //     DocumentSnapshot documentSnapshot = await _firestore.collection('users').doc('${currentUser?.uid}/parsedYaml/$curFileName').get();
  //     if (documentSnapshot.exists) {
  //       String field = documentSnapshot.get(FieldPath(const ['info', 'title'])) as String;
  //       setState(() {
  //         _data = field;
  //       });
  //     } else {
  //       print("Document does not exist");
  //     }
  //   } catch (e) {
  //     print(e.toString());
  //   }a
  // }

  Map<String, dynamic> _processYamlData(dynamic yamlData) {
    // Рекурсивная функция для обработки Map
    Map<String, dynamic> processMap(Map<dynamic, dynamic> map) {
      final Map<String, dynamic> result = {};
      map.forEach((key, value) {
        if (key == 'responses' && value is Map) {
          // Обработка раздела responses, преобразуем ключи int в String
          final responses = Map<String, dynamic>.fromIterables(
              value.keys.map((k) => k.toString()),
              value.values
          );
          result[key.toString()] = responses;
        } else if (value is Map) {
          // Рекурсивная обработка для вложенных Map
          result[key.toString()] = processMap(value);
        } else {
          // Копирование остальных значений без изменений
          result[key.toString()] = value;
        }
      });
      return result;
    }

    if (yamlData is Map) {
      // Запуск рекурсивной обработки для корневого элемента
      return processMap(yamlData);
    } else {
      // Возвращаем пустой Map, если данные не соответствуют ожидаемому формату
      return {};
    }
  }

  Future<void> _pickFile(User user) async {
    final Completer<void> completer = Completer<void>();

    final uploadInput = html.FileUploadInputElement();
    uploadInput.accept = '.yaml,.yml';
    uploadInput.click();
    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      if (files != null && files.isNotEmpty) {
        final file = files.first;
        final reader = html.FileReader();
        reader.readAsText(file);
        reader.onLoadEnd.listen((e) {
          var _yamlData = Map<String, dynamic>.from(loadYaml(reader.result as String));
          _yamlMap = _processYamlData(_yamlData);
          _fileName = getFileNameWithoutExtension(file.name);
          completer.complete();
        });
      }
    });
    return completer.future; // Возвращаем future, чтобы можно было дождаться его завершения
  }


  @override
  void dispose() {
    _projectNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create or import Project'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              DropdownMenu<IconLabel>(
                width: 100,
                hintText: 'Icon',
                inputDecorationTheme: const InputDecorationTheme(
                  contentPadding: EdgeInsets.symmetric(vertical: 5.0),
                ),
                dropdownMenuEntries:
                IconLabel.values.map<DropdownMenuEntry<IconLabel>>(
                      (IconLabel icon) {
                    return DropdownMenuEntry<IconLabel>(
                      value: icon,
                      label: icon.label,
                      leadingIcon: Icon(icon.icon),
                    );
                  },
                ).toList(),
              ),
              Expanded(
                child: SizedBox(
                  width: 80,
                  child: TextField(
                    onChanged: (text) {
                      _fileName = _projectNameController.text;
                    },
                    controller: _projectNameController,
                    decoration: const InputDecoration(
                      hintText: 'Project Name',
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 100,
            child: ElevatedButton(
              style: ButtonStyle(
                minimumSize: MaterialStateProperty.all(const Size(100, double.infinity)),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              onPressed: () async {
                await _pickFile(currentUser!);
                print(_yamlMap);
                setState(() {
                  _projectNameController.text = _fileName;
                });
              },
              child: const Row(
                children: [
                  Icon(Icons.save_alt),
                  Text(' Import from file'),
                ],
              ),
            ),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(onPressed: () {
          Navigator.of(context).pop();
        }, child: const Text('Cancel')),
        FilledButton.icon(
            onPressed: () {
              if (_projectNameController.text.isEmpty) {
                // Показать уведомление, что имя проекта не может быть пустым
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Project name cannot be empty'),
                    duration: Duration(seconds: 2),
                  ),
                );
              } else {
                // Логика создания проекта
                fireStore
                    .collection('users')
                    .doc('${currentUser?.uid}/parsedYaml/$_fileName')
                    .set(_yamlMap);
                Navigator.of(context).pop();
              }
            },
            icon: const Icon(Icons.create_new_folder_outlined),
            label: const Text('Create a project')
        ),

      ],
    );
  }
}
