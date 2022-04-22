library integration_test_helper;

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// The Integration Test Helper has pre-configured methods that allow for faster test deployment for end to end (e2e) test
/// coverage (using Android and iOS platform UIs). The Integration Test Helper is built on top of Flutter's Integration
/// Tests. This approach allows for a cleaner development experience, and less regressions within your apps. Integration
/// Test Helper (or the BaseIntegrationTest class) allows for BlackBox Testing using fixture data as well, and the fixtures currently
/// support JSON data, and can be loaded from anywhere within the project folder.
class IntegrationTestHelperBinding
    extends IntegrationTestWidgetsFlutterBinding {
  /// Similar to [WidgetsFlutterBinding.ensureInitialized].
  ///
  /// Returns an instance of the [IntegrationTestWidgetsFlutterBinding], creating and
  /// initializing it if necessary.
  static WidgetsBinding ensureInitialized() {
    if (WidgetsBinding.instance == null) {
      IntegrationTestHelperBinding();
    }
    assert(WidgetsBinding.instance is IntegrationTestHelperBinding);
    return WidgetsBinding.instance!;
  }

  @override
  Future<void> convertFlutterSurfaceToImage() async {
    try {
      await super.convertFlutterSurfaceToImage();
    } on AssertionError catch (_) {}
  }

  /// Takes a screenshot.
  ///
  /// On Android, you need to call `convertFlutterSurfaceToImage()`, and
  /// pump a frame before taking a screenshot.
  @override
  Future<List<int>> takeScreenshot(String screenshotName) async {
    await convertFlutterSurfaceToImage();
    return super.takeScreenshot(screenshotName);
  }
}

abstract class BaseIntegrationTest {

  late int _waitForMilliseconds;

  late WidgetTester tester;

  final IntegrationTestHelperBinding binding;

  BaseIntegrationTest(this.binding);

  Future<bool> isPlatformAndroid();

  Future<void> setupInitialData();

  Future<dynamic> loadFixtureJSON(String fixturePath) async {
    final source = await rootBundle.loadString(fixturePath);
    return json.decode(source);
  }

  void setWaitMilliseconds(int waitForMilliseconds) async {
    _waitForMilliseconds = waitForMilliseconds;
  }

  Future<void> initializeTests(WidgetTester tester, Widget main,
      {int waitForMilliseconds = 850}) async {
    this.tester = tester;
    setWaitMilliseconds(waitForMilliseconds);
    WidgetsApp.debugAllowBannerOverride = false;
    await tester.pumpWidget(main);

    await setupInitialData();
    await waitForUI(durationMultiple: 2);
  }

  Future<void> waitForUI({int durationMultiple = 1}) async {
    await tester.pumpAndSettle();
    await tester
        .pump(Duration(milliseconds: _waitForMilliseconds * durationMultiple));
  }

  Future<bool> verifyExactText(String itemText,
      {bool shouldThrowError = true}) async {
    try {
      var outputTextWidget = find.text(itemText);
      expect(outputTextWidget, findsOneWidget);
      return Future.value(true);
    } on Error catch (_) {
      if (shouldThrowError) throw AssertionError(_);
    }
    return Future.value(false);
  }

  Future<bool> verifyTextForKey(String fieldKey, String itemText,
      {bool shouldThrowError = true}) async {
    try {
      await waitForUI();
      final widgetFinder = find.byKey(Key(fieldKey));
      expect(widgetFinder, findsOneWidget);

      var text = widgetFinder.evaluate().single.widget as Text;
      assert(text.data == itemText);
      return Future.value(true);
    } on Error catch (_) {
      if (shouldThrowError) throw AssertionError(_);
    }

    return Future.value(false);
  }

