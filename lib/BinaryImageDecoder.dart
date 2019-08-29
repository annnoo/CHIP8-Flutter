import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:chip8/chip8/chip8.dart';

class BinaryImageDecoder {
  static createImage(List<bool> screen) {
    print(screen.length);
    const headerLengthBytes = 62;
    final lengthBytes = headerLengthBytes + (SCREEN_SIZE);
    var header = Uint8List(headerLengthBytes);
    var bmpImage = Uint8List(lengthBytes);

    header.setRange(0x00, 0x02, ascii.encode("BM")); // BM
    header.setRange(0x02, 0x06, CONVERT_4BYTES(lengthBytes)); // File Size
    header.setRange(0x0A, 0x0E,
        CONVERT_4BYTES(headerLengthBytes)); // Header Size )> Image Offset
    header.setRange(0x0E, 0x12, CONVERT_4BYTES(40));
    header.setRange(0x12, 0x16, CONVERT_4BYTES(SCREEN_WIDTH));
    header.setRange(0x16, 0x1A, CONVERT_4BYTES(SCREEN_HEIGHT));
    header.setRange(0x1A, 0x1C, CONVERT_2BYTES(1));
    header.setRange(0x1C, 0x1E, CONVERT_2BYTES(8));
    header.setRange(0x1E, 0x22, CONVERT_4BYTES(0));
    header.setRange(0x22, 0x26, CONVERT_4BYTES(0));
    header.setRange(0x26, 0x2A, CONVERT_4BYTES(2835));
    header.setRange(0x2A, 0x2E, CONVERT_4BYTES(2835));
    header.setRange(0x2E, 0x32, CONVERT_4BYTES(2));

    header.setRange(0x36, 0x3A, [0, 0, 0, 0]); // black
    header.setRange(0x3A, 0x3E, [255, 255, 255, 0]); // wh
    bmpImage.setAll(0, header);

    var i = headerLengthBytes;

    for (var y = 0; y < SCREEN_HEIGHT; y++) {
      for (var x = 0; x < SCREEN_WIDTH; x++) {
        bmpImage[i++] = screen[(( SCREEN_HEIGHT-1-y) * 64 + x)] ? 1 : 0;
        
      }
    }
    ;
    return bmpImage;
  }
}

CONVERT_4BYTES(int val) {
  return [val, val >> 8, val >> 16, val >> 24];
}

CONVERT_2BYTES(int val) {
  return [val, val >> 8];
}
