import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:social/models/user.dart';
import 'package:social/pages/editprofile.dart';
import 'package:social/pages/home.dart';
import 'package:social/pages/timeline.dart';
import 'package:social/widget/header.dart';
import 'package:social/widget/post.dart';
import 'package:social/widget/post_tile.dart';
import 'package:social/widget/waitingIndicator.dart';
class Profile extends StatefulWidget {
  final profileId;
  Profile({this.profileId});
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  bool isFollowing =false;

  bool isLoading=false;
  int postcount=0;
  int followerCount=0;
  int followingCount=0;
  List<Post> posts=[];
  String postOrientation="grid";
  bool ok=false;


  @override
  void initState() {
    super.initState();
    getProfilePosts();
    getFollowers();
    getFollowing();
    checkIfFollowing();
  }

  checkIfFollowing() async {
    DocumentSnapshot doc =await followersRef.document(widget.profileId)
        .collection('userFollowers')
        .document(currentUserId)
        .get();

    setState(() {
      isFollowing =doc.exists;
    });

  }
  getFollowers()async{
    QuerySnapshot snapshot =await followersRef
        .document(widget.profileId)
        .collection('userFollowers')
        .getDocuments();
    setState(() {
      followerCount=snapshot.documents.length;
    });
  }
  getFollowing()async{
    QuerySnapshot snapshot =await followingRef
        .document(widget.profileId)
        .collection('userFollowing')
        .getDocuments();
    setState(() {
      followingCount=snapshot.documents.length;
    });
  }
  getProfilePosts()async{
    setState(() {
      isLoading=true;
    });
    QuerySnapshot snapshot=await postRef.document(widget.profileId)
    .collection('userpost')
    .getDocuments();
      setState(() {
      isLoading=false;
      postcount=snapshot.documents.length;
      posts=snapshot.documents.map((doc)=>Post.fromDocument(doc)).toList();

    });

  }
  final String currentUserId=currentUser?.id;
  Column buildcountcol(String tit,int cnt){
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          cnt.toString(),
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 4.0),
          child: Text(tit,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 15.0,
            fontWeight: FontWeight.w400
          ),),
        )
      ],

    );

  }
  editprofile(){
    Navigator.push(context,MaterialPageRoute(builder: (context)=>
        EditProfile(currentUserId:currentUserId)
    ));

  }
  Container buildButton({String text,Function fuc}){
    return Container(
      padding: EdgeInsets.only(top:2.0),
      child: FlatButton(

        onPressed: fuc,
        child: Container(
          height:27 ,
          width: 200,
          child: Text(text,
          style: TextStyle(
            color: isFollowing?Colors.black:Colors.white,
            fontWeight: FontWeight.bold
          ),),
          alignment: Alignment.center ,
          decoration: BoxDecoration(
            color: isFollowing?Colors.white:Colors.blue,
            border: Border.all(
              color: isFollowing?Colors.grey:Colors.blue
            )
              ,
            borderRadius: BorderRadius.circular(5.0),
          ),
        ),
      ),


    );


  }

  buildprofilebutton(){

    // if we are Viweing our own profile
    bool isProfileOwner=currentUserId==widget.profileId;

    if(isProfileOwner){
      return buildButton(
        text: 'Edit Profile',
        fuc: editprofile
      );
    }else if(isFollowing){
      return buildButton(text:'unfollow',fuc:handleUnfollowuser);
    }else if(!isFollowing){
      return buildButton(text:'follow',fuc:handleFollowuser);
    }



  }
  handleFollowuser(){
    setState(() {
      isFollowing=true;
      followerCount+=1;
    });
    //Make auth user follower of the another user (update their follower collection)
    followersRef
    .document(widget.profileId)
    .collection('userFollowers')
    .document(currentUserId).setData({

    });
    // Put That User IN my following collection
    followingRef
    .document(currentUserId)
    .collection('userFollowing')
    .document(widget.profileId)
    .setData({

    });

    // add a activity feed notification
    actFeedRef.document(widget.profileId)
    .collection('feedItems')
    .document(currentUserId)
    .setData({
      "type":"follow",
      "ownerId":widget.profileId,
      "username":currentUser.username,
      "userId":currentUserId,
      "userProfileImg":currentUser.photoUrl,
      "timestamp":DateTime.now()


    });



  }
  handleUnfollowuser()async{
    setState(() {
      isFollowing=false;
      followerCount-=1;
    });
    // remove from their follower list
    DocumentSnapshot doc=await followersRef
        .document(widget.profileId)
        .collection('userFollowers')
        .document(currentUserId).get();

    if(doc.exists){
      doc.reference.delete();
    }
    // remove from folloeing
    DocumentSnapshot adoc=await followingRef
        .document(currentUserId)
        .collection('userFollowing')
        .document(widget.profileId)
        .get();
    if(adoc.exists){
      adoc.reference.delete();
    }


    // delete activity feed
   DocumentSnapshot actdoc=await actFeedRef.document(widget.profileId)
        .collection('feedItems')
        .document(currentUserId)
        .get();
    if(actdoc.exists){
      actdoc.reference.delete();
    }

  }
  buildprofileheader(){
    return FutureBuilder(
      future:usersref.document(widget.profileId).get() ,
      builder: (context,snapshot){
         if(!snapshot.hasData){
           return Center(child: Text(''));
         }
         User user=User.fromDocument(snapshot.data);
         print(user);
         return Padding(
           padding: EdgeInsets.all(16.0),
           child: Column(
             children: <Widget>[
               Row(
                 children: <Widget>[
                   CircleAvatar(
                     radius: 40.0,
                     backgroundColor: Colors.grey,
                     backgroundImage: CachedNetworkImageProvider(user.photoUrl),

                   ),

                   Expanded(
                     flex: 1,
                     child: Column(
                       children: <Widget>[
                         Row(
                           mainAxisSize: MainAxisSize.max,
                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                           children: <Widget>[
                             buildcountcol("posts",postcount),
                             buildcountcol("followers",followerCount),
                             buildcountcol("following",followingCount),
                           ],
                         ),
                         Row(
                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                           children: <Widget>[
                             buildprofilebutton()
                           ],
                         )

                       ],
                     ),

                   )
                 ],
               ),
               Container(
                 alignment: Alignment.centerLeft,
                 padding: EdgeInsets.only(top: 12.0),
                 child: Text(
                    user.username,
                   style: TextStyle(
                      fontWeight: FontWeight.bold,
                     fontSize: 16.0
                   ),
                 ),
               ),
               Container(
                 alignment: Alignment.centerLeft,
                 padding: EdgeInsets.only(top:4.0),
                 child: Text(
                   user.displayName,
                   style: TextStyle(
                     fontWeight:FontWeight.bold
                   ),
                 ),
               ),
               Container(
                 alignment: Alignment.centerLeft,
                 padding: EdgeInsets.only(top:2.0),
                 child: Text(
                   user.bio,
                   style: TextStyle(
                       fontWeight:FontWeight.bold
                   ),
                 ),
               )

             ],
           ),


         );
      },

    );
  }
  buildProfilePost(){
    print(postOrientation);
    if(isLoading){
      return Padding(
        padding: const EdgeInsets.only(top :100.0),
        child: Center(child:SpinKitWave(color: Colors.blueGrey, type: SpinKitWaveType.center)),
      );

    }else if(posts.length==0){
      print(ok);

      return buildNoPost();
    }
    else if(postOrientation=='grid'){

        print('innt the grid');
        List<GridTile> gridTile=[];
        posts.forEach((post){

          gridTile.add(GridTile(child: PostTile(post:post)));

        });
        return GridView.count(crossAxisCount: 3,
            childAspectRatio: 1.0,
            mainAxisSpacing: 1,
            crossAxisSpacing: 2,
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            children: gridTile
        );

    }else if(postOrientation=='list'){

      return Column(
        children: posts,
      );


    }











  }
  setPostOrien(String postorien){
    print('immmmm');
    setState(() {
      postOrientation=postorien;
    });

  }

  Container buildNoPost(){
    final Orientation mq=MediaQuery.of(context).orientation;
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top:80),
              child: SvgPicture.asset('assets/images/camera.svg',height:mq==Orientation.portrait ?100.0:50.0),
            ),
            Text('No Posts',textAlign: TextAlign.center,style:
            TextStyle(
                color: Colors.black,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
                fontSize: 30.0
            ),)
          ],
        ),
      ),

    );

  }


  buildTogglePost(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.grid_on),
          onPressed:()=> setPostOrien("grid"),
          color: postOrientation=='grid'?Colors.purple:Colors.grey,
        ),
        IconButton(
          icon: Icon(Icons.list),
          onPressed:()=>setPostOrien("list"),
          color: postOrientation=='list'?Colors.purple:Colors.grey,
        )
      ],

    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: header(title: 'Profile'),
      body: ListView(
        children: <Widget>[
           buildprofileheader(),
          Divider(),
          buildTogglePost(),
          Divider(
            height: 0.0
          ),
          buildProfilePost(),

        ],

      )
    );
  }
}
