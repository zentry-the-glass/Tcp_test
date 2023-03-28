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
        log.e('변경?');
      });
      log.e(_isConnected);
      print(_isConnected);
      _socket?.listen(
            (data) {
              log.e(data.runtimeType);
              log.e(data.length);
              print(data);
              List<String> hexArray = [];
              for (var i = 0; i < data.length; i++) {
                hexArray.add(data[i].toRadixString(16).padLeft(2, '0'));
              }
              //10진수로 변경해서 저장
              List<int> intArray = hexArray.map((hex) => int.parse(hex, radix: 16)).toList();

              //메세지 길이
              var msgSize = Util.unsignedBytesToIntBig(
                  intArray [0],
                  intArray [1],
                  intArray [2],
                  intArray [3],
              );

              //만약에 메세지이


              var msgMsgId = Util.unsignedBytesToIntBig(
                intArray [4],
                intArray [5],
                intArray [6],
                intArray [7],
              );

              var processId = Util.unsignedBytesToIntBig(
                  intArray[8],
                  intArray[9],
                  intArray[10],
                  intArray[11]
              );
              
              var bbyte = intArray.sublist(12, intArray.length);
              var addr1 = Util.bytesToHex([bbyte[0], bbyte[1], bbyte[2], bbyte[3], bbyte[4], bbyte[5]]);
              var addr2 = Util.bytesToHex([bbyte[6], bbyte[7], bbyte[8], bbyte[9], bbyte[10], bbyte[11]]);
              var type = bbyte[12].toInt();
              var cntData = Util.unsignedBytesToIntBig(bbyte[13], bbyte[14], bbyte[15], bbyte[16]);
              var timeStamp = Util.bytesToHex([bbyte[17], bbyte[18], bbyte[19], bbyte[20], bbyte[21], bbyte[21],bbyte[22],bbyte[23],bbyte[24]]);
              log.e('msg size $msgSize  - msId $msgMsgId - processId $processId ');
              log.e('addr1 $addr1 - addr2 $addr2 ');
              log.e('type  $type  - cntData $cntData - timeStamp $timeStamp ');
              String message = 'dasd';

          setState(() {
            _messages.add('Received: $message');
          });
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
    log.e(_isConnected);
    log.e(message);
    if (!_isConnected) {
      return;
    }
    _socket?.write('$message\n');
    setState(() {
      _messages.add('Sent: $message');
    });
    _controller.clear();
  }

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
