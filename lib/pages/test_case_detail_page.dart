import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diplom/pages/project_page.dart';
import 'package:flutter/material.dart';

import '../main.dart';


// Страница деталей для API
class TestCaseDetailPage extends StatefulWidget {
  final TestCase testCase;

  const TestCaseDetailPage({Key? key, required this.testCase}) : super(key: key);

  @override
  State<TestCaseDetailPage> createState() => _TestCaseDetailPageState();
}

class _TestCaseDetailPageState extends State<TestCaseDetailPage> with SingleTickerProviderStateMixin {
  TextEditingController nameController = TextEditingController();
  TextEditingController urlController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  String? selectedPathEndPoint;
  String? selectedPathMethod;

  List<String> fetchedApis = [];
  List<String> tempFetchedApisID = [];

  Iterable<Widget> getPaths(SearchController controller) {
    return paths
        .map(
          (PathObject filteredPath) => ListTile(
            leading: Text(filteredPath.method.name),
            title: Text(filteredPath.endpoint),
            trailing: const Icon(Icons.add),
            onTap: () {
              _handleSelection(filteredPath);
            },
          ),
    );
  }

  Iterable<Widget> getSuggestions(SearchController controller) {
    final String input = controller.value.text;
    return paths
        .where((PathObject path) => path.endpoint.contains(input))
        .map(
          (PathObject filteredPath) => ListTile(
            leading: Text(filteredPath.method.name),
            title: Text(filteredPath.endpoint),
              trailing: const Icon(Icons.add),
            onTap: () {
              _handleSelection(filteredPath);
            },
          ),
    );
  }

  void _handleSelection(PathObject selectedPath) {
    setState(() {
      selectedPathEndPoint = selectedPath.endpoint;
      selectedPathMethod = selectedPath.method.name;

      if (!fetchedApis.contains('$selectedPathMethod $selectedPathEndPoint')) {
        fetchedApis.add('$selectedPathMethod $selectedPathEndPoint');
        tempFetchedApisID.add(selectedPath.pathId);
      }
    });
  }

  @override
  void initState() {
    nameController.text = widget.testCase.name;
    urlController.text = widget.testCase.url ?? '';
    descriptionController.text = widget.testCase.description ?? '';
    tempFetchedApisID = widget.testCase.fetchedApisID ?? [];

    //loadTestCaseData();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Once the animation is completed, switch back to the button after a short delay
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            setState(() {
              showCheckmark = false;
            });
          }
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  late AnimationController _controller;
  bool showCheckmark = false;

  @override
  Widget build(BuildContext context) {
    //nameController = TextEditingController(text: widget.testCase.name);
    return StreamBuilder<Object>(
      stream: null,
      builder: (context, snapshot) {
        //loadTestCaseData();
        return Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  // Выравнивание по правому краю
                  children: [
                    Text('Selected TestCase:   ', style: Theme.of(context).textTheme.titleLarge),
                    Expanded(
                      child: TextField(
                        controller: nameController,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    SearchAnchor.bar(
                      barHintText: 'Search API',
                      suggestionsBuilder:
                          (BuildContext context, SearchController controller) {
                        if (controller.text.isEmpty) {
                          return getPaths(controller);
                        }
                        return getSuggestions(controller);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Fetched APIs',
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
                            children: List<Widget>.generate(tempFetchedApisID.length, (index) {
                              final matchingPath = paths.firstWhere(
                                      (path) => path.pathId == tempFetchedApisID[index]); // Handling no match case
                              return Chip(
                                label: Text('${matchingPath.method.name} ${matchingPath.endpoint}'),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10), // Rounded corners
                                ),
                                onDeleted: () {
                                  setState(() {
                                    // Remove element from fetchedApisID by index
                                    tempFetchedApisID.removeAt(index);
                                  });
                                },
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: ListTile(
                    title: const Text(
                      'Description',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        const Text('TestCase URL from test managing system'),
                        TextField(
                          controller: urlController,
                          decoration: const InputDecoration(
                            icon: Icon(Icons.link),
                            hintText: 'Input url to TMS',
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text('Description of the testcase'),
                        TextField(
                          minLines: 1,
                          maxLines: 5,
                          keyboardType: TextInputType.multiline,
                          controller: descriptionController,
                          decoration: const InputDecoration(
                            icon: Icon(Icons.text_snippet_outlined),
                            hintText: 'Input Description',
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  // Выравнивание по правому краю
                  children: [
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () {
                        setState(() {
                          nameController =
                              TextEditingController(text: widget.testCase.name);
                          urlController = TextEditingController(text: '');
                          descriptionController = TextEditingController(text: '');
                          fetchedApis = [];
                          tempFetchedApisID = [];
                        });
                      },
                    ),
                    showCheckmark
                        ? const Icon(
                            Icons.check,
                            key: ValueKey('checkmark'),
                            color: Colors.green,
                            size: 32,
                          )
                        : FilledButton.icon(
                            key: const ValueKey('button'),
                            icon: const Icon(Icons.check),
                            label: const Text('Save Changes'),
                            onPressed: () {
                              setState(() {
                                showCheckmark = true;
                              });
                              setDataToTestCase();
                            },
                          ),
                  ],
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  void setDataToTestCase() async {
    try {
      Future.delayed(const Duration(milliseconds: 100), () async {
        await fireStore
            .collection(
            'users/${currentUser?.uid}/APIs/${selectedProjectIdNotifier.value}/testcasefolders/${testCaseFolders[selectedTestFolderIndex].docId}/testcases')
            .doc(widget.testCase.docId)
            .set({
              'name': nameController.text,
              'url': urlController.text,
              'description': descriptionController.text,
              'fetchedApisID': tempFetchedApisID
            }, SetOptions(merge: true));
        _controller.forward();
      });
    } catch (e) {
      ScaffoldMessenger.of(
          context).showSnackBar(
          SnackBar(
            content: Text(
                'Error with adding a testcase: $e'),
          ));
    }
  }
}
