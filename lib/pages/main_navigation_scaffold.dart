import 'package:diplom/main.dart';
import 'package:flutter/material.dart';
import 'project_page.dart';
import '../widgets/settings_dialog.dart';
import '../widgets/createproject_dialog.dart';
import 'package:diplom/widgets/empty_nav_rail.dart';

ValueNotifier<NavigationRailLabelType> labelTypeNotifier =
ValueNotifier(NavigationRailLabelType.all);

class ApiDestination {
  final String id;
  final NavigationRailDestination destination;

  ApiDestination({required this.id, required this.destination});
}

class MainNavigationScaffold extends StatefulWidget {
  const MainNavigationScaffold({Key? key}) : super(key: key);

  @override
  _MainNavigationScaffoldState createState() => _MainNavigationScaffoldState();
}

class _MainNavigationScaffoldState extends State<MainNavigationScaffold> with TickerProviderStateMixin {

  int _screenIndex = 0;
  String? selectedApiId; // ID выбранного API

  // Инициализация списка виджетов ProjectPage
  final List<Widget> _pages = [
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

  List<ApiDestination> _destinations = [];
  var documentNames = [];

  Future<List<ApiDestination>> fetchApiTitlesAndIcons() async {
    _isLoading = true;
    print('[1] ${DateTime.now().toString()}');
    try {
      final apiCollection = await fireStore.collection('users/${currentUser?.uid}/APIs').get();
      print('[2] ${DateTime.now().toString()}');
      for (var doc in apiCollection.docs) {
        final data = doc.data();
        if (data.containsKey('info') && data['info'] is Map) {
          final title = data['info']['title'] as String? ?? 'No Title';
          IconData? iconData;

          // Проверка и конвертация iconCode в IconData
          iconData = IconData(data['iconCode'], fontFamily: 'MaterialIcons');

          // Если иконка не определена, используется стандартная иконка
          iconData ??= Icons.folder;

          // Создание ApiDestination
          _destinations.add(
            ApiDestination(
              id: doc.id,
              destination: NavigationRailDestination(
                icon: Icon(iconData),
                label: Text(title),
              ),
            ),
          );
        }
      }
      print('[3] ${DateTime.now().toString()}');
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching API titles and icons: $e");
    }
    return _destinations;
  }

  @override
  void initState() {
    super.initState();
    fetchApiTitlesAndIcons();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _isLoading == true ? EmptyNavigationRail() : ValueListenableBuilder(
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
                    selectedApiId = _destinations[index].id; // Сохранение ID выбранного API
                  });
                }),
                selectedIndex: null,
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
                destinations: _destinations.map((apiDest) => apiDest.destination).toList(),
              );
            },
          ),
          Expanded(child: _pages[_screenIndex]),
        ],
      ),
    );
  }
}