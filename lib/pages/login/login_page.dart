import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app/pages/home/home_page.dart';
import 'package:flutter_app/pages/register/register_page.dart';
import 'package:flutter_app/services/api.dart';
import 'package:flutter_app/services/storage.dart';

class LoginPage extends StatelessWidget {
  static const routeName = "/login";

  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          color: Colors.orange.shade50,
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: _LogoWidget(),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50.0),
                      child: _LoginFormWidget(),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoWidget extends StatelessWidget {
  const _LogoWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image(
          image: AssetImage("assets/images/logo.png"),
          width: 100.0,
          height: 100.0,
        ),
        Text(
          "สมุดบัญชีของฉัน",
          style: TextStyle(fontSize: 30.0),
        ),
      ],
    );
  }
}

class _LoginFormWidget extends StatefulWidget {
  const _LoginFormWidget({Key? key}) : super(key: key);

  @override
  _LoginFormWidgetState createState() => _LoginFormWidgetState();
}

class _LoginFormWidgetState extends State<_LoginFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          (_isLoading)
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              : SizedBox.shrink(),
          Text(
            "กรุณาลงชื่อเข้าใช้",
          ),
          SizedBox(height: 8.0),
          TextFormField(
            controller: _usernameController,
            decoration: InputDecoration(
              labelText: "ชื่อผู้ใช้",
              contentPadding: EdgeInsets.all(20),
            ),
            enabled: !_isLoading,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'กรุณากรอกชื่อผู้ใช้';
              }
              return null;
            },
          ),
          SizedBox(height: 8.0),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'กรุณากรอกรหัสผ่าน';
              }
              return null;
            },
            enabled: !_isLoading,
            decoration: InputDecoration(
              labelText: "รหัสผ่าน",
              contentPadding: EdgeInsets.all(20),
            ),
          ),
          SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: (_isLoading) ? null : () async {
                  if (!_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('กรุณากรอกข้อมูลให้สมบูรณ์'),
                        action: SnackBarAction(
                          label: 'ปิด',
                          onPressed: () {},
                        ),
                      ),
                    );
                    return;
                  }
                  setState(() {
                    _isLoading = true;
                  });

                  var username = _usernameController.text;
                  var password = _passwordController.text;
                  var res = await Api().login("login", username: username, password: password);
                  if (res == null) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("ไม่สามารถลงชื่อเข้าใช้ได้"),
                          content:
                              Text("กรุณาตรวจสอบชื่อผู้ใช้และรหัสผ่านอีกครั้ง"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text("ตกลง"),
                            )
                          ],
                        );
                      },
                    );
                    setState(() {
                      _isLoading = false;
                    });
                  } else {
                    Navigator.of(context)
                        .pushReplacementNamed(HomePage.routeName, arguments: {"username": username});
                  }
                },
                child: Text("ลงชื่อเข้าใช้"),
              ),
              TextButton(
                onPressed: (_isLoading) ? null : () {
                  Navigator.pushNamed(context, RegisterPage.routeName);
                },
                // style: TextButton.styleFrom(
                //   side: BorderSide(color: Theme.of(context).primaryColor, width: 1),
                //   textStyle: TextStyle(color: Theme.of(context).primaryColor)
                // ),
                child: Text("สมัครสมาชิก"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
