import 'dart:math';
import 'package:diplom/main.dart';
import 'package:diplom/pages/api_detail_page.dart';
import 'package:diplom/pages/test_case_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/change_notifier.dart';

// Определение перечисления ApiStatus
enum ApiStatus {
  done,
  notDone,
  inProgress,
}

extension ApiStatusExtension on ApiStatus {
  static ApiStatus fromString(String status) {
    switch (status) {
      case 'inProgress':
        return ApiStatus.inProgress;
      case 'done':
        return ApiStatus.done;
      case 'notDone':
        return ApiStatus.notDone;
      default:
        return ApiStatus.inProgress;
    }
  }

  static String convertToString(ApiStatus status) {
    switch (status) {
      case ApiStatus.inProgress:
        return 'inProgress';
      case ApiStatus.done:
        return 'done';
      case ApiStatus.notDone:
        return 'notDone';
      default:
        return 'inProgress';
    }
  }

  String get name {
    switch (this) {
      case ApiStatus.inProgress:
        return 'inProgress';
      case ApiStatus.done:
        return 'done';
      case ApiStatus.notDone:
        return 'notDone';
    }
  }
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

final TextEditingController descriptionController = TextEditingController();

class PathObject {
  final ApiMethodType method;
  final String endpoint;
  final String pathId;
  List<dynamic> tags;
  ApiStatus status;
  String summary;
  String description;
  String operationId;
  Map<String, dynamic> requestBody;
  List<dynamic> responses;
  List<String> fetchedTestCaseId;

  PathObject(
      {required this.method,
      required this.endpoint,
      required this.pathId,
      required this.operationId,
      this.tags = const [],
      this.status = ApiStatus.inProgress,
      this.summary = '',
      this.description = '',
      this.requestBody = const {'1': "Tom", '2': "Bob", '3': "Sam"},
      this.fetchedTestCaseId = const [],
      this.responses = const []});
}

Map<String, String> apiDataCache = {};

late ValueNotifier<String> selectedResponseNotifier =
    ValueNotifier(paths[selectedApiIndex].responses.first);

// Главная страница проекта с вкладками API и тестовых случаев
class ProjectPage extends StatefulWidget {
  final String? selectedProjectId;

