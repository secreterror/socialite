import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social/models/user.dart';
import 'package:social/pages/home.dart';
import 'package:social/pages/timeline.dart';
class EditProfile extends StatefulWidget {

  final currentUserId;
  EditProfile({this.currentUserId});
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final scaffoldkey=GlobalKey<ScaffoldState>();
  User user;
  TextEditingController displayName=TextEditingController();
  TextEditingController bio=TextEditingController();
  bool isLoading=false;

  @override
  void initState() {

    super.initState();
    getUser();
  }
  getUser() async{
    setState(() {
      isLoading=true;
    });


   DocumentSnapshot doc= await usersref.document(widget.currentUserId).get();
   user= User.fromDocument(doc);
   displayName.text=user.displayName;
   bio.text=user.bio;
   setState(() {
     isLoading=false;
   });
  }
  Column buildDisplayName(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: Text('DisplayName',
          style: TextStyle(
            color: Colors.grey
          ),
          ),


        )
        ,
        TextField(
          controller: displayName,
          decoration: InputDecoration(
            hintText: 'update',
            errorText: isOkDisplayName?null:"display Name too short"

          ),
        )
      ],
    );


  }
  Column buildBio(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: Text('Bio',
            style: TextStyle(
                color: Colors.grey
            ),
          ),


        )
        ,
        TextField(
          controller: bio,
          decoration: InputDecoration(
            hintText: 'update',
              errorText: isOkBio?null:"bio too long "

          ),
        )
      ],
    );

  }
  bool isOkBio=true;
  bool isOkDisplayName=true;
  updateTheprofile(){

    setState(() {
      displayName.text.trim().length<=5||displayName.text.isEmpty?
      isOkDisplayName=false:isOkDisplayName=true;
      bio.text.trim().length>100?isOkBio=false:isOkBio=true;
    });
    if(isOkBio&&isOkDisplayName){
      usersref.document(widget.currentUserId).updateData({
        "displayName":displayName.text,
        "bio":bio.text,

      });
     SnackBar snackbar=SnackBar(content: Text('profile updated'),);
     scaffoldkey.currentState.showSnackBar(snackbar);
    }

  }
  logout()async{
    await googleSignIn.signOut();
//    Navigator.push(context,MaterialPageRoute(builder: (context)=>
//    Home()));
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder:(context)=>Home() ), (Route<dynamic> route) => false);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldkey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Edit Profile',
        style: TextStyle(
            color: Colors.black,

        ),
        ),
        actions: <Widget>[

          IconButton(
            onPressed: ()=>Navigator.pop(context),
            icon: Icon(Icons.done),
            iconSize: 30.0,
            color: Colors.green,

          )
        ],

      ),
      body: isLoading?CircularProgressIndicator():ListView(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top:16,bottom: 8.0),
                  child: CircleAvatar(
                    radius: 50.0,
                    backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                  ),

                ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: <Widget>[
                      buildDisplayName(),
                      buildBio()
                    ],
                  ),
                ),
                RaisedButton(
                  onPressed: updateTheprofile,
                  child: Text('Update',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor ,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0
                  ),),


                ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: FlatButton.icon(
                    onPressed: logout,
                    icon: Icon(Icons.cancel,
                    color: Colors.red,),
                    label: Text('Logout',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 20.0
                    ),),
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
