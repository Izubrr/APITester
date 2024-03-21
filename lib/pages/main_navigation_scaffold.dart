import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diplom/main.dart';
import 'package:flutter/material.dart';
import 'project_page.dart';
import '../widgets/settings_dialog.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../widgets/createproject_dialog.dart';
import 'package:diplom/widgets/empty_nav_rail.dart';

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
    ProjectPage(
      projectName: 'MyApp1',
      // Создаем объекты Api с endpoint и method
      apis: [
        Api(method: ApiMethodType.GET, endpoint: '/api/v1/resource1', status: ApiStatus.done),
        Api(method: ApiMethodType.POST, endpoint: '/api/v1/resource2', status: ApiStatus.inProgress),
        Api(method: ApiMethodType.POST, endpoint: '/api/v1/resource3', ),
        Api(method: ApiMethodType.POST, endpoint: '/api/v1/resource4', ),
        Api(method: ApiMethodType.POST, endpoint: '/api/v1/resource5', ),
        Api(method: ApiMethodType.POST, endpoint: '/api/v1/resource6', ),
        Api(method: ApiMethodType.PUT, endpoint: '/api/v1/resource7', ),
        Api(method: ApiMethodType.PUT, endpoint: '/api/v1/resource8', ),
        Api(method: ApiMethodType.POST, endpoint: '/api/v1/resource9', ),
        Api(method: ApiMethodType.POST, endpoint: '/api/v1/resource10', ),
        Api(method: ApiMethodType.DELETE, endpoint: '/api/v1/resource11', ),
        Api(method: ApiMethodType.DELETE, endpoint: '/api/v1/resource12', ),
        Api(method: ApiMethodType.DELETE, endpoint: '/api/v1/resource13', ),

      ],
      testCases: const ['Test Case 1', 'Test Case 2'],
    ),
    ProjectPage(
      projectName: 'MyApp2',
      apis: [
        Api(method: ApiMethodType.PUT, endpoint: '/api/v2/resource3', ),
        Api(method: ApiMethodType.DELETE, endpoint: '/api/v2/resource4', ),
      ],
      testCases: const ['Test Case 3', 'Test Case 4'],
    ),
    ProjectPage(
      projectName: 'MyApp3',
      apis: [
        Api(method: ApiMethodType.GET, endpoint: '/api/v3/resource5', ),
        Api(method: ApiMethodType.POST, endpoint: '/api/v3/resource6', ),
      ],
      testCases: const ['Test Case 5', 'Test Case 6'],
    ),
  ];

  bool _isLoading = true;

  List<NavigationRailDestination> _destinations = [];

  Future<void> _loadDestinations() async {
    setState(() {
      _isLoading = true; // Начало загрузки
    });
    var collection = fireStore.collection('users/${currentUser?.uid}/parsedYaml').get();
    print('1 ${DateTime.now().toString()}');
    var snapshot = await collection;
    print('2 ${DateTime.now().toString()}');
    var docs = snapshot.docs.map((doc) => doc.id).toList(); // Получаем названия документов

    // Преобразуем названия документов в NavigationRailDestination
    setState(() {
      print('3 ${DateTime.now().toString()}');
      _destinations = docs.map((name) => NavigationRailDestination(
        icon: const Icon(Icons.folder),
        label: Text(name),
      )).toList();
    });
    setState(() {
      _isLoading = false; // Загрузка завершена
      print('Загрузка завершена ${DateTime.now().toString()}');
    });
  }

  @override
  void initState() {
    super.initState();
    _loadDestinations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          ValueListenableBuilder(
            valueListenable: labelTypeNotifier,
            builder: (context, labelType, child) {
              return _isLoading == true ? EmptyNavigationRail() : NavigationRail(
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
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return CreateProjectDialog();
                        },
                      );
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
                        )
                    ),
                  ),
                ),
                destinations: _destinations,
              );
            },
          ),
          _isLoading == true ? const Expanded(child: Center(child: Text('Please wait'))) : Expanded(child: _pages[_screenIndex]),
        ],
      ),
    );
  }
}
