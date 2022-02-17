import 'package:shared_preferences/shared_preferences.dart';

class UserData {
  var token, userID, userName, userNIK;

  UserData() {
    this.getData();
  }

  getData() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    token = localStorage.getString('token');
    userID = localStorage.getString('userID');
    userName = localStorage.getString('userName');
    userNIK = localStorage.getString('userNIK');
  }
}