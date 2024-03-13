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

  print('OpenAPI version: ${parseYaml.openapi}');
  print('Title: ${parseYaml.title}');
  print('Version: ${parseYaml.version}');
  print('Description: ${parseYaml.description}');
}

class AddApiDialog extends StatefulWidget {
  @override
  _AddApiDialogState createState() => _AddApiDialogState();
}

class _AddApiDialogState extends State<AddApiDialog> {
  ApiMethod apiMethod = ApiMethod.GET;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Row(
            children: [
              DropdownMenu<ApiMethod>(
                width: 100,
                hintText: 'Method',
                requestFocusOnTap: false,
                inputDecorationTheme: InputDecorationTheme(
                  //filled: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 5.0),
                ),
                dropdownMenuEntries: [
                  DropdownMenuEntry(value: ApiMethod.GET, label: 'GET'),
                  DropdownMenuEntry(value: ApiMethod.POST, label: 'POST'),
                  DropdownMenuEntry(value: ApiMethod.PUT, label: 'PUT'),
                  DropdownMenuEntry(value: ApiMethod.DELETE, label: 'DELETE'),
                ],
              ),
              Expanded(
                child: SizedBox(
                  width: 80,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Endpoint',
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
                minimumSize: MaterialStateProperty.all(Size(100, double.infinity)),
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
