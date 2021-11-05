import 'package:flutter/material.dart';
import 'package:flutter_app/pages/home/home_page.dart';
import 'package:flutter_app/services/api.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  static const routeName = "/register";

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _password2Controller = TextEditingController();

  bool _isLoading = false;
  String? _passwordError;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("สมัครสมาชิก"),
        ),
        body: Container(
          color: Colors.orange.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Column(
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
                  ),
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      (_isLoading)
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : SizedBox.shrink(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 50.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              "กรุณากรอกข้อมูล",
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
                            TextFormField(
                              controller: _password2Controller,
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'กรุณากรอกรหัสผ่าน';
                                }
                                return null;
                              },

                              enabled: !_isLoading,
                              decoration: InputDecoration(
                                labelText: "ยืนยันรหัสผ่าน",
                                contentPadding: EdgeInsets.all(20),
                                errorText: _passwordError,
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Row(
                              children: [
                                Expanded(child: ElevatedButton(
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

                                    var username = _usernameController.text;
                                    var password = _passwordController.text;
                                    var password2 = _password2Controller.text;

                                    if (password != password2) {
                                      setState(() {
                                        _passwordError = "กรุณากรอกรหัสผ่านให้ตรงกัน";
                                      });
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text("พบข้อผิดพลาด"),
                                            content:
                                            Text("รหัสผ่านและยืนยันรหัสผ่านไม่ตรงกัน"),
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
                                      return;
                                    }

                                    setState(() {
                                      _passwordError = null;
                                      _isLoading = true;
                                    });

                                    var res = await Api().register("register", username: username, password: password, password2: password2);
                                    if (res == null) {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text("ไม่สามารถสมัครสมาชิกได้"),
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
                                  child: Text("สมัครสมาชิก"),
                                ),),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
