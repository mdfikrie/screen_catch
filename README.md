# screen_catch

[![Pub](https://img.shields.io/pub/v/flutter_screen_capture)](https://pub.dev/packages/flutter_screen_capture)

A package to capture all displayed screens on the monitors

|             | macOS | Windows | Linux |
|:------------|:------|:--------|:------|
| **Support** | ✅     | ✅       | ❌     |


## Usage

### Capture all displayed screen on the monitors

```dart
final screenCatch = ScreenCapture();
final path = await getApplicationDocumentsDirectory();
      String imageName =
          'Screenshoot-${DateTime.now().millisecondsSinceEpoch}.jpg';
      String imagePath =
          '${path.path}/mauju-time-tracker/screencast/${imageName}';
  if (Platform.isWindows) {
        screenCatch.captureForWindows(fileName: imagePath);
      } else if (Platform.isMacOS) {
        var screenCatch = ScreenCatch();
        var listDisplay = <String>[];
        listDisplay = await screenCatch.getDisplayIDsMac();
        for (var i = 0; i < listDisplay.length; i++) {
          imageName =
              'Screenshoot-${DateTime.now().millisecondsSinceEpoch}${i}.jpg';
          imagePath = '${path.path}/mauju-time-tracker/screencast/${imageName}';
          screenCatch.captureForMacos(
              path: imagePath, displayId: (i + 1).toString());
        }
      }
```

## Current limitations

- Linux is not supported yet.
