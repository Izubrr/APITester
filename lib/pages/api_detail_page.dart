import 'dart:convert';
import 'package:diplom/main.dart';
import 'package:diplom/pages/project_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';


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
    assert(refPath != null || map != null,
    'Must provide either a refPath or a map');
    assert(!(refPath != null && map != null),
    'Cannot provide both a refPath and a map');
    assert(refPath == null || parentMapId != null,
    'Must provide parentMapId if refPath is given');

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

  Future<Map<String, dynamic>> resolveRefsInMap(Map<String, dynamic> map,
      {String? mapId = ''}) async {
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
        var refPath = current.replaceAll('#/',
            'users/${currentUser?.uid}/APIs/${selectedProjectIdNotifier.value}/');
        List<String> refParts = refPath.split('/');

        // Корректируем для правильного пути и ID документа
        refPath = refParts.sublist(0, refParts.length - 2).join('/');
        String refDocId = refParts[refParts.length - 2];
        String refMapId = refParts.last;

        // Получаем ссылочный документ
        final collection =
        await fireStore.collection(refPath).doc(refDocId).get();
        final collectionData = collection.data();

        // Предполагаем, что данные ссылки вложены в документ
        Map<String, dynamic>? data =
        collectionData?[refMapId] as Map<String, dynamic>?;
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

  int findTestCaseIndex(String selectedCaseId) {
    for (int i = 0; i < testCases.length; i++) {
      if (testCases[i].docId == selectedCaseId) {
        return i;
      }
    }
    return -1; // Возвращаем -1, если не нашли соответствующий TestCase
  }

  int findFolderIndexByTestCase(TestCase targetTestCase) {
    // Перебираем все папки
    for (int i = 0; i < testCaseFolders.length; i++) {
      // Проверяем, содержит ли текущая папка целевой TestCase по docId
      if (testCaseFolders[i].testCases.any((testCase) => testCase.docId == targetTestCase.docId)) {
        return i; // Возвращаем индекс папки, если нашли соответствие
      }
    }
    return -1; // Возвращаем -1, если не нашли папку, содержащую TestCase
  }


  @override
  Widget build(BuildContext context) {
    List<TestCase>? relatedTestCases = testCases.where(
            (testCase) => testCase.fetchedApisID!.contains(widget.api.pathId)
    ).toList();

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final codeTheme = isDarkMode ? monokaiSublimeTheme : githubTheme;

    if (paths[selectedApiIndex].responses.isNotEmpty) {
      selectedResponseNotifier.value = paths[selectedApiIndex].responses.first;
    }

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
                                      .update({'description': descriptionController.text});

                                  // Обновление локальной копии после успешного обновления Firestore
                                  setState(() {
                                    paths[selectedApiIndex].description =
                                        descriptionController.text;
                                  });

                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Description updated successfully')));
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Error updating description: $e')));
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
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                        Text('Error updating status: $e')));
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
                                  String cacheKey =
                                      'schema-${selectedProjectIdNotifier.value}-$selectedApiIndex';

                                  // Проверяем, есть ли данные в кэше для текущего API
                                  String? cachedData = apiDataCache[cacheKey];
                                  if (cachedData != null) {
                                    // Если данные есть в кэше, возвращаем их, оборачивая в Future
                                    return cachedData;
                                  } else {
                                    // Если в кэше нет данных, загружаем их и сохраняем в кэш
                                    String newData = await fetchMapWithRefs(
                                        map: requestBodyCodes[
                                        paths[selectedApiIndex].pathId],
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
                  Expanded(
                    child:Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SizedBox(
                          height: 308,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Fetched TestCases',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 8.0,
                                  // Расстояние между чипами по горизонтали
                                  runSpacing: 4.0,
                                  // Расстояние между строками чипов
                                  children: List<Widget>.generate(
                                    relatedTestCases.length, (index) {
                                      String selectedCaseId;
                                      return ActionChip(
                                        label: Text(relatedTestCases[index].name),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10), // Скруглённые края
                                        ),
                                        onPressed: () {
                                          selectedCaseId = relatedTestCases[index].docId;

                                          testCaseListCurrent.value = 'testcase';
                                          selectedTestCaseIndex.value = findTestCaseIndex(selectedCaseId);
                                          selectedTestFolderIndex = findFolderIndexByTestCase(relatedTestCases[index]);
                                          projectPageTabController.animateTo(1);
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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
                      child: ValueListenableBuilder<String?>(
                          valueListenable: selectedResponseNotifier,
                          builder: (context, value, child) {
                            return SegmentedButton<String>(
                              segments:
                              paths[selectedApiIndex].responses.map((key) {
                                return ButtonSegment<String>(
                                  value: key,
                                  label: Text(key),
                                );
                              }).toList(),
                              selected: {selectedResponseNotifier.value},
                              onSelectionChanged: (newSelection) {
                                selectedResponseNotifier.value =
                                    newSelection.first;
                              },
                            );
                          }),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          child: ListTile(
                            title: const Text('Request Example'),
                            subtitle: SizedBox(
                              height: 300,
                              child: SingleChildScrollView(
                                child: FutureBuilder<String>(
                                  future: () async {
                                    // Ключ для кэширования, который комбинирует идентификатор проекта и индекс API
                                    String cacheKey =
                                        'requestExample-${selectedProjectIdNotifier.value}-$selectedApiIndex';

                                    // Проверяем, есть ли данные в кэше для текущего API
                                    String? cachedData = apiDataCache[cacheKey];
                                    if (cachedData != null) {
                                      // Если данные есть в кэше, возвращаем их, оборачивая в Future
                                      return cachedData;
                                    } else {
                                      // Если в кэше нет данных, загружаем их и сохраняем в кэш
                                      String newData = await fetchMapWithRefs(
                                          map: requestBodyCodes[
                                          paths[selectedApiIndex].pathId],
                                          requestMapId: 'examples');
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
                                        'There is no Request Example')
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
                        child: ValueListenableBuilder<String?>(
                            valueListenable: selectedResponseNotifier,
                            builder: (context, value, child) {
                              return Card(
                                child: ListTile(
                                  title:
                                  const SelectableText('Response Example'),
                                  subtitle: SizedBox(
                                    height: 300,
                                    child: SingleChildScrollView(
                                      child: FutureBuilder<String>(
                                        future: () async {
                                          // Ключ для кэширования, который комбинирует идентификатор проекта и индекс API
                                          String cacheKey =
                                              'responseExample-${selectedProjectIdNotifier.value}-$selectedApiIndex-$selectedResponseNotifier.value';
                                          String? cacheResponseCode;

                                          // Проверяем, есть ли данные в кэше для текущего API
                                          String? cachedData =
                                          apiDataCache[cacheKey];
                                          if (cachedData != null) {
                                            // Если данные есть в кэше, возвращаем их, оборачивая в Future
                                            return cachedData;
                                          } else {
                                            // Если в кэше нет данных, загружаем их и сохраняем в кэш
                                            Map<String, dynamic> map =
                                            responseCodes[
                                            paths[selectedApiIndex]
                                                .pathId];
                                            String newData =
                                            await fetchMapWithRefs(
                                                map: map[
                                                selectedResponseNotifier
                                                    .value]);
                                            apiDataCache[cacheKey] = newData;
                                            cacheResponseCode ==
                                                selectedResponseNotifier.value;
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
                                                  const EdgeInsets.all(
                                                      12),
                                                  textStyle:
                                                  const TextStyle(
                                                    fontFamily: 'monospace',
                                                    fontSize: 14,
                                                  ),
                                                );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
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