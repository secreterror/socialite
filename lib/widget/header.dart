import 'package:flutter/material.dart';


AppBar header({bool isAppbar=false, String title,bool removebackbutton=false}){
  return AppBar(
    automaticallyImplyLeading: removebackbutton?false:true,
    title: Text(
      isAppbar?'':title,
      style: TextStyle(
        color: Colors.white,
        fontFamily: 'Montserrat',
        fontSize:   isAppbar?50.0:22.0
      ),
      overflow: TextOverflow.ellipsis,
    ),
    centerTitle: true,
    backgroundColor: Colors.blueGrey,
  );
}