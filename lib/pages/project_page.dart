import 'package:flutter/material.dart';

class ProjectPage extends StatefulWidget {
  final String projectName;
  final List<String> apis; // Список строковых данных API
  final List<String> testCases; // Список строковых данных Test Cases

  const ProjectPage({
    Key? key,
    required this.projectName,
    required this.apis,
    required this.testCases,
  }) : super(key: key);

  @override
  _ProjectPageState createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
            Tab(
              text: 'APIs',
              icon: Icon(Icons.api),
            ),
            Tab(
              text: 'Test Cases',
              icon: Icon(Icons.bug_report),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ListView.builder(
            itemCount: widget.apis.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(widget.apis[index]),
              );
            },
          ),
          ListView.builder(
            itemCount: widget.testCases.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(widget.testCases[index]),
              );
            },
          ),
        ],
      ),
    );
  }
}