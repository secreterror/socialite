import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:social/models/user.dart';
import 'package:social/pages/activityfeed.dart';
import 'package:social/pages/home.dart';
import 'package:social/pages/timeline.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';


class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> with AutomaticKeepAliveClientMixin<Search> {
  Future<QuerySnapshot> searchres;
  TextEditingController searchcontroller=TextEditingController ();

  String find;


  bool isLoading=false;

  List<UserResult> initUser=[];


  @override
  void initState(){
    super.initState();

    getAllTheUSer();
  }


  getAllTheUSer()async{
    setState(() {
      isLoading=true;
    });

    QuerySnapshot snapshot=await usersref.getDocuments();
    setState(() {
      isLoading=false;
      snapshot.documents.forEach((doc) {

        User u=User.fromDocument(doc);
        initUser.add(UserResult(u));
      });
    });

  }





  handleSearch(String q){
    find=q;
    Future<QuerySnapshot> users=usersref
    .where('displayName',isGreaterThanOrEqualTo: q)
        .getDocuments();
    setState(() {
      searchres=users;
    });
  }
  clearsearch(){
    searchcontroller.clear();
    setState(() {
      searchres=null;
    });
  }



  AppBar buildsearch(){
    return AppBar(



      title:  Container(
        decoration: BoxDecoration(
          color: Colors.black
        ),
        child: TextFormField(

          cursorColor: Colors.blueGrey,
          controller: searchcontroller,
           decoration: InputDecoration(

             hintText: 'Search..',
             filled: true,
             focusColor: Colors.blueGrey,
             focusedBorder:OutlineInputBorder(
               borderRadius: BorderRadius.all(Radius.circular(5)),
               borderSide: BorderSide(color: Colors.blueGrey)
             ),
             prefixIcon: Icon(
               Icons.account_circle,
               size: 28.0,
               color: Colors.blueGrey,
             ),
             suffixIcon: IconButton(
               icon: Icon(Icons.clear,
               color: Colors.blueGrey,),
               onPressed:clearsearch,

             )
           ),
          onFieldSubmitted: handleSearch,
        ),
      ),

    );

  }
//  Container buildnocontent(){
//    final Orientation mq=MediaQuery.of(context).orientation;
//    return Container(
//      child: Center(
//        child: Column(
//
//          children: <Widget>[
//
//            Padding(
//              padding: const EdgeInsets.only(top:10),
//              child: SvgPicture.asset('assets/images/newsearch.svg',height:mq==Orientation.portrait ?250.0:200.0),
//            ),
//
//          ],
//        ),
//      ),
//
//    );
//
//  }

    buildnocontent(){

    return isLoading?Scaffold(
      backgroundColor: Colors.black,
      body: Center(child: SpinKitChasingDots(color: Colors.white,),),):
        ListView(
          children: initUser,
        );
    }


  buildsearchres(){
    return FutureBuilder(
      future: searchres,
      builder: (context,snapshot){
        if(!snapshot.hasData){
          return Scaffold(
            backgroundColor: Colors.black,

            body: Center(
              child: SpinKitChasingDots(color: Colors.white,)
            ),

          );
        }

        List<UserResult > searchresults=[];
        snapshot.data.documents.forEach((doc){
          User  user=User.fromDocument(doc);
          UserResult searchResult =UserResult(user);
          searchresults.add(searchResult);
          print(user.username);

        });
        if(searchresults.length==0){

          return Scaffold(
            backgroundColor: Colors.black,
            body: Container(child:
              Center(
                child:Text('No Results With Name $find')

              ),
            ),
          );


        }
        return ListView(
          children: searchresults,
        );




      }

    );
  }

  bool get wantKeepAlive=>true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: buildsearch(),
      body:searchres==null?buildnocontent():buildsearchres(),
    );
  }
}
class UserResult extends StatelessWidget  {

  final User user;
   UserResult(this.user);
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black
      ),
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: ()=> showProfile(context,profileId: user.id),
            child: ListTile(
              leading:  CircleAvatar(
                backgroundColor: Colors.grey,
                backgroundImage: CachedNetworkImageProvider(user.photoUrl),

              ),
              title: Text(user.displayName,style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold
              ),
              ),
              subtitle: Text(user.username,style: TextStyle(
                color: Colors.grey
              ),
              ),


            ),
          ),
          Divider( height: 2.0,color: Colors.white54,)
        ],
      ),
    );
  }
}
