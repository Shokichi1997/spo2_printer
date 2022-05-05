import 'dart:async';
import 'dart:io';
import 'package:epos2_printer/entity/printer_device.dart';
import 'package:epos2_printer/utils/const.dart';
import 'package:flutter/services.dart';

class Epos2Printer {
  static const MethodChannel _channel = MethodChannel('epos2_printer');
  static const EventChannel _eventChannel = EventChannel('epos2_printer_event');

  /// Connect to selected printer with [target] address
  /// throw PlatformException if error occur
  static Future<void> connectPrinter(String? target) async {
    if (target == null) return;
    await _channel.invokeMethod('connect', {'address': 'target'});
  }

  /// Send a [text] to printer
  /// throw PlatformException if error occur
  static Future<void> addText(String text) async {
    final result = await _channel.invokeMethod('addText', {'text': text});
  }

  /// Send Image to printer
  /// throw PlatformException if error occur
  /// Android: Use List<Int> data to convert it to Bitmap (Kotlin)
  /// IOS: Use assetsPath directly
  static Future<void> addImage(String assetsPath) async {
    var data = {};
    if (Platform.isAndroid) {
      ByteData imageBytes = await rootBundle.load(assetsPath);
      List<int> imageIntData = imageBytes.buffer.asInt8List();
      data = {'image': imageIntData};
    } else {
      data = {'imagePath': assetsPath};
    }
    await _channel.invokeMethod('addImage', data);
  }

  /// Add a new line to the printer with [line] number
  /// throw PlatformException if error occur
  static Future<void> addFeedLine(int? line) async {
    final result = await _channel.invokeMethod('addFeedLine', {'line': line});
  }

  /// Disconnect to printer
  /// throw PlatformException if error occur
  static Future<void> disconnect() async {
    final result = await _channel.invokeMethod('disconnect');
  }

  /// Add a new line to the printer with [line] number
  /// throw PlatformException if error occur
  static Future<void> addTextSize({required int width, required int height}) async {
    final result = await _channel.invokeMethod('addTextSize', {
      'width': width,
      'height': height,
    });
  }

  /// Cut the paper with [cutType]
  /// [cutType] value is described in [PosCut]
  /// throw PlatformException if error occur
  static Future<void> addCut(int? cutType) async {
    final result = await _channel.invokeMethod('addCut', {'type': cutType});
  }

  /// Align text
  /// Apply to text after this command is called
  /// [align] value is described in [PosAlign]
  /// throw PlatformException if error occur
  static Future<void> addTextAlign(int? align) async {
    final result = await _channel.invokeMethod('addTextAlign', {'align': align});
  }

  /// Check if the printer is connected
  static Future<bool> isConnected() async {
    return (await _channel.invokeMethod('isConnected')) == PosConnection.EPOS2_TRUE;
  }

  /// Send prepared data to printer
  /// After calling this funtion, the printer will printer data due to addTex, addImage,... function
  /// throw PlatformException if error occur
  static Future<void> printData() async {
    final result = await _channel.invokeMethod('printData');
  }

  /// Set line space
  /// throw PlatformException if error occur
  static Future<void> addLineSpace(int? lineSpace) async {
    final result = await _channel.invokeMethod('addLineSpace', {'lineSpace': lineSpace});
  }

  /// Set text font
  /// [fontType] value is described in [PosFont]
  /// throw PlatformException if error occur
  static Future<void> addTextFont(int? fontType) async {
    final result = await _channel.invokeMethod('addTextFont', {'font': fontType});
  }

  /// Get list of printer
  static Stream<List<PrinterDevice>> getPrinters() {
    return _eventChannel
        .receiveBroadcastStream()
        .map<List<PrinterDevice>>((mapValue) => List.from(mapValue.map((x) => PrinterDevice.fromJson(mapValue))));
  }

  static void stopFindPrinter() {
    _channel.invokeListMethod('stopFindPrinter');
  }
}
