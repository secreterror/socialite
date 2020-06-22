import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:social/models/user.dart';
import 'package:social/pages/home.dart';
import 'package:social/widget/post.dart';


class MinUi extends StatefulWidget {

  final User currentUser;
  MinUi({this.currentUser});
  @override
  _MinUiState createState() => _MinUiState();
}

class _MinUiState extends State<MinUi> {
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
  @override
  Widget build(BuildContext context) {
    return posts==null?Scaffold(
      backgroundColor: Colors.black,
      body: Center(
          child: SpinKitWave(color: Colors.blueGrey,size: 100, type: SpinKitWaveType.end)
      ),
    ):Scaffold(
      backgroundColor:Colors.blueGrey,
      body: RefreshIndicator(
        onRefresh: ()=>getTimeline(),
        child: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 10,left: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(

                    child: Column(
                      children: <Widget>[
                        CircleAvatar(
                          backgroundImage: CachedNetworkImageProvider(currentUser.photoUrl),
                          backgroundColor: Colors.black,
                        ),
                        Row(
                          children: <Widget>[
                            Text('Welcome ',
                              style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                fontSize: 20
                              ),
                            ),
                            Text(currentUser.username,
                              style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  color: Colors.black,
                                fontSize: 20
                              ),
                            ),
                          ],
                        )


                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height:10),
            Container(
              height: MediaQuery.of(context).size.height-MediaQuery.of(context).size.height /5,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(75.0),topRight:Radius.circular(75.0) ),
              ),
              child: ListView(
                primary: false,
                padding: EdgeInsets.only(left: 20.0,right: 20.0),
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top:60),
                    child: Container(
                      height: MediaQuery.of(context).size.height-MediaQuery.of(context).size.height /3,
                      child: ListView(
                        children: posts,
                      ),
                    ),
                  ),
                ],
              )
              ,
            )

          ],
        ),
      ),

    );
  }
}
