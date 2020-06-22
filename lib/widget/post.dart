


import 'dart:async';

import 'package:animator/animator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:social/models/user.dart';
import 'package:social/pages/activityfeed.dart';
import 'package:social/pages/comments.dart';
import 'package:social/pages/home.dart';
import 'package:social/pages/timeline.dart';
import 'package:social/widget/custom_img.dart';
class Post extends StatefulWidget {
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String caption;
  final String mediaUrl;
  final Map likes;

  Post({
    this.postId,
    this.ownerId,this.username,this.location,this.caption,this.mediaUrl
    ,this.likes});

  factory Post.fromDocument(DocumentSnapshot doc){
    return Post(
      postId: doc['postId'],
      ownerId: doc['ownerId'],
      caption: doc['description'],
      mediaUrl: doc['mediaUrl'],
      likes: doc['likes'],
      location: doc['location'],
      username: doc['username'],


    );
  }
  int getLikeCnt(likes){
    if(likes==null){
      return 0;
    }
    int cnt=0;
    likes.values.forEach((val){
      if(val==true)
        {
          cnt+=1;
        }

    });
    return cnt;
  }

  @override
  _PostState createState() => _PostState(
    postId: this.postId,
    ownerId: this.ownerId,
    likecount: getLikeCnt(this.likes),
    username: this.username,
    mediaUrl: this.mediaUrl,
    caption: this.caption,
    likes: this.likes,
    location: this.location

  );
}

class _PostState extends State<Post> {
  bool isLiked;
  final String currUser=currentUser?.id;
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String caption;
  final String mediaUrl;
  int likecount=0;
  Map likes;
  bool showHeart=false;

  void initState(){
    super.initState();

  }


  _PostState({
    this.postId,
    this.ownerId,this.username,this.location,this.caption,this.mediaUrl,this.likecount
    ,this.likes});


