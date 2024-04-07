import 'package:diplom/main.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'project_page.dart';
import '../widgets/settings_dialog.dart';
import '../widgets/createproject_dialog.dart';
import 'package:diplom/widgets/empty_nav_rail.dart';

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

IconData? getIconData(int iconCode) {
  switch (iconCode) {
    case 0xe04e:
      return Icons.add_chart;
    case 0xe08a:
      return Icons.api;
    case 0xf03d6:
      return Icons.browser_updated_sharp;
    case 0xe115:
      return Icons.bug_report;
    case 0xe040:
      return Icons.account_balance;
    case 0xe427:
      return Icons.new_label;
    case 0xe491:
      return Icons.person;
    case 0xe323:
      return Icons.hourglass_bottom;
    case 0xe6e6:
      return Icons.widgets;
    default:
      return Icons.code_off_sharp; // Возвращаем null или какой-то дефолтный икон, если iconCode не совпадает ни с одним из случаев
  }
}

class _MainNavigationScaffoldState extends State<MainNavigationScaffold> with TickerProviderStateMixin {
  bool _isLoading = true;

  Future<List<ApiDestination>> fetchApiTitlesAndIcons() async {
    _isLoading = true;
    try {
      final apiCollection = await fireStore.collection('users/${currentUser?.uid}/APIs').get();
      for (var doc in apiCollection.docs) {
        final data = doc.data();
        if (data.containsKey('info') && data['info'] is Map) {
          final title = data['info']['title'] as String? ?? 'No Title';
          //IconData? iconData;

          // Проверка и конвертация iconCode в IconData
          //iconData = IconData(data['iconCode'], fontFamily: 'MaterialIcons');

          // Создание ApiDestination
          navRailDestinations.value.add(
            ApiDestination(
              id: doc.id,
              destination: NavigationRailDestination(
                label: contextListener(Text(title), doc.id),
                icon: contextListener(Icon(getIconData(data['iconCode'])), doc.id),
              ),
            ),
          );
        }
      }
      setState(() {
        _isLoading = false;
        navRailDestinations;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching API titles and icons: '.tr() + e.toString())));
    }
    return navRailDestinations.value;
  }

  @override
  void initState() {
    super.initState();
    fetchApiTitlesAndIcons();
  }

  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          if(_isLoading == true || !currentUser!.emailVerified) EmptyNavigationRail() else ValueListenableBuilder(
            valueListenable: labelTypeNotifier,
            builder: (context, labelType, child) {
              return ValueListenableBuilder<List<ApiDestination>>(
                valueListenable: navRailDestinations,
                builder: (context, value, child) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        // Установите минимальную высоту, достаточную для вмещения всех элементов NavigationRail
                        minHeight: MediaQuery.of(context).size.height,
                      ),
                      child: IntrinsicHeight(
                        child: NavigationRail(
                          backgroundColor: ElevationOverlay.applySurfaceTint(
                              Theme.of(context).colorScheme.background,
                              Theme.of(context).colorScheme.primary,
                              3
                          ),
                          onDestinationSelected: (index) {
                            setState(() {
                              _selectedIndex = index;
                              selectedProjectIdNotifier.value = '-1';
                              selectedProjectIdNotifier.value = value[index].id; // Сохранение ID выбранного проекта
                              updateProjectPage = true;
                            });
                          },
                          selectedIndex: _selectedIndex,
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
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
          Expanded(child: currentUser!.emailVerified ? ProjectPage(selectedProjectId: selectedProjectIdNotifier.value) : Center(child: Text('Verify Email to use App'.tr(),  style: Theme.of(context).textTheme.displayMedium),)),
        ],
      ),
    );
  }
  Widget contextListener(Widget childWidget, String docId) {
    return Listener(
      onPointerDown: (event) async {
        final int indexToChange = navRailDestinations.value.indexWhere((element) => element.id == docId);

        if (event.kind == PointerDeviceKind.mouse && event.buttons == kSecondaryMouseButton) {
          final position = event.position;
          final result = await showMenu<String>(
            context: context,
            position: RelativeRect.fromLTRB(position.dx, position.dy, position.dx, position.dy),
            items: [
              PopupMenuItem<String>(
                value: 'rename',
                child: Text('Rename'.tr()),
              ),
              PopupMenuItem<String>(
                value: 'delete',
                child: Text('Delete'.tr()),
              ),
            ],
          );

          if (result != null) {
            switch (result) {
              case 'rename':
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    // Создаем контроллер для текстового поля
                    TextEditingController nameController = TextEditingController();

                    // Возвращаем AlertDialog
                    return AlertDialog(
                      title: Text('Rename Project'.tr()),
                      content: TextField(
                        controller: nameController,
                        decoration: InputDecoration(hintText: "Enter project name".tr()),
                        autofocus: true,
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: Text('Cancel'.tr()),
                          onPressed: () {
                            Navigator.of(context).pop(); // Закрыть диалог без сохранения
                          },
                        ),
                        TextButton(
                          child: Text('Rename'.tr()),
                          onPressed: () async {
                            final projectName = nameController.text;

                            // Проверяем, пустое ли имя
                            if (projectName.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Project name cannot be empty'.tr()),
                                ),
                              );
                              // Проверяем, содержится ли уже такое имя в списке
                            } else if (testCaseFolders.any((folder) => folder.name == projectName)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Project name needs to be unique'.tr()),
                                ),
                              );
                            } else {
                              try {
                                await fireStore.collection('users/${currentUser?.uid}/APIs').doc(docId).update({'info': {'title': projectName}});

                                // Тут обновляем название в списке navRailDestinations
                                setState(() {
                                  var destinationToUpdate = navRailDestinations.value[indexToChange];
                                  var updatedDestination = NavigationRailDestination(
                                    label: contextListener(Text(projectName), docId),
                                    icon: destinationToUpdate.destination.icon, // Сохраняем тот же икон
                                  );

                                  // Создаем обновленный объект ApiDestination
                                  var updatedApiDestination = ApiDestination(id: docId, destination: updatedDestination);

                                  // Обновляем элемент в списке
                                  navRailDestinations.value[indexToChange] = updatedApiDestination;

                                  // Важно! Это гарантирует, что ValueListenableBuilder перестроит своих потомков
                                  navRailDestinations.notifyListeners();
                                });
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error with renaming: '.tr() + e.toString()),
                                  ),
                                );
                              }
                              Navigator.of(context).pop(); // Закрыть диалог после сохранения
                            }
                          },
                        ),
                      ],
                    );
                  },
                );
                break;
              case 'delete':
              // Находим индекс элемента, который нужно удалить
                if (indexToChange != -1) {
                  // Если элемент найден, удаляем его из списка
                  setState(() {
                    navRailDestinations.value.removeAt(indexToChange);
                  });
                }
                // Удаляем документ из Firestore
                fireStore.collection('users/${currentUser?.uid}/APIs').doc(docId).delete();
                break;
            }
          }
        }
      },
      child: childWidget,
    );
  }
}