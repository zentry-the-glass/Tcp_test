import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter_tcp_test/MultiAppDatas.dart';

import 'SocketModel.dart';
import 'SocketModel.dart';
import 'Util.dart';



class TestModel extends ChangeNotifier{
  int headerSize =12;
  Socket? _socket;
  Message2201? _message2201 = Message2201();
  Message2204? _message2204 = Message2204();
  bool _isConnected = false;
  int _count = 0;
  int get count => _count;
  Socket? get socket =>_socket;
  Message2201? get message2201 => _message2201;
  Message2204? get message2204 => _message2204;
  //Message2205? get message2205 => _message2205;

  bool get isConnected => _isConnected;

  void setData(int msgId, var bodyArr){
    switch (msgId){
      case 2201:
        _message2201 = Message2201.fromBytes(headerSize, bodyArr);
        notifyListeners();
      break;
       case 2204:
        _message2204 = Message2204.fromBytes(headerSize, bodyArr);
        notifyListeners();
        //roomUpdate(_message2204!,_message2201!);
    }
   //
  }

  void roomUpdate(Message2204 message2204,Message2201 message2201){
    Util.log.e('roomUpdate');
    var uuid = _message2204!.multiAppUUID;
    var roominfo = _message2204!.roominfo;
    Util.log.e(message2204.toString());
    switch(message2204.actionType){
      case 0:
        Util.log.e('삭제');
        Util.log.e(_message2201.toString());
        Util.log.e(uuid);
        Util.log.e(_message2201?.multiAppDatas?.map((e) => Util.log.e(e.multiAppUUID)));
        _message2201!.multiAppDatas!.map((e) => e.multiAppUUID==uuid?()=>{
           e.removeRoomInfo(roominfo!.roomId!)
        }: e);
        // _message2201!.multiAppDatas?.map((e){
        //   Util.log.e(e.toString());
        //   if(e.multiAppUUID==uuid){
        //     Util.log.e('룸 삭제전 ${e.roomCount}');
        //      e.removeRoomInfo(roominfo!.roomId!);
        //     Util.log.e('룸 삭제후 ${e.roomCount}');
        //   }else{
        //     return;
        //   }
        // });
        break;
      case 1:
      //추가
        _message2201!.multiAppDatas?.map((e){
          Util.log.e(e.toString());
          Util.log.e(e.multiAppUUID);
          Util.log.e(uuid);
          if(e.multiAppUUID==uuid){
            Util.log.e('룸 추가전 ${e.roomCount}');
            e.addRoomInfos(roominfo!);
            Util.log.e('룸 추가후 ${e.roomCount}');
          }else{
            return;
          }
        });
        Util.log.e('추가');
        break;

      case 2:
      //업데이트
        _message2201!.updateMultiAppData(uuid!, roominfo!);
        Util.log.e('수정');
        break;

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
    _socket!.destroy();
    notifyListeners();
  }

  void sendMsg(var bytes){
    Util.log.e('input2101 보낸 bytes 값 : $bytes');
    _socket!.add(bytes);
    _socket!.flush();
  }
}

class Value extends ChangeNotifier{
  int headerSize =12;
  Message2205? _message2205 = Message2205();
  Message2205? get message2205 => _message2205;

