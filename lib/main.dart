import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social/pages/home.dart';


void main(){

  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'socialite',
      home: Home(),
      theme: ThemeData.dark().copyWith(
        accentColor: Colors.black
      ),
    );
  }
}

