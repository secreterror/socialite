import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:social/models/user.dart';
import 'package:social/pages/home.dart';
import 'package:social/widget/header.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social/widget/post.dart';


class Timeline extends StatefulWidget {

  final User currentUser;
  Timeline({this.currentUser});
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  List<Post>posts;

  @override
  void initState(){

    super.initState();
    getTimeline();
  }

  getTimeline()async{
    QuerySnapshot snapshot =await timelineRef
        .document(widget.currentUser.id)
        .collection('timelinePosts')
        .orderBy('timestamp',descending: true)
        .getDocuments();
   List<Post> posts= snapshot.documents.map((doc)=>Post.fromDocument(doc)).toList();

   setState(() {
     this.posts=posts;
   });

  }

  buildTimeline(){
    if(posts==null){
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: SpinKitWave(color: Colors.blueGrey,size: 100, type: SpinKitWaveType.end)
        ),
      );
    }
    return Ink(
      color: Colors.black,
      child: ListView(
        children: posts,
      ),
    );

  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: header(isAppbar: true),
      body: RefreshIndicator(
        onRefresh: ()=>getTimeline(),
        child: buildTimeline(),

      ),

    );
  }
}
//class Timeline extends StatefulWidget {
//
//  final User currentUser;
//  Timeline({this.currentUser});
//
//
//  @override
//  _TimelineState createState() => _TimelineState();
//}
////final usersref = Firestore.instance.collection('users');
//class _TimelineState extends State<Timeline> {
//
//
////  List<dynamic> users = [];
//
//  @override
//  void initState() {
//////    getusers();
////////      getuserbyid();
////
////    updateUser();
//    super.initState();
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//        appBar: header(isAppbar: true),
//
//// so inn order to do this we have to apply logic here
////      body:Container(
////         child: ListView(children: users.map((user)=>
////             Text(user['username']))
////             .toList()
////         ),
////      )
//        // future builder
////        body: StreamBuilder<QuerySnapshot>(
////            stream: usersref.snapshots(),
////            builder: (context, snapshot) {
////              // this snapshot have different property
////              if (!snapshot.hasData) {
////                return Container(
////                    child: Center(child: CircularProgressIndicator()));
////              }
////              final List<dynamic> children = snapshot.data.documents
////                  .map((doc) => Container(
////
////                child: Row(
////                  children: <Widget>[
////                    Text(doc['username']),
////                    Text((doc['username']))
////                  ],
////                ),
////              ))
////                  .toList();
////              return Container(
////                  child: ListView(
////                    children: children,
////
////
////                  )
////              );
////            }
////        )
////    );
////  }
//
////  @override
////  Widget build(BuildContext context) {
////    // TODO: implement build
////    return null;
////  }
//
//// applied here
////  getusers() async {
////    final QuerySnapshot snapshot = await usersref.getDocuments();
//////        .where("likes",isLessThan: 500)
//////        .where("username",isEqualTo: "yash")
//////          .orderBy('likes',descending: true)
//////            .limit(2 )
//////
//////        .getDocuments();
////    // applied here and purt it iin list
////    setState(() {
////      users = snapshot.documents;
////    });
//
////    snapshot.documents.forEach((doc){
////
////      print(doc.data);
////      print(doc.documentID);
////
////    });
//
//
//
//
////  getusers(){
////    usersref.getDocuments().then((QuerySnapshot snapshot){
////      //this document is a list
////      snapshot.documents.forEach((DocumentSnapshot doc){
////        print(doc.data);
////        print(doc.documentID);
////
////      });
////
////    });
////  }
//  //either can use then to resolve future or make the fucnction body async
////  getuserbyid()async{
////    String id="vI8iL6RQjo1aRk71q3pM";
//////    usersref.document(id).get().then((DocumentSnapshot doc){
//////      print(doc.data);
//////      print(doc.documentID);
//////
//////    });
////      DocumentSnapshot doc=await usersref.document(id).get();
////
////      print(doc.data);
////      print(doc.documentID);
////  }
//
//
//
//    createUser()  async {
////        usersref.document("aanananan").setData({
////
////          "admin":true,
////          "likes":0,
////          "username":"bobooo"
////
////        });
//
//        await usersref.add({
//          "admin":true,
//          "likes":0,
//          "username":"boooo"
//        });
//
//
//
//    }
//
//
//    updateUser(){
//    usersref
//        .document('vI8iL6RQjo1aRk71q3pM')
//        .updateData({
//        "username":"cheerskun"
//
//    });
//
//    }
//
//}