  Future<void> verifyTextFieldForKey(String fieldKey, String itemText) async {
    await waitForUI();
    final widgetFinder = find.byKey(Key(fieldKey));
    expect(widgetFinder, findsOneWidget);

    final firstWidget = widgetFinder.evaluate().single.widget;

    if (firstWidget is TextField) {
      expect(firstWidget.controller!.text, itemText);
    } else if (firstWidget is TextFormField) {
      expect(firstWidget.controller!.text, itemText);
    } else if (firstWidget is CupertinoTextField) {
      expect(firstWidget.controller!.text, itemText);
    } else {
      String message =
          'verifyTextFieldForKey currently does not support ${firstWidget.runtimeType}, ';
      message +=
          'feel free to create an issue or make a pull request for the support of this widget.\n';
      message +=
          'Create issue here: https://github.com/the-mac/integration_test_helper/issues/new ';
      message +=
          '\nMake a pull request here: https://github.com/the-mac/integration_test_helper/compare';
      throw Exception(message);
    }
  }

  Future<void> verifyListExactText(int itemIndex,
      {required String widgetPrefix,
      required String widgetSuffix,
      required String expectedText}) async {
    final widgetKey = '${widgetPrefix}_${itemIndex}_$widgetSuffix';

    final itemWidgetFinder = find.byKey(ValueKey(widgetKey));
    expect(itemWidgetFinder, findsOneWidget);

    final actualWidget = itemWidgetFinder.evaluate().single.widget as Text;

    final actualText = actualWidget.data!;
    expect(actualText, expectedText);

    await waitForUI();
  }

  Future<void> enterText(String fieldKey, String inputText) async {
    await waitForUI();
    final userText = find.byKey(Key(fieldKey));

    expect(userText, findsOneWidget);
    await tester.enterText(userText, inputText);
  }

  /// The tapForKey handles the waiting for the UI to load, finding the Widget, and then tapping the found Widget.
  /// In addition, it also includes a post tap wait for any screen loading needed. Using the tapForKey implementation,
  /// we remove at the least 3 lines of code from your integration tests, and allow that functionality to be reused in your
  /// own custom implementation of the BaseIntegrationTest class.
  Future<void> tapForKey(String fieldKey) async {
    await waitForUI();
    final widgetFinder = find.byKey(Key(fieldKey));
    await tester.tap(widgetFinder);
    await waitForUI();
  }

  /// The tapForType handles the waiting for the UI to load, finding the Widget, and then tapping the found Widget.
  /// In addition, it also includes a post tap wait for any screen loading needed. Using the tapForType implementation,
  /// we remove at the least 3 lines of code from your integration tests, and allow that functionality to be reused in your
  /// own custom implementation of the BaseIntegrationTest class.
  Future<void> tapForType(Type fieldType) async {
    await waitForUI();
    final widgetFinder = find.byType(fieldType);
    await tester.tap(widgetFinder);
    await waitForUI();
  }

  /// The tapForTooltip handles the waiting for the UI to load, finding the Widget, and then tapping the found Widget.
  /// In addition, it also includes a post tap wait for any screen loading needed. Using the tapForTooltip implementation,
  /// we remove at the least 3 lines of code from your integration tests, and allow that functionality to be reused in your
  /// own custom implementation of the BaseIntegrationTest class.
  Future<void> tapForTooltip(String toolTip) async {
    await waitForUI();
    final widgetFinder = find.byTooltip(toolTip);
    await tester.tap(widgetFinder);
    await waitForUI();
  }

  /// The tapWidget handles the waiting for the UI to load, finding the Widget, and then tapping the found Widget.
  /// In addition, it also includes a post tap wait for any screen loading needed. Using the tapWidget implementation,
  /// we remove at the least 3 lines of code from your integration tests, and allow that functionality to be reused in your
  /// own custom implementation of the BaseIntegrationTest class.
  Future<void> tapWidget(String widgetText) async {
    await waitForUI();
    final widgetFinder = find.text(widgetText);
    await tester.tap(widgetFinder);
    await waitForUI();
  }

