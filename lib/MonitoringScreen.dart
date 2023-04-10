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
    var c = {};
    var dataType1 = 0;
    var dataType2 = 0;
    TestModel? testModel;
    Value? testvalue;
    Message2201? message2201;
    Message2205? message2205;
    bool _isLoading = true;
    Socket? _socket;

  @override
  void initState() {
    testModel = Provider.of<TestModel>(context, listen:false);
    testvalue = Provider.of<Value>(context,listen:false);
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
          message2201 = data.message2201;
          if(message2201!.connectedMultiAppCount==null){
            Util.log.e('null 로딩바 돌려야할듯');
            return Text('연결된 멀티앱 없음');
          }else {
            List<RoomInfo>? roomInfos = message2201!.multiAppDatas![0].RoomInfos;
            for (int i = 0; i <roomInfos!.length; i++) {
              c['roomId${roomInfos[i].roomId}']={
                'patientName':roomInfos[i].patientName,
                'chartnum':roomInfos[i].chartNumber,
                'roomnum':roomInfos[i].roomName,
                'DataType0':dataType1,
                'DataType1':dataType2
              };
            }
            return ListView.builder(
                itemCount: message2201!.multiAppDatas![0].roomCount,
                itemBuilder: (BuildContext context, int index) {
                  var rooms = message2201!.multiAppDatas![0].RoomInfos;
                  return testCard(rooms![index]);
                });
          }
        },
      ),),
    );
  }

    Widget testCard(RoomInfo roomInfo){
      return Card(
        child: Row(
          children: [
            Column(
              children: [
                Text('환자 이름 ${roomInfo.patientName}'),
                Text('차트 번호 ${roomInfo.chartNumber}'),
                Text('방 Num ${roomInfo.roomId}'),
              ],
            ),
            Container(margin: EdgeInsets.all(40),),
            Consumer<Value>(
                builder: (context, data, child) {
                  if(data.message2205?.RoomID!= null){
                    message2205 =data.message2205;
                    c['roomId${message2205!.RoomID}']['DataType${message2205!.DataType}']=message2205!.Data;
                    return valueCara(roomInfo.roomId, message2205!);
                  }else{
                    return Row(
                      children: [
                        Text('심박'),
                        Container(margin: EdgeInsets.all(10),),
                        Text('호흡'),
                      ],
                    );
                  }
                }
            ),
          ],
        ),
      );
    }

   Widget valueCara(var roomId, Message2205 data){
    Util.log.e(c.toString());
   return Expanded(
     child: Container(
       child: Row(
         children: [
           Text('심박 ${
               c['roomId$roomId']['DataType0'].toString()
           }'),
           Text('호흡 ${
               c['roomId$roomId']['DataType1'].toString()
           }'),
         ],
       ),
     ),
   );
  }

}
