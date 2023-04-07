import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter_tcp_test/MultiAppDatas.dart';

import 'Util.dart';



class TestModel extends ChangeNotifier{
  int headerSize =12;
  late Socket _socket;
  Message2201? _message2201 = Message2201();
  // Msg1101 _msg1101 = Msg1101();
  // Msg1103 _msg1103 = Msg1103();
  bool _isConnected = false;
  int _count = 0;

  int get count => _count;
  Socket get socket =>_socket;
  Message2201? get message2201 => _message2201;
  // Msg1101 get msg1101 => _msg1101;
  // Msg1103 get msg1103 => _msg1103;
  bool get isConnected => _isConnected;

  void setData(int msgId, var bodyArr){
    switch (msgId){
      case 2201:
        _message2201 = Message2201.fromBytes(headerSize, bodyArr);

      // case 1101:
      //   _msg1101 = Msg1101.fromBytes(headerSize, bodyArr);
      //   //Util.log.e(_msg1101.toString());
      //   break;
      // case 1103:
      //   _msg1103 = Msg1103.fromBytes(headerSize, bodyArr);
    }
    notifyListeners();
  }

  void setSocket(var socket){
    _socket = socket;
    _count++;
    notifyListeners();
  }
  void setConnected(bool connected){
    _isConnected = connected;
    notifyListeners();
  }

  void destroySocket(){
    _socket.destroy();
    notifyListeners();
  }

  void sendMsg(var bytes){
    Util.log.e('input2101 보낸 bytes 값 : $bytes');
    _socket.add(bytes);
    _socket.flush();
  }

}




class SHeader{
  late int msgSize;
  late int msgId;
  late int reId;
  SHeader({required this.msgSize, required this.msgId, required this.reId});

  SHeader.fromBytes(int length,List<int> bytes) {
    int index = length;
    this.msgSize = Util.readIntFromBytesBigEndian(bytes, index);
    index += 4;
    this.msgId = Util.readIntFromBytesBigEndian(bytes, index);
    index += 4;
    this.reId = Util.readIntFromBytesBigEndian(bytes, index);
  }

  @override
  String toString() {
    return 'msgSize: $msgSize\n'
        'msgId: $msgId\n'
        'RequestId: $reId\n';

  }

}

class InputHeader{
  late int msgSize;
  late int msgId;
  late int reId;

  InputHeader({required this.msgSize, required this.msgId, required this.reId});

}

class Msg1101{
   int? h_id;
   int? roomCount;
   int? totalLength;
   List<TestRoomInfo>? testRoomInfos;

  Msg1101(){
    testRoomInfos = [];
  }
  void addTestRoomInfo(TestRoomInfo testRoomInfo){
    testRoomInfos!.add(testRoomInfo);
  }

  Msg1101.fromBytes(int length,List<int> bytes) {
    int index = length;
    this.h_id =  Util.readIntFromBytesBigEndian(bytes, index);
    index += 4;
    this.roomCount = Util.readIntFromBytesBigEndian(bytes, index);
    index +=4;
    print('roomCount $index roomCount $roomCount');
    testRoomInfos = [];
    for (int i = 0; i < roomCount!; i++) {
      TestRoomInfo testRoomInfo = TestRoomInfo.fromBytes(index, bytes);
      addTestRoomInfo(testRoomInfo);
      this.totalLength = 16+4+testRoomInfo.totalLength!;
      index += testRoomInfo.totalLength!;
    }
  }

  @override
  String toString() {
    // TODO: implement toString
    return 'h_id: $h_id\n'
        'roomCount: $roomCount\n'
        'totalLength: $totalLength\n'
        'patientInfos: $testRoomInfos\n';
  }
}

class TestRoomInfo{
   int? roomNumber;
   int? type;
   int? patientsNameLength;
   String? patientName;
   int? chartNumberLength;
   String? chartNumber;
   int? totalLength ;


  TestRoomInfo.fromBytes(int length,List<int> bytes) {
    int index = length;
    this.roomNumber = Util.readIntFromBytesBigEndian(bytes, index);
    index += 4;
    this.type = bytes[index++];
    this.patientsNameLength = Util.readIntFromBytesBigEndian(bytes, index);
    index += 4;
    List<int> name = bytes.sublist(index, index + patientsNameLength!);
    this.patientName = utf8.decode(name);
    index += name.length;
    this.chartNumberLength = Util.readIntFromBytesBigEndian(bytes, index);
    index += 4;
    List<int> chart = bytes.sublist(index, index + chartNumberLength!);
    this.chartNumber = utf8.decode(chart);
    this.totalLength = 4 + 1 + 4 + patientsNameLength! + 4 + chartNumberLength!;
  }