  /// The tapForIcon handles the waiting for the UI to load, finding the Widget, and then tapping the found Widget.
  /// In addition, it also includes a post tap wait for any screen loading needed. Using the tapForIcon implementation,
  /// we remove at the least 3 lines of code from your integration tests, and allow that functionality to be reused in your
  /// own custom implementation of the BaseIntegrationTest class.
  Future<void> tapForIcon(IconData widgetIcon) async {
    await waitForUI();
    final widgetFinder = find.byIcon(widgetIcon);
    await tester.tap(widgetFinder);
    await waitForUI();
  }

  /// The tapForIconTooltip handles the waiting for the UI to load, finding the Widget, and then tapping the found Widget.
  /// In addition, it also includes a post tap wait for any screen loading needed. Using the tapForIconTooltip implementation,
  /// we remove at the least 3 lines of code from your integration tests, and allow that functionality to be reused in your
  /// own custom implementation of the BaseIntegrationTest class.
  Future<void> tapForIconTooltip(String widgetTooltip) async {
    await waitForUI();
    final widgetFinder = find.byWidgetPredicate((Widget w) =>
        w is IconButton && (w.tooltip?.startsWith(widgetTooltip) ?? false));
    await tester.tap(widgetFinder);
    await waitForUI();
  }

  Future<void> tapBackArrow() async {
    await waitForUI();
    await tester.pageBack();
    await waitForUI();
  }

  Future<void> _tapKeyboardKey(LogicalKeyboardKey key) async {
    await waitForUI();
    final targetPlatform = await isPlatformAndroid() ? 'android' : 'ios';
    await simulateKeyDownEvent(key, platform: targetPlatform);
    await waitForUI();
  }

  Future<void> tapEnterKey() async => await _tapKeyboardKey(LogicalKeyboardKey.enter);

  Future<void> tapShiftKey() async => await _tapKeyboardKey(LogicalKeyboardKey.shift);

  Future<void> tapSpaceKey() async => await _tapKeyboardKey(LogicalKeyboardKey.space);

  Future<void> tapSearchKey() async => await _tapKeyboardKey(LogicalKeyboardKey.browserSearch);

  Future<void> tapDeleteKey() async => await _tapKeyboardKey(LogicalKeyboardKey.delete);

  Future<void> tapDoneButton() async {
    await waitForUI();
    await tester.testTextInput.receiveAction(TextInputAction.done);
  }

  Future<void> tapCloseButton() async {
    await waitForUI();
    final widgetFinder = find.byTooltip('Close');
    await tester.tap(widgetFinder);
  }

  /// The tapListItem method handles the waiting for the UI to load, finding the Widget, and then tapping the found Widget.
  /// In addition, it also includes List item prefixes, and positions within the list. Using the tapListItem implementation,
  /// it removes at the least 3 lines of code from your integration tests, and allows that functionality to be reused in your
  /// own custom implementation of the BaseIntegrationTest class.
  Future<void> tapListItem(
      {required String widgetPrefix, required int itemIndex}) async {
    await waitForUI();
    final itemFinder = find.byKey(ValueKey('${widgetPrefix}_$itemIndex'));
    await tester.tap(itemFinder);
  }

  Future<void> tapListWidget(int itemIndex,
      {required String widgetPrefix, required String widgetType}) async {
    await waitForUI();
    final itemWidgetFinder =
        find.byKey(ValueKey('${widgetPrefix}_${itemIndex}_$widgetType'));
    await tester.tap(itemWidgetFinder);
  }

  Future<void> scrollToListItemText(String listKey, String itemText) async {

    final listFinder = find.byKey(Key(listKey));
    final itemFinder = find.text(itemText);

    final scrollable = find.byWidgetPredicate((w) => w is Scrollable);
    final scrollableOfList =
        find.descendant(of: listFinder, matching: scrollable);

    await tester.scrollUntilVisible(itemFinder, 200.0, scrollable: scrollableOfList, duration: const Duration(milliseconds: 1500));
    await tester.pump();
  }

