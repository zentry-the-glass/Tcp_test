import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter_tcp_test/MultiAppDatas.dart';
import 'package:vibration/vibration.dart';

import 'SocketModel.dart';
import 'SocketModel.dart';
import 'Util.dart';



class TestModel extends ChangeNotifier{
  int headerSize =12;
  Socket? _socket;
  Message2201? _message2201 = Message2201();
  Message2204? _message2204 = Message2204();
  Message2203? _message2203 = Message2203();
  Message2205? _message2205 = Message2205();
  Message2205? get message2205 => _message2205;
  bool _isConnected = false;
  static Map monitoringList={};
  int _count = 0;
  //Map get monitoringList =>_monitoringList;
  int get count => _count;
  Socket? get socket =>_socket;
  Message2201? get message2201 => _message2201;
  Message2204? get message2204 => _message2204;
  //Message2205? get message2205 => _message2205;


  bool get isConnected => _isConnected;

  void setData(int msgId, var bodyArr){
    switch (msgId){
      case 2201:
        Util.log.e('전체입원장 정보 메세지 받아오기!!!');
        _message2201 = Message2201.fromBytes(headerSize, bodyArr);
         Util.log.e(_message2201?.toJson().toString());
       // _monitoringList = message2201!.toJson();
        //monitoringList = _message2201!.toJson();
        notifyListeners();
      break;
       case 2204:
         //방정보변경
        _message2204 = Message2204.fromBytes(headerSize, bodyArr);
        //notifyListeners();
        roomUpdate(_message2204!);
        //그냥 여기서 json 을 만들어서 아예넘겨버리면 간섭안해도 되고 편할듯
      break;
      case 2202:
        //테블릿하나더킴 == 앱하나 더킴
        var a = MultiAppData.fromBytes(headerSize, bodyArr);
        //Util.log.e(a.toJson());
        _message2201!.addMultiAppData(a);
        _message2201?.connectedMultiAppCount= _message2201?.multiAppDatas?.length;
        notifyListeners();
        break;

      case 2203:
        //멀티모니터링앱 끊김
      Util.log.e('멀티 끊김');
         _message2203 = Message2203.fromBytes(headerSize, bodyArr);
        for (var i = _message2201!.multiAppDatas!.length-1; i>=0; i--){
          if(_message2201!.multiAppDatas![i].multiAppUUID==_message2203!.multiAppUUID){
            _message2201!.multiAppDatas!.removeAt(i); // removeAt() 대신 remove() 메서드 사용
            _message2201?.connectedMultiAppCount=_message2201?.multiAppDatas?.length;
          }
        }
        notifyListeners();

      break;
      case 2207:

        break;

      case 2206:


        break;

      // case 2205:
      //   _message2205 = Message2205.fromBytes(headerSize, bodyArr);
      //   Util.log.e(_message2205!.toJson());
      //   notifyListeners();
      //
      //   break;

    }
   //
  }



  void roomUpdate(Message2204 message2204){
    Util.log.e('roomUpdate');
    Util.log.e(_message2201.toString());
    Util.log.e(message2204.toString());
    var uuid =  message2204.multiAppUUID;
    var roomInfoData = message2204.roominfo;
    //notifyListeners();
    //notifyListeners 띄우면 다시 처음 부터 구축이 되어진다.
    switch(message2204.actionType){
      case 0:
        Util.log.e('삭제');
        message2201?.multiAppDatas!
            .where((element) => element.multiAppUUID == uuid)
            .forEach((element) {
          final updatedRoomInfos = element.RoomInfos?.where((roomInfo) => roomInfo.roomId != roomInfoData?.roomId).toList();
          Util.log.e(updatedRoomInfos?.length.toString());
          final updatedRoomCount = updatedRoomInfos?.length ?? 0;
          element.RoomInfos = updatedRoomInfos;
          element.roomCount = updatedRoomCount;
        });

        Util.log.e('삭제');
        notifyListeners();
        break;
      case 1:
        message2201?.multiAppDatas!
            .where((element) => element.multiAppUUID == uuid)
            .forEach((element) {
          element.RoomInfos?.add(roomInfoData!);
          element.roomCount=element.RoomInfos?.length;
        });
        message2201?.connectedMultiAppCount=message2201?.multiAppDatas?.length;
        notifyListeners();

        break;

      case 2:
      //업데이
      _message2201?.multiAppDatas!
          .where((element) => element.multiAppUUID == uuid)
          .forEach((element) {
            final roomInfos = element.RoomInfos;
             if(roomInfos !=null){
               for(int i=0; i<roomInfos.length; i++){
                 final roomInfo = roomInfos[i];
                 if(roomInfo.roomId==roomInfoData?.roomId){
                   roomInfos[i] = roomInfoData!;
                   break;
                 }
               }
             }
         });
        message2201?.connectedMultiAppCount=message2201?.multiAppDatas?.length;
        notifyListeners();
        break;

    }
   // notifyListeners();
  }

  void s2201update(){}

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
  //bool isbell = false;
 // final _controller = StreamController<Message2205>();
  //Stream<Message2205> get stream =>_controller.stream;
  Message2205? _message2205 = Message2205();
  Message2206? _message2206 = Message2206();

  Message2206? get message2206 =>_message2206;
  Message2205? get message2205 => _message2205;


