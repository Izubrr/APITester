import 'package:diplom/utils/parse_yaml.dart';
import 'package:flutter/material.dart';
import 'package:diplom/pages/project_page.dart';
import 'dart:html' as html;

void pickFile() {
  // Создание input элемента
  html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
  uploadInput.accept = '.yaml,.yml'; // Разрешить только файлы YAML
  uploadInput.click();

  // Прослушивание изменений
  uploadInput.onChange.listen((e) {
    // Получение выбранного файла
    final files = uploadInput.files;
    if (files != null && files.isNotEmpty) {
      final file = files.first;

      // Чтение файла
      final reader = html.FileReader();
      reader.readAsText(file);
      reader.onLoadEnd.listen((e) {
        // Доступ к содержимому файла
        _handleYamlContents(reader.result as String);
      });
    }
  });
}

void _handleYamlContents(String fileContents) {
  ParseYaml parseYaml = ParseYaml(fileContents);

  print('Project Title: ${parseYaml.projectTitle}');
  print('End Points: ${parseYaml.endPointsList}');
}

class AddApiDialog extends StatefulWidget {
  @override
  _AddApiDialogState createState() => _AddApiDialogState();
}

class _AddApiDialogState extends State<AddApiDialog> {
  ApiMethodType apiMethod = ApiMethodType.GET;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Row(
            children: [
              DropdownMenu<ApiMethodType>(
                width: 100,
                hintText: 'Method'.tr(),
                requestFocusOnTap: false,
                inputDecorationTheme: InputDecorationTheme(
                  //filled: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 5.0),
                ),
                dropdownMenuEntries: [
                  DropdownMenuEntry(value: ApiMethodType.GET, label: 'GET'),
                  DropdownMenuEntry(value: ApiMethodType.POST, label: 'POST'),
                  DropdownMenuEntry(value: ApiMethodType.PUT, label: 'PUT'),
                  DropdownMenuEntry(value: ApiMethodType.DELETE, label: 'DELETE'),
                  DropdownMenuEntry(value: ApiMethodType.PATCH, label: 'PATCH'),
                  DropdownMenuEntry(value: ApiMethodType.HEAD, label: 'HEAD'),
                  DropdownMenuEntry(value: ApiMethodType.OPTIONS, label: 'OPTIONS'),
                ],
              ),
              Expanded(
                child: SizedBox(
                  width: 80,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Endpoint'.tr(),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text('You can also import api request', textAlign: TextAlign.right,),
          const SizedBox(height: 5),
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
              onPressed: pickFile,
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
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.check_circle_outline),
            label: const Text(' Save an API')
        ),
      ],
    );
  }
}