  Future<void> _navigateDatePicker(
      List<String> monthArray, DateTime startingDate,
      {String newMonth = '', int newDay = 0, int newYear = 0}) async {
    // https://github.com/flutter/flutter/blob/master/packages/flutter/test/material/date_picker_test.dart

    // final Finder nextMonthIcon = find.byWidgetPredicate((Widget w) => w is IconButton && (w.tooltip?.startsWith('Next month') ?? false));
    // final Finder previousMonthIcon = find.byWidgetPredicate((Widget w) => w is IconButton && (w.tooltip?.startsWith('Previous month') ?? false));
    // final Finder switchToInputIcon = find.byIcon(Icons.edit);
    // final Finder switchToCalendarIcon = find.byIcon(Icons.calendar_today);

    var startingMonthPosition = startingDate.month - 1;
    var startingMonth = monthArray[startingMonthPosition];
    var startingDay = startingDate.day;
    var startingYear = startingDate.year;

    if (newYear != 0) {
      final gridFinder = find.byType(GridView);

      await tester.tap(find.text('$startingMonth $startingYear'));
      final scrollable = find.byWidgetPredicate((w) => w is Scrollable);
      final scrollableOfList =
          find.descendant(of: gridFinder, matching: scrollable);

      final itemFinder = find.text('$newYear');
      await tester.scrollUntilVisible(itemFinder, 200.0,
          scrollable: scrollableOfList,
          duration: const Duration(milliseconds: 1500));
      await tester.pump();

      await tapWidget('$newYear');
      await waitForUI();
    }

    if (newMonth.isNotEmpty) {
      var newMonthPosition = monthArray.indexOf(newMonth);
      var newMonthOffset = startingMonthPosition - newMonthPosition;

      assert(monthArray.contains(newMonth),
          'That is not a full month name (like January, February, etc.): $newMonth');

      if (newMonthPosition > startingMonthPosition) {
        for (int index = 0; index < newMonthOffset.abs(); index++) {
          await tapForIconTooltip('Next month');
        }
      } else if (newMonthPosition < startingMonthPosition) {
        for (int index = 0; index < newMonthOffset.abs(); index++) {
          await tapForIconTooltip('Previous month');
        }
      }
      await waitForUI();

    }

    if (newDay > 0) {
      await tapWidget('$newDay');
      await waitForUI();
    } else if (newYear != 0) {
      await tapWidget('$startingDay');
      await waitForUI();
    }
    await tapWidget('OK');
  }

  Future<void> scrollPicker(Finder widgetFinder, String pickerElement) async {

    await waitForUI();
    final scrollable = find.byWidgetPredicate((w) => w is Scrollable);
    final scrollableOfList = find.descendant(of: widgetFinder, matching: scrollable);

    await waitForUI();
    
    final itemFinder = find.text(pickerElement);
    await tester.scrollUntilVisible(itemFinder, 200.0, scrollable: scrollableOfList, duration: const Duration(milliseconds: 1500));
    await waitForUI();
      
  }

  Future<void> _scrollCupertinoDatePicker(
      List<String> monthArray, DateTime startingDate,
      {String newMonth = '', int newDay = 0, int newYear = 0}) async {

    // https://www.kindacode.com/article/flutter-how-to-get-width-and-height-of-a-widget/
    // https://github.com/flutter/flutter/blob/61a0add2865c51bfee33939c1820709d1115c77d/packages/flutter/test/cupertino/date_picker_test.dart
    // https://github.com/flutter/flutter/blob/a88888e448b67a6d5351f12c1ed6b85cf363963a/packages/flutter/test/cupertino/picker_test.dart

    await waitForUI();

    final cupertinoPickers = find.byWidgetPredicate((w) => w is CupertinoPicker);

    final monthPicker = cupertinoPickers.at(0);
    final dayPicker = cupertinoPickers.at(1);
    final yearPicker = cupertinoPickers.at(2);

    expect(monthPicker, findsOneWidget);
    expect(dayPicker, findsOneWidget);
    expect(yearPicker, findsOneWidget);

    await scrollPicker(monthPicker, newMonth);
    await scrollPicker(dayPicker, '$newDay');
    await scrollPicker(yearPicker, '$newYear');

    await waitForUI();

    final cupertinoDatePicker = find.byType(CupertinoDatePicker);

    final Offset aboveDatePicker = tester.getTopLeft(cupertinoDatePicker) - const Offset(0.0, 150.0);
    await tester.tapAt(aboveDatePicker);
    await waitForUI(durationMultiple: 3);

  }

