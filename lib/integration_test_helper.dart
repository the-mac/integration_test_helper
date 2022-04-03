library integration_test_helper;

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

class IntegrationTestHelperBinding extends IntegrationTestWidgetsFlutterBinding {
  
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

    final int timeoutDuration = 750;

    late WidgetTester tester;

    final IntegrationTestHelperBinding binding;

    BaseIntegrationTest(this.binding);

    Future<bool> isPlatformAndroid();

    Future<void> setupInitialData();

    Future<dynamic> loadFixtureJSON(String fixturePath) async {
        final source =  await rootBundle.loadString(fixturePath);
        return json.decode(source);
    }

    Future<void> initializeTests(WidgetTester tester, Widget main) async {

        this.tester = tester;
        WidgetsApp.debugAllowBannerOverride = false;
        await tester.pumpWidget(main);

        await setupInitialData();
        await waitForUI(durationMultiple: 2);

    }
    
    Future<void> waitForUI({int durationMultiple = 1}) async {
        await tester.pumpAndSettle();
        await tester.pump(Duration(milliseconds: timeoutDuration * durationMultiple));
    }

    Future<bool> verifyExactText(String itemText, {bool shouldThrowError = true}) async {
        try {
            var outputTextWidget = find.text(itemText);
            expect(outputTextWidget, findsOneWidget);
            return Future.value(true);
        } on Error catch(_) {
          if(shouldThrowError) throw AssertionError(_);
        }
        return Future.value(false);
    }
    
    Future<bool> verifyTextForKey(String fieldKey, String itemText, {bool shouldThrowError = true}) async {
        try {
            await waitForUI();
            final widgetFinder = find.byKey(Key(fieldKey));
            expect(widgetFinder, findsOneWidget);

            var text = widgetFinder.evaluate().single.widget as Text;
            assert(text.data == itemText);
            return Future.value(true);

        } on Error catch(_) {
          if(shouldThrowError) throw AssertionError(_);
        }

        return Future.value(false);

    }
    
    Future<void> verifyTextFieldForKey(String fieldKey, String itemText) async {
        await waitForUI();
        final widgetFinder = find.byKey(Key(fieldKey));
        expect(widgetFinder, findsOneWidget);

        final textField = widgetFinder.evaluate().single.widget as TextField;
        expect(textField.controller!.text, itemText);
    }

    Future<void> verifyListExactText(int itemIndex, { required String widgetPrefix, required String widgetSuffix, required String expectedText }) async {

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

        if(tester.firstWidget(userText) is TextField) {
            final textField = tester.firstWidget(userText) as TextField;
            textField.controller?.text = inputText;
        } else if(tester.firstWidget(userText) is CupertinoTextField) {
            final textField = tester.firstWidget(userText) as CupertinoTextField;
            textField.controller?.text = inputText;
        }
    }
    
    Future<void> tapForKey(String fieldKey) async {        
        await waitForUI();
        final widgetFinder = find.byKey(Key(fieldKey));
        await tester.tap(widgetFinder);
    }

    Future<void> tapForType(Type fieldType) async {        
        await waitForUI();
        final widgetFinder = find.byType(fieldType);
        await tester.tap(widgetFinder);
    }
    
    Future<void> tapForTooltip(String toolTip) async {
        await waitForUI();
        final widgetFinder = find.byTooltip(toolTip);
        await tester.tap(widgetFinder);
    }

    Future<void> tapWidget(String widgetText) async {        
        await waitForUI();
        final widgetFinder = find.text(widgetText);
        await tester.tap(widgetFinder);
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
    }

    Future<void> tapEnterKey() async  => await _tapKeyboardKey(LogicalKeyboardKey.enter);

    Future<void> tapShiftKey() async  => await _tapKeyboardKey(LogicalKeyboardKey.shift);

    Future<void> tapSpaceKey() async  => await _tapKeyboardKey(LogicalKeyboardKey.space);

    Future<void> tapSearchKey() async  => await _tapKeyboardKey(LogicalKeyboardKey.browserSearch);

    Future<void> tapDeleteKey() async  => await _tapKeyboardKey(LogicalKeyboardKey.delete); 
    
    Future<void> tapDoneButton() async {
        await waitForUI();
        await tester.testTextInput.receiveAction(TextInputAction.done);
    }
  
    Future<void> tapCloseButton() async {
        await waitForUI();
        final widgetFinder = find.byTooltip('Close');
        await tester.tap(widgetFinder);
    }

    Future<void> tapListItem({ required String widgetPrefix, required int itemIndex }) async {
        await waitForUI();
        final itemFinder = find.byKey(ValueKey('${widgetPrefix}_$itemIndex'));
        await tester.tap(itemFinder);
    }

    Future<void> tapListWidget(int itemIndex, { required String widgetPrefix, required String widgetType }) async {
        await waitForUI();
        final itemWidgetFinder = find.byKey(ValueKey('${widgetPrefix}_${itemIndex}_$widgetType'));
        await tester.tap(itemWidgetFinder);
    }

    Future<void> scrollToListItemText(String listKey, String itemText) async {

        final listFinder = find.byKey(Key(listKey));
        final itemFinder = find.text(itemText);

        // scrollable finders
        final scrollable = find.byWidgetPredicate((w) => w is Scrollable);
        final scrollableOfList = find.descendant(of: listFinder, matching: scrollable);

        await tester.scrollUntilVisible(
          itemFinder, 200.0, 
          scrollable: scrollableOfList,
          duration: const Duration(milliseconds: 1500)
        );
        await tester.pump();
        
    }

    Future<void> takeScreenshot(String filePath) async {      
        await waitForUI();
        binding.takeScreenshot(filePath);
    }

    Future<void> dismissModal() async {
      await tester.tapAt(const Offset(100, 100));
    }
}