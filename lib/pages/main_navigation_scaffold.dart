import 'package:flutter/material.dart';
import 'project_page.dart';
import 'settings_dialog.dart';
import 'package:firebase_storage/firebase_storage.dart';

ValueNotifier<NavigationRailLabelType> labelTypeNotifier =
    ValueNotifier(NavigationRailLabelType.all);

class MainNavigationScaffold extends StatefulWidget {
  const MainNavigationScaffold({Key? key}) : super(key: key);

  @override
  _MainNavigationScaffoldState createState() => _MainNavigationScaffoldState();
}

class _MainNavigationScaffoldState extends State<MainNavigationScaffold> with TickerProviderStateMixin {

  int _screenIndex = 0;

  // Инициализация списка виджетов ProjectPage
  late final List<Widget> _pages = [
    const ProjectPage(
      projectName: 'MyApp1',
      apis: ['API 1', 'API 2'], // Пример данных API
      testCases: ['Test Case 1', 'Test Case 2'], // Пример данных Test Cases
    ),
    const ProjectPage(
      projectName: 'MyApp2',
      apis: ['API 3', 'API 4'], // Пример данных API
      testCases: ['Test Case 3', 'Test Case 4'], // Пример данных Test Cases
    ),
    const ProjectPage(
      projectName: 'MyApp3',
      apis: ['API 5', 'API 6'], // Пример данных API
      testCases: ['Test Case 5', 'Test Case 6'], // Пример данных Test Cases
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ValueListenableBuilder(
          valueListenable: labelTypeNotifier,
          builder: (context, labelType, child) {
            return NavigationRail(
                backgroundColor: ElevationOverlay.applySurfaceTint(
                    Theme.of(context).colorScheme.background,
                    Theme.of(context).colorScheme.primary,
                    3),
                onDestinationSelected: ((index) {
                  setState(() {
                    _screenIndex = index;
                  });
                }),
                selectedIndex: _screenIndex,
                labelType: labelType,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FloatingActionButton(
                    onPressed: () {
                      // Add your onPressed code here!
                    },
                    child: const Icon(Icons.add),
                  ),
                ),
                trailing: Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: IconButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return SettingsDialog();
                              },
                            );
                          },
                          icon: const Icon(Icons.settings),
                        )),
                  ),
                ),
                destinations: const [
                  NavigationRailDestination(
                      icon: Icon(Icons.person), label: Text('MyApp 1')),
                  NavigationRailDestination(
                      icon: Icon(Icons.widgets), label: Text('MyApp 2')),
                  NavigationRailDestination(
                      icon: Icon(Icons.hourglass_bottom),
                      label: Text('MyApp 3')),
                ]);
          },
        ),
        Expanded(child: _pages[_screenIndex]),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
