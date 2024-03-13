import 'package:flutter/material.dart';
import 'package:diplom/pages/project_page.dart';

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
              const Expanded(
                child: SizedBox(
                  width: 80,
                  child: TextField(
                    decoration: InputDecoration(
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
                minimumSize: MaterialStateProperty.all(Size(100, double.infinity)),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              onPressed: () {
                // Здесь может быть ваша логика для импорта API запроса
                print('Import project');
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
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.create_new_folder_outlined),
            label: const Text(' Create a project')
        ),
      ],
    );
  }
}
