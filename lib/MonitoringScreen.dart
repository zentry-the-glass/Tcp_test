import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'SocketModel.dart';
import 'Util.dart';


class MonitoringScreen extends StatefulWidget {
  const MonitoringScreen({Key? key}) : super(key: key);

  @override
  State<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends State<MonitoringScreen> {
    TestModel? testModel;
    Message2201? message2201;
  //late Msg1103 msg1103 ;
  bool _isLoading = true;
  Socket? _socket;

  @override
  void initState() {
    testModel = Provider.of<TestModel>(context, listen:false);
    sendMsg();
    super.initState();
  }

  void setLoading(bool a){
    setState(() {
      _isLoading = a;
    });
  }




  void sendMsg(){
    final input =Message2101(msgSize:  21, msgId: 2101, reId: 1,hospitalId: 171,vetId: 55,isReceivedData: true);
    final bytes = input.toByteArray();
    testModel!.sendMsg(bytes);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('monitoringScreen'),),
      body: Container(child:
      Consumer<TestModel>(
        builder: (context, data ,child){
          message2201= data.message2201!;
          if(message2201!.connectedMultiAppCount==null){
            Util.log.e('null 로딩바 돌려야할듯');
            return Text('연결된 멀티앱 없음');
          }
          return ListView.builder(
            /**
             * 이부분을 계속 리로드 할 것 이냐 아니면 내부에 값만 리로드할 것 이냐
             *
             * */
            itemCount: message2201!.multiAppDatas![0].roomCount,
              itemBuilder: (BuildContext context, int index){
              Util.log.e(message2201!.multiAppDatas![0].roomCount);
              RoomInfo roomInfo = message2201!.multiAppDatas![0].RoomInfos![index];
              return testCard(roomInfo);
          }) ;
        },
      ),),
    );
  }

  Widget testCard(RoomInfo roomInfo){
    Util.log.e('reload');
    return Text('방번호 ${roomInfo.roomName}');
  }

  Widget MyWidget(TestRoomInfo roomInfo, Msg1103 msg1103){

    Util.log.e('만들어진 정보${roomInfo.roomNumber}');
    Util.log.e('들어오는 정보 ${msg1103.roomNumber}');
    return Card(
      child: Container(
        child: Column(
        children: [
          Text('방 번호 ${roomInfo.roomNumber}'),
          Text('방번호  ${msg1103.roomNumber}  값 ${roomInfo.roomNumber==msg1103.roomNumber?'${msg1103.data}':'0'} '),
          Text('환자 이름 ${roomInfo.patientName}'),
        ],
      ),),
    );
    // TestRoomInfo? machedroomInfo;
    // for(TestRoomInfo roomInfo in testRoomInfo){
    //   Util.log.e(roomInfo);
    //   if(roomInfo.roomNumber == msg1103.roomNumber){
    //     machedroomInfo = roomInfo;
    //     Util.log.e('room info ${roomInfo.toString()}');
    //     Util.log.e('room data ${msg1103.toString()}');
    //     break;
    //   }
    //
    // }
    // if(machedroomInfo == null){
    //   return Text('no');
    // }
    // return Text('있음');

  }



  // Widget roomCard(TestRoomInfo roomInfo){
  //   return Card(
  //       child: Row(
  //         children: [
  //           Expanded(
  //             flex: 2,
  //             child: Container(
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text('Name ${roomInfo.patientName}'),
  //                 Text('Number ${roomInfo.chartNumber}'),
  //                 Text('roomNumber  ${roomInfo.roomNumber}'),
  //                 Text('Type  ${roomInfo.type}'),
  //               ],
  //   ),
  //             ),
  //           ),
  //           Expanded(
  //               flex: 1,
  //               child:Container(
  //                 color: Colors.red,
  //                 child: Text('|'),
  //                 padding: EdgeInsets.all(20),)),
  //           Expanded(
  //             flex: 2,
  //             child: Container(
  //               color: Colors.orange,
  //               child: Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   Container(
  //                       color: Colors.white,
  //                       child: Text(' ${roomInfo.patientName}')),
  //                   Container(
  //                       color: Colors.white60,
  //                       child: Text(' ${roomInfo.chartNumber}')),
  //                 ],
  //               ),
  //             ),
  //           ),
  //           Padding(padding: EdgeInsets.only(right: 50))
  //         ],
  //
  //       ));
  // }

}

//var addr1 = Util.bytesToHex([bbyte[0], bbyte[1], bbyte[2], bbyte[3], bbyte[4], bbyte[5]]);