import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app/models/transaction_model.dart';
import 'package:flutter_app/pages/add_new/add_new_page.dart';
import 'package:flutter_app/pages/login/login_page.dart';
import 'package:flutter_app/services/api.dart';
import 'package:flutter_app/services/converter.dart';
import 'package:flutter_app/services/storage.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  static const routeName = "/home";

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _storage = Storage();
  late Future<List<TransactionItem>> _transactionList;
  var _username = "undefined";
  double _sum = 0.0;

  DateTime _endDate = DateTime.now();
  DateTime _startDate = DateTime.now().subtract(Duration(days: 7));
  bool _income = true;
  bool _expense = true;
  String _type = "";

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    _username = args["username"];

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("สมุดบัญชีของฉัน"),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, AddTransactionPage.routeName);
              },
              child: Row(
                children: [
                  Icon(Icons.add),
                  Text("เพิ่ม"),
                ],
              ),
            ),
          ],
        ),
        drawer: _buildDrawer(context),
        body: Container(
          color: Colors.orange.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildFilterWidget(context),
                const Divider(
                  height: 20,
                  thickness: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.library_books_sharp),
                        SizedBox(
                          width: 8.0,
                        ),
                        Text("รายการ", style: TextStyle(fontSize: 20.0)),
                      ],
                    ),
                    Row(
                      children: [
                        Text("รวม", style: TextStyle(fontSize: 20.0)),
                        Container(
                          color: Colors.grey.shade50,
                          child: Text(
                            " ${(_sum > 0) ? '+' : ''}${_sum.toStringAsFixed(2)} บาท",
                            style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                                color: (_sum == 0.0)
                                    ? Colors.black
                                    : (_sum > 0)
                                        ? Colors.green
                                        : Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Expanded(
                  child: FutureBuilder<List<TransactionItem>>(
                    future: _transactionList,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (snapshot.hasData) {
                        if (snapshot.data!.length == 0) {
                          return Center(
                            child: Text("ไม่พบรายการ"),
                          );
                        }

                        return ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            var item = snapshot.data![index];
                            var color =
                                (item.type == 0) ?
                                Colors.green : Colors.red;
                            return Card(
                              color: Colors.grey.shade50,
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          (item.type == 0) ? "รายรับ" : "รายจ่าย",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20.0,
                                            color: color,
                                          ),
                                        ),
                                        Text(
                                          "${item.created_at}",
                                          style: TextStyle(
                                              color: Colors.grey.shade600),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                16.0, 0.0, 16.0, 0.0),
                                            child: Text(
                                              "${item.desc}",
                                            ),
                                          ),
                                        ),
                                        Text(
                                          "${(item.type == 0) ? '+' : '-'}${item.amount.toStringAsFixed(2)} บาท",
                                          style: TextStyle(
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.bold,
                                            color: color,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }

                      return SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  initState() {
    super.initState();

    _transactionList = _loadTransactionList();
  }

  Future<List<TransactionItem>> _loadTransactionList() async {
    setState(() {
      _sum = 0.0;
    });
    if (["", "0", "1"].contains(_type)) {
      var res = await Api().loadTransactionList(
        "transaction",
        startDate: _startDate,
        endDate: _endDate,
        type: _type,
      );
      var sum = 0.0;
      for (var i = 0; i < res.length; ++i) {
        if (res[i].type == 0) {
          sum += res[i].amount;
        } else {
          sum -= res[i].amount;
        }
      }
      setState(() {
        _sum = sum;
      });

      return res;
    } else {
      return [];
    }
  }

  Widget _buildFilterWidget(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(Icons.filter_alt_outlined),
            SizedBox(
              width: 8.0,
            ),
            Text("ตัวกรอง", style: TextStyle(fontSize: 20.0)),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text("ตั้งแต่"),
            TextButton(
              onPressed: () async {
                final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _startDate,
                    firstDate: DateTime(2021),
                    lastDate: DateTime(2024));
                if (picked != null) {
                  setState(() {
                    _startDate = picked;
                  });
                }
              },
              child: Text("วันที่ ${formatDateTime(_startDate)}"),
            ),
            Text("ถึง"),
            TextButton(
              onPressed: () async {
                final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _endDate,
                    firstDate: DateTime(2021),
                    lastDate: DateTime(2024));
                if (picked != null) {
                  setState(() {
                    _endDate = picked;
                  });
                }
              },
              child: Text("วันที่ ${formatDateTime(_endDate)}"),
            ),
          ],
        ),
        Row(
          children: [
            Row(
              children: [
                Checkbox(
                    value: _income,
                    onChanged: (value) {
                      setState(() {
                        _income = !_income;
                      });
                    }),
                Text("รายรับ"),
              ],
            ),
            Row(
              children: [
                Checkbox(
                    value: _expense,
                    onChanged: (value) {
                      setState(() {
                        _expense = !_expense;
                      });
                    }),
                Text("รายจ่าย"),
              ],
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  if (_income & _expense) {
                    _type = "";
                  } else if (_income) {
                    _type = "0";
                  } else if (_expense) {
                    _type = "1";
                  } else {
                    _type = "3";
                  }
                  setState(() {
                    _transactionList = _loadTransactionList();
                  });
                },
                child: Text("ตกลง"),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.6),
            ),
            child: Column(
              children: [
                Container(
                  child: Row(
                    children: [
                      Image(
                        image: AssetImage("assets/images/logo.png"),
                        width: 50.0,
                        height: 50.0,
                      ),
                      SizedBox(width: 20.0),
                      Text(
                        "สมุดบัญชีของฉัน",
                        style: TextStyle(fontSize: 24.0),
                      ),
                    ],
                  ),
                ),
                const Divider(
                  height: 20,
                  thickness: 5,
                ),
                SizedBox(height: 20.0),
                Row(
                  children: [
                    Text(
                      "ยินดีต้อนรับ: คุณ $_username",
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(16.0, 0.0, 0.0, 0.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20.0),
                bottomLeft: const Radius.circular(20.0),
              ),
              color: Theme.of(context).primaryColor.withOpacity(0.7),
            ),
            child: ListTile(
              onTap: () {},
              title: Row(
                children: [
                  Icon(Icons.book, size: 28.0),
                  SizedBox(width: 8.0),
                  Text(
                    "สมุดบัญชีของฉัน",
                    style: TextStyle(fontSize: 20.0),
                  ),
                ],
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(16.0, 0.0, 0.0, 0.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20.0),
                bottomLeft: const Radius.circular(20.0),
              ),
            ),
            child: ListTile(
              onTap: () {
                _storage.remove("username");
                _storage.remove("auth_token");
                Navigator.pushReplacementNamed(context, LoginPage.routeName);
              },
              title: Row(
                children: [
                  Icon(Icons.exit_to_app, size: 28.0),
                  SizedBox(width: 8.0),
                  Text(
                    "ลงชื่อออก",
                    style: TextStyle(fontSize: 20.0),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
