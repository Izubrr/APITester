import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diplom/main.dart';
import 'package:diplom/pages/main_navigation_scaffold.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;

import 'package:yaml/yaml.dart';

class CreateProjectDialog extends StatefulWidget {
  @override
  _CreateProjectDialogState createState() => _CreateProjectDialogState();
}

enum IconLabel {
  chart('Chart', Icons.add_chart),
  api('API', Icons.api),
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
  final TextEditingController _projectNameController = TextEditingController();
  final TextEditingController _selectedIconController = TextEditingController();

  final FirebaseFirestore fireStore = FirebaseFirestore.instance;
  String _yamlString = '';
  var _docId;
  String _fileName = ' Import from file';
  int? _selectedIconCode = 0xe873;
  bool _fileSelected = false;

  Future<void> _pickFile() async {
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
          _yamlString = reader.result as String;
          setState(() {
            _fileName = ' ${file.name}';
            _fileSelected = true;
          });
          completer.complete();
        });
      }
    });
    return completer.future; // Возвращаем future, чтобы можно было дождаться его завершения
  }

  Future<void> loadAndSaveOpenApiSpec() async {
    // Загрузка YAML файла
    final doc = loadYaml(_yamlString);
    // Конвертация YamlMap в Map<String, dynamic>
    final Map<String, dynamic> docMap = Map<String, dynamic>.from(doc);
    // Сохранение данных в Firestore
    await saveApiToFirestore(docMap);
  }
  Map<String, dynamic> convertKeysToString(Map<dynamic, dynamic> map) {
    Map<String, dynamic> result = {};

    map.forEach((key, value) {
      // Convert the key to a string
      String stringKey = key.toString();

      if (value is Map) {
        // If the value is a Map, recursively call this function
        result[stringKey] = convertKeysToString(Map<dynamic, dynamic>.from(value));
      } else {
        // Otherwise, just assign the value to the new map
        result[stringKey] = value;
      }
    });

    return result;
  }

// Функция для сохранения данных API в Firestore
  Future<void> saveApiToFirestore(Map<String, dynamic> apiData) async {
    // Сохранение информации об API
    Map<String, dynamic> apiDataInfo = Map<String, dynamic>.from(apiData['info']);
    if(_projectNameController.text.isNotEmpty) apiDataInfo['title'] = _projectNameController.text;

    final apiRef = await fireStore.collection('users/${currentUser?.uid}/APIs').add({
      'openapi': apiData['openapi'],
      'info': apiDataInfo,
      'servers': apiData['servers'],
    });
    _docId = apiRef.id;

    // Сохранение путей и операций
    final paths = apiData['paths'] as Map<dynamic, dynamic>;
    paths.forEach((path, pathValue) async {
      final pathAsString = path.toString(); // Преобразование ключа в строку
      final pathRef = await fireStore.collection('users/${currentUser?.uid}/APIs/$_docId/paths').add({
        'path': pathAsString,
      });

      Map<String, dynamic> operations = Map<String, dynamic>.from(pathValue);
      operations.forEach((operation, operationValue) async {
        final operationAsString = operation.toString(); // Преобразование ключа в строку
        Map<String, dynamic> convertedOperationValue = convertKeysToString(operationValue);

// Now use convertedOperationValue in your Firestore operation
        await fireStore.collection('users/${currentUser?.uid}/APIs/$_docId/paths/${pathRef.id}/operations').doc(operationAsString).set(convertedOperationValue);

      });
    });

    // Сохранение компонентов, если есть
    if (apiData.containsKey('components')) {
      final components = apiData['components'] as Map<dynamic, dynamic>;
      components.forEach((componentType, componentDetails) async {
        final componentTypeAsString = componentType.toString(); // Преобразование ключа в строку
        final componentRef = fireStore.collection('users/${currentUser?.uid}/APIs/$_docId/components').doc(componentTypeAsString);
        await componentRef.set(Map<String, dynamic>.from(componentDetails));
      });
    }
    final docRef = fireStore.collection('users/${currentUser?.uid}/APIs').doc(_docId);

    // Обновление или установка поля 'info'
    await docRef.set({ 'iconCode': _selectedIconCode ?? 0xe873 }, SetOptions(merge: true));

    navRailDestinations.value.add(
      ApiDestination(
        id: _docId,
        destination: NavigationRailDestination(
          icon: Icon(IconData(_selectedIconCode!, fontFamily: 'MaterialIcons')),
          label: Text(apiDataInfo['title']),
        ),
      ),
    );
    navRailDestinations.notifyListeners();
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
                hintText: 'Icon'.tr(),
                inputDecorationTheme: const InputDecorationTheme(
                  contentPadding: EdgeInsets.symmetric(vertical: 5.0),
                ),
                // Предполагается, что _selectedIconController - это контроллер для текущего выбранного значения
                controller: _selectedIconController,
                onSelected: (selected) {
                  setState(() {
                    _selectedIconCode = selected?.icon.codePoint; // Сохраняем код выбранной иконки
                  });
                },
                dropdownMenuEntries: IconLabel.values.map<DropdownMenuEntry<IconLabel>>(
                      (IconLabel icon) {
                    return DropdownMenuEntry<IconLabel>(
                      value: icon,
                      label: icon.label,
                      leadingIcon: Icon(icon.icon), // Использование IconData для создания виджета Icon
                    );
                  },
                ).toList(),
              ),

              Expanded(
                child: SizedBox(
                  width: 80,
                  child: TextField(
                    controller: _projectNameController,
                    decoration: const InputDecoration(
                      hintText: 'Project Name'.tr(),
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
                await _pickFile();
              },
              child: Row(
                children: [
                  const Icon(Icons.save_alt),
                  Text(_fileName),
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
            onPressed: () async {
              if(_fileSelected) {
                _fileSelected = true;
                Navigator.of(context).pop();
                await loadAndSaveOpenApiSpec();
              }
              else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a file')));
              }
            },
            icon: const Icon(Icons.create_new_folder_outlined),
            label: const Text('Create a project')
        ),
      ],
    );
  }
  @override
  void dispose() {
    _projectNameController.dispose();
    super.dispose();
  }
}
