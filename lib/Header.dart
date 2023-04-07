import 'dart:convert';
import 'dart:typed_data';
import 'dart:ffi';

import 'package:logger/logger.dart';

import 'Util.dart';



// class TranInput {
//   final Header header;
//
//   TranInput(this.header);
//
//   List<int> toByteArrayTotal() {
//     final headerBytes = header.toByteArray();
//     final bodyBytes = toByteArray();
//     final messageBytes = Uint8List(headerBytes.length + bodyBytes.length);
//     messageBytes.setRange(0, headerBytes.length, headerBytes);
//     messageBytes.setRange(headerBytes.length, messageBytes.length, bodyBytes);
//     return messageBytes.toList();
//   }
//   List<int> toByteArray() {
//     return <int>[];
//   }
//
//   int toByte(int value) {
//     return value & 0xFF;
//   }
//
// }

// class Header {
//   int messageLength;
//   int messageId;
//   int nPID;
//
//   Header(this.messageLength, this.messageId, this.nPID);
//
//   Uint8List toByteArray() {
//     final buffer = ByteData(3 * sizeOf<Int32>());
//     buffer.setUint32(0, messageLength, Endian.big);
//     buffer.setUint32(sizeOf<Int32>(), messageId, Endian.big);
//     buffer.setUint32(2 * sizeOf<Int32>(), nPID, Endian.big);
//     return buffer.buffer.asUint8List();
//   }
// }

// class Input2005 extends TranInput {
//   final String macAddr1;
//   final String macAddr2;
//   final int type;
//   final int value;
//   final int timeStamp;
//
//   Input2005(this.macAddr1, this.macAddr2, this.type, this.value, this.timeStamp,
//       Header header)
//       : super(header);
//
//
//   Uint8List toByteArray() {
//     final buffer = Uint8List(25);
//     final byteArrMacAddr1 = macAddr1
//         .split(':')
//         .map((s) => int.parse(s, radix: 16).toUnsigned(8))
//         .toList();
//
//     final byteArrMacAddr2 = macAddr2
//         .split(':')
//         .map((s) => int.parse(s, radix: 16).toUnsigned(8))
//         .toList();
//
//
//     final byteBuffer = ByteData(4)..setInt32(0, value, Endian.big);
//     final byteArrValue = byteBuffer.buffer.asUint8List();
//
//     final byteArrTimeStamp = Uint8List(8);
//     Util.write8BytesToBufferBigEndian(byteArrTimeStamp, 0, timeStamp);
//
//     buffer.setRange(0, 6, byteArrMacAddr1);
//     buffer.setRange(6, 12, byteArrMacAddr2);
//     buffer[12] = type;
//     buffer.setRange(13, 17, byteArrValue);
//     buffer.setRange(17, 25, byteArrTimeStamp);
//
//     print('buffer: ${buffer}');
//     return buffer;
//   }
// }


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



class Message2201 {
  late int connectedMultiAppCount;
  late List<MultiAppData> multiAppDatas;

  Message2201(){
    multiAppDatas = [];
  }

  void addMultiAppData(MultiAppData multiAppData){
    multiAppDatas.add(multiAppData);
  }

  Message2201.fromBytes(int length, List<int> bytes) {
    int index = length;
    this.connectedMultiAppCount = Util.readIntFromBytesBigEndian(bytes, index);
    print('$index connectedMultiAppCount:  $connectedMultiAppCount');
    index += 4;
    multiAppDatas =[];
    for (int i = 0; i < connectedMultiAppCount; i++) {
      MultiAppData multiAppData = MultiAppData.fromBytes(index, bytes);
      addMultiAppData(multiAppData);
      index += multiAppData.totalLength;
    }
  }

  @override
  String toString() {
    // TODO: implement toString
    return 'connectedMultiAppCount: $connectedMultiAppCount\n'
        'multiAppDatas: $multiAppDatas\n';
  }
}

