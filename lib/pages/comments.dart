

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:social/widget/header.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'home.dart';

class Comments extends StatefulWidget {
  final String postId;
  final String postOwnerId;
  final String  postMediaUrl;
  Comments({this.postId,this.postOwnerId,this.postMediaUrl});
  @override
  _CommentsState createState() => _CommentsState(
    postId: this.postId,
    postMediaUrl: this.postMediaUrl,
    postOwnerId: this.postOwnerId

  );
}

class _CommentsState extends State<Comments> {
  TextEditingController commentcontroller=TextEditingController();

  final String postId;
  final String postOwnerId;
  final String  postMediaUrl;
  _CommentsState({
    this.postId,
    this.postOwnerId,
    this.postMediaUrl

});

  buildComments(){
    return StreamBuilder(
      stream: commentsRef.document(postId).collection('comments')
          .orderBy("timestamp").snapshots(),
      builder: (context,snapshot){
        if(!snapshot.hasData){
          return Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: SpinKitChasingDots(color: Colors.white,)
            ),
          );
        }
        List<Comment> comments=[];
        snapshot.data.documents.forEach((doc){
          comments.add(Comment.fromDocument(doc));

        });
        return Ink(
          color: Colors.black,
          child: ListView(
            children: comments,
          ),
        );

      },

    );
  }
  addcomment(){

    bool isPostOwner=currentUser.id==postOwnerId;
    commentsRef
    .document(postId)
        .collection('comments')
        .add({

      "username":currentUser.username,
      'comment':commentcontroller.text,
       'timestamp':DateTime.now(),
      'avatar':currentUser.photoUrl,
      'userId':currentUser.id

    });
    if(!isPostOwner){
      actFeedRef.document(postOwnerId)
          .collection('feedItems')
          .add({
        "type":"comment",
        "comment":commentcontroller.text,
        "username":currentUser.username,
        "userId":currentUser.id,
        "userProfileImg":currentUser.photoUrl,
        "postId": postId,
        "mediaUrl":postMediaUrl,
        "timestamp":DateTime.now()

      });
    }
    commentcontroller.clear();

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(title: 'Comments'),
      body: Column(
         children: <Widget>[
           Expanded(
             child: buildComments(),

           ),
           Divider(
             color: Colors.grey,
             height: 1,
           ),
           Container(
             decoration: BoxDecoration(
               color: Colors.black
             ),
             child: ListTile(
               title: TextFormField(
                 controller: commentcontroller,
                 decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.blueGrey
                      ),
                      borderRadius: BorderRadius.circular(38)
                    ),
                   labelText: 'Write A Comment....',
                   labelStyle: TextStyle(
                     color: Colors.blueGrey
                   )
                 ),

               ),
               trailing: Container(
                 decoration: BoxDecoration(
                   borderRadius: BorderRadius.circular(32),
                   color: Colors.blueGrey
                 ),
                 child: OutlineButton(
                   onPressed: addcomment,
                   borderSide: BorderSide.none,
                   child: Text('Post',

                   style: TextStyle(
                     color: Colors.black,
                     fontWeight: FontWeight.bold,
                     fontSize: 15
                   ),
                   ),
                 ),
               ),
             ),
           )
         ],
      ),
    );
  }
}
class Comment extends StatelessWidget {

  final String username;
  final String userId;
  final String avatarUrl;
  final String comment;
  final Timestamp timestamp;

  Comment({
    this.username,
    this.userId,
    this.avatarUrl,
    this.comment,
    this.timestamp
  });

  factory Comment.fromDocument(DocumentSnapshot doc){
    return Comment(
      username: doc['username'],
      userId: doc['userId'],
      avatarUrl: doc['avatar'],
      comment: doc['comment'],
      timestamp: doc['timestamp'],

    );
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
           title: Row(children: <Widget>[
             Text(username,
             style: TextStyle(
               fontFamily: 'Montserrat',
               fontWeight: FontWeight.bold
             ),
             ),
             Padding(padding: EdgeInsets.only(left:8),),
             Expanded(child: Text(comment))
           ],),
          leading: CircleAvatar(

            backgroundImage: CachedNetworkImageProvider(avatarUrl),

          ),
          subtitle: Text(timeago.format(timestamp.toDate())),
        )
      ],

    );
  }
}

