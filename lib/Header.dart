import 'dart:convert';
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


class HeadrTest{
  late int msgSize;
  late int msgId;
  late int RequestId;

  HeadrTest.fromBytes(int length,List<int> bytes) {
    int index = length;
    this.msgSize = Util.readIntFromBytesBigEndian(bytes, index);
    index += 4;
    this.msgId = Util.readIntFromBytesBigEndian(bytes, index);
    index += 4;
    this.RequestId = Util.readIntFromBytesBigEndian(bytes, index);
  }

  @override
  String toString() {
    return 'msgSize: $msgSize\n'
        'msgId: $msgId\n'
        'RequestId: $RequestId\n';

  }

}


class Message1101 {
  late int HospitalId;
  late int RoomCount;
  late List<PatientInfo> patients;

  Message1101() {
    patients = [];
  }

  void addPatient(PatientInfo patient) {
    patients.add(patient);
  }

  Message1101.fromBytes(int length, List<int> bytes) {
    int index = length;
    this.HospitalId = Util.readIntFromBytesBigEndian(bytes, index);
    index += 4;
    this.RoomCount = Util.readIntFromBytesBigEndian(bytes, index);
    patients = [];

    for (int i = 0; i < RoomCount; i++) {
      index +=4;
      PatientInfo patient = PatientInfo.fromBytes(index, bytes);
      patients.add(patient);
      index += patient.totalLength;
    }
  }
  @override
  String toString() {
    // TODO: implement toString
    return 'Room HospitalId: $HospitalId\n'
        'RoomCount: $RoomCount\n';
  }
}



class PatientInfo {
 late int roomNumber;
 late int type;
 late String patientName;
 late String chartNumber;
 late int totalLength ;


  PatientInfo.fromBytes(int length,List<int> bytes) {
    int index = length;
    print(index);
    this.roomNumber = Util.readIntFromBytesBigEndian(bytes, index);
    print(roomNumber);
    index += 4;
    this.type = bytes[index++];
    int patientsNameLength = Util.readIntFromBytesBigEndian(bytes, index);
    index += 4;
    List<int> name = bytes.sublist(index, index + patientsNameLength);
    this.patientName = utf8.decode(name);
    index += name.length;
    int chartNumberLength = Util.readIntFromBytesBigEndian(bytes, index);
    index += 4;
    List<int> chart = bytes.sublist(index, index + chartNumberLength);
    this.chartNumber = utf8.decode(chart);
    this.totalLength = 4 + 1 + 4 + patientsNameLength + 4 + chartNumberLength;


  }

  @override
  String toString() {
    return 'Room Number: $roomNumber\n'
        'Type: $type\n'
        'Patient Name: $patientName\n'
        'totalLength: $totalLength\n'
        'Chart Number: $chartNumber';
  }




}


class Util {

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
