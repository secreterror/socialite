import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:social/pages/home.dart';
import 'package:social/widget/header.dart';
import 'package:social/widget/post.dart';

class PostScreen extends StatelessWidget {

  final String userId;
  final String postId;

  PostScreen({this.userId,this.postId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: postRef.document(userId).collection('userpost').document(postId).get(),
      builder: (context,snapshot){
        if(!snapshot.hasData){
          return Scaffold(
            backgroundColor: Colors.black,
              body:Center(
                  child:SpinKitWave(color: Colors.blueGrey, type: SpinKitWaveType.center)
          ));

        }
        Post post=Post.fromDocument(snapshot.data);
        return Center(
          child: Scaffold(
            backgroundColor: Colors.black,
            appBar: header(title: post.caption),
            body: ListView(
              children: <Widget>[
                Container(
                  child: post,
                )
              ],
            ),

          ),
        );
      }




    );
  }
}


