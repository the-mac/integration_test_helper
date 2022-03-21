import 'package:example/preferences.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drawer_manager/drawer_manager.dart';

import 'hello.dart';
import 'counter.dart';
import 'languages.dart';
import 'the_mac.dart';

// clear && printf '\e[3J' && flutter run ; flutter clean

void main() {
  runApp(setupMainWidget());
}

Widget setupMainWidget() {
  return const MyApp();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DrawerManagerProvider>(
        create: (_) => DrawerManagerProvider(),
        child: MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(primarySwatch: Colors.blue),
          home: const MyHomePage(),
        ));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  String _getTitle(int index) {
      switch (index) {
        case 0: return 'Hello';
        case 1: return 'Languages';
        case 2: return 'Counter Sample';
        case 3: return 'Mobile Community';
        case 4: return 'Preferences';
        default: return '';
      }
  }

  Widget _getTitleWidget() {
    return Consumer<DrawerManagerProvider>(builder: (context, dmObj, _) {
      return Text(
        _getTitle(dmObj.drawer),
        key: const Key('app-bar-text')
      );
    });
  }

  @override
  Widget build(BuildContext context) {

    final drawerSelections = [
      const HelloPage(),
      LanguagesPage(),
      const CounterPage(),
      const TheMACPage(),
      PreferencesPage()
    ];
    
    final manager = Provider.of<DrawerManagerProvider>(context, listen: false);

    return Scaffold(
        appBar: AppBar(title: _getTitleWidget()),
        body: manager.body,
        drawer: DrawerManager(
          context,
          drawerElements: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Icon(
                  Icons.account_circle,
                  color: Colors.blueGrey,
                  size: 96,
                ),
              ),
            ),
            DrawerTile(
              key: const Key('drawer-hello'),
              context: context,
              leading: const Icon(Icons.hail_rounded),
              title: Text(_getTitle(0)),
              onTap: () async {
                // RUN A BACKEND Hello, Flutter OPERATION
              },
            ),
            DrawerTile(
              key: const Key('drawer-languages'),
              context: context,
              leading: const Icon(Icons.hail_rounded),
              title: Text(_getTitle(1)),
              onTap: () async {
                // RUN A BACKEND Hello, Flutter OPERATION
              },
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(),
            ),
            DrawerTile(
              key: const Key('drawer-counter'),
              context: context,
              leading: const Icon(Icons.calculate),
              title: Text(_getTitle(2)),
              onTap: () async {
                // RUN A BACKEND Counter OPERATION
              },
            ),
            DrawerTile(
              key: const Key('drawer-community'),
              context: context,
              leading: const Icon(Icons.plus_one),
              title: Text(_getTitle(3)),
              onTap: () async {
                // RUN A BACKEND Signup OPERATION
              },
            ),
            DrawerTile(
              key: const Key('drawer-preferences'),
              context: context,
              leading: const Icon(Icons.settings),
              title: Text(_getTitle(4)),
              onTap: () async {
                // RUN A BACKEND Preferences OPERATION
              },
            ),
          ],
          tileSelections: drawerSelections,
        ));
  }

  @override
  void dispose() {
    Prefs.clearPreferences();
    super.dispose();
  }
}
