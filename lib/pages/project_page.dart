import 'dart:convert';
import 'dart:math';
import 'package:diplom/main.dart';
import 'package:diplom/widgets/request-response_example.dart';
import 'package:flutter/material.dart';
import 'package:diplom/widgets/addapi_dialog.dart';
import 'package:flutter/src/foundation/change_notifier.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';

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
      this.responses = const []});
}

Map<String, dynamic> testCases = {'1': "Tom", '2': "Bob", '3': "Sam"};

Map<String, String> apiDataCache = {};

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

  Future<String> fetchMapWithRefs({
    String? refPath,
    Map<String, dynamic>? map,
    String? parentMapId,
    String? requestMapId,
  }) async {
    assert(refPath != null || map != null, 'Must provide either a refPath or a map');
    assert(!(refPath != null && map != null), 'Cannot provide both a refPath and a map');
    assert(refPath == null || parentMapId != null, 'Must provide parentMapId if refPath is given');

    Map<String, dynamic>? requestMap;

    // Если предоставлен refPath, загрузите Map из Firestore
    if (refPath != null) {
      var operationDoc = await fireStore.doc(refPath).get();
      var operationData = operationDoc.data();
      requestMap = operationData?[parentMapId] as Map<String, dynamic>?;
    } else {
      // Если предоставлен Map, используйте его напрямую
      requestMap = map;
    }

    if (requestMap == null) {
      throw Exception('Map not found at the given path or map is null');
    }

    var resultMap = await resolveRefsInMap(requestMap, mapId: requestMapId);
    var result = const JsonEncoder.withIndent('  ').convert(resultMap);
    return result;
  }


  Future<Map<String, dynamic>> resolveRefsInMap(Map<String, dynamic> map, {String? mapId = ''}) async {
    Future<dynamic> resolve(dynamic current) async {
      if (current is Map<String, dynamic>) {
        Map<String, dynamic> resolvedMap = {};
        for (var key in current.keys) {
          var value = current[key];
          resolvedMap[key] = await resolve(value);
        }
        return resolvedMap;
      } else if (current is List) {
        List<dynamic> resolvedList = [];
        for (var item in current) {
          resolvedList.add(await resolve(item));
        }
        return resolvedList as dynamic;
      } else if (current is String && current.startsWith('#/')) {
        // Обработка $ref ссылок, предполагается, что строка начинается с '#/'
        var refPath = current.replaceAll('#/', 'users/${currentUser?.uid}/APIs/${selectedProjectIdNotifier.value}/');
        List<String> refParts = refPath.split('/');

        // Корректируем для правильного пути и ID документа
        refPath = refParts.sublist(0, refParts.length - 2).join('/');
        String refDocId = refParts[refParts.length - 2];
        String refMapId = refParts.last;

        // Получаем ссылочный документ
        final collection = await fireStore.collection(refPath).doc(refDocId).get();
        final collectionData = collection.data();

        // Предполагаем, что данные ссылки вложены в документ
        Map<String, dynamic>? data = collectionData?[refMapId] as Map<String, dynamic>?;
        if (data != null) {
          return await resolve(data);
        } else {
          return current; // Возвращаем текущую строку, если ссылка не разрешена
        }
      } else {
        return current; // Возвращаем текущее значение без изменений, если оно не Map и не List
      }
    }

    var result = await resolve(map);
    if (mapId != null && mapId.isNotEmpty) {
      result = extractValueByKey(result, mapId);
    }
    return result as Map<String, dynamic>;
  }


  dynamic extractValueByKey(Map<String, dynamic> map, String key) {
    dynamic value;
    void searchMap(Map<String, dynamic> currentMap) {
      if (currentMap.containsKey(key)) {
        value = currentMap[key];
        return;
      }
      for (var entry in currentMap.entries) {
        if (entry.value is Map<String, dynamic>) {
          searchMap(entry.value);
          if (value != null) return;
        }
      }
    }

    searchMap(map);
    return value;
  }

  late String selectedResponse;

  @override
  void initState() {
    super.initState();
    if (paths[selectedApiIndex].responses.isNotEmpty) {
      selectedResponse = paths[selectedApiIndex].responses.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final codeTheme = isDarkMode ? monokaiSublimeTheme : githubTheme;
    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 7),
                        child: SelectableText('${widget.api.method.name}  ',
                            style: Theme.of(context).textTheme.titleLarge),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 7),
                        child: SelectableText(widget.api.endpoint,
                            style: Theme.of(context).textTheme.titleMedium),
                      ),
                      const VerticalDivider(),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
                          child: TextField(
                            controller: descriptionController,
                            onEditingComplete: () async {
                              // Проверка на валидность выбранного индекса API
                              if (selectedApiIndex >= 0 &&
                                  selectedApiIndex < paths.length) {
                                try {
                                  // Обновление поля description для конкретного API в Firestore
                                  await fireStore
                                      .collection(
                                          'users/${currentUser?.uid}/APIs/${selectedProjectIdNotifier.value}/paths/${paths[selectedApiIndex].pathId}/operations')
                                      .doc(paths[selectedApiIndex]
                                          .operationId) // ID документа API
                                      .update({
                                    'description': descriptionController.text
                                  });

                                  // Обновление локальной копии после успешного обновления Firestore
                                  setState(() {
                                    paths[selectedApiIndex].description =
                                        descriptionController.text;
                                  });

                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Description updated successfully')));
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating description: $e')));
                                }
                              }
                            },
                            decoration: const InputDecoration(
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
                          value: paths[selectedApiIndex].status,
                          onChanged: (ApiStatus? newValue) async {
                            // Проверка на валидность выбранного индекса API
                            if (paths[selectedApiIndex].status != newValue) {
                              try {
                                // Обновление поля description для конкретного API в Firestore
                                await fireStore
                                    .collection(
                                        'users/${currentUser?.uid}/APIs/${selectedProjectIdNotifier.value}/paths/${paths[selectedApiIndex].pathId}/operations')
                                    .doc(paths[selectedApiIndex]
                                        .operationId) // ID документа API
                                    .update({
                                  'status': ApiStatusExtension.convertToString(
                                      newValue!)
                                });

                                // Обновление локальной копии после успешного обновления Firestore
                                setState(() {
                                  paths[selectedApiIndex].status = newValue;
                                });
                                //selectedProjectIdNotifier.notifyListeners();
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating status: $e')));
                              }
                            }
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
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: ListTile(
                        title: const Text('JSON Scheme'),
                        subtitle: SizedBox(
                          height: 300,
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: FutureBuilder<String>(
                                future: () async {
                                  // Ключ для кэширования, который комбинирует идентификатор проекта и индекс API
                                  String cacheKey = 'schema-${selectedProjectIdNotifier.value}-$selectedApiIndex';

                                  // Проверяем, есть ли данные в кэше для текущего API
                                  String? cachedData = apiDataCache[cacheKey];
                                  if (cachedData != null) {
                                    // Если данные есть в кэше, возвращаем их, оборачивая в Future
                                    return cachedData;
                                  } else {
                                    // Если в кэше нет данных, загружаем их и сохраняем в кэш
                                    String newData = await fetchMapWithRefs(
                                        map: requestBodyCodes[paths[selectedApiIndex].pathId],
                                        requestMapId: 'schema');
                                    apiDataCache[cacheKey] = newData;
                                    return newData;
                                  }
                                }(),
                                builder: (context, snapshot) {
                                  return snapshot.connectionState ==
                                          ConnectionState.waiting
                                      ? const CircularProgressIndicator()
                                      : !snapshot.hasData
                                          ? const Text(
                                              'There is no JSON Scheme')
                                          : HighlightView(
                                              snapshot.data!,
                                              language: 'json',
                                              theme: codeTheme,
                                              padding: const EdgeInsets.all(12),
                                              textStyle: const TextStyle(
                                                fontFamily: 'monospace',
                                                fontSize: 14,
                                              ),
                                            );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Card(
                      child: ListTile(
                        title: Text('Linked Test Cases'),
                        subtitle: SizedBox(
                            height: 300,
                            child:
                                Text('Left - light theme; Right - dark theme')),
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: SegmentedButton<String>(
                        segments: paths[selectedApiIndex].responses.map((key) {
                          return ButtonSegment<String>(
                            value: key,
                            label: Text(key),
                          );
                        }).toList(),
                        selected: {selectedResponse},
                        onSelectionChanged: (newSelection) {
                          setState(() {
                            selectedResponse = newSelection.first;
                          });
                        },
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          child: ListTile(
                            title: const Text('Request Sample'),
                            subtitle: SizedBox(
                              height: 300,
                              child: SingleChildScrollView(
                                child: FutureBuilder<String>(
                                  future: () async {
                                    // Ключ для кэширования, который комбинирует идентификатор проекта и индекс API
                                    String cacheKey = 'requestExample-${selectedProjectIdNotifier.value}-$selectedApiIndex';

                                    // Проверяем, есть ли данные в кэше для текущего API
                                    String? cachedData =
                                        apiDataCache[cacheKey];
                                    if (cachedData != null) {
                                      // Если данные есть в кэше, возвращаем их, оборачивая в Future
                                      return cachedData;
                                    } else {
                                      // Если в кэше нет данных, загружаем их и сохраняем в кэш
                                      String newData = await fetchMapWithRefs(
                                          map: requestBodyCodes[paths[selectedApiIndex].pathId],
                                          requestMapId: 'schema');
                                      apiDataCache[cacheKey] = newData;
                                      return newData;
                                    }
                                  }(),
                                  builder: (context, snapshot) {
                                    return snapshot.connectionState ==
                                            ConnectionState.waiting
                                        ? const CircularProgressIndicator()
                                        : !snapshot.hasData
                                            ? const Text(
                                                'There is no Request Sample')
                                            : HighlightView(
                                                snapshot.data!,
                                                language: 'json',
                                                theme: codeTheme,
                                                padding:
                                                    const EdgeInsets.all(12),
                                                textStyle: const TextStyle(
                                                  fontFamily: 'monospace',
                                                  fontSize: 14,
                                                ),
                                              );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Card(
                          child: ListTile(
                            title: const SelectableText('Response Example'),
                            subtitle: SizedBox(
                              height: 300,
                              child: SingleChildScrollView(
                                child: FutureBuilder<String>(
                                  future: () async {
                                    // Ключ для кэширования, который комбинирует идентификатор проекта и индекс API
                                    String cacheKey = 'responseExample-${selectedProjectIdNotifier.value}-$selectedApiIndex-$selectedResponse';
                                    String? cacheResponseCode;

                                    // Проверяем, есть ли данные в кэше для текущего API
                                    String? cachedData = apiDataCache[cacheKey];
                                    if (cachedData != null && cacheResponseCode == selectedResponse) {
                                      // Если данные есть в кэше, возвращаем их, оборачивая в Future
                                      return cachedData;
                                    } else {
                                      // Если в кэше нет данных, загружаем их и сохраняем в кэш
                                      Map<String, dynamic> map = responseCodes[paths[selectedApiIndex].pathId];
                                      String newData = await fetchMapWithRefs(
                                          map: map[selectedResponse]);
                                      apiDataCache[cacheKey] = newData;
                                      cacheResponseCode == selectedResponse;
                                      return newData;
                                    }
                                  }(),
                                  builder: (context, snapshot) {
                                    return snapshot.connectionState ==
                                            ConnectionState.waiting
                                        ? const CircularProgressIndicator()
                                        : !snapshot.hasData
                                            ? const Text(
                                                'There is no Response Example')
                                            : HighlightView(
                                                snapshot.data!,
                                                language: 'json',
                                                theme: codeTheme,
                                                padding:
                                                    const EdgeInsets.all(12),
                                                textStyle: const TextStyle(
                                                  fontFamily: 'monospace',
                                                  fontSize: 14,
                                                ),
                                              );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
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

String projectName = 'Project Name';
List<PathObject> paths = [];
bool updateProjectPage = false;
bool filterEnabled = false;
late int apiIndex;
int selectedApiIndex = -1;
Map<String, dynamic> responseCodes = {};
Map<String, dynamic> requestBodyCodes = {};

class _ProjectPageState extends State<ProjectPage>
    with SingleTickerProviderStateMixin {
  void _onSelectedProjectIdChange() {
    // Устанавливаем selectedApiIndex в -1 при каждом изменении selectedProjectId
    setState(() {
      selectedApiIndex = -1;
      paths = [];
      apiDataCache = {};
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    selectedProjectIdNotifier.addListener(_onSelectedProjectIdChange);
  }

  var pathsCollection;
  var operationsCollection;

  Map<String, List<PathObject>> taggedApis = {};

  Future<void> fetchProjectData() async {
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

    Map<String, List<PathObject>> tempTaggedApis = {};
    List<PathObject> apisWithoutTag = [];

    final pathsCollection = await apiRef.collection('paths').get();
    for (var pathDoc in pathsCollection.docs) {
      final pathData = pathDoc.data();
      final operationsCollection = await apiRef.collection('paths/${pathDoc.id}/operations').get();
      for (var operationDoc in operationsCollection.docs) {
        var operationData = operationDoc.data();

        var tags = operationData['tags'] ?? [];
        var description = operationData['description'];
        var status = operationData['status'] ?? 'inProgress';
        Map<String, dynamic> responses = operationData['responses'] ?? {};
        Map<String, dynamic> requestBody = operationData['requestBody']?? {};

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
    });
  }

  late TabController _tabController;

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
                                  selectedProjectIdNotifier.value == null
                                      ? ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a project at first')))
                                      : showDialog(
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
                                      if (selectedProjectId != null &&
                                          updateProjectPage) {
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
                                                              trailing: api.status ==
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
                                                      apiIndex = paths
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
              if (_isListVisible) const VerticalDivider(width: 1),
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: Icon(_isListVisible
                      ? Icons.arrow_back_ios_new
                      : Icons.arrow_forward_ios_outlined),
                  onPressed: () {
                    setState(() {
                      _isListVisible = !_isListVisible;
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
