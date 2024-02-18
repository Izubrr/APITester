import 'package:adaptive_navigation/adaptive_navigation.dart';
import 'package:flutter/material.dart';

class MainNavigationScaffold extends StatefulWidget {
  final int selectedIndex;

  const MainNavigationScaffold({
    required this.selectedIndex,
    Key? key,
  }) : super(key: key);

  @override
  _MainNavigationScaffoldState createState() => _MainNavigationScaffoldState();
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Card(
              child: ListTile(
                leading: Icon(Icons.notification_add),
                title: Text('Setting 1'),
                subtitle: Text('This is a setting'),
              ),
            ),
            Card(
              child: ListTile(
                leading: Icon(Icons.language),
                title: Text('Setting 2'),
                subtitle: Text('This is a setting'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MainNavigationScaffoldState extends State<MainNavigationScaffold>
    with TickerProviderStateMixin {
  late int currentPageIndex;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    currentPageIndex = widget.selectedIndex;
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AdaptiveNavigationScaffold(
        drawerFooter: ListTile(
          leading: Icon(Icons.settings, color: Colors.grey), // Значок кнопки
          title: Text('Settings', style: TextStyle(color: Colors.grey)), // Текст кнопки
          onTap: () {

          },
        ),
        drawerHeader: const Text(
          'MyApp',
          style: TextStyle(
            fontSize: 24, // Большой размер текста
            fontWeight: FontWeight.bold,
          ),
        ),
        selectedIndex: currentPageIndex,
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        destinations: const [
          AdaptiveScaffoldDestination(
            title: 'Projects',
            icon: Icons.book,
          ),
        ],
        body: <Widget>[
          /// Home page
          Scaffold(
            appBar: AppBar(
              title: const Text('Projects'),
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
              children: const [
                Center(child: Text('APIs Content')),
                Center(child: Text('Test Cases Content')),
              ],
            ),
          ),
        ][currentPageIndex],
      ),
    );
  }
}
