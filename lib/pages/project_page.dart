import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diplom/main.dart';
import 'package:flutter/material.dart';
import 'package:diplom/widgets/addapi_dialog.dart';

// Определение перечисления ApiStatus
enum ApiStatus {
  inProgress,
  done,
  notDone,
}

enum ApiMethodType {
  GET,
  POST,
  PUT,
  DELETE,
  PATCH,
  OPTIONS,
  HEAD,
}

extension ApiMethodTypeExtension on ApiMethodType {
  static ApiMethodType fromString(String method) {
    switch (method.toUpperCase()) {
      case 'GET':
        return ApiMethodType.GET;
      case 'POST':
        return ApiMethodType.POST;
      case 'PUT':
        return ApiMethodType.PUT;
      case 'DELETE':
        return ApiMethodType.DELETE;
      case 'PATCH':
        return ApiMethodType.PATCH;
      case 'OPTIONS':
        return ApiMethodType.OPTIONS;
      case 'HEAD':
        return ApiMethodType.HEAD;
      default:
        throw FormatException('Unknown API method type: $method');
    }
  }

  String get name {
    switch (this) {
      case ApiMethodType.GET:
        return 'GET';
      case ApiMethodType.POST:
        return 'POST';
      case ApiMethodType.PUT:
        return 'PUT';
      case ApiMethodType.DELETE:
        return 'DELETE';
      case ApiMethodType.PATCH:
        return 'PATCH';
      case ApiMethodType.OPTIONS:
        return 'OPTIONS';
      case ApiMethodType.HEAD:
        return 'HEAD';
      default:
        throw const FormatException('Unknown API method type');
    }
  }
}


class PathObject {
  final ApiMethodType method;
  final String endpoint;
  List<String> tags;
  ApiStatus status;
  String summary;
  Map<String, dynamic> requestBody;
  Map<String, dynamic> responses;

  PathObject({
    required this.method,
    required this.endpoint,
    this.tags = const ['', ''],
    this.status = ApiStatus.inProgress,
    this.summary = '',
    this.requestBody = const {
      '1': "Tom",
      '2': "Bob",
      '3': "Sam"
    },
    this.responses = const {
      '1': "Tom",
      '2': "Bob",
      '3': "Sam"
    },
  });
}

Map<String, dynamic> testCases = {
  '1': "Tom",
  '2': "Bob",
  '3': "Sam"
};

// Страница деталей для API
class ApiDetailPage extends StatefulWidget {
  final PathObject api;

  const ApiDetailPage({Key? key, required this.api}) : super(key: key);

  @override
  State<ApiDetailPage> createState() => _ApiDetailPageState();
}

class _ApiDetailPageState extends State<ApiDetailPage> {
  Color getStatusColor() {
    switch (widget.api.status) {
      case ApiStatus.notDone:
        return getColorScheme(Colors.red).primaryContainer;
      case ApiStatus.inProgress:
        return Colors.transparent;
      case ApiStatus.done:
        return getColorScheme(Colors.green).primaryContainer;
      default:
        return getColorScheme(Colors.green).primaryContainer;
    }
  }

