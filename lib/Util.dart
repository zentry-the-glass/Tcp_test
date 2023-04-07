import 'package:logger/logger.dart';

class Util {

  static var log = Logger();
  static int HeaderSize = 12;
  static int hospitalIdSize = 4;
  static int RoomCount = 4;
  static int RoomNumSzie = 4;
  static int RoomStatus = 1;
  static int PatientsNameLength = 4;
  static int ChartNumberLength = 4;

  static int unsignedBytesToInt(
      int b0, int b1, int b2, int b3) {
    return (unsignedByteToInt(b0) +
        (unsignedByteToInt(b1) << 8) +
        (unsignedByteToInt(b2) << 16) +
        (unsignedByteToInt(b3) << 24));
  }




  static String test_bytesToHex(List<int> bytes) {
    final hexDigits = '0123456789ABCDEF';
    return bytes
        .map((byte) => hexDigits[(byte & 0xf0) >> 4] + hexDigits[byte & 0x0f])
        .join();
  }

  static int unsignedBytesToIntBig(
      int b0, int b1, int b2, int b3) {
    return ((unsignedByteToInt(b0) << 24) + (unsignedByteToInt(b1) << 16) +
        (unsignedByteToInt(b2) << 8) + unsignedByteToInt(b3));
  }

  static int readIntFromBytesBigEndian(List<int> bytes, int index) {
    return ((bytes[index++] << 24) |
    (bytes[index++] << 16) |
    (bytes[index++] << 8) |
    bytes[index++]);
  }

  static int calculateLengthOfNumbers(List<int> numbers) {
    String numbersString = numbers.join();
    return numbersString.length;
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

  static String convertToHexString(List<int> numbers) {
    StringBuffer buffer = StringBuffer();
    for (int number in numbers) {
      buffer.write(number.toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
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