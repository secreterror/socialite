
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:social/pages/home.dart';
import 'package:social/pages/post_screen.dart';
import 'package:social/pages/profile.dart';
import 'package:social/widget/header.dart';
import 'package:timeago/timeago.dart' as timeago;


class ActivityFeed extends StatefulWidget {
  @override
  _ActivityFeedState createState() => _ActivityFeedState();
}

class _ActivityFeedState extends State<ActivityFeed> {

  getActivityFeed()async {
    print(currentUser.id);
    QuerySnapshot snapshot =await actFeedRef.document(currentUser.id).collection("feedItems")
    .orderBy('timestamp',descending: true)
        .limit(50)
        .getDocuments();
    print(snapshot.documents);

    List<ActFeedItems> lis=[];
    snapshot.documents.forEach((doc){
      print('im here');
      lis.add(ActFeedItems.fromDocument(doc));
      print('hree tooo');
      print(doc);

    });



    return lis;


  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(title: "Activity Feed",removebackbutton: true),
      body: Container(
        child: FutureBuilder(
          future: getActivityFeed(),
          builder: (context,snapshot){
            if(!snapshot.hasData){
              return Scaffold(
                backgroundColor: Colors.black,
                body: Center(
                  child: SpinKitSpinningCircle(color: Colors.blueGrey,size: 70,)
                  ,
                ),
              );

            }
            return Ink(
              color: Colors.black,
              child: ListView(
                children: snapshot.data,

              ),
            );
          },
        ),
      ),

    );
  }
}
Widget mediaPreview;
String actItemText;
class ActFeedItems extends StatelessWidget {
  final String username;
  final String userId;
  final String type;
  final String mediaUrl;
  final String userProfileImg;
  final String comments;
  final Timestamp timestamp;
  final String postId;
  ActFeedItems({this.username,this.userId,this.timestamp,this.type,this.comments,this.mediaUrl,this.userProfileImg,this.postId});

  factory ActFeedItems.fromDocument(DocumentSnapshot doc){

    print('in the method');
    return ActFeedItems(


      username: doc['username'],

      userId:doc['userId'],
      mediaUrl: doc['mediaUrl'],
      userProfileImg:doc['userProfileImg'],
      timestamp: doc['timestamp'],
      type:doc['type'],
      comments: doc['comment'],
      postId: doc['postId'],





    );
  }
  showpost(context){
    Navigator.push(context, MaterialPageRoute(builder: (context)=>
        PostScreen(postId:postId,userId:currentUser.id)
    ));
    
  }
  configureMediaPreview(context){

    if(type=="like"||type=='comment'){
      mediaPreview=GestureDetector(
        onTap: ()=>showpost(context),
        child: Container(
          height: 50.0,
          width: 50.0,
          child: AspectRatio(
            aspectRatio: 16/9,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: CachedNetworkImageProvider(mediaUrl)
                )
              ),
            ),
          ),
        ),


      );

    }
    else{
      mediaPreview=Text('');

    }

    if(type=='like'){
      actItemText=' liked your post';
    }else if(type=='follow'){
      actItemText='  is following you';
    }
    else if(type=='comment'){
      actItemText=' replied: $comments';
    }
    else{
        actItemText=' Error : $type';
    }
  }

  @override
  Widget build(BuildContext context) {

    configureMediaPreview(context);
    return Padding(
      padding: EdgeInsets.only(bottom: 2.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black
        ),
        child: ListTile(
          title: GestureDetector(
            onTap: ()=>showProfile(context,profileId: userId),
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.white,


                ),
                children: [
                  TextSpan(
                    text: username,
                    style: TextStyle(fontWeight: FontWeight.bold)
                  ),
                  TextSpan(
                    text: '$actItemText'
                  )
                ]
              ),

            ),
          ),
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(userProfileImg),

          ),
          subtitle: Text(
            timeago.format(timestamp.toDate()),



          ),
          trailing: mediaPreview,
        ),
      ),

    );
  }
}

showProfile(BuildContext context,{String profileId}){
  Navigator.push(context, MaterialPageRoute(builder: (context)=>
  Profile(profileId: profileId,)
  ),
  );
}

