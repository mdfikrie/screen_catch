# screen_catch

[![Pub](https://img.shields.io/pub/v/flutter_screen_capture)](https://pub.dev/packages/flutter_screen_capture)

A package to capture all displayed screens on the monitors

|             | macOS | Windows | Linux |
|:------------|:------|:--------|:------|
| **Support** | ❌     | ✅       | ❌     |


## Usage

### Capture all displayed screen on the monitors

```dart
final path = Directory.current.path + 'screencatch.png';
final capture = ScreenCapture();
capture.captureAllScreens(fileName: path);
```

## Current limitations

- Linux is not supported yet.
- MacOs is not supported yet.
