import 'package:flutter/material.dart';
import 'package:flutter_app/pages/add_new/add_new_page.dart';
import 'package:flutter_app/pages/home/home_page.dart';
import 'package:flutter_app/pages/login/login_page.dart';
import 'package:flutter_app/pages/register/register_page.dart';
import 'package:flutter_app/services/api.dart';
import 'package:flutter_app/services/storage.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        fontFamily: GoogleFonts.kanit().fontFamily,
        primaryTextTheme: TextTheme(headline6: TextStyle(color: Colors.white)),
        textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
                side: BorderSide(color: Colors.deepOrange, width: 1),
                textStyle:
                    TextStyle(fontFamily: GoogleFonts.kanit().fontFamily))),
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
                textStyle:
                    TextStyle(fontFamily: GoogleFonts.kanit().fontFamily))),
        inputDecorationTheme: InputDecorationTheme(
          border: const OutlineInputBorder(),
        ),
      ),
      routes: {
        LoginPage.routeName: (context) => const LoginPage(),
        HomePage.routeName: (context) => const HomePage(),
        RegisterPage.routeName : (context) => const RegisterPage(),
        AddTransactionPage.routeName: (context) => const AddTransactionPage(),
      },
      initialRoute: LoginPage.routeName,
    );
  }
}

