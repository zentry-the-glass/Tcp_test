import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_tcp_test/MultiAppDatas.dart';
import 'package:logger/logger.dart';

import 'Header.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TCP Chat',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:  ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _messages = [];
  Logger log = Logger();

  Socket? _socket ;
  bool _isConnected = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    if (_isConnected) {
      _socket?.destroy();
    }
    super.dispose();
  }

  void _connect() async {
    try {
      _socket = await Socket.connect('192.168.0.66', 1234);
      /**
       *
       * @휴대폰 와이파이 같게해야함
       * _socket = await Socket.connect('192.168.0.66', 1234);
       * 애뮬레이터
       *  _socket = await Socket.connect('10.0.2.2', 1234);
       * **/
      setState(() {
        _isConnected = true;
      });
      _socket?.listen(
            (data) {
          //데이터가 들어올때만 호출 됨
          List<String> hexArray = [];
          for (var i = 0; i < data.length; i++) {
            hexArray.add(data[i].toRadixString(16).padLeft(2, '0'));
          }
          List<int> intArray = hexArray.map((hex) => int.parse(hex, radix: 16)).toList();
          List fruits =['A23','data','data2','A1','13','DD','msg2','33',8,9,10,11,12,13,14];
          int min = 2;
          int max = 8;
          Random random = Random();
          int testmsg_size = min + random.nextInt(max - min);

          //리스트를 나눠서 담는다
          List<List> saveData = [];
          while (fruits.isNotEmpty) {
              if(fruits.length<=testmsg_size){
                List subList = fruits.sublist(0);
                log.e('msg_size$testmsg_size 여기들어옴!!$subList');
                List newlist = List.filled(testmsg_size-subList.length, 'hello');
                saveData.add(subList+newlist);
                fruits.clear();
            }else{
                log.e('만들어진 msg_size:$testmsg_size');
                List subList = fruits.sublist(0, testmsg_size);
                log.e(subList);
                //saveData.add(subList);
                fruits.removeRange(0, testmsg_size);
              }
              testmsg_size = min + random.nextInt(max - min);
              log.e('saveData  ->  ${saveData.toString()}');
              //break;
          }
          var msgSize = Util.unsignedBytesToIntBig(
            intArray [0],
            intArray [1],
            intArray [2],
            intArray [3],
          );
          log.e('들어온 데이터길이 ${data.length}');
          log.e(data.lengthInBytes);
          log.e('들어와야할 데이터길이 ${msgSize}');

          if(data.length>msgSize){
            //값만큼 데이터 잘라주기
            var a = true;
            // while(a){
            //   var data2 = intArray.sublist(0,msgSize);
            //   //총데이터 - 부분데이터  =>238남음
            //
            // }
            //
            //나머지 데이터들이 있음

          }

          if(data.length==msgSize){
            var  msgID  = Util.unsignedBytesToIntBig(
                intArray[4],
                intArray[5],
                intArray[6],
                intArray[7]);
            var  ReID  = Util.unsignedBytesToIntBig(
                intArray[8],
                intArray[9],
                intArray[10],
                intArray[11]);
            var  hospitalId  = Util.unsignedBytesToIntBig(
                intArray[12],
                intArray[13],
                intArray[14],
                intArray[15]);

            var  roomCount  = Util.unsignedBytesToIntBig(
                intArray[16],
                intArray[17],
                intArray[18],
                intArray[19]);
            var bbyte = intArray.sublist(20, intArray.length);
            var  roomNumber  = Util.unsignedBytesToIntBig(
                bbyte[0],
                bbyte[1],
                bbyte[2],
                bbyte[3]);
            var status = bbyte[4].toInt();
            var  patientsNameLength  = Util.unsignedBytesToIntBig(
                bbyte[5],
                bbyte[6],
                bbyte[7],
                bbyte[8]);
            var name = bbyte.sublist(9, patientsNameLength+9);
            String stName = utf8.decode(name);
            print(stName);
            log.e("환자이름 : $stName");
            log.e('전체 arr ${intArray.length}');  //여기서 20이 줄어듬
            log.e('RoomInfos  ${bbyte.length}'); //이거
            int a = roomNumber.bitLength+status.bitLength+patientsNameLength.bitLength+patientsNameLength;
            log.e(a);
            var charr = bbyte.sublist(a,bbyte.length);
            var chartNumberLe  = Util.unsignedBytesToIntBig(
                charr[0],
                charr[1],
                charr[2],
                charr[3]);
            log.e("chartNumber : $chartNumberLe");
            var chartNumber = charr.sublist(4, chartNumberLe+4);
            String lath = utf8.decode(chartNumber);
            log.e("data : ${data.length} msgSize: $msgSize mId: $msgID ReId: $ReID hospital: $hospitalId 멀티앱이 관리하는 입원장개수: $roomCount");
            log.e("입원장 번호 : $roomNumber 입원장 상태: $status 환자이름길이: $patientsNameLength");
            log.e("환자이름 : $stName 차트번호길이 : $chartNumberLe 차트번호 $lath");

          }

          // if(data.length==msgSize){
          //   //메세지 길이와 데이터가 일치하면 ok
          //   //메세지 아이디에따라 거른다
          //   var msgMsgId = Util.unsignedBytesToIntBig(
          //     intArray [4],
          //     intArray [5],
          //     intArray [6],
          //     intArray [7],
          //   );
          //   var bbyte = intArray.sublist(12, intArray.length);
          //
          //   if(msgMsgId==2005){
          //     //실시간데이터
          //     print(data);
          //     var addr1 = Util.bytesToHex([bbyte[0], bbyte[1], bbyte[2], bbyte[3], bbyte[4], bbyte[5]]);
          //     var addr2 = Util.bytesToHex([bbyte[6], bbyte[7], bbyte[8], bbyte[9], bbyte[10], bbyte[11]]);
          //     var type = bbyte[12].toInt();
          //     var cntData = Util.unsignedBytesToIntBig(bbyte[13], bbyte[14], bbyte[15], bbyte[16]);
          //     var timeStamp = Util.bytesToHex([bbyte[17], bbyte[18], bbyte[19], bbyte[20], bbyte[21], bbyte[21],bbyte[22],bbyte[23],bbyte[24]]);
          //     log.e(' 실시간 데이터 가져오기 : bbyte.length-  ${bbyte.length}  addr1 $addr1 - addr2 $addr2 type  $type  - cntData $cntData - timeStamp $timeStamp');
          //   }else if(msgMsgId==2004){
          //     //방전체 가져오기
          //     print(data);
          //     var roomCount = bbyte[0].toInt();
          //     log.e('방 전체가져오기 :  bbyte.length ${bbyte.length}  - roomCount $roomCount');
          //     List<int> bytes = [171, 136, 248, 41, 80, 136, 248, 41, 56, 136, 248, 41, 0, 0];
          //     List<String> chars = [];
          //     for (int i = 0; i < bytes.length; i += 2) {
          //       int codeUnit = ((bytes[i] & 0xff) << 8) | (bytes[i + 1] & 0xff);
          //       chars.add(String.fromCharCode(codeUnit));
          //     }
          //     String str = chars.join('');
          //     print(str); // Hello, World!
          //
          //     //var cntData = Util.bytesToHex([bbyte[1],bbyte[2],bbyte[3],bbyte[4],bbyte[5]]);
          //     //0000001b000007d40000000103ab88f8295088f8293888f8290000
          //     //0000001b000007d40000000103ab88f8295088f8293888f8290000
          //     //print(cntData);
          //
          //     //ㅇㅋ 가져옴 쩐다
          //   }
          //   String message = 'dasd';
          //   setState(() {
          //     _messages.add('Received: $message');
          //   });
          // }else{
          //    log.e("일치하지 않음 data : ${data.length} msg : $msgSize");
          // }

        },
        onError: (error) {
          log.e(error);
          print('Error: $error');
          _socket?.destroy();
          setState(() {
            _isConnected = false;
          });
        },
        onDone: () {
          log.e('Server disconnected');
          print('Server disconnected');
          _socket?.destroy();
          setState(() {
            _isConnected = false;
          });
        },
      );
    } catch (e) {
      log.e(e);
      print('Error: $e');
    }
  }

  void _send(String message) {
    if (!_isConnected) {
      return;
    }
    _socket?.write('$message\n');
    setState(() {
      _messages.add('Sent: $message');
    });
    _controller.clear();
  }


  // import 'dart:io';
  //
  // void main() async {
  //   // TCP 서버에 접속
  //   final socket = await Socket.connect('localhost', 12345);
  //
  //   // 전체 데이터 크기
  //   final totalSize = 110;
  //
  //   // 일정 크기의 데이터를 받음
  //   var buffer = List<int>.filled(40, 0);
  //   var bytesRead = await socket.read(buffer);
  //
  //   // 받은 데이터 출력
  //   print('Received ${bytesRead} bytes: ${buffer.sublist(0, bytesRead)}');
  //
  //   // 누락된 데이터가 있는지 확인
  //   while (bytesRead < totalSize) {
  //     // 요청할 데이터의 크기
  //     var remainingSize = totalSize - bytesRead;
  //     if (remainingSize > 40) {
  //       remainingSize = 40;
  //     }
  //
  //     // 누락된 데이터 요청
  //     var remainingBuffer = List<int>.filled(remainingSize, 0);
  //     var remainingBytesRead = await socket.read(remainingBuffer);
  //
  //     // 받은 데이터 출력
  //     print('Received ${remainingBytesRead} bytes: ${remainingBuffer.sublist(0, remainingBytesRead)}');
  //
  //     // 받은 데이터를 기존 데이터에 추가
  //     buffer.addAll(remainingBuffer);
  //     bytesRead += remainingBytesRead;
  //   }
  //
  //   // 접속 종료
  //   await socket.close();
  // }

  // String bytesToHex(List<int> bytes) {
  //   var hexArray = '0123456789ABCDEF'.split('');
  //
  //   var hexChars = List.filled(bytes.length * 2, '');
  //   for (var j = 0; j < bytes.length; j++) {
  //     var v = bytes[j] & 0xFF;
  //
  //     hexChars[j * 2] = hexArray[v >> 4];
  //     hexChars[j * 2 + 1] = hexArray[v & 0x0F];
  //   }
  //   return hexChars.join();
  // }


  // int unsignedBytesToIntBig(int b0, int b1, int b2, int b3) {
  //   return ((unsignedByteToInt(b0) << 24) + (unsignedByteToInt(b1) << 16) +
  //       (unsignedByteToInt(b2) << 8) + unsignedByteToInt(b3));
  // }
  // int unsignedByteToInt(int b) {
  //   return b & 0xff;
  // }

  Widget _buildMessageList() {
    return Expanded(
      child: ListView.builder(
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          final message = _messages[index];
          return ListTile(
            title: Text(message),
          );
        },
      ),
    );
  }


  List<int> convertByteArrayToIntList(List<int?> byteArray) {
    List<int> intList = [];
    for (var i = 0; i < byteArray.length; i += 4) {
      int value = 0;
      for (var j = 0; j < 4; j++) {
        value += (byteArray[i + j]! << (8 * (3 - j)));
      }
      intList.add(value);
    }
    return intList;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TCP Chat'),
        leading: IconButton(onPressed: (){
          log.e('tcp 연결 실행');
          _connect();
        }, icon: const Icon(Icons.add_circle_outline)),
      ),
      body: Container(
        margin: const EdgeInsets.fromLTRB(0, 20, 0, 20),
        child: Column(
          children: [
            _buildMessageList(),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                  suffixIcon: IconButton(onPressed: (){
                    _send(_controller.text.toString());
                  }, icon: Icon(Icons.send))
              ),
            )
            // TextField(
            //   controller: _controller,
            //   enabled: _isConnected,
            //   decoration: InputDecoration(
            //     labelText: 'Message',
            //     suffixIcon: IconButton(
            //       icon: Icon(Icons.send),
            //       onPressed: _isConnected
            //           ? () => _send(_controller.text)
            //           : null,
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   child: Icon(Icons.connected_tv),
      //   onPressed: _isConnected ? null : _connect,
      // ),

    );
  }
}




