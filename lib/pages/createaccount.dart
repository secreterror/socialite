import 'dart:async';

import 'package:flutter/material.dart';
import 'package:social/widget/header.dart';
class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  String username;
  final fkey=GlobalKey<FormState>();
  final sckey=GlobalKey<ScaffoldState>();

  submit(){

    if(fkey.currentState.validate()){
      fkey.currentState.save();
      final SnackBar snackbar=SnackBar(content:  Text('Welcommeee $username!!!'),);
      sckey.currentState.showSnackBar(snackbar);

      Timer(Duration(seconds: 2),(){
        Navigator.pop(context,username);
      });

    }

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: sckey,
      appBar:header(title: 'Set Up Your Profile',removebackbutton: true) ,
      body: ListView(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 35.0),
                  child: Center(
                    child: Text('Create A Username',
                    style: TextStyle(
                      fontSize: 25.0
                    ),),
                  ),

                ),
                Padding(
                  padding:EdgeInsets.all(16.0) ,
                  child: Container(
                    child: Form(
                      key: fkey,
                      autovalidate: true,
                      child: TextFormField(
                        onSaved: (val)=>username=val,
                        validator: (val){
                          if(val.trim().length<5||val.isEmpty){
                            return 'Username too short';
                          }
                          else if(val.trim().length>15){
                            return 'username too long';
                          }
                          return null;
                        },

                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Username',
                          labelStyle: TextStyle(fontSize:15.0),

                          hintText:"MUST  be at least 3 char"
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(

                  onTap: submit,
                  child: Container(
                    height: 50,
                    width: 350,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(7.0)
                    ),
                    child: Center(
                      child: Text(
                        'Submit',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ),

                )


              ],
            ),
          )
        ],
      ),
    );
  }
}