  @override
  String toString() {
    return 'Room Number: $roomNumber\n'
        'Type: $type\n'
        'patientsNameLength: $patientsNameLength\n'
        'patientName: $patientName\n'
        'chartNumberLength: $chartNumberLength\n'
        'chartNumber: $chartNumber\n'
        'totalLength: $totalLength';
  }



}

class Msg1103{
  int? roomNumber;
  String? macAddress;
  int? type;
  int? data;

  Msg1103({this.roomNumber, this.macAddress, this.type, this.data});



  Msg1103.fromBytes(int length, List<int> bytes){
    int index = length;
    this.roomNumber = Util.readIntFromBytesBigEndian(bytes, index);
    index +=4;
    this.macAddress = Util.bytesToHex([bytes[index],bytes[index+1],bytes[index+2],bytes[index+3],bytes[index+4]]);
    index+=6;
    this.type = bytes[index++];
    this.data = Util.readIntFromBytesBigEndian(bytes, index);
    //Util.log.e(toString());
  }

  @override
  String toString() {
    // TODO: implement toString
    return 'Room Number: $roomNumber\n'
        'macAddress: $macAddress\n'
        'type: $type\n'
        'data: $data\n';
  }

}


//보냄
class Message2101 extends InputHeader{
  late int hospitalId;
  late int vetId;
  late bool isReceivedData;