//----------------------------------------------------------------
// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'dart:math';
// import 'dart:typed_data';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_tcp_test/MultiAppDatas.dart';
// import 'package:logger/logger.dart';
//
// import 'Header.dart';
//
// void main() {
//   runApp(MyApp());
// }
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
//   final TextEditingController _controller = TextEditingController();
//   final List<String> _messages = [];
//   Logger log = Logger();
//
//    Socket? _socket ;
//   bool _isConnected = false;
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     if (_isConnected) {
//       _socket?.destroy();
//     }
//     super.dispose();
//   }
//
//   void _connect() async {
//     try {
//       _socket = await Socket.connect('192.168.0.66', 1234);
//       /**
//        *
//        * @휴대폰 와이파이 같게해야함
//        * _socket = await Socket.connect('192.168.0.66', 1234);
//        * 애뮬레이터
//        *  _socket = await Socket.connect('10.0.2.2', 1234);
//        * **/
//       setState(() {
//         _isConnected = true;
//         log.e('변경?');
//       });
//       log.e(_isConnected);
//       print(_isConnected);
//       _socket?.listen(
//             (data) {
//               List<String> hexArray = [];
//               for (var i = 0; i < data.length; i++) {
//                 hexArray.add(data[i].toRadixString(16).padLeft(2, '0'));
//               }
//               List<int> intArray = hexArray.map((hex) => int.parse(hex, radix: 16)).toList();
//               List<int> totalData = hexArray.map((hex) => int.parse(hex, radix: 16)).toList();
//              var a = true;
//               while(a){
//               for (var i = 0; i < totalData.length; i++){
//                 var test_msgSize = Util.unsignedBytesToIntBig(
//                     totalData[0],totalData[2],totalData[3],totalData[4]);
//               }
//               }
//
//
//               print(intArray.length);
//               //메세지 길이
//               var msgSize = Util.unsignedBytesToIntBig(
//                   intArray [0],
//                   intArray [1],
//                   intArray [2],
//                   intArray [3],
//               );
//               log.e('들어온 데이터길이 ${data.length}');
//               log.e(data.lengthInBytes);
//               log.e('들어와야할 데이터길이 ${msgSize}');
//
//               if(data.length>msgSize){
//                 //값만큼 데이터 잘라주기
//                 var a = true;
//                 // while(a){
//                 //   var data2 = intArray.sublist(0,msgSize);
//                 //   //총데이터 - 부분데이터  =>238남음
//                 //
//                 // }
//                 //
//                 //나머지 데이터들이 있음
//
//               }
//
//               if(data.length==msgSize){
//                 var  msgID  = Util.unsignedBytesToIntBig(
//                     intArray[4],
//                     intArray[5],
//                     intArray[6],
//                     intArray[7]);
//                 var  ReID  = Util.unsignedBytesToIntBig(
//                     intArray[8],
//                     intArray[9],
//                     intArray[10],
//                     intArray[11]);
//                 var  hospitalId  = Util.unsignedBytesToIntBig(
//                     intArray[12],
//                     intArray[13],
//                     intArray[14],
//                     intArray[15]);
//
//                 var  roomCount  = Util.unsignedBytesToIntBig(
//                     intArray[16],
//                     intArray[17],
//                     intArray[18],
//                     intArray[19]);
//                 var bbyte = intArray.sublist(20, intArray.length);
//                 var  roomNumber  = Util.unsignedBytesToIntBig(
//                     bbyte[0],
//                     bbyte[1],
//                     bbyte[2],
//                     bbyte[3]);
//                 var status = bbyte[4].toInt();
//                 var  patientsNameLength  = Util.unsignedBytesToIntBig(
//                     bbyte[5],
//                     bbyte[6],
//                     bbyte[7],
//                     bbyte[8]);
//                 var name = bbyte.sublist(9, patientsNameLength+9);
//                 String stName = utf8.decode(name);
//                 print(stName);
//                 log.e("환자이름 : $stName");
//                 log.e('전체 arr ${intArray.length}');  //여기서 20이 줄어듬
//                 log.e('RoomInfos  ${bbyte.length}'); //이거
//                 int a = roomNumber.bitLength+status.bitLength+patientsNameLength.bitLength+patientsNameLength;
//                 log.e(a);
//                 var charr = bbyte.sublist(a,bbyte.length);
//                 var chartNumberLe  = Util.unsignedBytesToIntBig(
//                     charr[0],
//                     charr[1],
//                     charr[2],
//                     charr[3]);
//                 log.e("chartNumber : $chartNumberLe");
//                 var chartNumber = charr.sublist(4, chartNumberLe+4);
//                 String lath = utf8.decode(chartNumber);
//                 log.e("data : ${data.length} msgSize: $msgSize mId: $msgID ReId: $ReID hospital: $hospitalId 멀티앱이 관리하는 입원장개수: $roomCount");
//                 log.e("입원장 번호 : $roomNumber 입원장 상태: $status 환자이름길이: $patientsNameLength");
//                 log.e("환자이름 : $stName 차트번호길이 : $chartNumberLe 차트번호 $lath");
//
//               }
//
//               // if(data.length==msgSize){
//               //   //메세지 길이와 데이터가 일치하면 ok
//               //   //메세지 아이디에따라 거른다
//               //   var msgMsgId = Util.unsignedBytesToIntBig(
//               //     intArray [4],
//               //     intArray [5],
//               //     intArray [6],
//               //     intArray [7],
//               //   );
//               //   var bbyte = intArray.sublist(12, intArray.length);
//               //
//               //   if(msgMsgId==2005){
//               //     //실시간데이터
//               //     print(data);
//               //     var addr1 = Util.bytesToHex([bbyte[0], bbyte[1], bbyte[2], bbyte[3], bbyte[4], bbyte[5]]);
//               //     var addr2 = Util.bytesToHex([bbyte[6], bbyte[7], bbyte[8], bbyte[9], bbyte[10], bbyte[11]]);
//               //     var type = bbyte[12].toInt();
//               //     var cntData = Util.unsignedBytesToIntBig(bbyte[13], bbyte[14], bbyte[15], bbyte[16]);
//               //     var timeStamp = Util.bytesToHex([bbyte[17], bbyte[18], bbyte[19], bbyte[20], bbyte[21], bbyte[21],bbyte[22],bbyte[23],bbyte[24]]);
//               //     log.e(' 실시간 데이터 가져오기 : bbyte.length-  ${bbyte.length}  addr1 $addr1 - addr2 $addr2 type  $type  - cntData $cntData - timeStamp $timeStamp');
//               //   }else if(msgMsgId==2004){
//               //     //방전체 가져오기
//               //     print(data);
//               //     var roomCount = bbyte[0].toInt();
//               //     log.e('방 전체가져오기 :  bbyte.length ${bbyte.length}  - roomCount $roomCount');
//               //     List<int> bytes = [171, 136, 248, 41, 80, 136, 248, 41, 56, 136, 248, 41, 0, 0];
//               //     List<String> chars = [];
//               //     for (int i = 0; i < bytes.length; i += 2) {
//               //       int codeUnit = ((bytes[i] & 0xff) << 8) | (bytes[i + 1] & 0xff);
//               //       chars.add(String.fromCharCode(codeUnit));
//               //     }
//               //     String str = chars.join('');
//               //     print(str); // Hello, World!
//               //
//               //     //var cntData = Util.bytesToHex([bbyte[1],bbyte[2],bbyte[3],bbyte[4],bbyte[5]]);
//               //     //0000001b000007d40000000103ab88f8295088f8293888f8290000
//               //     //0000001b000007d40000000103ab88f8295088f8293888f8290000
//               //     //print(cntData);
//               //
//               //     //ㅇㅋ 가져옴 쩐다
//               //   }
//               //   String message = 'dasd';
//               //   setState(() {
//               //     _messages.add('Received: $message');
//               //   });
//               // }else{
//               //    log.e("일치하지 않음 data : ${data.length} msg : $msgSize");
//               // }
//
//         },
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
//   void _send(String message) {
//     log.e(_isConnected);
//     log.e(message);
//     if (!_isConnected) {
//       return;
//     }
//     _socket?.write('$message\n');
//     setState(() {
//       _messages.add('Sent: $message');
//     });
//     _controller.clear();
//   }
//
//   // String bytesToHex(List<int> bytes) {
//   //   var hexArray = '0123456789ABCDEF'.split('');
//   //
//   //   var hexChars = List.filled(bytes.length * 2, '');
//   //   for (var j = 0; j < bytes.length; j++) {
//   //     var v = bytes[j] & 0xFF;
//   //
//   //     hexChars[j * 2] = hexArray[v >> 4];
//   //     hexChars[j * 2 + 1] = hexArray[v & 0x0F];
//   //   }
//   //   return hexChars.join();
//   // }
//
//
//   // int unsignedBytesToIntBig(int b0, int b1, int b2, int b3) {
//   //   return ((unsignedByteToInt(b0) << 24) + (unsignedByteToInt(b1) << 16) +
//   //       (unsignedByteToInt(b2) << 8) + unsignedByteToInt(b3));
//   // }
//   // int unsignedByteToInt(int b) {
//   //   return b & 0xff;
//   // }
//
//   Widget _buildMessageList() {
//     return Expanded(
//       child: ListView.builder(
//         itemCount: _messages.length,
//         itemBuilder: (context, index) {
//           final message = _messages[index];
//           return ListTile(
//             title: Text(message),
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
//                 suffixIcon: IconButton(onPressed: (){
//                   _send(_controller.text.toString());
//                 }, icon: Icon(Icons.send))
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