class MultiAppData{
   late String multiAppUUID;
   late int roomCount;
   late int totalLength;
   late List<PatientInfo> patientInfos;

   MultiAppData(){
     patientInfos = [];
   }

   void addPatient(PatientInfo patientInfo){
     patientInfos.add(patientInfo);
   }

   MultiAppData.fromBytes(int length,List<int> bytes) {
     int index = length;
     this.multiAppUUID = Util.test_bytesToHex(bytes.sublist(index,16+index));
     index += 16;
     print('multiAppUUID 16부터 시작 해야 함 $index multiAppUUID 값 $multiAppUUID');
     // this.multiAppUUID = Util.readIntFromBytesBigEndian(bytes, index);
     this.roomCount = Util.readIntFromBytesBigEndian(bytes, index);
     index +=4;
     print('roomCount $index roomCount $roomCount');
     patientInfos = [];
     for (int i = 0; i < roomCount; i++) {
       PatientInfo patient = PatientInfo.fromBytes(index, bytes);
       addPatient(patient);
       this.totalLength = 16+4+patient.totalLength;
       index += patient.totalLength;
     }
   }

   @override
  String toString() {
    // TODO: implement toString
     return 'multiAppUUID: $multiAppUUID\n'
         'roomCount: $roomCount\n'
         'totalLength: $totalLength\n'
         'patientInfos: $patientInfos\n';
  }
}

class PatientInfo {
  late int roomNumber;
  late int type;
  late int patientsNameLength;
  late int chartNumberLength;
  late String patientName;
  late String chartNumber;
  late int totalLength ;


  PatientInfo.fromBytes(int length,List<int> bytes) {
    int index = length;
    this.roomNumber = Util.readIntFromBytesBigEndian(bytes, index);
    index += 4;
    this.type = bytes[index++];
    this.patientsNameLength = Util.readIntFromBytesBigEndian(bytes, index);
    index += 4;
    List<int> name = bytes.sublist(index, index + patientsNameLength);
    this.patientName = utf8.decode(name);
    index += name.length;
    this.chartNumberLength = Util.readIntFromBytesBigEndian(bytes, index);
    index += 4;
    List<int> chart = bytes.sublist(index, index + chartNumberLength);
    this.chartNumber = utf8.decode(chart);
    this.totalLength = 4 + 1 + 4 + patientsNameLength + 4 + chartNumberLength;
    // print('roomNumber $roomNumber type $type NameLength $patientsNameLength  name $patientName');
    // print('NumberLength $chartNumberLength chartNumber $chartNumber total $totalLength');


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







class InputHeader{
  late int msgSize;
  late int msgId;
  late int reId;

  InputHeader({required this.msgSize, required this.msgId, required this.reId});

}

class Input2101 extends InputHeader{
  late int hospitalId;
  late int vetId;
  late bool isReceivedData;

  Input2101({
    required super.msgSize, required super.msgId, required super.reId,
    required this.hospitalId,
    required this.vetId,
    required this.isReceivedData,
  });


  List<int> toByteArray() {
    final buffer = ByteData(21);
    buffer.setInt32(0, msgSize);
    buffer.setInt32(4, msgId);
    buffer.setInt32(8, reId);
    buffer.setInt32(12, hospitalId);
    buffer.setInt32(16,  vetId);
    buffer.setUint8(20,  isReceivedData ? 1 : 0);
    return buffer.buffer.asUint8List();
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
    index +=4;
    for (int i = 0; i < RoomCount; i++) {
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


class Input2102 extends InputHeader{
  late bool isReceivedData;
  Input2102({
    required super.msgSize,
    required super.msgId,
    required super.reId,
    required this.isReceivedData
  });

  List<int> toByteArray() {
    final buffer = ByteData(21);
    buffer.setInt32(0, msgSize);
    buffer.setInt32(4, msgId);
    buffer.setInt32(8, reId);
    buffer.setUint8(12,  isReceivedData ? 1 : 0);
    return buffer.buffer.asUint8List();
  }

}