  buildPostHeader(){

    return FutureBuilder(
      future: usersref.document(ownerId).get(),
      builder: (context,snapshot){

        if(!snapshot.hasData){
          return Center(
            child: Container(
              child: Padding(
                padding: const EdgeInsets.only(top:250),
                child: SpinKitDualRing(color: Colors.white),
              ),
            ),
          );
        }

        User user=User.fromDocument(snapshot.data);
        bool isPostOwner=(currUser==ownerId);
        return Column(
          children: <Widget>[
            ListTile(
              leading:  CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(
                  user.photoUrl
                ),
                backgroundColor: Colors.deepPurple,

              ),
              title: GestureDetector(
                onTap: ()=>showProfile(context,profileId:  user.id),
                child: Text(user.username,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Montserrat'
                ),
                ),


              ),
              subtitle: Text(location),
              trailing: isPostOwner ?IconButton(
                onPressed: ()=>handleDeletePost(context),
                icon: Icon(Icons.more_vert),

              ):Text(''),

            ),
            buildPostImage(),
            buildPostFooter()
          ],
        );

      }
    );


  }

  handleDeletePost(BuildContext parentContext){
    return showDialog(
      context: parentContext,
      builder: (context){
        return SimpleDialog(
          title: Text('Remove This Post'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: (){
                Navigator.pop(context);
                deletePost();
              },
              child: Text(
                'Delete',
                style: TextStyle(
                  color: Colors.red
                ),
              ),
            ),
            SimpleDialogOption(
              onPressed: ()=>Navigator.pop(context),
              child: Text('Cancel'),
            )

          ],
        );
      }

    );

  }
  deletePost()async{

    DocumentSnapshot doc =await postRef
    .document(ownerId)
        .collection('userpost')
        .document(postId)
        .get();
    if(doc.exists){
      doc.reference.delete();
    }
    storageref.child("post_$postId.jpg").delete();


    QuerySnapshot actFeedSnapshot= await actFeedRef
    .document(ownerId)
    .collection('feedItems')
    .where('postId',isEqualTo: postId)
    .getDocuments();

    actFeedSnapshot.documents.forEach((doc){
      if(doc.exists){
        doc.reference.delete();
      }

    });

    QuerySnapshot commentsSnapshot= await commentsRef.document(postId)
    .collection('comments')
    .getDocuments();

    commentsSnapshot.documents.forEach((doc){
      if(doc.exists){
        doc.reference.delete();
      }

    });




  }
  buildPostImage(){
    return GestureDetector(

      onDoubleTap: ()=>handleLike(),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          cachedNetworkImage(mediaUrl),
//          showHeart?Icon(Icons.favorite,size: 80.0 ,color: Colors.red,):Text(""
        showHeart?Animator(
          duration: Duration(milliseconds: 200),
          tween: Tween(begin: 0.8,end: 1.4),
          curve: Curves.elasticOut,
          cycles: 0,
          builder: (context,anim,child) => Transform.scale(

            scale: anim.value,
            child: Icon(
              Icons.favorite,
              size: 80,
              color: Colors.red,)

          ),


        ):Text("")

        ],
      ),



    );
  }
  
  
  buildPostFooter(){

    print("i am "+"$username");
    print("location "+location);
    print("caption "+caption);
    print("media usrl "+mediaUrl);
//    print("i am "+"$username");
//    print("i am "+"$username");
//    print("i am "+"$username");
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top:40.0,left: 20.0),

            ),
            GestureDetector(
              onTap: ()=>handleLike(),
              child: Icon(
                isLiked?Icons.favorite:Icons.favorite_border,
                color: Colors.pink,
                size: 28.0,
              ),

            ),
            Padding(
              padding: EdgeInsets.only(right: 20.0),
            ),
            GestureDetector(
              onTap: ()=>showcomments(
                context,
                postId:postId,
                ownerId:ownerId,
                mediaUrl:mediaUrl

              ),
              child: Icon(
                Icons.chat_bubble_outline,
                color: Colors.blue,
                size: 28.0,
              ),

            ),

          ],
        ),
        Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: Text(
                "$likecount likes",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold
                ),
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: Text(
                "$username",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  fontFamily: 'Montserrat'
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 20,bottom:30),
            ),
            Expanded(
              child: Text(caption),
            )
          ],
        )
      ],
    );

  }

  handleLike(){
    bool _isLiked = likes[currUser]   == true;

    if(_isLiked){
      print('liked');
      postRef.document(ownerId)
      .collection('userpost')
      .document(postId)
      .updateData({
        'likes.$currUser'.toString():false

      });
      removelikefromact();
      setState(() {
        likecount-=1;
        isLiked=false;
        likes[currUser]=false;
      });
    }else if(!_isLiked){

      print('not liked');
      postRef.document(ownerId)
          .collection('userpost')
          .document(postId)
          .updateData({
      'likes.$currUser'.toString():true

      });
      addLikeToAct();
      setState(() {
        likecount+=1;
        isLiked=true;
        likes[currUser]=true;
        showHeart=true;
      });
      Timer(Duration(milliseconds: 500),(){
        setState(() {
          showHeart=false;
        });



      });

    }


  }
  removelikefromact()async{
    bool isPostOwner=currentUser.id==ownerId;

    if(!isPostOwner){
      DocumentSnapshot doc=await actFeedRef.document(ownerId)
          .collection('feedItems')
          .document(postId)
          .get();
      if(doc.exists){
        doc.reference.delete();
      }
    }
  }
  addLikeToAct(){
    bool isPostOwner=currentUser.id==ownerId;
    if(!isPostOwner){
      actFeedRef.document(ownerId)
          .collection('feedItems')
          .document(postId)
          .setData({
        "type":"like",
        "username":currentUser.username,
        "userId":currentUser.id,
        "userProfileImg":currentUser.photoUrl,
        "postId": postId,
        "mediaUrl":mediaUrl,
        "timestamp":DateTime.now()

      });
    }

  }


  @override
  Widget build(BuildContext context) {
    isLiked=(likes[currUser]==true);
    print(likes[currUser]);
    print(currUser);
    print(likes);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        buildPostHeader(),
      ],
    );
  }

}

showcomments(BuildContext context,{String postId,String ownerId,String mediaUrl}){
  Navigator.push(context,MaterialPageRoute(
    builder:(context){
      return Comments(
        postId:postId,
        postOwnerId:ownerId,
        postMediaUrl:mediaUrl

      );
    }
  )
  );
}






