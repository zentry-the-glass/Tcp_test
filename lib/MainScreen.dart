import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_tcp_test/Header.dart';
import 'package:flutter_tcp_test/MonitoringScreen.dart';
import 'package:flutter_tcp_test/SocketModel.dart';
import 'package:provider/provider.dart';

import 'Util.dart';



class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Socket? _socket;
  late TestModel testModel;
  late Value testValue;
  bool _isLoading = true;
  bool _isConnected = false;

  @override
  void initState() {
    // TODO: implement initState
     testModel = Provider.of<TestModel>(context, listen:false);
     testValue =  Provider.of<Value>(context, listen:false);
    _connect();
    super.initState();
  }

  Future<void> _connect() async {
      Util.log.e('tcp 연결');
      try {
        //  * @휴대폰 와이파이 같게해야함
        //        * _socket = await Socket.connect('192.168.0.66', 1234);
        //        * 애뮬레이터

            //        * **/
        //_socket = await Socket.connect('10.0.2.2', 30000);
        _socket = await Socket.connect('52.78.41.178', 30000);
        //_socket = await Socket.connect('192.168.0.66', 1234);
        testModel.setSocket(_socket);
        testModel.setConnected(true);
         sendMsg();
         if(testModel.socket==null){
           return;
         }else {
           testModel.socket!.listen((data) {
             reciveData(data);
           }, onError: (error) {
             setLoading(true);
             Util.log.e('socket connect err ${error.toString()}');
             testModel.setConnected(false);
             setLoading(false);
           }, onDone: () {
             setLoading(true);
             Util.log.e('Server disconnected');
             testModel.destroySocket();
             testModel.setConnected(false);
             setLoading(false);
           });
         }
      }catch(error){
        setLoading(true);
        Util.log.e('sconnected err ${error.toString()}');
        testModel.setConnected(false);
        setLoading(false);
      }
  }

  void sendMsg(){
    final input = Message2101(msgSize:  21, msgId: 2101, reId: 1,hospitalId: 167,vetId: 55,isReceivedData: false);
    final bytes = input.toByteArray();
    testModel.sendMsg(bytes);
  }

  void setLoading(bool a){
    setState(() {
      _isLoading = a;
    });
  }

  void reciveData(Uint8List data){
    List<int> dataList = data.toList();
    SHeader sHeader = SHeader.fromBytes(0, dataList);
    Util.log.e('msgSize ${sHeader.msgSize} msgId ${sHeader.msgId}  RequestId ${sHeader.reId}');
    while(dataList.isNotEmpty){
      //빈값이 아닐때까지 반복문 돌림
      if(dataList.length<sHeader.msgSize){
        //받아온데이터 길이가 설정된 데이터 크기 보다작으면 덜받음
      }else{
         var bodyArr = dataList;
       //  Util.log.e('데이터 사용하기전 데이터 길이 bodyArr ${dataList.length}');
         if(sHeader.msgId==2205){
           testValue.setData(sHeader.msgId, bodyArr);
         }else{
           testModel.setData(sHeader.msgId, bodyArr);
         }
         //testModel.setData(sHeader.msgId, bodyArr);
         dataList.removeRange(0,sHeader.msgSize);
         //Util.log.e('데이터 사용하기전 데이터 길이 bodyArr ${dataList.length}');
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Main')),
      body: Center(
        child: Container(child: Column(
          children: [
            Padding(padding: EdgeInsets.all(50)),
            Text('Main'),
            Padding(padding: EdgeInsets.all(50)),
            ElevatedButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>MonitoringScreen()));
            }, child: Text('모니터링 화면'))
          ],
        ),),
      )

    ,);
  }
}
