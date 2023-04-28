import 'package:flutter/material.dart';
import 'package:flutter_tcp_test/SocketModel.dart';
import 'package:flutter_tcp_test/Util.dart';
import 'package:provider/provider.dart';
class ChardCard extends StatelessWidget {
  final Map? roominfo;
  final String multiAppUUID;
  const ChardCard({Key? key ,required this.roominfo, required this.multiAppUUID}) : super(key: key);

  @override
  Widget build(BuildContext context) {
      return Container(
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${roominfo!['patientName']}',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                          Text('Room id.${roominfo!['roomId']}'),
                          Text('Chart No.${roominfo!['chartNumber']}'),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                      flex: 1,
                      child: Container(
                          child: Text(' | ',style: TextStyle(fontSize: 40,color: Colors.grey)))),
                     Expanded(
                        flex: 2,
                        child: Selector<Value, Message2205?>(
                          selector: (context, value)=> value.message2205,
                          builder: (context, message2205, child) {
                            if(message2205!.RoomID==null){
                              return Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment
                                      .spaceAround,
                                  children: [
                                    Text('${roominfo?['dataType0'] ?? '-'}',
                                      style: TextStyle(fontSize: 30,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF27C32B)),),
                                    Text('${roominfo?['dataType1'] ?? '-'}',
                                        style: TextStyle(fontSize: 30,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF45A1FF))),
                                  ],),);
                            }else if(message2205.MultiAppUUID == multiAppUUID) {
                                if(roominfo!['roomId']==message2205.RoomID){
                                   roominfo!['dataType${message2205.DataType}'] = message2205.Data;
                                }
                              return Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment
                                      .spaceAround,
                                  children: [
                                    Text('${roominfo?['dataType0'] ?? '-'}',
                                      style: TextStyle(fontSize: 30,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF27C32B)),),
                                    Text('${roominfo?['dataType1'] ?? '-'}',
                                        style: TextStyle(fontSize: 30,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF45A1FF))),
                                  ],),);
                             }else{
                              return Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment
                                      .spaceAround,
                                  children: [
                                    Text('${roominfo?['dataType0'] ?? '-'}',
                                      style: TextStyle(fontSize: 30,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF27C32B)),),
                                    Text('${roominfo?['dataType1'] ?? '-'}',
                                        style: TextStyle(fontSize: 30,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF45A1FF))),
                                  ],),);
                            }
                           }
                        ))
                      // child: DataValue(roomInfo)





                  // Selector<Value, Message2205?>(
                  //   selector: (context, value)=> value.message2205,
                  //   builder: (context, message2205, child) {
                  //     if(message2205!.RoomID == null){
                  //
                  //     }else{
                  //       Util.log.e('!!!');
                  //       var roomId = message2205.RoomID;
                  //       var type = message2205.DataType;
                  //       var dataValue = message2205.Data;
                  //       if(roominfo!['roomId']==roomId){
                  //         roominfo!['dataType$type']=dataValue;
                  //       }
                  //       // for (var j = 0; j < data!['roomcount']; j++) {
                  //       //   if (roomInfo['roomId'] == roomId) {
                  //       //     roomInfo['dataType$type']=dataValue;
                  //       //     // if(type==0){
                  //       //     //   roomInfo['dataType$type']=dataValue;
                  //       //     // }else{
                  //       //     //   roomInfo['dataType1']=dataValue;
                  //       //     // }
                  //       //   }
                  //       // }
                  //       return Expanded(
                  //           flex: 2,
                  //           child: Container(
                  //             child: Row(
                  //               mainAxisAlignment: MainAxisAlignment.spaceAround,
                  //               children: [
                  //                 Text('${roominfo?['dataType0']??'-'}',
                  //                   style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold,color: Color(0xFF27C32B)
                  //                   ),),
                  //                 Text('${roominfo?['dataType1']??'-'}',
                  //                     style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold,color: Color(0xFF45A1FF)
                  //                     )),
                  //               ],
                  //             ),
                  //             // child: DataValue(roomInfo)
                  //           ));
                  //     }
                  //   }
                  // )
                ],
              ),
            );

  }

  ss(var data){
    Util.log.e(data);

  }
}

