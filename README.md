The Integration Test Helper has pre-configured methods that allow for faster test deployment for end to end (e2e) test coverage.


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

The Integration Test Helper is built on top of [Flutter's Integration Tests](https://docs.flutter.dev/testing/integration-tests). Running End to End (e2e) tests can become bloated and unorganized code, and [lead to regressions](https://en.wikipedia.org/wiki/Software_regression) but with this helper writing tests can be faster, modular and with [full test coverage](https://www.simform.com/blog/test-coverage/). This approach allows for a cleaner development experience, and [less regressions within your apps](https://www.gratasoftware.com/what-is-regression-in-software-development/).

[![Regression Testing](https://raw.githubusercontent.com/the-mac/integration_test_helper/main/media/integration_test_4.png)](https://youtu.be/0wHKVXbsppw)

Integration Test Helper supports all Major Widget Interactions, and also allows for black box fixture data testing. When tapping Widgets, the package currently supports tapForKey, tapForType, tapForTooltip and tapWidget("Containing This Text"). The fixtures currently support JSON data, and can be loaded from anywhere within the project.

With the tapForKey, we handle the waiting for the UI to load, finding the Widget, and then tapping the found Widget.

```dart
    
    Future<void> tapForKey(String fieldKey) async {        
        await waitForUI();
        final widgetFinder = find.byKey(Key(fieldKey));
        await tester.tap(widgetFinder);
    }

```
Note: Using the tapForKey implementation, we remove at the least 3 lines of code from your integration tests, and allow that functionality to be reused in your own custom implementation of the BaseIntegrationTest class.

## Getting started


## Usage

TODO: Include short and useful examples for package users. Add longer examples
to `/example` folder. 

```dart
const like = 'sample';
```

## Additional information

TODO: Tell users more about the package: where to find more information, how to 
contribute to the package, how to file issues, what response they can expect 
from the package authors, and more.
