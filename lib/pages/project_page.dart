import 'dart:math';

import 'package:flutter/material.dart';
import 'package:diplom/widgets/addapi_dialog.dart';

// Определение перечисления ApiStatus
enum ApiStatus {
  inProgress,
  done,
  notDone,
}

enum ApiMethod {
  GET,
  POST,
  PUT,
  DELETE,
}

class Api {
  final ApiMethod method;
  final String endpoint;
  ApiStatus status;

  Api({
    required this.method,
    required this.endpoint,
    ApiStatus? status,
  }) : status = status ?? ApiStatus.notDone; // Установка значения по умолчанию
}

// Страница деталей для API
class ApiDetailPage extends StatefulWidget {
  final Api api;

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
                  Text('${widget.api.method}  ',
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
                          child: Text('Not Done'),
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
  final String projectName;
  final List<Api> apis;
  final List<String> testCases;

  const ProjectPage({
    Key? key,
    required this.projectName,
    required this.apis,
    required this.testCases,
  }) : super(key: key);

  @override
  _ProjectPageState createState() => _ProjectPageState();
}

enum FilterOption {
  getByMethodGET,
  getByMethodPOST,
  getByMethodPUT,
  getByMethodDELETE,
  orderByEndpoint,
  orderByStatus,
}

class _ProjectPageState extends State<ProjectPage>
    with SingleTickerProviderStateMixin {
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

  void sortApisByEndpoint(List<Api> apis) {
    apis.sort((a, b) => naturalSortComparator(a.endpoint, b.endpoint));
  }

  bool _isListVisible = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.projectName),
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
                                currentFilter.value = result;
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
                                  value: FilterOption.orderByEndpoint,
                                  child: Text('Endpoint'),
                                ),
                                const PopupMenuItem<FilterOption>(
                                  value: FilterOption.orderByStatus,
                                  child: Text('Status'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      Expanded(
                        child: ValueListenableBuilder<FilterOption?>(
                          valueListenable: currentFilter,
                          builder: (context, value, child) {
                            List<Api> filteredApis = widget.apis;
                            switch (value) {
                              case FilterOption.getByMethodGET:
                                filteredApis = filteredApis
                                    .where((api) =>
                                        api.method.name.toString() == "GET")
                                    .toList();
                                break;
                              case FilterOption.getByMethodPOST:
                                filteredApis = filteredApis
                                    .where((api) =>
                                        api.method.name.toString() == "POST")
                                    .toList();
                                break;
                              case FilterOption.getByMethodPUT:
                                filteredApis = filteredApis
                                    .where((api) =>
                                        api.method.name.toString() == "PUT")
                                    .toList();
                                break;
                              case FilterOption.getByMethodDELETE:
                                filteredApis = filteredApis
                                    .where((api) =>
                                        api.method.name.toString() == "DELETE")
                                    .toList();
                                break;
                              case FilterOption.orderByEndpoint:
                                sortApisByEndpoint(filteredApis);
                                break;
                              case FilterOption.orderByStatus:
                                filteredApis.sort((a, b) =>
                                    a.status.index.compareTo(b.status.index));
                                break;
                              default:
                                break;
                            }

                            // Возвращаем отфильтрованный и отсортированный список
                            return ListView.builder(
                              itemCount: filteredApis.length,
                              itemBuilder: (context, index) {
                                Api api = filteredApis[index];
                                return ListTile(
                                  trailing: api.status == ApiStatus.done
                                      ? const Icon(Icons.check)
                                      : api.status == ApiStatus.notDone
                                          ? const Icon(Icons.not_interested)
                                          : null,
                                  title: Text(
                                      '${api.method.name} ${api.endpoint}'),
                                  onTap: () => setState(() {
                                    selectedApiIndex = index;
                                  }),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const VerticalDivider(width: 1),
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
                  child: selectedApiIndex == -1
                      ? const Center(
                          child: Text(
                              'Select an object from list to view details'))
                      : ApiDetailPage(api: widget.apis[selectedApiIndex]),
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
                            icon: const Icon(Icons.menu),
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
                        itemCount: widget.testCases.length,
                        itemBuilder: (context, index) {
                          String testCase = widget.testCases[index];
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
                          testCase: widget.testCases[selectedTestCaseIndex])),
            ],
          ),
        ],
      ),
    );
  }
}
