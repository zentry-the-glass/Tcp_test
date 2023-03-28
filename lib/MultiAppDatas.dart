

class MultiAppDatas {
   late List<MultiAppData> multiAppData;
   MultiAppDatas(this.multiAppData);
}

class MultiAppData {
  String multiAppUUID;
  String roomCount;
  List<RoomInfos> roomInfos;
  MultiAppData({required this.multiAppUUID, required this.roomCount, required this.roomInfos});

}

class RoomInfos {
  String roomNumber;
  String status;
  String patientsNameLength;
  String patientsName;
  String chartNumberLength;
  String chartNumber;

  RoomInfos({required this.roomNumber,
        required this.status,
        required this.patientsNameLength,
        required this.patientsName,
        required this.chartNumberLength,
        required this.chartNumber});


}