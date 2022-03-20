
// ignore_for_file: avoid_print

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test_helper/integration_test_helper.dart';

import 'package:example/the_mac.dart';
import 'package:example/preferences.dart';

class ScreenIntegrationTestGroups extends BaseIntegrationTest {

    late Map _languagesTestData;

    @override
    Future<void> setupInitialData() async {

        _languagesTestData = await loadFixture('assets/fixtures/languages.json') as Map;

        if (_languagesTestData.isEmpty) {
            throw 'No languages test data found';
        }

    }

    Future<void> validateTestDataAt(int itemIndex, { required String widgetSuffix, required String jsonKey }) async {
        var languageData = _languagesTestData['results'][itemIndex] as Map;
        var itemText = languageData[jsonKey] as String;
        await verifyListExactText(itemIndex, widgetPrefix: 'item', widgetSuffix: widgetSuffix, expectedText: itemText);
    }

    Future<void> showHelloFlutter() async {
        print('Showing Hello, Flutter!');
        if(Platform.isAndroid) {
            await tapForTooltip('Open navigation menu');
            await tapForKey('drawer-hello');
        } else {
            await tapWidget('Hello');
        }
        await waitForUI();
    }

    Future<void> showLanguagesList() async {
        print('Showing Languages');
        if(Platform.isAndroid) {
            await tapForTooltip('Open navigation menu');
            await tapForKey('drawer-languages');
        } else {
            await tapWidget('Items');
        }
        await waitForUI();
    }

    Future<void> showCounterSample() async {
        print('Showing Counter Sample');
        if(Platform.isAndroid) {
            await tapForTooltip('Open navigation menu');
            await tapForKey('drawer-counter');
        } else {
            await tapWidget('Counter');
        }
        await waitForUI();
    }

    Future<void> showTheMACSocials() async {
        print('Showing Mobile Community');
        if(Platform.isAndroid) {
            await tapForTooltip('Open navigation menu');
            await tapForKey('drawer-community');
        } else {
            await tapWidget('Mobile Community');
        }
        await waitForUI();
    }

    Future<void> showPreferences() async {
        print('Showing Preferences');
        if(Platform.isAndroid) {
            await tapForTooltip('Open navigation menu');
            await tapForKey('drawer-preferences');
        } else {
            await tapWidget('Preferences');
        }
        await waitForUI();
    }

    Future<void> tapPreference(int number) async {
      await tapForKey('preference-$number');
    }

    Future<void> testHelloFlutterFeature() async {
        await showHelloFlutter();
        await verifyTextForKey('app-bar-text', 'Hello');
        await verifyTextForKey('hello-page-text', 'Hello, Flutter!');
    }

    Future<void> testLanguagesFeature() async {
        
        // VIEW LANGUAGES PAGE
        await showLanguagesList();
        await verifyTextForKey('app-bar-text', 'Languages');

        await validateTestDataAt(0, widgetSuffix: 'name', jsonKey: 'name');
        await validateTestDataAt(1, widgetSuffix: 'name', jsonKey: 'name');

        // VIEW LANGUAGE PAGE
        await tapListItem(widgetPrefix: 'item', itemIndex: 0);
        await verifyExactText('Python');
        await tapBackArrow();

        // VIEW LANGUAGE PAGE
        await tapListItem(widgetPrefix: 'item', itemIndex: 1);
        await verifyExactText('Java');
        await tapBackArrow();  

    }

    Future<void> testCounterFeature() async {

        await showCounterSample();
        await verifyTextForKey('app-bar-text', 'Counter Sample');

        await verifyTextForKey('counter-page-text', '0');
        await tapForTooltip('Increment');

        await verifyTextForKey('counter-page-text', '1');
        await tapForTooltip('Increment');

        await verifyTextForKey('counter-page-text', '2');
        await tapForTooltip('Increment');

        await verifyTextForKey('counter-page-text', '3');
        await tapForTooltip('Increment');

        await verifyTextForKey('counter-page-text', '4');

    }

    Future<void> testSocialFeature() async {

        await showTheMACSocials();
        await verifyTextForKey('app-bar-text', 'Mobile Community');
        await verifyExactText('Welcome to\nThe Mobile Apps Community!');

        await verifyExactText('Share Integration Test Helper');
        await tapWidget('Share Integration Test Helper');
        await waitForUI(durationMultiple: 2);
        await tapBackArrow();

        final launchResultsHasShareURL = launchResults.containsKey(TheMACPage.shareURL);
        final pubDevLaunchSuccessful = launchResultsHasShareURL && launchResults[TheMACPage.shareURL];
        assert(pubDevLaunchSuccessful);

        await verifyExactText('Check out our Facebook');
        await tapWidget('Check out our Facebook');
        await waitForUI(durationMultiple: 2);
        await tapBackArrow();

        final launchResultsHasFacebookURL = launchResults.containsKey(TheMACPage.facebookURL);
        final facebookLaunchSuccessful = launchResultsHasFacebookURL && launchResults[TheMACPage.facebookURL];
        assert(facebookLaunchSuccessful);

        await verifyExactText('Check out our Github');
        await tapWidget('Check out our Github');
        await waitForUI(durationMultiple: 2);
        await tapBackArrow();

        final launchResultsHasGithubURL = launchResults.containsKey(TheMACPage.githubURL);
        final githubLaunchSuccessful = launchResultsHasGithubURL && launchResults[TheMACPage.githubURL];
        assert(githubLaunchSuccessful);

    }

    Future<void> testPreferencesFeature() async {

        // SHOW SETTINGS PAGE
        await showPreferences();
        await verifyTextForKey('app-bar-text', 'Preferences');
        
        await verifyExactText('Notifications for new packages');
        assert(!Prefs.getBool('preference-0'));

        await tapPreference(0);
        assert(Prefs.getBool('preference-0'));

        await verifyExactText('Github Pull Requests updates');
        assert(!Prefs.getBool('preference-1'));

        await tapPreference(1);
        assert(Prefs.getBool('preference-1'));

        await showCounterSample();
        await showPreferences();

        assert(Prefs.getBool('preference-0'));
        assert(Prefs.getBool('preference-1'));

        await verifyExactText('Send Mobile Community updates');
        assert(!Prefs.getBool('preference-2'));
        
        await tapPreference(2);
        assert(Prefs.getBool('preference-2'));

        await tapPreference(2);
        assert(!Prefs.getBool('preference-2'));

    }

}