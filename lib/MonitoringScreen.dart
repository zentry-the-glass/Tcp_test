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
    Map<String, dynamic> jsonData = {};
    var c ={};
    var dataType0 = 0;
    var dataType1 = 0;
    TestModel? testModel;
    Value? testvalue;
    Message2201? message2201;
    Message2205? message2205;
    Message2204? message2204;
    bool _isLoading = true;
    Socket? _socket;

  @override
  void initState() {
    testModel = Provider.of<TestModel>(context, listen:false);
    testvalue = Provider.of<Value>(context,listen:false);
    super.initState();
  }

  void setLoading(bool a){
    setState(() {
      _isLoading = a;
    });
  }

  void sendMsg(){
    final input =Message2101(msgSize:  21, msgId: 2101, reId: 1,hospitalId: 167,vetId: 55,isReceivedData: true);
    final bytes = input.toByteArray();
    print(testModel?.socket);
    if(testModel?.socket!=null){
      testModel!.sendMsg(bytes);
      message2201 = testModel!.message2201;
      if(message2201?.connectedMultiAppCount==null){
        return;
      }else{
        jsonData = message2201!.toJson();
      }
    }else {
      return;
    }
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
            sendMsg();
            return Text('연결된 멀티앱 없음');
          }else {
            jsonData = message2201!.toJson();
            //Util.log.e(message2201!.toJson());
            for (var multiAppData in jsonData['multiAppDatas']) {
              c['${multiAppData['multiAppUUID']}'] = {};
              for (var roomInfo in multiAppData['RoomInfos']) {
                c['${multiAppData['multiAppUUID']}']['room_id${roomInfo['roomId']}'] = {
                  "Datatype0":dataType0,
                  "Datatype1":dataType1,
                };

              }
            }
            Util.log.e('${c.toString()}');
            return ListView.builder(
                itemCount: message2201!.connectedMultiAppCount,
                itemBuilder: (BuildContext context, int index) {
                  var multiAppDatas = message2201!.multiAppDatas![index];
                 // var rooms = message2201!.multiAppDatas![0].RoomInfos;
                  return multi(multiAppDatas);
                 // return testCard();
                });
           }
        },
      ),),
    );
  }

  Widget multi(MultiAppData multiAppData){
    return Column(
      children: [
        Container(
            color: Colors.blueAccent,
            child: Text('${multiAppData.multiAppUUID}')),
        Container(
          color: Colors.black12,
          height: multiAppData.roomCount!*50.0 ,
          child: ListView.builder(
              itemCount: multiAppData.roomCount,
              itemExtent: 50,
              itemBuilder: (BuildContext context, int index) {
                return Consumer<TestModel>(
                    builder: (context, data, child) {
                     message2204 = data.message2204;

                     return testCard(multiAppData.multiAppUUID,multiAppData.RoomInfos![index]);
                    }
                );
          }),
        )
      ],
    );
  }

    Widget testCard(var uuid, RoomInfo roomInfo){
      return Card(
        child: Row(
          children: [
            Column(
              children: [
                Expanded(child: Text('환자 이름 ${roomInfo.patientName}')),
                Expanded(child: Text('차트 번호 ${roomInfo.chartNumber}')),
                Expanded(child: Text('방 Num ${roomInfo.roomId}')),
              ],
            ),
            Container(margin: EdgeInsets.all(40),),
            Consumer<Value>(
                builder: (context, data, child) {
                  message2205 = data.message2205;
                  var upDatekey = message2205!.MultiAppUUID;
                  var upDateroomId= message2205!.RoomID;
                  var upDatetype = message2205!.DataType;
                  if(data.message2205?.RoomID!= null){
                    for (upDatekey in c.keys) {
                      c[upDatekey]['room_id$upDateroomId']['Datatype$upDatetype']=message2205!.Data;

                    }
                    return valueCara(roomInfo,upDatekey);
                  }else{
                    return Row(
                      children: [
                        Text('${roomInfo.roomId}'),
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

   Widget valueCara(RoomInfo roomInfo ,var uuid){
   return Expanded(
     child: Container(
       child: Row(
         children: [
           Text('방번호:${roomInfo.roomId}'),
           Text('심박 : ${c[uuid]['room_id${roomInfo.roomId}']['Datatype0']}'),
           Text('호흡 : ${c[uuid]['room_id${roomInfo.roomId}']['Datatype1']}'),
         ],
       ),
     ),
   );
  }

}
