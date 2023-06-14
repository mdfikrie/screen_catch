import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

class ScreenCatch {
  // void captureScreenWindows({String? fileName}) {
  //   if (Platform.isWindows) {
  //     _captureForWindows(fileName: fileName);
  //   } else if (Platform.isMacOS) {}
  // }

  void captureForMacos({String? path, String? displayId}) async {
    final process =
        await Process.start("screencapture", ["-x", "-D", displayId!, path!]);
    final exitCode = await process.exitCode;
    if (exitCode == 0) {
      print(path);
    } else {
      print("Screenshoot gagal dijalankan");
    }
  }

  Future<List<String>> getDisplayIDsMac() async {
    var displayList = <String>[];
    final process = await Process.start('ioreg', ['-l']);
    final output = await process.stdout.transform(utf8.decoder).join();
    var matches =
        RegExp(r'"IODisplayEDID" = <([a-zA-Z0-9]+)').allMatches(output);
    matches.forEach((element) {
      displayList.add(element.group(1).toString());
    });
    return displayList;
  }

  void captureForWindows({String? fileName}) {
    final hDC = GetDC(NULL);
    final hMemoryDC = CreateCompatibleDC(hDC);

    // Get the size of all screens combined (considering the primary screen at (0,0))
    final left = GetSystemMetrics(SM_XVIRTUALSCREEN);
    final top = GetSystemMetrics(SM_YVIRTUALSCREEN);
    final width = GetSystemMetrics(SM_CXVIRTUALSCREEN);
    final height = GetSystemMetrics(SM_CYVIRTUALSCREEN);

    final hBitmap = CreateCompatibleBitmap(hDC, width, height);
    SelectObject(hMemoryDC, hBitmap);

    BitBlt(hMemoryDC, 0, 0, width, height, hDC, left, top, SRCCOPY);

    // Save the captured image to a file.
    final bitmapInfo = calloc<BITMAPINFO>()
      ..ref.bmiHeader.biSize = sizeOf<BITMAPINFOHEADER>();
    GetDIBits(
        hMemoryDC, hBitmap, 0, height, nullptr, bitmapInfo, DIB_RGB_COLORS);

    final imageSize = bitmapInfo.ref.bmiHeader.biSizeImage;
    final imagePtr = calloc<Uint8>(imageSize);
    bitmapInfo.ref.bmiHeader.biCompression = BI_RGB;

    GetDIBits(
        hMemoryDC, hBitmap, 0, height, imagePtr, bitmapInfo, DIB_RGB_COLORS);

    final bitmapFileHeaderSize = 14;
    final bitmapInfoHeaderSize = 40;
    final fileSize = bitmapFileHeaderSize + bitmapInfoHeaderSize + imageSize;
    final fileHeader = calloc<Uint8>(fileSize);
    final fileHeaderPtr = fileHeader.asTypedList(fileSize);

    // BITMAPFILEHEADER
    fileHeaderPtr[0] = 0x42; // 'B'
    fileHeaderPtr[1] = 0x4D; // 'M'
    fileHeaderPtr[2] = fileSize & 0xFF;
    fileHeaderPtr[3] = fileSize >> 8 & 0xFF;
    fileHeaderPtr[4] = fileSize >> 16 & 0xFF;
    fileHeaderPtr[5] = fileSize >> 24 & 0xFF;
    fileHeaderPtr[10] = bitmapFileHeaderSize + bitmapInfoHeaderSize;

    // BITMAPINFOHEADER
    final infoHeaderPtr =
        bitmapInfo.cast<Uint8>().asTypedList(bitmapInfoHeaderSize);
    fileHeaderPtr.setRange(bitmapFileHeaderSize,
        bitmapFileHeaderSize + bitmapInfoHeaderSize, infoHeaderPtr);

    // Image Data
    final imageBytes = imagePtr.asTypedList(imageSize);
    fileHeaderPtr.setRange(
        bitmapFileHeaderSize + bitmapInfoHeaderSize, fileSize, imageBytes);

    // Write to a file
    final file = File("${fileName!}.jpg");
    file.writeAsBytesSync(fileHeaderPtr.toList());

    // Clean up
    DeleteObject(hBitmap);
    DeleteDC(hMemoryDC);
    ReleaseDC(NULL, hDC);

    calloc.free(imagePtr);
    calloc.free(fileHeader);
    calloc.free(bitmapInfo);
  }
}