  /// The selectPlatformDate method allows for testing of an Android DatePickerDialog, and an iOS CupertinoDatePicker and 
  /// accepts two DateTime objects. The default date that is set on the date picker is the first parameter @startingDate, and 
  /// the destination date is the @endingDate. selectPlatformDate handles the waiting for the UI to load, finding the Picker Widget, and then tapping 
  /// or scrolling the correct date Widget components. In addition, it also includes List item prefixes, and positions within the list. Using the selectPlatformDate implementation,
  /// it removes at the least 3 lines of code from your integration tests, and allows that functionality to be reused in your
  /// own custom implementation of the BaseIntegrationTest class.
  Future<void> selectPlatformDate(
      DateTime startingDate, DateTime endingDate) async {

    await waitForUI();

    var monthArray = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];

    var endingMonthPosition = endingDate.month - 1;
    String newMonth = monthArray[endingMonthPosition];
    int newDay = endingDate.day;
    int newYear = endingDate.year;

    if (await isPlatformAndroid()) {
      await _navigateDatePicker(monthArray, startingDate,
          newMonth: newMonth, newDay: newDay, newYear: newYear);
    } else {
      await _scrollCupertinoDatePicker(monthArray, startingDate,
          newMonth: newMonth, newDay: newDay, newYear: newYear);
    }
    await waitForUI();

  }

  Future<void> changeSliderForKey(String fieldKey,
      {required double percentage}) async {
    await waitForUI();
    final widgetFinder = find.byKey(Key(fieldKey));
    await _changeSlider(widgetFinder, percentage: percentage);
    await waitForUI();
  }

  Future<void> changeSliderForType({required double percentage}) async {
    await waitForUI();
    final widgetFinder = find.byType(Slider);
    await _changeSlider(widgetFinder, percentage: percentage);
    await waitForUI();
  }

  Future<void> changeSliderForTooltip(String toolTip,
      {required double percentage}) async {
    await waitForUI();
    final widgetFinder = find.byTooltip(toolTip);
    await _changeSlider(widgetFinder, percentage: percentage);
    await waitForUI();
  }

  Future<void> _changeSlider(Finder slider,
      {required double percentage}) async {
    await waitForUI();
    await tester.tap(slider);

    final Offset topLeft = tester.getTopLeft(slider);
    final Offset bottomRight = tester.getBottomRight(slider);

    final Offset target = (topLeft + (bottomRight - topLeft)) * percentage;
    await tester.tapAt(target);
    await waitForUI();
  }

  Future<void> takeScreenshot(String filePath) async {
    await waitForUI();
    binding.takeScreenshot(filePath);
    await waitForUI();
  }

  Future<void> dismissBottomSheet() async {

    await waitForUI();

    final cupertinoBottomSheets = find.byWidgetPredicate((w) => w is BottomSheet);

    print('cupertinoBottomSheets: $cupertinoBottomSheets');
    final cupertinoBottomSheet = cupertinoBottomSheets.at(0);

    await tester.drag(cupertinoBottomSheet, const Offset(0.0, 150.0));
    await waitForUI(durationMultiple: 3);

  }

  Future<void> dismissModal() async {

    await waitForUI();

    final modalBarrier = find.byType(ModalBarrier);
    final aboveModalBarrier = tester.getTopLeft(modalBarrier) - const Offset(0.0, 150.0);

    await tester.tapAt(aboveModalBarrier);
    await waitForUI();
    
    // await tester.tapAt(const Offset(100, 100));
    // await waitForUI();
  }
}
