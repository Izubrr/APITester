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

ValueNotifier<List<ApiDestination>> navRailDestinations = ValueNotifier([]);

class _MainNavigationScaffoldState extends State<MainNavigationScaffold> with TickerProviderStateMixin {
  bool _isLoading = true;

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

          // Создание ApiDestination
          navRailDestinations.value.add(
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
        navRailDestinations;
      });
    } catch (e) {
      print("Error fetching API titles and icons: $e");
    }
    return navRailDestinations.value;
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
          if (_isLoading == true) EmptyNavigationRail() else ValueListenableBuilder(
            valueListenable: labelTypeNotifier,
            builder: (context, labelType, child) {
              return ValueListenableBuilder<List<ApiDestination>>(
                valueListenable: navRailDestinations,
                builder: (context, value, child) {
                  return NavigationRail(
                    backgroundColor: ElevationOverlay.applySurfaceTint(
                        Theme.of(context).colorScheme.background,
                        Theme.of(context).colorScheme.primary,
                        3
                    ),
                    onDestinationSelected: (index) {
                      setState(() {
                        selectedProjectIdNotifier.value = value[index].id; // Сохранение ID выбранного API
                        updateProjectPage = true;
                      });
                    },
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
                          ),
                        ),
                      ),
                    ),
                    destinations: value.map((apiDest) => apiDest.destination).toList(),
                  );
                },
              );

            },
          ),
          Expanded(child: ProjectPage(selectedProjectId: selectedProjectIdNotifier.value)),
        ],
      ),
    );
  }
}