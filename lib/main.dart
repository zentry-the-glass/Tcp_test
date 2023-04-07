import 'package:flutter/material.dart';
import 'package:flutter_tcp_test/MainScreen.dart';
import 'package:flutter_tcp_test/MultiAppDatas.dart';
import 'package:flutter_tcp_test/SocketModel.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import 'Header.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context)=>TestModel(),
      child: MaterialApp(
        title: 'Tcp',
        home: LoginScreen(),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tcp'),),
      body: Center(
        child: Container(child:
        Column(
          children: [
            Padding(padding: EdgeInsets.all(50)),
            Text('Hospital Id : 171'),
            Text('Vet Id : 55'),
            Text('IsReceivedData : false'),
            Padding(padding: EdgeInsets.all(50)),
            ElevatedButton(onPressed: (){
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder:(context)=>MainScreen()));
            }, child: Text('로그인'))
          ],
        ),),
      ),
    );
  }
}



//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'TCP Chat',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home:  ChatScreen(),
//     );
//   }
// }
//
// class ChatScreen extends StatefulWidget {
//   @override
//   _ChatScreenState createState() => _ChatScreenState();
// }
//
// class _ChatScreenState extends State<ChatScreen> {
//   ScrollController _scrollController = ScrollController();
//   final TextEditingController _controller = TextEditingController();
//   final List<String> _messages = [];
//   Logger log = Logger();
//   late Timer _timer;
//   Socket? _socket ;
//   bool _isConnected = false;
//   var hospitalId = 171;
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
//     });
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     _scrollController.dispose();
//     if (_isConnected) {
//       _socket?.destroy();
//     }
//     super.dispose();
//   }
//
//
//
//   void addmsg(var a){
//     log.e('addmsg');
//     //메세지 추가
//       setState(() {
//         // 스크롤을 하단으로 이동
//
//           _messages.add('Received: ${a}');
//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
//           });
//
//
//       });
//
//   }
//
//   void _connect() async {
//     try {
//       _socket = await Socket.connect('192.168.0.89', 30000);
//
//      // _socket = await Socket.connect('172.30.1.2', 1234);
//
//       /**
//        *
//        * @휴대폰 와이파이 같게해야함
//        * _socket = await Socket.connect('192.168.0.66', 1234);
//        * 애뮬레이터
//        *  _socket = await Socket.connect('10.0.2.2', 1234);
//        * **/
//       setState(() {
//         _isConnected = true;
//       });
//
//       //데이터가 들어올때만 호출 됨
//       _socket?.listen(
//             (data) async {
//               log.e(data.toString());
//           List<String> hexArray = [];
//           for (var i = 0; i < data.length; i++) {
//             hexArray.add(data[i].toRadixString(16).padLeft(2, '0'));
//           }
//           List<int> dataArr = hexArray.map((hex) => int.parse(hex, radix: 16)).toList();
//           //들어온데이터가 null이 될때까지
//           log.e(dataArr.length);
//           HeadrTest headrTest = HeadrTest.fromBytes(0, dataArr);
//           log.e('msgSize ${headrTest.msgSize} msgId ${headrTest.msgId}  RequestId ${headrTest.RequestId}');
//           while (dataArr.isNotEmpty) {
//             if(dataArr.length<headrTest.msgSize){
//               List subList = dataArr.sublist(0);
//               log.e('지금 남아있는 data Size야${dataArr.length} 여기서 msgSize빼야돼 ${headrTest.msgSize}');
//               log.e('부족해 ${dataArr.length-headrTest.msgSize}');
//               dataArr.clear();
//             }
//             else{
//               var bodyArr = dataArr;
//
//               if(headrTest.msgId==1101) {
//                  Message1101 message = Message1101.fromBytes(Util.HeaderSize, bodyArr);
//                  for(var i=0; i<message.RoomCount; i++){
//                    log.e(message.patients[i].toString());
//                    addmsg(message.patients[i].toString());
//                  }
//               }
//               else if(headrTest.msgId==2201){
//                 log.e('Message2201 여기들어옴');
//                 Message2201 message = Message2201.fromBytes(Util.HeaderSize, bodyArr);
//                 log.e(message.toString());
//                 for(var i=0; i<message.connectedMultiAppCount; i++){
//                   for(var i=0; i<message.multiAppDatas[i].roomCount; i++){
//                     log.e(message.multiAppDatas[i].patientInfos[i].toString());
//                   }
//                 }
//               }
//               log.e('남은 dataArr${dataArr.length}');
//                //dataArr.removeRange(0, headrTest.msgSize);
//             }
//             log.e('멈춤 dataArr${dataArr.length}');
//             break;
//            }
//
//         },
//
//         onError: (error) {
//           log.e(error);
//           print('Error: $error');
//           _socket?.destroy();
//           setState(() {
//             _isConnected = false;
//           });
//         },
//         onDone: () {
//           log.e('Server disconnected');
//           print('Server disconnected');
//           _socket?.destroy();
//           setState(() {
//             _isConnected = false;
//           });
//         },
//       );
//     } catch (e) {
//       log.e(e);
//       print('Error: $e');
//     }
//   }
//
//   void _send() {
//     final input = Input2101(msgSize:  21, msgId: 2101, reId: 1,hospitalId: hospitalId,vetId: 200,isReceivedData: true);
//     final bytes = input.toByteArray();
//     log.e('input2101 보낸 bytes 값 : $bytes');
//     _socket?.add(bytes);
//     _socket?.flush();
//   }
//
//
//   Widget _buildMessageList() {
//     return Expanded(
//       child: ListView.builder(
//         controller: _scrollController,
//         itemCount: _messages.length,
//         itemBuilder: (context, index) {
//           final message = _messages[index];
//           return ListTile(
//             title: Container(
//                 margin: EdgeInsets.all(10),
//                 color: Colors.amberAccent,
//                 child: Text(message)),
//           );
//         },
//       ),
//     );
//   }
//
//
//   List<int> convertByteArrayToIntList(List<int?> byteArray) {
//     List<int> intList = [];
//     for (var i = 0; i < byteArray.length; i += 4) {
//       int value = 0;
//       for (var j = 0; j < 4; j++) {
//         value += (byteArray[i + j]! << (8 * (3 - j)));
//       }
//       intList.add(value);
//     }
//     return intList;
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('TCP Chat'),
//         leading: IconButton(onPressed: (){
//           log.e('tcp 연결 실행');
//           _connect();
//         }, icon: const Icon(Icons.add_circle_outline)),
//       ),
//       body: Container(
//         margin: const EdgeInsets.fromLTRB(0, 20, 0, 20),
//         child: Column(
//           children: [
//             _buildMessageList(),
//             TextField(
//               controller: _controller,
//               decoration: InputDecoration(
//                   suffixIcon: IconButton(onPressed: (){
//                     _send();
//                   }, icon: Icon(Icons.send))
//               ),
//             )
//             // TextField(
//             //   controller: _controller,
//             //   enabled: _isConnected,
//             //   decoration: InputDecoration(
//             //     labelText: 'Message',
//             //     suffixIcon: IconButton(
//             //       icon: Icon(Icons.send),
//             //       onPressed: _isConnected
//             //           ? () => _send(_controller.text)
//             //           : null,
//             //     ),
//             //   ),
//             // ),
//           ],
//         ),
//       ),
//       // floatingActionButton: FloatingActionButton(
//       //   child: Icon(Icons.connected_tv),
//       //   onPressed: _isConnected ? null : _connect,
//       // ),
//
//     );
//   }
// }
//
//

