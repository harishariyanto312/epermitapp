import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class SanctumApi {
  final String _endpoint = 'http://10.0.2.2:8000/api/v1/';
  // final String _endpoint = 'https://cdn.xxx.com/api/v1/';
  var token;

  _getToken() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    token = localStorage.getString('token');
    return token;
  }

  sendPost({data, apiURL, additionalHeaders, withToken = false}) async {
    var fullUrl = Uri.parse(_endpoint + apiURL);
    print('Sending POST request $fullUrl');
    return await http.post(
      fullUrl,
      body: jsonEncode(data),
      headers: {
        ...{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        ...additionalHeaders,
        if (withToken) 'Authorization': 'Bearer ' + await this._getToken(),
      }
    );
  }

  sendGet({data, apiURL, additionalHeaders, withToken = false}) async {
    var fullUrl = Uri.parse(_endpoint + apiURL);
    print('Sending GET request $fullUrl');
    return await http.get(
      fullUrl,
      headers: {
        ...{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        ...additionalHeaders,
        if (withToken) 'Authorization': 'Bearer ' + this._getToken(),
      }
    );
  }

  authenticate({userNik, userPassword, userDevice}) async {
    var data = {
      'nik': userNik,
      'password': userPassword,
      'device_name': userDevice,
    };

    var result = sendPost(
      data: data,
      apiURL: 'login',
      additionalHeaders: {}
    );

    return result;
  }
}