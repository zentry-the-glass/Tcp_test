import 'dart:typed_data';
import 'dart:ffi';

class TranInput {
  final Header header;

  TranInput(this.header);

  List<int> toByteArrayTotal() {
    final headerBytes = header.toByteArray();
    final bodyBytes = toByteArray();
    final messageBytes = Uint8List(headerBytes.length + bodyBytes.length);
    messageBytes.setRange(0, headerBytes.length, headerBytes);
    messageBytes.setRange(headerBytes.length, messageBytes.length, bodyBytes);
    return messageBytes.toList();
  }
  List<int> toByteArray() {
    return <int>[];
  }

  int toByte(int value) {
    return value & 0xFF;
  }

}

class Header {
  int messageLength;
  int messageId;
  int nPID;

  Header(this.messageLength, this.messageId, this.nPID);

  Uint8List toByteArray() {
    final buffer = ByteData(3 * sizeOf<Int32>());
    buffer.setUint32(0, messageLength, Endian.big);
    buffer.setUint32(sizeOf<Int32>(), messageId, Endian.big);
    buffer.setUint32(2 * sizeOf<Int32>(), nPID, Endian.big);
    return buffer.buffer.asUint8List();
  }
}

class Input2005 extends TranInput {
  final String macAddr1;
  final String macAddr2;
  final int type;
  final int value;
  final int timeStamp;

  Input2005(this.macAddr1, this.macAddr2, this.type, this.value, this.timeStamp,
      Header header)
      : super(header);


  Uint8List toByteArray() {
    final buffer = Uint8List(25);
    final byteArrMacAddr1 = macAddr1
        .split(':')
        .map((s) => int.parse(s, radix: 16).toUnsigned(8))
        .toList();

    final byteArrMacAddr2 = macAddr2
        .split(':')
        .map((s) => int.parse(s, radix: 16).toUnsigned(8))
        .toList();


    final byteBuffer = ByteData(4)..setInt32(0, value, Endian.big);
    final byteArrValue = byteBuffer.buffer.asUint8List();

    final byteArrTimeStamp = Uint8List(8);
    Util.write8BytesToBufferBigEndian(byteArrTimeStamp, 0, timeStamp);

    buffer.setRange(0, 6, byteArrMacAddr1);
    buffer.setRange(6, 12, byteArrMacAddr2);
    buffer[12] = type;
    buffer.setRange(13, 17, byteArrValue);
    buffer.setRange(17, 25, byteArrTimeStamp);

    print('buffer: ${buffer}');
    return buffer;
  }
}

class Util {
  static int unsignedBytesToInt(
      int b0, int b1, int b2, int b3) {
    return (unsignedByteToInt(b0) +
        (unsignedByteToInt(b1) << 8) +
        (unsignedByteToInt(b2) << 16) +
        (unsignedByteToInt(b3) << 24));
  }

  static int unsignedBytesToIntBig(
      int b0, int b1, int b2, int b3) {
    return ((unsignedByteToInt(b0) << 24) + (unsignedByteToInt(b1) << 16) +
        (unsignedByteToInt(b2) << 8) + unsignedByteToInt(b3));
  }

  static int toBigEndianUnsignedInt(List<int> bytes) {
    var value = 0;
    for (var i = 0; i < bytes.length; i++) {
      value = (value << 8) |
      (bytes[i] & 0xFF);
    }
    return value;
  }

  static int unsignedByteToInt(int b) {
    return b & 0xff;
  }

  static String bytesToHex(List<int> bytes) {
    var hexArray = '0123456789ABCDEF'.split('');

    var hexChars = List.filled(bytes.length * 2, '');
    for (var j = 0; j < bytes.length; j++) {
      var v = bytes[j] & 0xFF;

      hexChars[j * 2] = hexArray[v >> 4];
      hexChars[j * 2 + 1] = hexArray[v & 0x0F];
    }
    return hexChars.join();
  }

  static void write4BytesToBufferBigEndian(
      List<int> buffer, int offset, int data) {
    buffer[offset + 3] = (data >> 24) & 0xFF;
    buffer[offset + 2] = (data >> 16) & 0xFF;
    buffer[offset + 1] = (data >> 8) & 0xFF;
    buffer[offset + 0] = (data >> 0) & 0xFF;
  }

  static void write8BytesToBufferBigEndian(
      List<int> buffer, int offset, int data) {
    buffer[offset + 7] = (data >> 56) & 0xFF;
    buffer[offset + 6] = (data >> 48) & 0xFF;
    buffer[offset + 5] = (data >> 40) & 0xFF;
    buffer[offset + 4] = (data >> 32) & 0xFF;
    buffer[offset + 3] = (data >> 24) & 0xFF;
    buffer[offset + 2] = (data >> 16) & 0xFF;
    buffer[offset + 1] = (data >> 8) & 0xFF;
    buffer[offset + 0] = (data >> 0) & 0xFF;
  }

  static String convertStringToMacAddress(String input) {
    final regex = RegExp(r'(.{2})(.{2})(.{2})(.{2})(.{2})(.{2})');
    return regex
        .allMatches(input)
        .map((m) => m.group(0))
        .join(':');
  }
}
