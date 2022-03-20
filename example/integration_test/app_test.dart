
// clear && printf '\e[3J' && flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart ; flutter clean

// clear && printf '\e[3J' && flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart

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
            await integrationTestGroups.testLanguagesFeature();
            await integrationTestGroups.testCounterFeature();
            await integrationTestGroups.testSocialFeature();
            await integrationTestGroups.testPreferencesFeature();

        }, timeout: const Timeout(Duration(minutes: 3)));

    });
}