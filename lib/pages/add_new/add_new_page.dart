import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/pages/home/home_page.dart';
import 'package:flutter_app/services/api.dart';
import 'package:flutter_app/services/storage.dart';

class AddTransactionPage extends StatefulWidget {
  static const routeName = "/add";

  const AddTransactionPage({Key? key}) : super(key: key);

  @override
  _AddTransactionPageState createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  int _type = 0;

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("เพิ่มรายการใหม่"),
        ),
        body: Container(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  Column(
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
                            InputDecorator(
                              decoration: InputDecoration(
                                  // labelStyle: textStyle,
                                  errorStyle: TextStyle(
                                      color: Colors.redAccent, fontSize: 16.0),
                                  hintText: 'Please select expense',
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(5.0))),
                              // isEmpty: _currentSelectedValue == '',
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: (_type == 0) ? "รายรับ" : "รายจ่าย",
                                  isDense: true,
                                  onChanged: (_isLoading)
                                      ? null
                                      : (String? newValue) {
                                          setState(() {
                                            _type =
                                                (newValue == "รายรับ") ? 0 : 1;
                                          });
                                        },
                                  items: [
                                    'รายรับ',
                                    'รายจ่าย',
                                  ].map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                            SizedBox(height: 8.0),
                            TextFormField(
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r"^\d*\.?\d*"))
                              ],
                              controller: _amountController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'กรุณากรอกจำนวนเงิน';
                                }
                                return null;
                              },
                              enabled: !_isLoading,
                              decoration: InputDecoration(
                                labelText: "จำนวนเงิน",
                                suffix: Text("บาท"),
                                contentPadding: EdgeInsets.all(20),
                              ),
                            ),
                            SizedBox(height: 8.0),
                            TextFormField(
                              maxLength: 50,
                              controller: _descController,
                              enabled: !_isLoading,
                              decoration: InputDecoration(
                                labelText: "คำอธิบาย",
                                contentPadding: EdgeInsets.all(20),
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: (false)
                                        ? null
                                        : () async {
                                            if (!_formKey.currentState!
                                                .validate()) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      'กรุณากรอกข้อมูลให้สมบูรณ์'),
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

                                            var type = _type;
                                            double? amount = double.parse(
                                                _amountController.text);
                                            var desc = _descController.text;
                                            var res = await Api()
                                                .addTransaction("transaction",
                                                    type: type,
                                                    amount: amount,
                                                    desc: desc);
                                            print(res);
                                            if (res == null) {
                                              showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return AlertDialog(
                                                    title: Text("ไม่สามารถเพิ่มรายการใหม่ได้"),
                                                    content:
                                                    Text("กรุณาตรวจสอบชข้อมูลอีกครั้ง"),
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
                                              var _storage = Storage();
                                              var username = await _storage.get("username");
                                              Navigator.of(context)
                                                  .pushReplacementNamed(HomePage.routeName, arguments: {"username": username});
                                            }
                                          },
                                    child: Text("ยืนยัน"),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
