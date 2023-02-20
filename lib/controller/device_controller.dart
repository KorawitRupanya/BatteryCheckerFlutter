import 'dart:convert';

import 'package:http/http.dart' as http;

const String API = "http://localhost:3000"; // Change this to your API
class DeviceController
{
  var client = http.Client();

  Future<dynamic> get(String api) async {
    var url = Uri.parse(API + api);
    var response = await client.get(url);
    if(response.statusCode == 200)
      return response.body;
    else
      throw Exception("Error: ${response.statusCode} ${response.body}");
  }

  Future<dynamic> post(String api, dynamic object) async {
    var url = Uri.parse(API + api);
    var payload = jsonEncode(object);
    var header = {"Content-Type": "application/json", "Accept": "application/json"};
    var response = await client.post(url, body: payload, headers: header);
    if(response.statusCode == 200)
      return response.body;
    else
      throw Exception("Error: ${response.statusCode} ${response.body}");
  }

  Future<dynamic> put(String api) async {}

  Future<dynamic> delete(String api) async {}
}