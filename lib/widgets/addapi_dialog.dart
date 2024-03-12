import 'package:flutter/material.dart';
import 'package:diplom/pages/project_page.dart';

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
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Endpoint',
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
              onPressed: () {
                // Здесь может быть ваша логика для импорта API запроса
                print('Import API Request');
              },
              child: const Row(
                children: [
                  Icon(Icons.save_alt),
                  Text(' Import file'),
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
        FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.check_circle_outline), label: const Text(' Save an API')),
      ],
    );
  }
}
