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

Integration Test Helper (or the BaseIntegrationTest class) allows for [BlackBox Testing](https://www.guru99.com/black-box-testing.html) using fixture data. The fixtures currently support JSON data, and can be loaded from anywhere within the project folder. Here is what the fixture test data (assets/fixtures/languages.json) looks like that is being blackbox tested...

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

This data is typically initialized in the setupInitialData implementation of the BaseIntegrationTest subclass. The following is an example of how you can BlackBox Test your ListViews, as well other types of Widgets with Integration Test Helper:

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

Note: this package example uses another one of our packages. It's called the drawer_manager 
package, and can be found [here](https://pub.dev/packages/drawer_manager) for more details on how it works.

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
  drawer_manager: 0.0.4
    
dev_dependencies:

  flutter_test:
    sdk: flutter

  integration_test:
    sdk: flutter

  integration_test_helper: <latest_version>

```

### Add Integration Test Driver file (test_driver/app_features_test.dart)
```dart

import 'package:integration_test/integration_test_driver.dart';

Future<void> main() => integrationDriver();

```

## Usage

### Create hello file (lib/hello.dart)
```dart

import 'package:flutter/material.dart';

class HelloPage extends StatelessWidget {

  final int position;
  
  const HelloPage({Key? key, required this.position}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Hello, Flutter $position!',
        key: Key('hello-page-text-$position'),
        textAlign: TextAlign.center,
        style: const TextStyle(
            color: Color(0xff0085E0),
            fontSize: 48,
            fontWeight: FontWeight.bold
        )
      ),
    );
  }
}

```

### Create main file (lib/main.dart)

```dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drawer_manager/drawer_manager.dart';

import 'hello.dart';

void main() {
  runApp(setupMainWidget());
}

Widget setupMainWidget() {
  WidgetsFlutterBinding.ensureInitialized();
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

class MyHomePage extends StatelessWidget {

  const MyHomePage({Key? key}) : super(key: key);

  String _getTitle(int index) {
      switch (index) {
        case 0: return 'Hello 1';
        case 1: return 'Hello 2';
        default: return '';
      }
  }

  Widget _getTitleWidget() {
    return Consumer<DrawerManagerProvider>(builder: (context, dmObj, _) {
      return Text(
        _getTitle(dmObj.selection),
        key: const Key('app-bar-text')
      );
    });
  }

  @override
  Widget build(context) {

    final drawerSelections = [
      const HelloPage(position: 1),
      const HelloPage(position: 2),
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
              key: const Key('drawer-hello-1'),
              context: context,
              leading: const Icon(Icons.hail_rounded),
              title: Text(_getTitle(0)),
              onTap: () async {
                // RUN A BACKEND Hello, Flutter OPERATION
              },
            ),
            DrawerTile(
              key: const Key('drawer-hello-2'),
              context: context,
              leading: const Icon(Icons.hail_rounded),
              title: Text(_getTitle(1)),
              onTap: () async {
                // RUN A BACKEND Hello, Flutter OPERATION
              },
            )
          ],
          tileSelections: drawerSelections,
        ));
    }

}

```

### Import Flutter Test & Integration Test Helper (in integration_test/app_test_groups.dart)
```yaml
    ...
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test_helper/integration_test_helper.dart';

```

### Subclass BaseIntegrationTest (in integration_test/app_feature_groups.dart)

The Integration Test Helper can support platform specific implementations, like the showHelloFlutter
method. This method uses the Drawer for Android and accomodates the Android environment.

```dart

class ScreenIntegrationTestGroups extends BaseIntegrationTest {

    // ...

    @override
    Future<bool> isPlatformAndroid() async {
        return Future.value(true);
    }

    @override
    Future<void> setupInitialData() async {
        // ...
    }

    Future<void> showHelloFlutter({required int position}) async {
        print('Showing Hello, Flutter $position!');
        if(Platform.isAndroid) {
            await tapForTooltip('Open navigation menu');
            await tapForKey('drawer-hello-$position');
        }
        await waitForUI();
    }

    Future<void> testHelloFlutterFeature() async {
        await showHelloFlutter(position: 1);
        await verifyTextForKey('app-bar-text', 'Hello 1');
        await verifyTextForKey('hello-page-text-1', 'Hello, Flutter 1!');

        await showHelloFlutter(position: 2);
        await verifyTextForKey('app-bar-text', 'Hello 2');
        await verifyTextForKey('hello-page-text-2', 'Hello, Flutter 2!');
    }

    // ...

}

```

### Setup BaseIntegrationTest Subclass (in integration_test/app_features.dart)
```dart

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:example/main.dart' as app;
import 'app_feature_groups.dart';

void main() async {

    IntegrationTestWidgetsFlutterBinding.ensureInitialized();

    testWidgets('Testing end to end single-screen integration', (WidgetTester tester) async {
      
          final main = app.setupMainWidget();
          final integrationTestGroups = ScreenIntegrationTestGroups();
          await integrationTestGroups.initializeTests(tester, main);

          await integrationTestGroups.testHelloFlutterFeature();

      }, timeout: const Timeout(Duration(minutes: 1))
    );
    
}

```

### Run Driver on BaseIntegrationTest Subclass (using integration_test/app_features.dart)
```bash

    flutter drive -t integration_test/app_features.dart

```


## Additional information

### Alternatively, you can run the example
The [example project](https://github.com/the-mac/integration_test_helper/tree/main/example) has 5 screens that have grouped integration tests:

- [Hello, Flutter](https://github.com/the-mac/integration_test_helper/blob/707c6a797b28a6275b50ed6624b10cc9b79e8b4a/example/integration_test/app_test_groups.dart#L114)
- [Hello, Languages](https://github.com/the-mac/integration_test_helper/blob/707c6a797b28a6275b50ed6624b10cc9b79e8b4a/example/integration_test/app_test_groups.dart#L120)
- [Counter Sample](https://github.com/the-mac/integration_test_helper/blob/707c6a797b28a6275b50ed6624b10cc9b79e8b4a/example/integration_test/app_test_groups.dart#L141)
- [Mobile Community](https://github.com/the-mac/integration_test_helper/blob/707c6a797b28a6275b50ed6624b10cc9b79e8b4a/example/integration_test/app_test_groups.dart#L162)
- [Preferences](https://github.com/the-mac/integration_test_helper/blob/707c6a797b28a6275b50ed6624b10cc9b79e8b4a/example/integration_test/app_test_groups.dart#L197)

### Package Support
To support this repo, take a look at the [SUPPORT.md](https://github.com/the-mac/integration_test_helper/blob/main/SUPPORT.md) file.

### Package Documentation
To view the documentation on the package, [follow this link](https://pub.dev/documentation/integration_test_helper/latest/integration_test_helper/integration_test_helper-library.html)