  void setData(int msgId, var bodyArr){
    switch (msgId){
      case 2205:
        _message2205 = Message2205.fromBytes(headerSize, bodyArr);
        //Util.log.e(_message2205.toString());
        notifyListeners();
        break;
    }
    //
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



//----------------------------------------------------------------

class Message2201 {
   int? connectedMultiAppCount;
   List<MultiAppData>? multiAppDatas;

   Message2201({this.connectedMultiAppCount, this.multiAppDatas});

  void addMultiAppData(MultiAppData multiAppData){
    multiAppDatas!.add(multiAppData);
    //this.connectedMultiAppCount= multiAppDatas!.length;
  }

   void updateMultiAppData(String uuid, RoomInfo roomInfo) {
    multiAppDatas!.map((e) {
      Util.log.e(e.toString());
       if (e.multiAppUUID == uuid) {
          e.RoomInfos!.map((e) {
            if(e.roomId==roomInfo.roomId){
              Util.log.e('기존 ${e}');
              Util.log.e('업데이트 ${roomInfo}');
              return e = roomInfo;
            }});
        } else {
          return e;
       }
     });
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

   factory Message2201.fromJson(Map<String, dynamic> json) {
     return Message2201(
       connectedMultiAppCount: json['connectedMultiAppCount'],
       multiAppDatas: (json['multiAppDatas'] as List<dynamic>?)
           ?.map((e) => MultiAppData.fromJson(e as Map<String, dynamic>))
           .toList(),
     );
   }

   Map<String, dynamic> toJson() {
     final Map<String, dynamic> data = <String, dynamic>{};
     data['connectedMultiAppCount'] = connectedMultiAppCount;
     data['multiAppDatas'] =
         multiAppDatas?.map((e) => e.toJson()).toList(growable: false);
     return data;
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
   // this.roomCount =this.RoomInfos!.length;
  }

   void updateRoomInfos(RoomInfo roomInfo) {
     Util.log.e('리스트 값 변경전 ${this.RoomInfos.toString()}');
     this.RoomInfos = RoomInfos!.map((e) {
       if (e.roomId == roomInfo.roomId) {
         return e = roomInfo;
       } else {
         return e;
       }
     }).toList();

     Util.log.e('리스트 값 변경후 ${this.RoomInfos.toString()}');
   }


   void removeRoomInfo(int roomId) {
     this.RoomInfos!.remove((room) => room.roomId == roomId);
    // this.roomCount =this.RoomInfos!.length;
     // removedInfo 변수에는 삭제된 RoomInfo 요소가 들어갑니다.
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
     // Util.log.e(RoomInfos![i].toString());
     // Util.log.e('총 ${RoomInfosLength}');
    }
  }

   MultiAppData.fromJson(Map<String, dynamic> json) {
     this.roomCount = json['roomcount'];
     this.multiAppUUID = json['multiAppUUID'];
     if (json['RoomInfos'] != null) {
       RoomInfos = <RoomInfo>[];
       json['RoomInfos'].forEach((v) {
         RoomInfos!.add(RoomInfo.fromJson(v));
       });
     }
   }

   Map<String, dynamic> toJson() {
     final Map<String, dynamic> data = new Map<String, dynamic>();
     data['roomcount'] = this.roomCount;
     data['multiAppUUID'] = this.multiAppUUID;
     if (this.RoomInfos != null) {
       data['RoomInfos'] =
           this.RoomInfos!.map((v) => v.toJson()).toList();
     }
     return data;
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
   int? totalLength;
   int? DataType0;
   int? DataType1;

   RoomInfo({
     this.roomId,
     this.type,
     this.roomNameLength,
     this.patientsNameLength,
     this.chartNumberLength,
     this.roomName,
     this.patientName,
     this.chartNumber,
     this.totalLength,
   });

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

   Map<String, dynamic> toJson() {
     final Map<String, dynamic> data = new Map<String, dynamic>();
     data['roomId'] = this.roomId;
     data['type'] = this.type;
     data['roomNameLength'] = this.roomNameLength;
     data['patientsNameLength'] = this.patientsNameLength;
     data['chartNumberLength'] = this.chartNumberLength;
     data['roomName'] = this.roomName;
     data['patientName'] = this.patientName;
     data['chartNumber'] = this.chartNumber;
     data['totalLength'] = this.totalLength;
     return data;
   }

   factory RoomInfo.fromJson(Map<String, dynamic> json) {
     return RoomInfo(
       roomId: json['roomId'],
       type: json['type'],
       roomNameLength: json['roomNameLength'],
       patientsNameLength: json['patientsNameLength'],
       chartNumberLength: json['chartNumberLength'],
       roomName: json['roomName'],
       patientName: json['patientName'],
       chartNumber: json['chartNumber'],
       totalLength: json['totalLength'],
     );
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

//----------------------------------------------------------------

class Message2204{
  String? multiAppUUID;
  int? actionType;
  RoomInfo? roominfo;

  Message2204({this.multiAppUUID, this.actionType, this.roominfo});

  Message2204.fromBytes(int length, List<int> bytes){
    int index = length;
    List<int> listuuid = bytes.sublist(index, index + 36);
    this.multiAppUUID = utf8.decode(listuuid);
    index += 36;
    this.actionType = bytes[index++];
    this.roominfo=RoomInfo.fromBytes(index, bytes);

  }

  @override
  String toString() {
    return
      'multiAppUUID: $multiAppUUID\n'
          'actionType: $actionType\n'
          'roominfo: ${roominfo.toString()}';
  }



}


//----------------------------------------------------------------
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



class Message2205{
  String? MultiAppUUID;
  int? RoomID;
  String? DolittleMacAddress;
  int? DataType;
  int? Data;

  Message2205(
      {this.MultiAppUUID,
      this.RoomID,
      this.DolittleMacAddress,
      this.DataType,
      this.Data});


  Message2205.fromBytes(int lenth, List<int> bytes){
    int index = lenth;
    List<int> listuuid = bytes.sublist(index, index + 36);
    this.MultiAppUUID = utf8.decode(listuuid);
    index+=36;
    this.RoomID =Util.readIntFromBytesBigEndian(bytes, index);
    index += 4;
    List<int> Listmacaddress = bytes.sublist(index, index + 6);
    this.DolittleMacAddress = Util.bytesToHex(
        [Listmacaddress[0],
          Listmacaddress[1],
          Listmacaddress[2],
          Listmacaddress[3],
          Listmacaddress[4],
          Listmacaddress[5],
        ]);
    index += 6;
    this.DataType  = bytes[index++];
    this.Data = Util.readIntFromBytesBigEndian(bytes,index);
    index +=4;
  }

  @override
  String toString() {
    // TODO: implement toString
    return "MultiAppUUID : $MultiAppUUID\n "
            "RoomId : $RoomID\n"
            "address : $DolittleMacAddress\n"
            "dataType : $DataType\n"
            "data : $Data\n";
  }

  factory Message2205.fromJson(Map<String, dynamic> json) {
    return Message2205(
      MultiAppUUID: json['MultiAppUUID'],
      RoomID: json['RoomID'],
      DolittleMacAddress: json['DolittleMacAddress'],
      DataType: json['DataType'],
      Data: json['Data'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['MultiAppUUID'] = this.MultiAppUUID;
    data['RoomID'] = this.RoomID;
    data['DolittleMacAddress'] = this.DolittleMacAddress;
    data['DataType'] = this.DataType;
    data['Data'] = this.Data;
    return data;
  }

}

class Message2206{

}

class Message2207{

}