The Integration Test Helper has pre-configured methods that allow for faster test deployment for end to end (e2e) test coverage (using Android and iOS platform UIs).

<table border="0">
  <tr>
    <td><img width="140" src="https://raw.githubusercontent.com/the-mac/integration_test_helper/main/media/integration_test_0.png"></td>
    <td><img width="140" src="https://raw.githubusercontent.com/the-mac/integration_test_helper/main/media/integration_test_1.png"></td>
    <td><img width="140" src="https://raw.githubusercontent.com/the-mac/integration_test_helper/main/media/integration_test_2.png"></td>
    <td><img width="140" src="https://raw.githubusercontent.com/the-mac/integration_test_helper/main/media/integration_test_3.png"></td>
    <td><img width="140" src="https://raw.githubusercontent.com/the-mac/integration_test_helper/main/media/integration_test_helper.gif"></td>
  </tr>  
  <tr center>
    <td  align="center"><p>Open Drawer</p></td>
    <td  align="center"><p>Languages</p></td>
    <td  align="center"><p>Counter</p></td>
    <td  align="center"><p>The MAC</p></td>
    <td  align="center"><p>All Pages</p></td>
  </tr>   
</table>

## Features

The Integration Test Helper is built on top of [Flutter's Integration Tests](https://docs.flutter.dev/testing/integration-tests). Running End to End (e2e) tests can become bloated and unorganized code, and [lead to regressions](https://en.wikipedia.org/wiki/Software_regression) but with this helper, writing tests can be faster, modular and with [full test coverage](https://www.simform.com/blog/test-coverage/). This approach allows for a cleaner development experience, and [less regressions within your apps](https://www.gratasoftware.com/what-is-regression-in-software-development/).

[![Regression Testing](https://raw.githubusercontent.com/the-mac/integration_test_helper/main/media/integration_test_4.png)](https://youtu.be/0wHKVXbsppw)

Integration Test Helper (or the BaseIntegrationTest class) allows for black box fixture data testing. The fixtures currently support JSON data, and can be loaded from anywhere within the project folder. This data is typically initialized in the setupInitialData child implementation. The following is an example of how you can Black Box Test your ListViews, as well other types of Widgets:

```dart

class ScreenIntegrationTestGroups extends BaseIntegrationTest {

    late Map _languagesTestData;

    @override
    Future<void> setupInitialData() async {

        _languagesTestData = await loadFixtureJSON('assets/fixtures/languages.json') as Map;

        if (_languagesTestData.isEmpty) {
            throw 'No languages test data found';
        }

    }

    Future<void> validateTestDataAt(int itemIndex, { required String widgetSuffix, required String jsonKey }) async {
        var languageData = _languagesTestData['results'][itemIndex] as Map;
        var itemText = languageData[jsonKey] as String;
        await verifyListExactText(itemIndex, widgetPrefix: 'item', widgetSuffix: widgetSuffix, expectedText: itemText);
    }
        
    Future<void> testLanguagesFeature() async {
        
        // VIEW LANGUAGES PAGE
        await showLanguagesList();
        await verifyTextForKey('app-bar-text', 'Languages');

        await validateTestDataAt(0, widgetSuffix: 'name', jsonKey: 'name');
        await validateTestDataAt(1, widgetSuffix: 'name', jsonKey: 'name');

        // VIEW LANGUAGE Python PAGE
        await tapListItem(widgetPrefix: 'item', itemIndex: 0);
        await verifyExactText('Python');
        await tapBackArrow();

        // VIEW LANGUAGE Java PAGE
        await tapListItem(widgetPrefix: 'item', itemIndex: 1);
        await verifyExactText('Java');
        await tapBackArrow();

    }

    Future<void> testCounterFeature() async {

        await showCounterSample();
        await verifyTextForKey('app-bar-text', 'Counter Sample');
        ...

    }

    ...
    
}

```

Here is what the test data could like that is being blackbox tested...

```json
{
    "count": 7,
    "next": null,
    "previous": null,
    "results": [
        {
            "id": 1,
            "name": "Python",
            "year": 1991,
            "person": "Guido van Rossum",
            "favorited": true,
            "category" : "Scripting, Object Oriented",
            "logo": "logos/python.png",
            "hello" : "helloworld/1_code_prism_language_python.png",
            "arguments" : "arguments/1_code_prism_language_python.png",
            "description" : "Python is an interpreted high-level general-purpose programming language. Guido van Rossum began working on Python in the late 1980s, as a successor to the ABC programming language, and first released it in 1991 as Python 0.9.0. Python’s design philosophy emphasizes code readability with its notable use of significant indentation. Its language constructs as well as its object-oriented approach aim to help programmers write clear, logical code for small and large-scale projects."
        },
        ...
    ]
}
```

Integration Test Helper also supports all Major Widget Interactions. When tapping Widgets, the package supports tapForKey, tapForType, tapForTooltip, tapWidget("Containing This Text"), tapListItem and more.

With the tapListItem, we handle the waiting for the UI to load, finding the Widget, and then tapping the found Widget. In addition, we also include ListView item prefixes, and positions within the list.

```dart
    
    Future<void> tapListItem({ required String widgetPrefix, required int itemIndex }) async {
        await waitForUI();
        final itemFinder = find.byKey(ValueKey('${widgetPrefix}_$itemIndex'));
        await tester.tap(itemFinder);
    }

```
Note: Using the tapListItem implementation, we remove at the least 3 lines of code from your integration tests, and allow that functionality to be reused in your own custom implementation of the BaseIntegrationTest class.

Here is what your Widget Key implementation could look like:

```dart
    Card(
        elevation: 1.5,
        child: InkWell(
            key: Key('item_$index'),
            onTap: () {
                Navigator.push<void>(context,
                    MaterialPageRoute(builder: (BuildContext context) =>
                            LanguagePage(index: index, language: item)));
            },
            child: LanguagePreview(index: index, language: item)),
        ),
    );
```

And here is an example of using that Key to tap the list item widget:

```dart
        
    Future<void> testLanguagesFeature() async {
        
        // VIEW LANGUAGES PAGE
        ...

        // VIEW LANGUAGE Python PAGE
        await tapListItem(widgetPrefix: 'item', itemIndex: 0);
        await verifyExactText('Python');
        await tapBackArrow();

        // VIEW LANGUAGE Java PAGE
        ...

    }

```

## Getting started

Note: this package example uses another one of our packages. Its called the drawer_manager 
pacakge, and can be found [here](https://pub.dev/packages/drawer_manager) for more details on how it works.

### Install Provider, Drawer Manager & Integration Test Helper
```bash

  flutter pub get provider
  flutter pub get drawer_manager
  flutter pub get integration_test_helper

```

### Or install Provider, Drawer Manager & Integration Test Helper (in pubspec.yaml)
```yaml

    ...
    
dependencies:
  flutter:
    sdk: flutter

    ...

  provider: 6.0.2
  drawer_manager: 0.0.3
    
dev_dependencies:

  flutter_test:
    sdk: flutter

  integration_test:
    sdk: flutter

  integration_test_helper: 0.0.1

```

### Add Integration Test Driver file (test_driver/integration_test.dart)
```dart

import 'package:integration_test/integration_test_driver.dart';

Future<void> main() => integrationDriver();

```

## Usage

### Create hello file (hello.dart)
```dart

import 'package:flutter/material.dart';

class HelloPage extends StatelessWidget {
  
  const HelloPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Hello, Flutter!',
        key: Key('hello-page-text'),
        textAlign: TextAlign.center,
        style: TextStyle(
            color: Color(0xff0085E0),
            fontSize: 48,
            fontWeight: FontWeight.bold
        )
      ),
    );
  }
}

```

### Create main file (main.dart)

If testing on an Android device/emulator the PlatformWidget allows for native Android interations 
with the Drawer. If testing on an iOS device/simulator the PlatformWidget allows for native iOS
interations with the TabBar.

```dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:drawer_manager/drawer_manager.dart';

import 'hello.dart';

void main() {
  runApp(setupMainWidget());
}

Widget setupMainWidget() {
  return const MyApp();
}

class PlatformWidget extends StatelessWidget {
  const PlatformWidget({
    Key? key,
    required this.androidBuilder,
    required this.iosBuilder,
  })  : assert(androidBuilder != null),
        assert(iosBuilder != null),
        super(key: key);

  final WidgetBuilder androidBuilder;
  final WidgetBuilder iosBuilder;

  @override
  Widget build(context) {
    switch (DeviceHelper.targetPlatform()) {
      case TargetPlatform.android:
        return androidBuilder(context);
      case TargetPlatform.iOS:
        return iosBuilder(context);
      default:
        assert(false, 'Unexpected platform $defaultTargetPlatform');
        return Container();
    }
  }
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
  Widget _buildAndroidHomePage(BuildContext context) {

    final drawerSelections = [
      const HelloPage(),
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
            )
          ],
          tileSelections: drawerSelections,
        ));
  }

  @override
  Widget _buildIosHomePage(BuildContext context) {
      return CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
            items: [
                BottomNavigationBarItem(
                    label: "Hello 1",
                    icon: const Icon(Icons.hail_rounded),
                ),
                BottomNavigationBarItem(
                    label: "Hello 2",
                    icon: const Icon(Icons.hail_rounded),
                ),
            ],
        ),
        // ignore: avoid_types_on_closure_parameters
        tabBuilder: (BuildContext context, int index) {
            switch (index) {
            case 0:
                return CupertinoTabView(
                    defaultTitle: "Hello 1",
                    builder: (context) => HelloPage(),
                );
            case 1:
                return CupertinoTabView(
                    defaultTitle: "Hello 2",
                    builder: (context) => HelloPage(),
                );
            default:
                assert(false, 'Unexpected tab');
                return Container();
            }
        },
    );
  }

  @override
  Widget build(context) {
    return PlatformWidget(
      androidBuilder: _buildAndroidHomePage,
      iosBuilder: _buildIosHomePage,
    );
  }

}

```

### Import Flutter Test & Integration Test Helper (in integration_test/app_test_groups.dart)
```yaml
    ...
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test_helper/integration_test_helper.dart';

```

### Subclass BaseIntegrationTest (in integration_test/app_test_groups.dart)

The Integration Test Helper can support platform specific implementations, like the showHelloFlutter
method. This method uses the Drawer for Android and the Tab Bar for iOS, and accomodates the different
implmentations.

```dart

class ScreenIntegrationTestGroups extends BaseIntegrationTest {

    ...

    @override
    Future<void> setupInitialData() async {
        ...
    }

    Future<void> showHelloFlutter({int position = 1}) async {
        print('Showing Hello, Flutter!');
        if(Platform.isAndroid) {
            await tapForTooltip('Open navigation menu');
            await tapForKey('drawer-hello');
        } else {
            await tapForTooltip('Tab Bar Hello $position');
        }
        await waitForUI();
    }

    Future<void> testHelloFlutterFeature() async {
        await showHelloFlutter();
        await verifyTextForKey('app-bar-text', 'Hello');
        await verifyTextForKey('hello-page-text', 'Hello, Flutter!');
    }

    ...

}
```

### Setp BaseIntegrationTest Subclass (in integration_test/app_test.dart)
```dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:example/main.dart' as app;
import 'app_test_groups.dart';

void main() async {

    IntegrationTestWidgetsFlutterBinding.ensureInitialized();
    
    group('end-to-end test', () {
      
        ScreenIntegrationTestGroups integrationTestGroups;

        testWidgets('Testing end to end single-screen integration', (WidgetTester tester) async {

            final main = app.setupMainWidget();
            WidgetsApp.debugAllowBannerOverride = false;
            await tester.pumpWidget(main);
            
            integrationTestGroups = ScreenIntegrationTestGroups();
            await integrationTestGroups.initializeTests(tester);
            await integrationTestGroups.waitForUI(durationMultiple: 2); // Wait initial Load
            await integrationTestGroups.testHelloFlutterFeature();
            ...

        }, timeout: const Timeout(Duration(minutes: 3)));

    });
}
```

### Run Driver on BaseIntegrationTest Subclass (using integration_test/app_test.dart)
```bash

    flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart

```

## Additional information


To support this repo, take a look at the [SUPPORT.md](https://github.com/the-mac/integration_test_helper/blob/main/SUPPORT.md) file.

To view the documentation on the package, [follow this link](https://pub.dev/documentation/integration_test_helper/latest/integration_test_helper/integration_test_helper-library.html)
