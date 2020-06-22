
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:social/models/user.dart';
import 'package:social/pages/activityfeed.dart';
import 'package:social/pages/createaccount.dart';
import 'package:social/pages/minUi.dart';
import 'package:social/pages/profile.dart';
import 'package:social/pages/search.dart';
import 'package:social/pages/timeline.dart';
import 'package:social/pages/upload.dart';
import 'package:social/pages/welcome.dart';


class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}
final followersRef=Firestore.instance.collection('followers');
final firestore=Firestore.instance;
final followingRef=Firestore.instance.collection('following');
final StorageReference storageref=FirebaseStorage.instance.ref();
final postRef=Firestore.instance.collection('posts');
final timelineRef=Firestore.instance.collection('timeline');
final DateTime timestamp=DateTime.now();
User currentUser;
final GoogleSignIn googleSignIn=GoogleSignIn();
final commentsRef=Firestore.instance.collection('comments');
final actFeedRef=Firestore.instance.collection('feed');
final usersref=Firestore.instance.collection('users');
class _HomeState extends State<Home> {

  final _scaffoldKey=GlobalKey<ScaffoldState>();
  FirebaseMessaging _firebaseMessaging=FirebaseMessaging();

//  _scaffoldKey.currentState.showSnackbar()


  PageController controller;
  int pageIndex=0;

  int cnt=0;
  @override
  void initState(){
    super.initState();

    controller=PageController();

    googleSignIn.onCurrentUserChanged.listen((acc){
      handleSignIn(acc);
    },onError:(err){
      print('error while signing in $err');
    });

    googleSignIn.signInSilently(suppressErrors: false)
        .then((acc){
      handleSignIn(acc);
    }).catchError((err){
      print(err);
    });







  }

  handleSignIn (GoogleSignInAccount acc)async {
    if(acc!=null){
      await createUserInFirestore();

      setState(() {

        print('here');
        isAuth=true;
      });
      configurePushNotification(currentUser );


    }
    else{
      setState(() {
        isAuth=false;
      });
    }
  }
  configurePushNotification(user){


    // for ios

    if(Platform.isIOS) getiOSPerimission();

    _firebaseMessaging.getToken().then((token){

      print('firebase messaging token $token');
      usersref.document(user.id).updateData({
        'androidNotificationToken':token
      });

    });

    _firebaseMessaging.configure(
//      onLaunch: (Map<String ,dynamic> message) async {},
//      onResume:(Map<String ,dynamic> message) async{},
      onMessage: (Map<String ,dynamic> message) async{
        print('on message $message');
        final String recipientId=message['data']['recipient'];
        final String body=message['notification']['body'];

        if(recipientId==user.id){
          print('notification shown');
          SnackBar snackBar =SnackBar(content: Text(body,
            overflow: TextOverflow.ellipsis,)
            ,);
          _scaffoldKey.currentState.showSnackBar(snackBar);
        }
        else{
          print('not shown');
        }
      }
    );





  }
  getiOSPerimission(){
    _firebaseMessaging.requestNotificationPermissions(IosNotificationSettings(
      alert: true,
      badge: true,
      sound: true
    ));

    _firebaseMessaging.onIosSettingsRegistered.listen((setting){

      print('setting registered $setting');

    });
  }
  // ignore: must_call_super
  @override
  void dispose(){
    controller.dispose();
    super.dispose();
  }

  bool isAuth=false;


  logout(){
    googleSignIn.signOut();
  }
  onPageChanged(int page){
    setState(() {
      pageIndex=page;
    });

  }
  onTap(int page){
    controller.jumpToPage(page);

  }

  Widget buildAuth(){
    return Scaffold(
      key: _scaffoldKey,
      body: PageView(
        controller: controller,
        children: <Widget>[
          MinUi(currentUser: currentUser),

          ActivityFeed(),
          Upload(currentUser: currentUser,),
          Search(),
          Profile(profileId:currentUser?.id)

        ],
        onPageChanged: onPageChanged,

      ),
      bottomNavigationBar: CupertinoTabBar(
        backgroundColor: Colors.black,
        currentIndex: pageIndex,
        onTap: onTap,
        activeColor: Colors.blue,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home)),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_active)),
          BottomNavigationBarItem(icon: Icon(Icons.photo_camera,
          size: 40,)),
          BottomNavigationBarItem(icon: Icon(Icons.search)),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle)),
        ],
      ),
    );

  }
  Widget buildUnAuth(){
   return Welcome();
  }
//
//
//
//      body: Container(
//
//        decoration: BoxDecoration(
//          gradient: LinearGradient(
//            begin: Alignment.topRight,
//            end: Alignment.bottomLeft,
//            colors: [
//              Colors.teal,
//              Colors.deepPurple,
//
//            ]
//          )
//        ),
//        alignment: Alignment.center,
//
//
//
//        child: Column(
//          mainAxisAlignment: MainAxisAlignment.center,
//          crossAxisAlignment: CrossAxisAlignment.center,
//          children: <Widget>[
//            Text('SocialLite'),
//            SizedBox(
//
//              height: 50.0,
//              width:300.0,
//              child: Material(
//
//                borderRadius: BorderRadius.circular(20.0),
//                color: Colors.blueGrey,
//                child: InkWell(
//                  onTap: login,
//                  child: Row(
//                    children: <Widget>[
//                      Padding(
//                        padding: EdgeInsets.fromLTRB(110.0,0.0,0.0,0.0),
//                        child: Icon(
//                          Icons.email,
//                          color: Colors.black,
//                        ),
//                      ),
//                      Padding(
//                        padding: const EdgeInsets.fromLTRB(5.0, 0.0, 0.0,0.0),
//                        child: Text(
//                          'EMAIL',
//                          style: TextStyle(
//                            color: Colors.black,
//                            fontFamily: 'Montserrat',
//                            fontWeight: FontWeight.bold,
//
//                          ),
//                        ),
//                      ),
//                    ],
//                  ),
//                ),
//
//              ),
//            ),
//          ],
//        ),
//      ),
//    );






  createUserInFirestore()async{

      GoogleSignInAccount user=googleSignIn.currentUser;
      DocumentSnapshot doc= await usersref.document(user.id).get();


     print('the doc is $doc');
     // if user dosent exist take them to create acc page

    if(!doc.exists){

      final username =await Navigator.push(context,MaterialPageRoute(builder:(context)=>
          CreateAccount()
      ));

      usersref.document(user.id).setData({
        "id":user.id,
        "username":username,
        "photoUrl":user.photoUrl,
        "email":user.email,
        "displayName":user.displayName,
        "bio":"",
        "timestamp":timestamp



      });
      doc= await usersref.document(user.id).get();
    }
    currentUser=User.fromDocument(doc);
    print(currentUser.username);
    print(isAuth);


  }




  @override
  Widget build(BuildContext context) {
    return  isAuth?buildAuth():buildUnAuth();
  }
}

login()async{
  await googleSignIn.signIn();
}