  ColorScheme getColorScheme(Color color) {
    ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: color,
      brightness: Theme.of(context).brightness,
    );
    return colorScheme;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${widget.api.method.name}  ',
                      style: Theme.of(context).textTheme.titleLarge),
                  Text(widget.api.endpoint,
                      style: Theme.of(context).textTheme.labelLarge),
                  const VerticalDivider(),
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 16),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Description',
                        ),
                      ),
                    ),
                  ),
                  const VerticalDivider(),
                  Container(
                    decoration: BoxDecoration(
                        color: getStatusColor(),
                        borderRadius:
                        const BorderRadius.all(Radius.circular(12))),
                    child: DropdownButton<ApiStatus>(
                      focusColor: Colors.transparent,
                      isDense: true,
                      underline: const Text(''),
                      padding: const EdgeInsets.all(5),
                      borderRadius: BorderRadius.circular(12.0),
                      value: widget.api.status,
                      onChanged: (ApiStatus? newValue) {
                        setState(() {
                          widget.api.status = newValue!;
                        });
                      },
                      items: const [
                        DropdownMenuItem(
                          value: ApiStatus.notDone,
                          child: Text('ToDo'),
                        ),
                        DropdownMenuItem(
                          value: ApiStatus.inProgress,
                          child: Text('In Progress'),
                        ),
                        DropdownMenuItem(
                          value: ApiStatus.done,
                          child: Text('Done'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Страница деталей для тестового случая
class TestCaseDetailPage extends StatelessWidget {
  final String testCase;

  const TestCaseDetailPage({Key? key, required this.testCase})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Test Case Detail: $testCase'),
    );
  }
}

// Главная страница проекта с вкладками API и тестовых случаев
class ProjectPage extends StatefulWidget {
  final String? selectedProjectId;

  const ProjectPage({Key? key, required this.selectedProjectId}) : super(key: key);

  @override
  _ProjectPageState createState() => _ProjectPageState();
}

enum FilterOption {
  getByMethodGET,
  getByMethodPOST,
  getByMethodPUT,
  getByMethodDELETE,
  getByMethodPATCH,
  getByMethodOPTIONS,
  getByMethodHEAD,
  orderByEndpoint,
  orderByStatus,
  disabled,
}

String projectName = 'Project Name';
List<PathObject> paths = [];
bool updateProjectPage = false;
bool filterEnabled = false;

class _ProjectPageState extends State<ProjectPage>
    with SingleTickerProviderStateMixin {

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  var pathsCollection;
  var operationsCollection;

  Map<String, List<PathObject>> taggedApis = {};
  List<PathObject> paths = [];

  Future<void> fetchProjectData() async {
    try {
      final apiRef = fireStore.collection('users/${currentUser?.uid}/APIs').doc(widget.selectedProjectId);
      final apiDoc = await apiRef.get();
      final apiData = apiDoc.data();
      if (apiData != null && apiData.containsKey('info') && apiData['info'] is Map) {
        projectName = apiData['info']['title'];
      }

      Map<String, List<PathObject>> tempTaggedApis = {};
      List<PathObject> apisWithoutTag = [];

      final pathsCollection = await apiRef.collection('Paths').get();
      for (var pathDoc in pathsCollection.docs) {
        final pathData = pathDoc.data();
        final operationsCollection = await apiRef.collection('Paths/${pathDoc.id}/Operations').get();
        for (var operationDoc in operationsCollection.docs) {
          var operationData = operationDoc.data();
          var tags = operationData['tags'] as List<dynamic>? ?? [];
          var pathObject = PathObject(
            method: ApiMethodTypeExtension.fromString(operationDoc.id),
            endpoint: pathData['path'],
          );
          paths.add(PathObject(
            method: ApiMethodTypeExtension.fromString(operationDoc.id), // предполагается, что у вас есть метод для конвертации строки в enum
            endpoint: pathData['path'],
          ));

          if (tags.isEmpty) {
            apisWithoutTag.add(pathObject);
          } else {
            tags.forEach((tag) {
              tempTaggedApis.putIfAbsent(tag.toString(), () => []).add(pathObject);
            });
          }
        }
      }

      // Добавляем APIs без тегов под специальным ключом
      tempTaggedApis['Without Tag'] = apisWithoutTag;

      setState(() {
        taggedApis = tempTaggedApis;
        updateProjectPage = false;
      });
    } catch (e) {
      print("Error fetching project data: $e");
    }
  }

  late TabController _tabController;

  int selectedApiIndex = -1;
  int selectedTestCaseIndex = -1;

  final ValueNotifier<FilterOption?> currentFilter = ValueNotifier(null);

  int naturalSortComparator(String a, String b) {
    final RegExp regExp = RegExp(r'(\d+)|(\D+)');
    final Iterable<RegExpMatch> matchesA = regExp.allMatches(a);
    final Iterable<RegExpMatch> matchesB = regExp.allMatches(b);

    final List<String> partsA = matchesA.map((m) => m.group(0)!).toList();
    final List<String> partsB = matchesB.map((m) => m.group(0)!).toList();

    for (int i = 0; i < min(partsA.length, partsB.length); i++) {
      final String partA = partsA[i];
      final String partB = partsB[i];

      if (partA == partB) continue;

      final num? numA = int.tryParse(partA);
      final num? numB = int.tryParse(partB);

      if (numA != null && numB != null) {
        return numA.compareTo(numB);
      }
      return partA.compareTo(partB);
    }
    return partsA.length.compareTo(partsB.length);
  }

  void sortApisByEndpoint(List<PathObject> apis) {
    apis.sort((a, b) => naturalSortComparator(a.endpoint, b.endpoint));
  }

  bool _isListVisible = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(projectName),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'APIs', icon: Icon(Icons.api)),
            Tab(text: 'Test Cases', icon: Icon(Icons.bug_report)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Row(
            children: [
              if (_isListVisible)
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(8, 8, 0, 0),
                              child: ElevatedButton(
                                onPressed: () {
                                  selectedProjectIdNotifier.value == null ? ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a project at first'))) :
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AddApiDialog();
                                    },
                                  );
                                },
                                child: const Text('Add API'),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                            child: PopupMenuButton<FilterOption>(
                              icon: const Icon(Icons.filter_list),
                              onSelected: (FilterOption result) {
                                selectedProjectIdNotifier.value == null ? ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a project at first'))) : currentFilter.value = result;
                              },
                              itemBuilder: (BuildContext context) =>
                              <PopupMenuEntry<FilterOption>>[
                                const PopupMenuItem<FilterOption>(
                                  value: FilterOption.getByMethodGET,
                                  child: Text('GET'),
                                ),
                                const PopupMenuItem<FilterOption>(
                                  value: FilterOption.getByMethodPOST,
                                  child: Text('POST'),
                                ),
                                const PopupMenuItem<FilterOption>(
                                  value: FilterOption.getByMethodPUT,
                                  child: Text('PUT'),
                                ),
                                const PopupMenuItem<FilterOption>(
                                  value: FilterOption.getByMethodDELETE,
                                  child: Text('DELETE'),
                                ),
                                const PopupMenuItem<FilterOption>(
                                  value: FilterOption.getByMethodPATCH,
                                  child: Text('PATCH'),
                                ),
                                const PopupMenuItem<FilterOption>(
                                  value: FilterOption.getByMethodOPTIONS,
                                  child: Text('OPTIONS'),
                                ),
                                const PopupMenuItem<FilterOption>(
                                  value: FilterOption.getByMethodHEAD,
                                  child: Text('HEAD'),
                                ),
                                const PopupMenuItem<FilterOption>(
                                  value: FilterOption.orderByEndpoint,
                                  child: Text('Endpoint'),
                                ),
                                const PopupMenuItem<FilterOption>(
                                  value: FilterOption.orderByStatus,
                                  child: Text('Status'),
                                ),
                                const PopupMenuItem(
                                  value: FilterOption.disabled,
                                  child: Text('Disable Filter'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      selectedProjectIdNotifier.value == null ? const Expanded(child: Center(child: Text('Select a project'))) : ValueListenableBuilder<FilterOption?>(
                        valueListenable: currentFilter,
                        builder: (context, value, child) {
                          List<PathObject> filteredApis = paths;
                          switch (value) {
                            case FilterOption.getByMethodGET:
                              filterEnabled = true;
                              filteredApis = filteredApis
                                  .where((api) =>
                              api.method.name.toString() == "GET")
                                  .toList();
                              break;
                            case FilterOption.getByMethodPOST:
                              filterEnabled = true;
                              filteredApis = filteredApis
                                  .where((api) =>
                              api.method.name.toString() == "POST")
                                  .toList();
                              break;
                            case FilterOption.getByMethodPUT:
                              filterEnabled = true;
                              filteredApis = filteredApis
                                  .where((api) =>
                              api.method.name.toString() == "PUT")
                                  .toList();
                              break;
                            case FilterOption.getByMethodDELETE:
                              filterEnabled = true;
                              filteredApis = filteredApis
                                  .where((api) =>
                              api.method.name.toString() == "DELETE")
                                  .toList();
                              break;
                            case FilterOption.getByMethodPATCH:
                              filterEnabled = true;
                              filteredApis = filteredApis
                                  .where((api) =>
                              api.method.name.toString() == "PATCH")
                                  .toList();
                              break;
                            case FilterOption.getByMethodOPTIONS:
                              filterEnabled = true;
                              filteredApis = filteredApis
                                  .where((api) =>
                              api.method.name.toString() == "OPTIONS")
                                  .toList();
                              break;
                            case FilterOption.getByMethodHEAD:
                              filterEnabled = true;
                              filteredApis = filteredApis
                                  .where((api) =>
                              api.method.name.toString() == "HEAD")
                                  .toList();
                              break;
                            case FilterOption.disabled:
                              filterEnabled = false;
                              break;
                            case FilterOption.orderByEndpoint:
                              filterEnabled = true;
                              sortApisByEndpoint(filteredApis);
                              break;
                            case FilterOption.orderByStatus:
                              filterEnabled = true;
                              filteredApis.sort((a, b) =>
                                  a.status.index.compareTo(b.status.index));
                              break;
                            default: filterEnabled = false;
                              break;
                          }
                          // Возвращаем отфильтрованный и отсортированный список
                          return ValueListenableBuilder<String?>(
                              valueListenable: selectedProjectIdNotifier,
                              builder: (context, selectedProjectId, child) {
                                if (selectedProjectId != null && updateProjectPage) {
                                  fetchProjectData(); // Асинхронно загружаем данные
                                  // Центрирование CircularProgressIndicator
                                  return const Expanded(
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }
                                // Возвращаем список API, когда данные доступны
                                return !filterEnabled ? Expanded(
                                  child: ListView.builder(
                                    itemCount: taggedApis.keys.length,
                                    itemBuilder: (context, index) {
                                      String tag = taggedApis.keys.elementAt(index);
                                      List<PathObject> apis = taggedApis[tag]!;

                                      return ExpansionTile(
                                        title: Text(tag),
                                        children: apis.map((api) => ListTile(
                                          trailing: api.status == ApiStatus.done
                                              ? const Icon(Icons.check)
                                              : api.status == ApiStatus.notDone
                                              ? const Icon(Icons.not_interested)
                                              : null,
                                          title: Text('${api.method.name} ${api.endpoint}'),
                                          onTap: () => setState(() {
                                            // Находим индекс api в общем списке paths
                                            int apiIndex = paths.indexWhere((path) =>
                                            path.method == api.method && path.endpoint == api.endpoint);
                                            // Обновляем selectedApiIndex если объект найден
                                            if (apiIndex != -1) {
                                              setState(() {
                                                selectedApiIndex = apiIndex;
                                              });
                                            }
                                          }),
                                        )).toList(),
                                      );
                                    },
                                  ),
                                ) :  Expanded(
                                  child: ListView.builder(
                                    itemCount: filteredApis.length,
                                    itemBuilder: (context, index) {
                                      PathObject api = filteredApis[index];
                                      return ListTile(
                                        trailing: api.status == ApiStatus.done
                                            ? const Icon(Icons.check)
                                            : api.status == ApiStatus.notDone
                                            ? const Icon(Icons.not_interested)
                                            : null,
                                        title: Text('${api.method.name} ${api.endpoint}'),
                                        onTap: () => setState(() {
                                          // Находим индекс api в общем списке paths
                                          int apiIndex = paths.indexWhere((path) =>
                                          path.method == api.method && path.endpoint == api.endpoint);
                                          // Обновляем selectedApiIndex если объект найден
                                          if (apiIndex != -1) {
                                            setState(() {
                                              selectedApiIndex = apiIndex;
                                            });
                                          }
                                        }),
                                      );
                                    },
                                  ),
                                );
                              }
                          );
                        },
                      ),
                    ],
                  ),
                ),
              if (_isListVisible) const VerticalDivider(width: 1),
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: Icon(_isListVisible ? Icons.arrow_back_ios_new : Icons.arrow_forward_ios_outlined),
                  onPressed: () {
                    setState(() {
                      _isListVisible = !_isListVisible;
                    });
                  },
                ),
              ),
              Expanded(
                flex: 5,
                child: selectedProjectIdNotifier.value == null ? const Center(child: Text('Please select a project to show this content')) : selectedApiIndex == -1
                    ? const Center(
                    child: Text(
                        'Select an object from list to view details'))
                    : ApiDetailPage(api: paths[selectedApiIndex]),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(8, 8, 0, 0),
                            child: ElevatedButton(
                              onPressed: () {
                                // Здесь должна быть ваша логика для добавления API
                              },
                              child: const Text('Add TestCase'),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                          child: IconButton(
                            icon: const Icon(Icons.filter_list),
                            onPressed: () {
                              // Здесь должна быть ваша логика для добавления чего-либо ещё
                            },
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    Expanded(
                      child: ListView.builder(
                        itemCount: testCases.length,
                        itemBuilder: (context, index) {
                          String testCase = testCases[index];
                          return ListTile(
                            title: Text(testCase),
                            onTap: () => setState(() {
                              selectedTestCaseIndex = index;
                            }),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const VerticalDivider(width: 1),
              Expanded(
                  flex: 5,
                  child: selectedTestCaseIndex == -1
                      ? const Center(
                      child: Text(
                          'Select an object from list to view details'))
                      : TestCaseDetailPage(
                      testCase: testCases[selectedTestCaseIndex])),
            ],
          ),
        ],
      ),
    );
  }
}