  void setData(int msgId, var bodyArr){
    switch (msgId){
      case 2205:
        _message2205 = Message2205.fromBytes(headerSize, bodyArr);
         notifyListeners();
        break;
      case 2206:
        _message2206 = Message2206.fromBytes(headerSize, bodyArr);
        notifyListeners();
        bell(true);
        break;
      case 2207:
        _message2206 = Message2206.fromBytes(headerSize, bodyArr);
        bell(false);
        notifyListeners();
        break;
    }
  }

  void bell(bool isbell){
    while(isbell){
      Vibration.vibrate(duration: 1000);
    }

  }

}


// class Streemvalue {
//   int headerSize =12;
//   StreamController<Message2205> _controller = StreamController<Message2205>();
//   Stream<Message2205> get stream =>_controller.stream;
//
//
//
//
//
//   void setData(int msgId, var bodyArr){
//     switch (msgId){
//       case 2205:
//          _controller.add(Message2205.fromBytes(headerSize, bodyArr));
//         //_message2205 = Message2205.fromBytes(headerSize, bodyArr);
//
//         break;
//       case 2206:
//         break;
//
//     }
//
//   }
//
// }




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

class room{
  static List<MultiAppData> multiAppDatas=[] ;

  static void a(MultiAppData multiAppData){
    multiAppDatas.add(multiAppData);
    Util.log.e(multiAppData.toString());
  }
}

class Message2201 {
   int? connectedMultiAppCount;
   List<MultiAppData>? multiAppDatas =[] ;

   Message2201({this.connectedMultiAppCount,  this.multiAppDatas});

  void addMultiAppData(MultiAppData multiAppData){
    multiAppDatas?.add(multiAppData);
  }

   void updateMultiAppData(Message2204 message2204) {
    Util.log.e(message2204.toString());


    // multiAppDatas!.map((e) {
    //   Util.log.e(e.toString());
    //    if (e.multiAppUUID == uuid) {
    //       e.RoomInfos!.map((e) {
    //         if(e.roomId==roomInfo.roomId){
    //           Util.log.e('기존 ${e}');
    //           Util.log.e('업데이트 ${roomInfo}');
    //           return e = roomInfo;
    //         }});
    //     } else {
    //       return e;
    //    }
    //  });
   }


  Message2201.fromBytes(int length, List<int> bytes) {
    //헤더를자르자
    int index = length;
    this.connectedMultiAppCount = Util.readIntFromBytesBigEndian(bytes, index);
    index += 4;
    for (int i = 0; i < connectedMultiAppCount!; i++) {
       MultiAppData multiAppData = MultiAppData.fromBytes(index, bytes);
       addMultiAppData(multiAppData);
       index = multiAppData.RoomInfosLength!;
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


    ;
  }

}

class MultiAppData{
   String? multiAppUUID;
   int? roomCount;
   List<RoomInfo>? RoomInfos;
   int? RoomInfosLength ;

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
    //RoomInfosLength = 0;
    int index = length;
    List<int> listuuid = bytes.sublist(index, index + 36);
    this.multiAppUUID = utf8.decode(listuuid);
    index += 36;
    this.roomCount = Util.readIntFromBytesBigEndian(bytes, index);
    index +=4;
    //56
    RoomInfos = [];
    for (int i = 0; i < roomCount!; i++) {
      RoomInfo roomInfo = RoomInfo.fromBytes(index, bytes);
      addRoomInfos(roomInfo);
      index+=RoomInfos![i].totalLength!;

      this.RoomInfosLength = index;
     // Util.log.e(RoomInfos![i].toString());
       //Util.log.e('총 ${RoomInfosLength}');
    }
    //Util.log.e(toString());
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
   int dataType0=0;
   int dataType1=0;


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
    //Util.log.e(bytes.length);
    //Util.log.e('index ${index}  몇부터 몇까지? ${index+roomNameLength!}');
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
     //Util.log.e(toString());
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
     data['dataType0']=this.dataType0;
     data['dataType1']=this.dataType1;

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
   String? multiAppUUID;


   Message2203({this.multiAppUUID});

  Message2203.fromBytes(int lenth, List<int> bytes){
    int index = lenth;
    List<int> listuuid = bytes.sublist(index, index + 36);
    this.multiAppUUID = utf8.decode(listuuid);
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
  String? MultiAppUUID;
  int? RoomID;
  int? AlarmType;

  Message2206({this.MultiAppUUID, this.RoomID, this.AlarmType});



  Message2206.fromBytes(int lenth, List<int> bytes){
    int index = lenth;
    List<int> listuuid = bytes.sublist(index, index + 36);
    this.MultiAppUUID = utf8.decode(listuuid);
    index+=36;
    this.RoomID =Util.readIntFromBytesBigEndian(bytes, index);
    index += 4;
    this.AlarmType  = bytes[index++];


  }

  @override
  String toString() {
    // TODO: implement toString
    return "MultiAppUUID : $MultiAppUUID\n "
        "RoomId : $RoomID\n"
        "AlarmType : $AlarmType\n";
  }

  factory Message2206.fromJson(Map<String, dynamic> json) {
    return Message2206(
      MultiAppUUID: json['MultiAppUUID'],
      RoomID: json['RoomID'],
      AlarmType: json['AlarmType'],

    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['MultiAppUUID'] = this.MultiAppUUID;
    data['RoomID'] = this.RoomID;
    data['AlarmType'] = this.AlarmType;
    return data;
  }

}

class Message2207{

}