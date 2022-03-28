import 'dart:io';
import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() => integrationDriver(
    onScreenshot: (String screenshotPath, List<int> screenshotBytes) async {
        
        final File image = File(screenshotPath);
        final dir = image.parent;
        print(image);

        if(!await dir.exists()) await dir.create(recursive: true);
        image.writeAsBytesSync(screenshotBytes);
        
        return true;

    }
);