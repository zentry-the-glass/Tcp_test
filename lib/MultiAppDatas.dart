//
//
// // class MultiAppDatas {
// //    late List<MultiAppData> multiAppData;
// //    MultiAppDatas(this.multiAppData);
// // }
// //
// // class MultiAppData {
// //   String multiAppUUID;
// //   String roomCount;
// //   List<RoomInfos> RoomInfos;
// //   MultiAppData({required this.multiAppUUID, required this.roomCount, required this.roomInfos});
// //
// // }
//
// class RoomInfos {
//   List<RoomInfo>? roomInfo;
//
//   RoomInfos({this.roomInfo});
//
//   RoomInfos.fromJson(Map<String, dynamic> json) {
//     if (json['RoomInfo'] != null) {
//       roomInfo = <RoomInfo>[];
//       json['RoomInfo'].forEach((v) {
//         roomInfo!.add(new RoomInfo.fromJson(v));
//       });
//     }
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     if (this.roomInfo != null) {
//       data['RoomInfo'] = this.roomInfo!.map((v) => v.toJson()).toList();
//     }
//     return data;
//   }
// }
//
// class RoomInfo {
//   String? roomNum;
//   int? status;
//   int? patientsNameLength;
//   String? patientsName;
//   int? chartNumberLength;
//   String? chartNumber;
//
//   RoomInfo(this.roomNum, this.status, this.patientsNameLength,
//       this.patientsName, this.chartNumberLength, this.chartNumber);
//
//   RoomInfo.fromJson(Map<String, dynamic> json){
//     roomNum = json['roomNum'];
//     status = json['status'];
//     patientsNameLength = json['patientsNameLength'];
//     patientsName = json['patientsName'];
//     chartNumberLength = json['chartNumberLength'];
//     chartNumber = json['chartNumber'];
//
//   }
//
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['roomNum'] = this.roomNum;
//     data['status'] = this.status;
//     data['patientsNameLength'] = this.patientsNameLength;
//     data['patientsName'] = this.patientsName;
//     data['chartNumberLength'] = this.chartNumberLength;
//     data['chartNumber'] = this.chartNumber;
//     return data;
//   }
//
//
// }