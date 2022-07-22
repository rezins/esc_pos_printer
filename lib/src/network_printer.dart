/*
 * esc_pos_printer
 * Created by Andrey Ushakov
 * 
 * Copyright (c) 2019-2020. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import 'dart:io';
import 'dart:typed_data' show Uint8List;
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:image/image.dart';
import './enums.dart';

/// Network Printer
class NetworkPrinter {
  NetworkPrinter(this._paperSize, this._profile, {int spaceBetweenRows = 5}) {
    _generator =
        Generator(paperSize, profile, spaceBetweenRows: spaceBetweenRows);
  }

  final PaperSize _paperSize;
  final CapabilityProfile _profile;
  String? _host;
  int? _port;
  late Generator _generator;
  late Socket _socket;

  int? get port => _port;
  String? get host => _host;
  PaperSize get paperSize => _paperSize;
  CapabilityProfile get profile => _profile;

  Future<PosPrintResult> connect(String host,
      {int port = 91000, Duration timeout = const Duration(seconds: 5)}) async {
    _host = host;
    _port = port;
    try {
      _socket = await Socket.connect(host, port, timeout: timeout);
      _socket.add(_generator.reset());
      return Future<PosPrintResult>.value(PosPrintResult.success);
    } catch (e) {
      return Future<PosPrintResult>.value(PosPrintResult.timeout);
    }
  }

  /// [delayMs]: milliseconds to wait after destroying the socket
  void disconnect({int? delayMs}) async {
    _socket.destroy();
    if (delayMs != null) {
      await Future.delayed(Duration(milliseconds: delayMs), () => null);
    }
  }

  // ************************ Printer Commands ************************
  void reset() async{
    _socket.add(_generator.reset());
    if(Platform.isWindows){
      await Future.delayed(Duration(milliseconds: 500),(){});
    }
  }

  void text(
    String text, {
    PosStyles styles = const PosStyles(),
    int linesAfter = 0,
    bool containsChinese = false,
    int? maxCharsPerLine,
  }) async{
    _socket.add(_generator.text(text,
        styles: styles,
        linesAfter: linesAfter,
        containsChinese: containsChinese,
        maxCharsPerLine: maxCharsPerLine));
    if(Platform.isWindows){
      await Future.delayed(Duration(milliseconds: 500),(){});
    }
  }

  void setGlobalCodeTable(String codeTable) async{
    _socket.add(_generator.setGlobalCodeTable(codeTable));
    if(Platform.isWindows){
      await Future.delayed(Duration(milliseconds: 500),(){});
    }
  }

  void setGlobalFont(PosFontType font, {int? maxCharsPerLine}) async{
    _socket
        .add(_generator.setGlobalFont(font, maxCharsPerLine: maxCharsPerLine));
    if(Platform.isWindows){
      await Future.delayed(Duration(milliseconds: 500),(){});
    }
  }

  void setStyles(PosStyles styles, {bool isKanji = false}) async{
    _socket.add(_generator.setStyles(styles, isKanji: isKanji));
    if(Platform.isWindows){
      await Future.delayed(Duration(milliseconds: 500),(){});
    }
  }

  void rawBytes(List<int> cmd, {bool isKanji = false}) async{
    _socket.add(_generator.rawBytes(cmd, isKanji: isKanji));
    if(Platform.isWindows){
      await Future.delayed(Duration(milliseconds: 500),(){});
    }
  }

  void emptyLines(int n) async{
    _socket.add(_generator.emptyLines(n));
    if(Platform.isWindows){
      await Future.delayed(Duration(milliseconds: 500),(){});
    }
  }

  void feed(int n) async{
    _socket.add(_generator.feed(n));
    if(Platform.isWindows){
      await Future.delayed(Duration(milliseconds: 500),(){});
    }
  }

  void cut({PosCutMode mode = PosCutMode.full}) async{
    _socket.add(_generator.cut(mode: mode));
    if(Platform.isWindows){
      await Future.delayed(Duration(milliseconds: 500),(){});
    }
  }

  void printCodeTable({String? codeTable}) async{
    _socket.add(_generator.printCodeTable(codeTable: codeTable));
    if(Platform.isWindows){
      await Future.delayed(Duration(milliseconds: 500),(){});
    }
  }

  void beep({int n = 3, PosBeepDuration duration = PosBeepDuration.beep450ms}) async{
    _socket.add(_generator.beep(n: n, duration: duration));
    if(Platform.isWindows){
      await Future.delayed(Duration(milliseconds: 500),(){});
    }
  }

  void reverseFeed(int n) async{
    _socket.add(_generator.reverseFeed(n));
    if(Platform.isWindows){
      await Future.delayed(Duration(milliseconds: 500),(){});
    }
  }

  void row(List<PosColumn> cols) async{
    _socket.add(_generator.row(cols));
    if(Platform.isWindows){
      await Future.delayed(Duration(milliseconds: 500),(){});
    }
  }

  void image(Image imgSrc, {PosAlign align = PosAlign.center}) async{
    _socket.add(_generator.image(imgSrc, align: align));
    if(Platform.isWindows){
      await Future.delayed(Duration(milliseconds: 500),(){});
    }
  }

  void imageRaster(
    Image image, {
    PosAlign align = PosAlign.center,
    bool highDensityHorizontal = true,
    bool highDensityVertical = true,
    PosImageFn imageFn = PosImageFn.bitImageRaster,
  }) async{
    _socket.add(_generator.imageRaster(
      image,
      align: align,
      highDensityHorizontal: highDensityHorizontal,
      highDensityVertical: highDensityVertical,
      imageFn: imageFn,
    ));
    if(Platform.isWindows){
      await Future.delayed(Duration(milliseconds: 500),(){});
    }
  }

  void barcode(
    Barcode barcode, {
    int? width,
    int? height,
    BarcodeFont? font,
    BarcodeText textPos = BarcodeText.below,
    PosAlign align = PosAlign.center,
  }) async{
    _socket.add(_generator.barcode(
      barcode,
      width: width,
      height: height,
      font: font,
      textPos: textPos,
      align: align,
    ));
    if(Platform.isWindows){
      await Future.delayed(Duration(milliseconds: 500),(){});
    }
  }

  void qrcode(
    String text, {
    PosAlign align = PosAlign.center,
    QRSize size = QRSize.Size4,
    QRCorrection cor = QRCorrection.L,
  }) async{
    _socket.add(_generator.qrcode(text, align: align, size: size, cor: cor));
    if(Platform.isWindows){
      await Future.delayed(Duration(milliseconds: 500),(){});
    }
  }

  void drawer({PosDrawer pin = PosDrawer.pin2}) async{
    _socket.add(_generator.drawer(pin: pin));
    if(Platform.isWindows){
      await Future.delayed(Duration(milliseconds: 500),(){});
    }
  }

  void hr({String ch = '-', int? len, int linesAfter = 0}) async{
    _socket.add(_generator.hr(ch: ch, linesAfter: linesAfter));
    if(Platform.isWindows){
      await Future.delayed(Duration(milliseconds: 500),(){});
    }
  }

  void textEncoded(
    Uint8List textBytes, {
    PosStyles styles = const PosStyles(),
    int linesAfter = 0,
    int? maxCharsPerLine,
  }) async{
    _socket.add(_generator.textEncoded(
      textBytes,
      styles: styles,
      linesAfter: linesAfter,
      maxCharsPerLine: maxCharsPerLine,
    ));
    if(Platform.isWindows){
      await Future.delayed(Duration(milliseconds: 500),(){});
    }
  }
  // ************************ (end) Printer Commands ************************
}
