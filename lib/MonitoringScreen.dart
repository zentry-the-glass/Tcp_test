import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';
import 'SocketModel.dart';
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
    var is_bb =true;
    TestModel? testModel;
    Value? testvalue;
    Message2201? message2201;
    Message2205? message2205;
    Message2204? message2204;
    bool _isLoading = true;
    Socket? _socket;
    final player = AudioPlayer();

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
    final input =Message2101(msgSize:  21, msgId: 2101, reId: 1,hospitalId: 167,vetId: 55,isReceivedData: true);
    final bytes = input.toByteArray();
    print(testModel?.socket);
    if(testModel?.socket!=null){
      testModel!.sendMsg(bytes);
      Util.log.e(message2201?.multiAppDatas);
      setLoading(false);
    }else {
      setLoading(false);
      return;
    }
  }

  Future<void> bb() async {

    //수의사는 처음 1회 알람
    //그냥 반복
    //List<int> pattern = [0, 3000, 4000, 3000, 4000];
    //짧은 반복
    List<int> pattern = [0, 2000, 500, 2000, 500];
    while(is_bb){
      Vibration.vibrate(pattern: pattern);
    }
    Vibration.cancel();

  }
  void bcancel(){
    is_bb = false;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('monitoringScreen'),),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: EdgeInsets.all(2),
            child: Card(
              child: Container(
                padding: EdgeInsets.all(20),
                child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Patient detail',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                        ],
                      ),
                    ),
                    flex: 2,
                  ),
                  Expanded(
                      flex: 1,
                      child: Container(
                          child: Text(' | ',style: TextStyle(fontSize: 40,color: Colors.grey)))),
                  Expanded(
                      flex: 2,
                      child: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              GestureDetector(
                                  onTap: (){
                                    Util.log.e('진동');
                                    bb();
                                  },
                                  child: Icon(Icons.heart_broken,size: 30,)),
                              GestureDetector(
                                  onTap: (){
                                    Util.log.e('진동취소');
                                    bcancel();
                                  },
                                  child: Icon(Icons.account_tree_rounded,size: 30,)),
                            ],
                          )))
                ],
              ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              child: Consumer<TestModel>(
                builder: (context, data ,child){
                  message2201 = data.message2201;
                  if(message2201!.connectedMultiAppCount==null){
                    Util.log.e('null 로딩바 돌려야할듯');
                    return Text('연결 된 멀티 앱 없음 ');
                  }
                  else {
                    Util.log.e('2201 표가만들어질때만 rebuild');
                    c = message2201!.toJson();
                    if (message2201!.connectedMultiAppCount! <= 0) {
                      return Text ('연결 된 멀티 앱 없음');
                    } else {
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        itemCount: c['connectedMultiAppCount'],
                        itemBuilder: (BuildContext context, int index) {
                          Util.log.e(c['connectedMultiAppCount']);
                          final roomInfos = c['multiAppDatas'][index]['RoomInfos'];
                          final roomCount = c['multiAppDatas'][index]['roomcount'];
                          final multiAppUUID = c['multiAppDatas'][index]['multiAppUUID'];
                          return Container(
                            color: Colors.white60,
                            child: ListView.builder(
                              // physics: ClampingScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: roomCount,
                              itemBuilder: (BuildContext context, int index) {
                               final roomInfo = roomInfos[index];
                               return Container(
                                  width: double.infinity,
                                  margin: EdgeInsets.all(5),
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                      side: BorderSide(
                                        color: Colors.grey.withOpacity(0.5),
                                        width: 2,
                                      ),
                                    ),
                                    child: Container(
                                      padding: EdgeInsets.all(10),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          Expanded(
                                            child: Container(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text('${roomInfo['patientName']}',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                                                  Text('Room No.${roomInfo['roomName']}'),
                                                  Text('Chart No.${roomInfo['chartNumber']}'),
                                                ],
                                              ),
                                            ),
                                            flex: 2,
                                          ),
                                          Expanded(
                                              flex: 1,
                                              child: Container(
                                                  child: Text(' | ',style: TextStyle(fontSize: 40,color: Colors.grey)))),
                                          Expanded(
                                              flex: 2,
                                              child: Container(
                                                  child: DataValue(roomInfo)
                                           ))
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    }
                  }
                }
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget DataValue(Map roomInfo){
    return Consumer<Value>(
        builder: (context,data,child) {
              message2205 = data.message2205;
                if(message2205!.Data==null){
                  return  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text('3',
                        style: TextStyle(fontSize:30, fontWeight: FontWeight.bold, color: Color(0xFF27C32B)),),
                      Text('12',
                        style: TextStyle(fontSize: 30 , fontWeight: FontWeight.bold,color: Color(0xFF45A1FF)),),
                    ],
                  );
                 }else{
                  Util.log.e('데이터 값이바뀔때 여기서 구축이 이루어짐');
                  var multiAppUUID = message2205!.MultiAppUUID;
                  var roomId = message2205!.RoomID;
                  var type = message2205!.DataType;
                  var dataValue = message2205!.Data;
                 for (var i = 0; i < c['connectedMultiAppCount']; i++) {
                            var multiApp = c['multiAppDatas'][i];
                            if (multiApp['multiAppUUID'] == multiAppUUID) {
                              var roomInfos = multiApp['RoomInfos'];
                              for (var j = 0; j < roomInfos.length; j++) {
                                var roomInfoData = roomInfos[j];
                                if (roomInfoData['roomId'] == roomId) {
                                  roomInfoData['dataType$type'] = dataValue;
                                }
                              }
                     }
                 }
                 return  Row(
                   mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text('${roomInfo['dataType0']}',
                              style: TextStyle(fontSize:30, fontWeight: FontWeight.bold, color: Color(0xFF27C32B)),),
                            Text('${roomInfo['dataType1']} ',
                              style: TextStyle(fontSize: 30 , fontWeight: FontWeight.bold,color: Color(0xFF45A1FF)),),
                          ],
                        );
                }});}


}
