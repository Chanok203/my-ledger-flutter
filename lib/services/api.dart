import 'dart:convert';

import 'package:flutter_app/models/transaction_model.dart';
import 'package:flutter_app/services/converter.dart';
import 'package:flutter_app/services/storage.dart';
import 'package:http/http.dart' as http;

class Api {
  static const BASE_URL = 'https://chanok-ledger-api.herokuapp.com';
  var _storage = Storage();

  Future<dynamic> addTransaction(
    String endPoint, {
    int? type,
    double? amount,
    String? desc,
  }) async {
    final url = Uri.parse('$BASE_URL/$endPoint/');

    var token = await _storage.get("auth_token");
    String basicAuth = 'Basic ' + token;
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        "Authorization": basicAuth,
      },
      body: json.encode(
        {
          "amount": amount,
          "type": type,
          "desc": desc,
        },
      ),
    );

    print(response.statusCode);
    if (response.statusCode == 201) {
      return response.statusCode;
    }
    return null;
  }

  Future<dynamic> register(
    String endPoint, {
    String? username,
    String? password,
    String? password2,
  }) async {
    final url = Uri.parse('$BASE_URL/$endPoint/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(
        {
          "username": username,
          "password": password,
          "password2": password2,
        },
      ),
    );
    if (response.statusCode == 201) {
      var jsonBody = json.decode(utf8.decode(response.bodyBytes));
      var token = base64Encode(utf8.encode('$username:$password'));
      _storage.add(key: "auth_token", value: token);
      _storage.add(key: "username", value: username);
      return jsonBody["username"];
    }
    return null;
  }

  Future<dynamic> login(
    String endPoint, {
    Map<String, dynamic>? queryParams,
    String username = "",
    String password = "",
  }) async {
    String queryString = Uri(queryParameters: queryParams).query;
    final url = Uri.parse('$BASE_URL/$endPoint/?$queryString');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(
        {
          "username": username,
          "password": password,
        },
      ),
    );
    if (response.statusCode == 200) {
      var jsonBody = json.decode(utf8.decode(response.bodyBytes));
      var token = base64Encode(utf8.encode('$username:$password'));
      _storage.add(key: "auth_token", value: token);
      _storage.add(key: "username", value: username);
      return jsonBody["username"];
    } else {
      return null;
    }
  }

  Future<dynamic> loadTransactionList(
    String endPoint, {
    Map<String, dynamic>? queryParams,
    DateTime? startDate,
    DateTime? endDate,
    String? type,
  }) async {
    if (queryParams == null) {
      queryParams = {};
    }

    queryParams["start_date"] = formatDateTime(startDate);
    queryParams["end_date"] = formatDateTime(
        (endDate == null) ? null : endDate.add(Duration(days: 1)));
    queryParams["type"] = (type == null) ? null : type;

    String queryString = Uri(queryParameters: queryParams).query;
    var url = Uri.parse('$BASE_URL/$endPoint/?$queryString');
    print(url);

    var token = await _storage.get("auth_token");
    String basicAuth = 'Basic ' + token;
    final response = await http.get(url, headers: {"Authorization": basicAuth});

    if (response.statusCode == 200) {
      // แปลง text ที่มีรูปแบบเป็น JSON ไปเป็น Dart's data structure (List/Map)
      // print(json.decode(response.body));
      List<dynamic> jsonBody = json.decode(utf8.decode(response.bodyBytes));
      return jsonBody.map((e) => TransactionItem.fromJson(e)).toList();

      // แปลง Dart's data structure ไปเป็น model (POJO)
      // return TransactionItem.fromJson(jsonBody);
    } else {
      return null;
    }
  }
}