  Message2101({
    required super.msgSize, required super.msgId, required super.reId,
    required this.hospitalId,
    required this.vetId,
    required this.isReceivedData
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

//보냄
class Message2102 extends InputHeader{
  late bool isReceivedData;
  Message2102({required super.msgSize,
                 required super.msgId,
                  required super.reId,
                  required this.isReceivedData});

  List<int> toByteArray() {
    final buffer = ByteData(13);
    buffer.setInt32(0, msgSize);
    buffer.setInt32(4, msgId);
    buffer.setInt32(8, reId);
    buffer.setUint8(12,  isReceivedData ? 1 : 0);
    return buffer.buffer.asUint8List();
  }
}

//----------------------------------------------------------------


class Message2201 {
   int? connectedMultiAppCount;
   List<MultiAppData>? multiAppDatas;

  Message2201(){
    multiAppDatas = [];
  }

  void addMultiAppData(MultiAppData multiAppData){
    multiAppDatas!.add(multiAppData);
  }

  Message2201.fromBytes(int length, List<int> bytes) {
    int index = length;
    this.connectedMultiAppCount = Util.readIntFromBytesBigEndian(bytes, index);
    index += 4;
    multiAppDatas =[];
    MultiAppData multiAppData;
    for (int i = 0; i < connectedMultiAppCount!; i++) {
      multiAppData = MultiAppData.fromBytes(index, bytes);
      addMultiAppData(multiAppData);
      index += multiAppData.RoomInfosLength;
    }
  }

  @override
  String toString() {
    // TODO: implement toString
    return '연결되어있는 모니터링앱 갯수: $connectedMultiAppCount\n'
        '모니터링앱이 관리하는 데이터: ${multiAppDatas!.length}\n'
        '방갯수 : ${multiAppDatas![0].roomCount}\n'

    ;
  }

}

class MultiAppData{
   String? multiAppUUID;
   int? roomCount;
   List<RoomInfo>? RoomInfos;
   late int RoomInfosLength ;

  MultiAppData(){
    RoomInfos = [];
  }

  void addRoomInfos(RoomInfo roomInfo){
    this.RoomInfos!.add(roomInfo);
  }

  MultiAppData.fromBytes(int length,List<int> bytes) {
    RoomInfosLength = 0;
    int index = length;
    List<int> listuuid = bytes.sublist(index, index + 36);
    this.multiAppUUID = utf8.decode(listuuid);
    index += 36;
    this.roomCount = Util.readIntFromBytesBigEndian(bytes, index);
    index +=4;
    RoomInfos = [];
    for (int i = 0; i < roomCount!; i++) {
      RoomInfo roomInfo = RoomInfo.fromBytes(index, bytes);
      addRoomInfos(roomInfo);
      RoomInfosLength +=RoomInfos![i].totalLength!;
      index+=RoomInfos![i].totalLength!;
      Util.log.e(RoomInfos![i].toString());
      Util.log.e('총 ${RoomInfosLength}');
    }
  }

  @override
  String toString() {
    // TODO: implement toString
    return 'multiAppUUID: $multiAppUUID\n'
        'RoomInfoslength: ${RoomInfos?.length}\n'
        'RoomInfosLength: $RoomInfosLength\n';
  }
}

class RoomInfo {
   int? roomId;
   int? type;
   int? roomNameLength;
   int? patientsNameLength;
   int? chartNumberLength;
   String? roomName;
   String? patientName;
   String? chartNumber;
   int? totalLength ;


   RoomInfo.fromBytes(int length,List<int> bytes) {
    int index = length;
    this.roomId = Util.readIntFromBytesBigEndian(bytes, index);
    index += 4;
    this.type = bytes[index++];
    this.roomNameLength =Util.readIntFromBytesBigEndian(bytes, index);
    index += 4;
    List<int> listRoomName = bytes.sublist(index, index + roomNameLength!);
    this.roomName = utf8.decode(listRoomName);
    index += listRoomName.length;
    this.patientsNameLength = Util.readIntFromBytesBigEndian(bytes, index);
    index += 4;
    List<int> listPatientName = bytes.sublist(index, index + patientsNameLength!);
    this.patientName = utf8.decode(listPatientName);
    index += listPatientName.length;
    this.chartNumberLength = Util.readIntFromBytesBigEndian(bytes, index);
    index += 4;
    List<int> listChartName = bytes.sublist(index, index + chartNumberLength!);
    this.chartNumber = utf8.decode(listChartName);
    index+=listChartName.length;
    this.totalLength = 16+1+roomNameLength!+patientsNameLength!+chartNumberLength!;
    //Util.log.e('하나의 클래스길이는 몇입니까? : $totalLength');
   // Util.log.e('현재 인덱스길이는 몇입니까? ${index.toString()}');
    //this.totalLength = 4+4 + 1 + 4 + patientsNameLength! + 4 + chartNumberLength!;
  }

  @override
  String toString() {
    return
        'roomId: $roomId\n'
        'Type: $type\n'
        'Patient Name: $patientName\n'
        'totalLength: $totalLength\n'
        'Chart Number: $chartNumber';
  }




}


// class Message2202{
//    late int MultiAppuuid;
//    late int RoomCount;
//    late List<RoomInfo> roomInfos;
//
//    Message2202(){
//      roomInfos = [];
//    }
//    void addRoomInfo(RoomInfo roomInfo){
//      roomInfos.add(roomInfo);
//    }
//
//    Message2202.fromBytes(int length, List<int> bytes) {
//      int index = length;
//      this.MultiAppuuid = Util.readIntFromBytesBigEndian(bytes, index);
//      index += 16;
//      this.RoomCount = Util.readIntFromBytesBigEndian(bytes, index);
//      index +=4;
//      roomInfos = [];
//      for (int i = 0; i < RoomCount; i++) {
//        RoomInfo roomInfo = RoomInfo.fromBytes(index, bytes);
//        addRoomInfo(roomInfo);
//        index += roomInfo.totalLength;
//      }
//    }
//
// }


// class RoomInfo {
//   late int roomId;
//   late int roomNumber;
//   late int type;
//   late int patientsNameLength;
//   late int chartNumberLength;
//   late String patientName;
//   late String chartNumber;
//   late int totalLength ;
//
//
//   RoomInfo.fromBytes(int length,List<int> bytes) {
//     int index = length;
//     this.roomId = Util.readIntFromBytesBigEndian(bytes, index);
//     index += 4;
//     this.roomNumber = Util.readIntFromBytesBigEndian(bytes, index);
//     index += 4;
//     this.type = bytes[index++];
//     this.patientsNameLength = Util.readIntFromBytesBigEndian(bytes, index);
//     index += 4;
//     List<int> name = bytes.sublist(index, index + patientsNameLength);
//     this.patientName = utf8.decode(name);
//     index += name.length;
//     this.chartNumberLength = Util.readIntFromBytesBigEndian(bytes, index);
//     index += 4;
//     List<int> chart = bytes.sublist(index, index + chartNumberLength);
//     this.chartNumber = utf8.decode(chart);
//     this.totalLength = 4 + 1 + 4 + patientsNameLength + 4 + chartNumberLength;
//   }
//
//   @override
//   String toString() {
//     return 'Room Number: $roomNumber\n'
//         'Room roomId: $roomId\n'
//         'Type: $type\n'
//         'Patient Name: $patientName\n'
//         'totalLength: $totalLength\n'
//         'Chart Number: $chartNumber';
//   }
//
//
//
//
// }

class Message2203{
  late int multiAppUUID;

  Message2203.fromBytes(int lenth, List<int> bytes){
    int index = lenth;
    this.multiAppUUID = Util.readIntFromBytesBigEndian(bytes, index);
  }

}


class Message2204{
 late int multiAppUUID;
 late int actionType;



}
class Message2205{

}

class Message2206{

}

class Message2207{

}