  const ProjectPage({Key? key, required this.selectedProjectId})
      : super(key: key);

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

late TabController projectPageTabController;

String projectName = 'Project Name';
List<PathObject> paths = [];
List<Folder> testCaseFolders = [];
List<TestCase> testCases = [];
bool updateProjectPage = false;
bool filterEnabled = false;
int selectedApiIndex = -1;
int selectedTestFolderIndex = -1;
ValueNotifier<int> selectedTestCaseIndex = ValueNotifier(-1);
ValueNotifier<TestCase>? selectedTestCase;
Map<String, dynamic> responseCodes = {};
Map<String, dynamic> requestBodyCodes = {};
bool isFolderEditing = false;
bool isTestCaseEditing = false;
ValueNotifier<String> testCaseListCurrent = ValueNotifier('folder');

class _ProjectPageState extends State<ProjectPage>
    with SingleTickerProviderStateMixin {
  void _onSelectedProjectIdChange() {
    setState(() {
      selectedApiIndex = -1;
      selectedTestCaseIndex.value = -1;
      testCaseFolders = [];
      testCases = [];
      paths = [];
      apiDataCache = {};
    });
  }

  @override
  void initState() {
    super.initState();
    projectPageTabController = TabController(length: 2, vsync: this);
    selectedProjectIdNotifier.addListener(_onSelectedProjectIdChange);
  }

  Map<String, List<PathObject>> taggedApis = {};

  Future<void> fetchProjectData() async {
    _isFetchProjectDataLoading = true;

    List<String> fetches;

    final apiRef = fireStore
        .collection('users/${currentUser?.uid}/APIs')
        .doc(widget.selectedProjectId);
    final apiDoc = await apiRef.get();
    final apiData = apiDoc.data();
    if (apiData != null &&
        apiData.containsKey('info') &&
        apiData['info'] is Map) {
      projectName = apiData['info']['title'];
    }

    final testcasefolders = await apiRef.collection('testcasefolders').get();
    for (var folderDoc in testcasefolders.docs) {
      final folderData = folderDoc.data();
      final cases = await apiRef.collection('testcasefolders/${folderDoc.id}/testcases').get();

      // Если подколлекция существует и содержит документы, заполняем список testCases
      if (cases.docs.isNotEmpty) {
        for (var caseDoc in cases.docs) {
          final caseData = caseDoc.data();
          fetches = List<String>.from(caseData['fetchedApisID'] ?? []);
          testCases.add(
              TestCase(
                name: caseData['name'],
                url: caseData['url'] ?? '',
                description: caseData['description'] ?? '',
                fetchedApisID: fetches,
                docId: caseDoc.id,
              )
          );
        }
      }
      testCaseFolders.add(
          Folder(
            name: folderData['title'],
            docId: folderDoc.id,
            testCases: testCases,
          )
      );
    }

    Map<String, List<PathObject>> tempTaggedApis = {};
    List<PathObject> apisWithoutTag = [];

    var pathsCollection = await apiRef.collection('paths').get();
    for (var pathDoc in pathsCollection.docs) {
      final pathData = pathDoc.data();
      var operationsCollection =
          await apiRef.collection('paths/${pathDoc.id}/operations').get();
      for (var operationDoc in operationsCollection.docs) {
        var operationData = operationDoc.data();

        var tags = operationData['tags'] ?? [];
        var description = operationData['description'];
        var status = operationData['status'] ?? 'inProgress';
        Map<String, dynamic> responses = operationData['responses'] ?? {};
        Map<String, dynamic> requestBody = operationData['requestBody'] ?? {};

        responseCodes[pathDoc.id] = responses;
        requestBodyCodes[pathDoc.id] = requestBody;

        var pathObject = PathObject(
          method: ApiMethodTypeExtension.fromString(operationDoc.id),
          endpoint: pathData['path'],
          pathId: pathDoc.id,
          operationId: operationDoc.id,
          tags: tags,
          description: description ?? '',
          status: ApiStatusExtension.fromString(status),
          responses: responses.keys.toList(),
        );
        paths.add(pathObject);

        if (tags.isEmpty) {
          apisWithoutTag.add(pathObject);
        } else {
          tags.forEach((tag) {
            tempTaggedApis
                .putIfAbsent(tag.toString(), () => [])
                .add(pathObject);
          });
        }
      }
    }

    // Добавляем APIs без тегов под специальным ключом
    tempTaggedApis['Without Tag'] = apisWithoutTag;

    setState(() {
      taggedApis = tempTaggedApis;
      updateProjectPage = false;
      _isFetchProjectDataLoading = false;
    });
  }

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

  bool _isApiListVisible = true;
  bool _isCaseListVisible = true;

  void renameItem(String docId, String collectionPath, Map<String, dynamic> newData, Function update) async {
    try {
      // Обращение к документу в Firestore и обновление поля 'name'
      await fireStore
          .collection(collectionPath)
          .doc(docId) // Используйте идентификатор документа папки
          .update(newData);

      // Если обновление в Firestore прошло успешно, обновляем имя в локальном списке
      setState(() {
        update;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to rename item: $e'),
      ));
    }
  }

  void deleteItem(String docId, String collectionPath, List list, int index) async {
    try {
      // Обращение к документу в Firestore и обновление поля 'name'
      await fireStore
          .collection(collectionPath)
          .doc(docId) // Используйте идентификатор документа папки
          .delete();

      // Если обновление в Firestore прошло успешно, обновляем имя в локальном списке
      setState(() {
        list.removeAt(index);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to delete item: $e'),
      ));
    }
  }

  bool _isFetchProjectDataLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(projectName),
        bottom: TabBar(
          controller: projectPageTabController,
          tabs: const [
            Tab(text: 'APIs', icon: Icon(Icons.api)),
            Tab(text: 'Test Cases', icon: Icon(Icons.bug_report)),
          ],
        ),
      ),
      body: TabBarView(
        controller: projectPageTabController,
        children: [
          Row(
            children: [
              if (_isApiListVisible)
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(8, 8, 0, 0),
                              child: Text('API list count: ${paths.length}'),
                              // ElevatedButton(
                              //   child: const Text('Add API'),
                              //   onPressed: () {
                              //     selectedProjectIdNotifier.value == null
                              //         ? ScaffoldMessenger.of(context)
                              //             .showSnackBar(const SnackBar(
                              //                 content: Text(
                              //                     'Please select a project at first')))
                              //         : showDialog(
                              //             context: context,
                              //             builder: (BuildContext context) {
                              //               return AddApiDialog();
                              //             },
                              //           );
                              //  },
                              // ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                            child: PopupMenuButton<FilterOption>(
                              icon: const Icon(Icons.filter_list),
                              onSelected: (FilterOption result) {
                                selectedProjectIdNotifier.value == null
                                    ? ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(
                                            content: Text(
                                                'Please select a project at first')))
                                    : currentFilter.value = result;
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
                      selectedProjectIdNotifier.value == null
                          ? const Expanded(
                              child: Center(child: Text('Select a project')))
                          : ValueListenableBuilder<FilterOption?>(
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
                                            api.method.name.toString() ==
                                            "POST")
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
                                            api.method.name.toString() ==
                                            "DELETE")
                                        .toList();
                                    break;
                                  case FilterOption.getByMethodPATCH:
                                    filterEnabled = true;
                                    filteredApis = filteredApis
                                        .where((api) =>
                                            api.method.name.toString() ==
                                            "PATCH")
                                        .toList();
                                    break;
                                  case FilterOption.getByMethodOPTIONS:
                                    filterEnabled = true;
                                    filteredApis = filteredApis
                                        .where((api) =>
                                            api.method.name.toString() ==
                                            "OPTIONS")
                                        .toList();
                                    break;
                                  case FilterOption.getByMethodHEAD:
                                    filterEnabled = true;
                                    filteredApis = filteredApis
                                        .where((api) =>
                                            api.method.name.toString() ==
                                            "HEAD")
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
                                    filteredApis.sort((a, b) => a.status.index
                                        .compareTo(b.status.index));
                                    break;
                                  default:
                                    filterEnabled = false;
                                    break;
                                }
                                // Возвращаем отфильтрованный и отсортированный список
                                return ValueListenableBuilder<String?>(
                                    valueListenable: selectedProjectIdNotifier,
                                    builder:
                                        (context, selectedProjectId, child) {
                                      if (selectedProjectId != null && updateProjectPage && !_isFetchProjectDataLoading) {
                                          fetchProjectData(); // Асинхронно загружаем данные
                                          // Центрирование CircularProgressIndicator
                                          return const Expanded(
                                            child: Center(
                                              child: CircularProgressIndicator(),
                                            ),
                                          );
                                      }
                                      // Возвращаем список API, когда данные доступны
                                      return !filterEnabled
                                          ? Expanded(
                                              child: ListView.builder(
                                                itemCount:
                                                    taggedApis.keys.length,
                                                itemBuilder: (context, index) {
                                                  String tag = taggedApis.keys
                                                      .elementAt(index);
                                                  List<PathObject> apis =
                                                      taggedApis[tag]!;

                                                  return ExpansionTile(
                                                    title: Text(tag),
                                                    children: apis
                                                        .map((api) => ListTile(
                                                              trailing: api
                                                                          .status ==
                                                                      ApiStatus
                                                                          .done
                                                                  ? const Icon(
                                                                      Icons
                                                                          .check)
                                                                  : api.status ==
                                                                          ApiStatus
                                                                              .notDone
                                                                      ? const Icon(
                                                                          Icons
                                                                              .not_interested)
                                                                      : null,
                                                              title: Text(
                                                                  '${api.method.name} ${api.endpoint}'),
                                                              onTap: () =>
                                                                  setState(() {
                                                                // Находим индекс api в общем списке paths
                                                                int apiIndex = paths.indexWhere((path) =>
                                                                    path.method ==
                                                                        api
                                                                            .method &&
                                                                    path.endpoint ==
                                                                        api.endpoint);
                                                                // Обновляем selectedApiIndex если объект найден
                                                                if (apiIndex !=
                                                                    -1) {
                                                                  setState(() {
                                                                    selectedApiIndex =
                                                                        apiIndex;
                                                                    descriptionController
                                                                        .text = paths[
                                                                            apiIndex]
                                                                        .description;
                                                                  });
                                                                }
                                                              }),
                                                            ))
                                                        .toList(),
                                                  );
                                                },
                                              ),
                                            )
                                          : Expanded(
                                              child: ListView.builder(
                                                itemCount: filteredApis.length,
                                                itemBuilder: (context, index) {
                                                  PathObject api =
                                                      filteredApis[index];
                                                  return ListTile(
                                                    trailing: api.status ==
                                                            ApiStatus.done
                                                        ? const Icon(
                                                            Icons.check)
                                                        : api.status ==
                                                                ApiStatus
                                                                    .notDone
                                                            ? const Icon(Icons
                                                                .not_interested)
                                                            : null,
                                                    title: Text(
                                                        '${api.method.name} ${api.endpoint}'),
                                                    onTap: () => setState(() {
                                                      // Находим индекс api в общем списке paths
                                                      int apiIndex = paths
                                                          .indexWhere((path) =>
                                                              path.method ==
                                                                  api.method &&
                                                              path.endpoint ==
                                                                  api.endpoint);
                                                      // Обновляем selectedApiIndex если объект найден
                                                      if (apiIndex != -1) {
                                                        setState(() {
                                                          selectedApiIndex =
                                                              apiIndex;
                                                        });
                                                      }
                                                    }),
                                                  );
                                                },
                                              ),
                                            );
                                    });
                              },
                            ),
                    ],
                  ),
                ),
              if (_isApiListVisible) const VerticalDivider(width: 1),
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: Icon(_isApiListVisible
                      ? Icons.arrow_back_ios_new
                      : Icons.arrow_forward_ios_outlined),
                  onPressed: () {
                    setState(() {
                      _isApiListVisible = !_isApiListVisible;
                    });
                  },
                ),
              ),
              Expanded(
                flex: 5,
                child: selectedProjectIdNotifier.value == null
                    ? const Center(
                        child: Text(
                            'Please select a project to show this content'))
                    : selectedApiIndex == -1
                        ? const Center(
                            child: Text(
                                'Select an object from list to view details'))
                        : ApiDetailPage(api: paths[selectedApiIndex]),
              ),
            ],
          ),
          Row(
            children: [
              if (_isCaseListVisible)
                ValueListenableBuilder<String>(
                    valueListenable: testCaseListCurrent,
                    builder: (context, value, child) {
                  if(value == 'folder') { return
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                                child: ElevatedButton(
                                  child: const Text('Add Folder'),
                                  onPressed: () {
                                    selectedProjectIdNotifier.value == null
                                        ? ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(
                                        content: Text(
                                            'Please select a project at first')))
                                        : isFolderEditing
                                        ? ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(
                                        content: Text(
                                            'Please finish editing')))
                                        : showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              // Создаем контроллер для текстового поля
                                              TextEditingController nameController = TextEditingController();

                                              // Возвращаем AlertDialog
                                              return AlertDialog(
                                                title: const Text('Add New Folder'),
                                                content: TextField(
                                                  controller: nameController,
                                                  decoration: const InputDecoration(
                                                      hintText: "Enter folder name".tr()),
                                                  autofocus: true,
                                                ),
                                                actions: <Widget>[
                                                  TextButton(
                                                    child: const Text('Cancel'),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop(); // Закрыть диалог без сохранения
                                                    },
                                                  ),
                                                  TextButton(
                                                    child: const Text('Add'),
                                                    onPressed: () async {
                                                      final folderName = nameController
                                                          .text;

                                                      // Проверяем, пустое ли имя папки
                                                      if (folderName.isEmpty) {
                                                        ScaffoldMessenger.of(context)
                                                            .showSnackBar(
                                                            const SnackBar(
                                                              content: Text(
                                                                  'Folder name cannot be empty'),
                                                            ));
                                                        // Проверяем, содержится ли уже такое имя в списке
                                                      } else if (testCaseFolders.any((
                                                          folder) =>
                                                      folder.name == folderName)) {
                                                        ScaffoldMessenger.of(context)
                                                            .showSnackBar(
                                                            const SnackBar(
                                                              content: Text(
                                                                  'Folder name needs to be unique'),
                                                            ));
                                                      } else {
                                                        // Добавление новой папки в список
                                                        try {
                                                          final docRef = await fireStore
                                                              .collection(
                                                              'users/${currentUser
                                                                  ?.uid}/APIs/${selectedProjectIdNotifier
                                                                  .value}/testcasefolders')
                                                              .add({
                                                            'title': folderName
                                                          });
                                                          setState(() {
                                                            testCaseFolders.add(
                                                                Folder(
                                                                    name: folderName,
                                                                    docId: docRef
                                                                        .id));
                                                          });
                                                        } catch (e) {
                                                          ScaffoldMessenger.of(
                                                              context).showSnackBar(
                                                              SnackBar(
                                                                content: Text(
                                                                    'Error with adding a folder: $e'),
                                                              ));
                                                        }
                                                        Navigator.of(context)
                                                            .pop(); // Закрыть диалог после сохранения
                                                      }
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                        selectedProjectIdNotifier.value == null
                            ? const Expanded(
                            child: Center(child: Text('Select a project')))
                            : ValueListenableBuilder<String?>(
                            valueListenable: selectedProjectIdNotifier,
                            builder: (context, selectedProjectId, child) {
                              if (selectedProjectId != null &&
                                  updateProjectPage) {
                                // Центрирование CircularProgressIndicator
                                return const Expanded(
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                              return Expanded(
                                child: ListView.builder(
                                  itemCount: testCaseFolders.length,
                                  itemBuilder: (context, index) {
                                    return FolderTile(
                                      index: index,
                                      folder: testCaseFolders[index],
                                      onRename: (newName) {
                                        renameItem(
                                            testCaseFolders[index].docId,
                                            'users/${currentUser
                                                ?.uid}/APIs/${selectedProjectIdNotifier
                                                .value}/testcasefolders',
                                            {'name': newName}, () {
                                          testCaseFolders[index].name = newName;
                                        }
                                        );
                                      },
                                      onDelete: () {
                                        deleteItem(
                                            testCaseFolders[index].docId,
                                            'users/${currentUser
                                                ?.uid}/APIs/${selectedProjectIdNotifier
                                                .value}/testcasefolders',
                                            testCaseFolders,
                                            index
                                        );
                                      },
                                    );
                                  },
                                ),
                              );
                            }),
                      ],
                    ),
                  );
                  } else {
                  return
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: IconButton(
                                icon: const Icon(Icons.arrow_back),
                                onPressed: () {
                                  setState(() {
                                    testCaseListCurrent.value = 'folder';
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(0, 8, 8, 0),
                                child: ElevatedButton(
                                  child: const Text('Add TestCase'),
                                  onPressed: () {
                                    selectedProjectIdNotifier.value == null
                                        ? ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(
                                        content: Text(
                                            'Please select a project at first')))
                                        : isFolderEditing
                                        ? ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(
                                        content: Text(
                                            'Please finish editing')))
                                        : showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        // Создаем контроллер для текстового поля
                                        TextEditingController nameController = TextEditingController();

                                        // Возвращаем AlertDialog
                                        return AlertDialog(
                                          title: const Text('Add New TestCase'),
                                          content: TextField(
                                            controller: nameController,
                                            decoration: const InputDecoration(
                                                hintText: "Enter testcase name".tr()),
                                            autofocus: true,
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              child: const Text('Cancel'),
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .pop(); // Закрыть диалог без сохранения
                                              },
                                            ),
                                            TextButton(
                                              child: const Text('Add'),
                                              onPressed: () async {
                                                final caseName = nameController.text;

                                                // Проверяем, пустое ли имя папки
                                                if (caseName.isEmpty) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                            'TestCase name cannot be empty'),
                                                      ));
                                                  // Проверяем, содержится ли уже такое имя в списке
                                                } else if (testCases.any((testcase) =>
                                                testcase.name == caseName)) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                            'TestCase name needs to be unique'),
                                                      ));
                                                } else {
                                                  // Добавление нового кейса в список
                                                  try {
                                                    final docRef = await fireStore
                                                        .collection(
                                                        'users/${currentUser?.uid}/APIs/${selectedProjectIdNotifier.value}/testcasefolders/${testCaseFolders[selectedTestFolderIndex].docId}/testcases')
                                                        .add({
                                                          'name': caseName
                                                        });
                                                    setState(() {
                                                      testCaseFolders[selectedTestFolderIndex].testCases.add(
                                                          TestCase(
                                                              name: caseName,
                                                              docId: docRef.id));
                                                    });
                                                  } catch (e) {
                                                    ScaffoldMessenger.of(
                                                        context).showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                              'Error with adding a testcase: $e'),
                                                        ));
                                                  }
                                                  Navigator.of(context).pop(); // Закрыть диалог после сохранения
                                                }
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                        selectedProjectIdNotifier.value == null
                            ? const Expanded(
                            child: Center(child: Text('Select a project')))
                            : ValueListenableBuilder<int>(
                            valueListenable: selectedTestCaseIndex,
                            builder: (context, selectedProjectId, child) {
                              return Expanded(
                                child: ListView.builder(
                                  itemCount: testCaseFolders[selectedTestFolderIndex].testCases.length,
                                  itemBuilder: (context, index) {
                                    return CaseTile(
                                      index: index,
                                      testCase: testCaseFolders[selectedTestFolderIndex].testCases[index],
                                      onRename: (newName) {
                                        renameItem(
                                              testCaseFolders[selectedTestFolderIndex]
                                                  .testCases[index].docId,
                                              'users/${currentUser?.uid}/APIs/${selectedProjectIdNotifier.value}/testcasefolders/${testCaseFolders[selectedTestFolderIndex].docId}/testcases',
                                              {'name': newName},
                                              () {
                                                testCaseFolders[selectedTestFolderIndex].testCases[index].name = newName;
                                              }
                                        );
                                      },
                                      onDelete: () {
                                        deleteItem(
                                            testCaseFolders[selectedTestFolderIndex]
                                                .testCases[index].docId,
                                                  'users/${currentUser?.uid}/APIs/${selectedProjectIdNotifier
                                                .value}/testcasefolders/${testCaseFolders[selectedTestFolderIndex]
                                                .docId}/testcases',
                                            testCaseFolders[selectedTestFolderIndex]
                                                .testCases,
                                            index
                                        );
                                        setState(() {
                                          selectedTestCaseIndex.value = -1;
                                        });
                                      },
                                    );
                                  },
                                ),
                              );
                            }),
                      ],
                    ),
                  );
                  }}),
              if (_isCaseListVisible) const VerticalDivider(width: 1),
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: Icon(_isCaseListVisible
                      ? Icons.arrow_back_ios_new
                      : Icons.arrow_forward_ios_outlined),
                  onPressed: () {
                    setState(() {
                      _isCaseListVisible = !_isCaseListVisible;
                    });
                  },
                ),
              ),
              Expanded(
                flex: 5,
                child: ValueListenableBuilder<int>(
                  valueListenable: selectedTestCaseIndex,
                  builder: (context, selectedProjectId, child) {
                    if(selectedProjectIdNotifier.value == null) {
                      return const Center(child: Text('Please select a project to show this content'));
                    } else if(selectedTestCaseIndex.value == -1) {
                      return const Center(child: Text('Select test case from list to view details'));
                    } else {

                      return TestCaseDetailPage(
                        key: ValueKey(testCases[selectedTestCaseIndex.value].docId),
                        testCase: testCases[selectedTestCaseIndex.value],
                      );
                    }
                  }
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class Folder {
  String name;
  final String docId; // Идентификатор документа в Firestore
  List<TestCase> testCases;

  Folder({required this.name, required this.docId, this.testCases = const []});
}

class FolderTile extends StatefulWidget {
  final Folder folder;
  final ValueChanged<String> onRename;
  final VoidCallback onDelete;
  final int index;

  const FolderTile({super.key,
    required this.folder,
    required this.onRename,
    required this.onDelete,
    required this.index,
  });

  @override
  _FolderTileState createState() => _FolderTileState();
}


class _FolderTileState extends State<FolderTile> {
  TextEditingController? _controller;
  late String _initialName;

  @override
  void initState() {
    super.initState();
    _initialName = widget.folder.name;
    _controller = TextEditingController(text: widget.folder.name);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _startEditing() {
    setState(() {
      isFolderEditing = true;
    });
  }

  String _getUniqueName(String newName) {
    final baseName = newName;
    int count = 1;

    while (testCaseFolders.any((folder) => folder.name == newName)) {
      newName = '$baseName($count)';
      count++;
    }
    return newName;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: isFolderEditing
          ? TextField(
              controller: _controller,
              autofocus: true,
              onEditingComplete: () {
                final newName = _controller!.text;
                if (newName.isEmpty) {
                  // Если поле ввода пустое, возвращаем исходное имя
                  _controller?.text = _initialName;
                } else {
                  // Проверяем, есть ли уже такое имя в списке
                  final uniqueName = _getUniqueName(newName);
                  widget.onRename(uniqueName);
                  _controller?.text = uniqueName; // Обновляем текст в TextField
                }
                FocusManager.instance.primaryFocus?.unfocus();
                setState(() {
                  isFolderEditing = false;
                });
              },
              onTapOutside: (event) {
                final newName = _controller!.text;
                if (newName.isEmpty) {
                  // Если поле ввода пустое, возвращаем исходное имя
                  _controller?.text = _initialName;
                } else {
                  // Проверяем, есть ли уже такое имя в списке
                  final uniqueName = _getUniqueName(newName);
                  widget.onRename(uniqueName);
                  _controller?.text = uniqueName; // Обновляем текст в TextField
                }
                FocusManager.instance.primaryFocus?.unfocus();
                setState(() {
                  isFolderEditing = false;
                });
              },
            )
          : Text(widget.folder.name),
      trailing: PopupMenuButton(
        onSelected: (value) {
          if (value == 'rename') {
            if (!isFolderEditing) {
              _startEditing();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Finish Rename operation at first')));
            }
          } else {
            widget.onDelete();
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'rename',
            child: Text('Rename Folder'),
          ),
          const PopupMenuItem(
            value: 'delete',
            child: Text('Delete Folder'),
          ),
        ],
      ),
      onTap: () {
        setState(() {
          selectedTestFolderIndex = widget.index; // Обновляем выбранный индекс папки
          testCaseListCurrent.value = 'testcase';
        });
      },
    );
  }
}

class TestCase {
  String name;
  List<String>? fetchedApisID;
  String? url;
  String? description;
  final String docId; // Идентификатор документа в Firestore

  TestCase({required this.name, this.fetchedApisID, this.url, this.description, required this.docId});
}

class CaseTile extends StatefulWidget {
  final TestCase testCase;
  final ValueChanged<String> onRename;
  final VoidCallback onDelete;
  final int index;

  const CaseTile({super.key,
    required this.testCase,
    required this.onRename,
    required this.onDelete,
    required this.index,
  });

  @override
  _CaseTileState createState() => _CaseTileState();
}


class _CaseTileState extends State<CaseTile> {
  TextEditingController? _controller;
  late String _initialName;

  @override
  void initState() {
    super.initState();
    _initialName = widget.testCase.name;
    _controller = TextEditingController(text: widget.testCase.name);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _startEditing() {
    setState(() {
      isFolderEditing = true;
    });
  }

  String _getUniqueName(String newName) {
    final baseName = newName;
    int count = 1;

    while (testCaseFolders.any((folder) => folder.name == newName)) {
      newName = '$baseName($count)';
      count++;
    }
    return newName;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: isTestCaseEditing
          ? TextField(
        controller: _controller,
        autofocus: true,
        onEditingComplete: () {
          final newName = _controller!.text;
          if (newName.isEmpty) {
            // Если поле ввода пустое, возвращаем исходное имя
            _controller?.text = _initialName;
          } else {
            // Проверяем, есть ли уже такое имя в списке
            final uniqueName = _getUniqueName(newName);
            widget.onRename(uniqueName);
            _controller?.text = uniqueName; // Обновляем текст в TextField
          }
          FocusManager.instance.primaryFocus?.unfocus();
          setState(() {
            isTestCaseEditing = false;
          });
        },
        onTapOutside: (event) {
          final newName = _controller!.text;
          if (newName.isEmpty) {
            // Если поле ввода пустое, возвращаем исходное имя
            _controller?.text = _initialName;
          } else {
            // Проверяем, есть ли уже такое имя в списке
            final uniqueName = _getUniqueName(newName);
            widget.onRename(uniqueName);
            _controller?.text = uniqueName; // Обновляем текст в TextField
          }
          FocusManager.instance.primaryFocus?.unfocus();
          setState(() {
            isTestCaseEditing = false;
          });
        },
      )
          : Text(widget.testCase.name),
      trailing: PopupMenuButton(
        onSelected: (value) {
          if (value == 'rename') {
            if (!isFolderEditing) {
              _startEditing();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Finish Rename operation at first')));
            }
          } else {
            widget.onDelete();
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'rename',
            child: Text('Rename TestCase'),
          ),
          const PopupMenuItem(
            value: 'delete',
            child: Text('Delete TestCase'),
          ),
        ],
      ),
      onTap: () {
        setState(() {
          selectedTestCaseIndex.value = widget.index; // Обновляем выбранный индекс папки
        });
      },
    );
  }
}
