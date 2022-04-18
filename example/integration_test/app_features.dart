// clear && printf '\e[3J' && flutter drive -t integration_test/app_features.dart ; flutter clean

// clear && printf '\e[3J' && flutter drive -t integration_test/app_features.dart

// clear && printf '\e[3J' && flutter run -t integration_test/app_features.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test_helper/integration_test_helper.dart';

import 'package:example/main.dart' as app;
import 'app_feature_groups.dart';

void main() async {
  final binding = IntegrationTestHelperBinding.ensureInitialized();

  testWidgets('Testing end to end single-screen integration', (WidgetTester tester) async {

    final main = app.setupMainWidget();
    final integrationTestGroups = ScreenIntegrationTestGroups(binding);
    await integrationTestGroups.initializeTests(tester, main);

    await integrationTestGroups.testEndToEndUsing(TargetPlatform.android);
    await integrationTestGroups.testEndToEndUsing(TargetPlatform.iOS);

  }, timeout: const Timeout(Duration(minutes: 15)));
}
