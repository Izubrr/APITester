import 'package:flutter/material.dart';

// Определение перечисления ApiStatus
enum ApiStatus {
  notDone,
  done,
  inProgress,
}

class Api {
  final String method;
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
                        borderRadius: const BorderRadius.all(Radius.circular(12))),
                    child: DropdownButton<ApiStatus>(
                      focusColor: Colors.transparent,
                      isDense: true,
                      underline: Text(''),
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

class _ProjectPageState extends State<ProjectPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  int selectedApiIndex = -1;
  int selectedTestCaseIndex = -1;

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
                              child: const Text('Add API'),
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
                        itemCount: widget.apis.length,
                        itemBuilder: (context, index) {
                          Api api = widget.apis[index];
                          return ListTile(
                            trailing: api.status == ApiStatus.done ? const Icon(Icons.check) : api.status == ApiStatus.notDone ? const Icon(Icons.not_interested) : null,
                            title: Text('${api.method} ${api.endpoint}'),
                            onTap: () => setState(() {
                              selectedApiIndex = index;
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
                child: selectedApiIndex == -1
                    ? const Center(
                        child:
                            Text('Select an object from list to view details'))
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
