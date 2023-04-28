
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_tcp_test/MonitoringScreen.dart';
import 'package:flutter_tcp_test/chart_card.dart';
import 'package:provider/provider.dart';

import 'Header.dart';
import 'SocketModel.dart';
import 'Util.dart';

class MultiAppDataList extends StatelessWidget {
  final Map? data;
  MultiAppDataList({Key? key ,required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white60,
      child: ListView.builder(
        physics: ClampingScrollPhysics(),
        shrinkWrap: true,
        itemCount: data!['roomcount'],
        itemBuilder: (BuildContext context, int index) {
         var multiAppUUID = data!['multiAppUUID'];
         final roomInfo = data!['RoomInfos'][index];
        return Selector<Value, Message2206?>(
          selector: (context, value)=>value.message2206,
          builder: (context, message2206 ,child ) {
            if(message2206!.MultiAppUUID==null){
              //Util.log.e('알람 안울림');
              return Container(
                  width: double.infinity,
                  margin: roomInfo['type']!=0?EdgeInsets.all(0):EdgeInsets.all(2),
                  child: Card(
                      elevation: 2.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                        side: BorderSide(color: Colors.grey.withOpacity(0.3), width: 1),),
                      child: ChardCard(roominfo: roomInfo, multiAppUUID: multiAppUUID,)));
            }else {
              //Util.log.e(data!['RoomInfos'][index]);
              if(multiAppUUID==message2206.MultiAppUUID){
                if(roomInfo['roomId']==message2206.RoomID){
                  roomInfo['type']=message2206.AlarmType;
                }
              }
              return Container(
                  width: double.infinity,
                  margin: roomInfo['type']!=0?EdgeInsets.all(0):EdgeInsets.all(2),
                  child: Card(
                      elevation: roomInfo['type']!=0?10.0:2.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                        side: roomInfo['type']!=0?BorderSide(color: Colors.red, width: 2,):
                        BorderSide(color: Colors.grey.withOpacity(0.3), width: 1),),
                      child: ChardCard(
                        roominfo: roomInfo, multiAppUUID: multiAppUUID,)));
            }
            return Container(
                width: double.infinity,
                margin: EdgeInsets.all(5),
                child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                      side: BorderSide( color: Colors.grey.withOpacity(0.3),
                        width: 1,),),
                    child: ChardCard(roominfo: roomInfo, multiAppUUID:  multiAppUUID,)));
          }
        );
          //Util.log.e(roomInfo.toString());
          // return Selector<Value, Message2205?>(
          //   selector: (context, value)=> value.message2205,
          //   builder: (context, message2205, child) {
          //     if (message2205!.RoomID == null) {
          //       return Container(
          //         width: double.infinity,
          //         margin: EdgeInsets.all(5),
          //         child: Card(
          //           shape: RoundedRectangleBorder(
          //             borderRadius: BorderRadius.circular(5),
          //             side: BorderSide(
          //               color: Colors.grey.withOpacity(0.5),
          //               width: 2,
          //             ),
          //           ),
          //           child: Container(
          //             padding: EdgeInsets.all(10),
          //             child: Row(
          //               mainAxisAlignment: MainAxisAlignment.spaceAround,
          //               children: [
          //                 Expanded(
          //                   flex: 2,
          //                   child: Container(
          //                     child: Column(
          //                       crossAxisAlignment: CrossAxisAlignment
          //                           .start,
          //                       children: [
          //                         Text('${roomInfo!['patientName']}',
          //                           style: TextStyle(fontSize: 20,
          //                               fontWeight: FontWeight.bold),),
          //                         Text('Room id.${roomInfo!['roomId']}'),
          //                         Text(
          //                             'Chart No.${roomInfo!['chartNumber']}'),
          //                       ],
          //                     ),
          //                   ),
          //                 ),
          //                 Expanded(
          //                     flex: 1,
          //                     child: Container(
          //                         child: Text(' | ', style: TextStyle(
          //                             fontSize: 40, color: Colors.grey)))),
          //                 Expanded(
          //                     flex: 2,
          //                     child: Container(
          //                         child: Row(
          //                           mainAxisAlignment: MainAxisAlignment
          //                               .spaceAround,
          //                           children: [
          //                             Text('-',
          //                               style: TextStyle(fontSize: 30,
          //                                   fontWeight: FontWeight.bold,
          //                                   color: Color(0xFF27C32B)),),
          //                             Text('-',
          //                               style: TextStyle(fontSize: 30,
          //                                   fontWeight: FontWeight.bold,
          //                                   color: Color(0xFF45A1FF)),),
          //                           ],
          //                         )
          //                       // child: DataValue(roomInfo)
          //                     ))
          //               ],
          //             ),
          //           ),
          //         ),
          //       );
          //     }
          //     else {
          //      Util.log.e('rebuild 되는곳');
          //       var valueAppUUID = message2205.MultiAppUUID;
          //       var roomId = message2205.RoomID;
          //       var type = message2205.DataType;
          //       var dataValue = message2205.Data;
          //       Util.log.e(roomId);
          //      Util.log.e(type);
          //
          //       //Util.log.e('데이터 옴  rebuild');
          //       for (var j = 0; j < data!['roomcount']; j++) {
          //         if (roomInfo['roomId'] == roomId) {
          //           roomInfo['dataType$type']=dataValue;
          //           // if(type==0){
          //           //   roomInfo['dataType$type']=dataValue;
          //           // }else{
          //           //   roomInfo['dataType1']=dataValue;
          //           // }
          //         }
          //       }
          //       return ChardCard(roominfo: roomInfo);
          //     }
          //   },
          //
          // );
        },
      ),
    );

  }
}


//// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_tcp_test/MonitoringScreen.dart';
// import 'package:flutter_tcp_test/chart_card.dart';
// import 'package:provider/provider.dart';
//
// import 'Header.dart';
// import 'SocketModel.dart';
// import 'Util.dart';
//
// class MultiAppDataList extends StatelessWidget {
//   final Map? data;
//   var a1 ={};
//   var a2 ={};
//   MultiAppDataList({Key? key ,required this.data}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//    // Util.log.e(data.toString());
//         return Container(
//           color: Colors.white60,
//           child: ListView.builder(
//              physics: ClampingScrollPhysics(),
//             shrinkWrap: true,
//             itemCount: data!['roomcount'],
//             itemBuilder: (BuildContext context, int index) {
//                //Util.log.e(data.toString());
//               var multiAppUUID = data!['multiAppUUID'];
//               final roomInfo = data!['RoomInfos'][index];
//                //Util.log.e(roomInfo.toString());
//                return Consumer<Value>(
//                  builder: (context,value, child) {
//                    if (value.message2205!.Data == null) {
//                      return Container(
//                        width: double.infinity,
//                        margin: EdgeInsets.all(5),
//                        child: Card(
//                          shape: RoundedRectangleBorder(
//                            borderRadius: BorderRadius.circular(5),
//                            side: BorderSide(
//                              color: Colors.grey.withOpacity(0.5),
//                              width: 2,
//                            ),
//                          ),
//                          child: Container(
//                            padding: EdgeInsets.all(10),
//                            child: Row(
//                              mainAxisAlignment: MainAxisAlignment.spaceAround,
//                              children: [
//                                Expanded(
//                                  flex: 2,
//                                  child: Container(
//                                    child: Column(
//                                      crossAxisAlignment: CrossAxisAlignment
//                                          .start,
//                                      children: [
//                                        Text('${roomInfo!['patientName']}',
//                                          style: TextStyle(fontSize: 20,
//                                              fontWeight: FontWeight.bold),),
//                                        Text('Room id.${roomInfo!['roomId']}'),
//                                        Text(
//                                            'Chart No.${roomInfo!['chartNumber']}'),
//                                      ],
//                                    ),
//                                  ),
//                                ),
//                                Expanded(
//                                    flex: 1,
//                                    child: Container(
//                                        child: Text(' | ', style: TextStyle(
//                                            fontSize: 40, color: Colors.grey)))),
//                                Expanded(
//                                    flex: 2,
//                                    child: Container(
//                                        child: Row(
//                                          mainAxisAlignment: MainAxisAlignment
//                                              .spaceAround,
//                                          children: [
//                                            Text('-',
//                                              style: TextStyle(fontSize: 30,
//                                                  fontWeight: FontWeight.bold,
//                                                  color: Color(0xFF27C32B)),),
//                                            Text('-',
//                                              style: TextStyle(fontSize: 30,
//                                                  fontWeight: FontWeight.bold,
//                                                  color: Color(0xFF45A1FF)),),
//                                          ],
//                                        )
//                                      // child: DataValue(roomInfo)
//                                    ))
//                              ],
//                            ),
//                          ),
//                        ),
//                      );
//                    }
//                    else {
//                      Util.log.e('rebuild 되는곳??');
//                       var valueAppUUID = value.message2205!.MultiAppUUID;
//                       var roomId = value.message2205!.RoomID;
//                       var type = value.message2205!.DataType;
//                       var dataValue = value.message2205!.Data;
//
//                       //Util.log.e('데이터 옴  rebuild');
//                       for (var j = 0; j < data!['roomcount']; j++) {
//                         if (roomInfo['roomId'] == roomId) {
//                           roomInfo['dataType$type']=dataValue;
//                           // if(type==0){
//                           //   roomInfo['dataType$type']=dataValue;
//                           // }else{
//                           //   roomInfo['dataType1']=dataValue;
//                           // }
//                         }
//                       }
//                       return ChardCard(roominfo: roomInfo);
//                    }
//                  },
//
//                );
//             },
//           ),
//         );
//
//   }
// }
