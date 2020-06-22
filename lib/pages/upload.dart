
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:social/models/user.dart';
import 'package:image/image.dart' as im;
import 'package:uuid/uuid.dart';
import 'home.dart';
class Upload extends StatefulWidget {

  final User currentUser;
  Upload({this.currentUser});
  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> with AutomaticKeepAliveClientMixin<Upload>{
  PickedFile file;
  bool isUploading =false;
  String postId=Uuid().v4();
  TextEditingController location =TextEditingController();
  TextEditingController caption=TextEditingController();
  File img;







  handleTakePhoto()async{
    Navigator.pop(context);

    final ImagePicker picker=ImagePicker();

    final PickedFile file=await picker.getImage(source: ImageSource.camera,
    maxHeight: 675,
    maxWidth: 960);

    setState(() {
      this.file=file;
    });



  }
  handleChooseFromGallery()async{
    Navigator.pop(context);
    final ImagePicker picker=ImagePicker();

    PickedFile file=await picker.getImage(source:ImageSource.gallery,maxHeight: MediaQuery.of(context).size.height-MediaQuery.of(context).size.height/3);
    setState(() {
      this.file=file;
    });
  }

  selectImage(parentcontext){
    return showDialog(
      context:parentcontext,
      builder: (context){
        return SimpleDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(32)),
          ),
          title: Center(
            child: Text('Create Post',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.bold,
              fontSize: 20

            ),
            ),
          ),
          children: <Widget>[
            Divider(color: Colors.white54,),
            SimpleDialogOption(
              child: Text('Take A Photo'),
              onPressed: handleTakePhoto,
            )
            ,
            SimpleDialogOption(
              child: Text('Select From Gallery'),
              onPressed: handleChooseFromGallery,
            ),
            SimpleDialogOption(
              child: Text('Cancel'),
              onPressed: ()=>Navigator.pop(context),
            )
          ],

        );
      }
    );
  }

  Container buildSplashScreen(){
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SvgPicture.asset('assets/images/upload.svg',height: 200,),
            Padding(
              padding: EdgeInsets.only(top: 20),
              child: SizedBox(
                height: 50,
                width: 200,




                child: Material(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.blue,

                  child: InkWell(
                    onTap: (){
                      selectImage(context);

                    },
                    child:  Center(
                      child: Text(
                        'Upload',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,

                        ),
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
  clearimg(){
    setState(() {
      file=null;
      img=null;
    });
  }
  compressImage() async {
    final temp=await  getTemporaryDirectory();
    final path =temp.path;

    im.Image imageFile=im.decodeImage(File(file.path).readAsBytesSync());

    final compressedfile =File('$path/img_$postId.jpg')..writeAsBytesSync(im.encodeJpg(
        imageFile,quality:85));
    setState(() {
      img=compressedfile;
    });



  }

  Future<String > uploadimage(file) async {
     StorageUploadTask uploadtask= storageref.child('post_$postId.jpg')
         .putFile(file);
      StorageTaskSnapshot storagesnap= await uploadtask.onComplete;
      String downloadurl= await storagesnap.ref.getDownloadURL();
      return downloadurl;



  }
  createPostInFirestore({String mediaUrl ,String Caption,String Location }){

    print('im creating a post '+ widget.currentUser.username);
    postRef.document(widget.currentUser.id)
        .collection('userpost')
        .document(postId)
        .setData({
      "postId":postId,
      "ownerId":widget.currentUser.id,
      "username":widget.currentUser.username,
      "mediaUrl":mediaUrl,
      "description":Caption,
      "location":Location,
      "timestamp":timestamp,
      "likes":{}



    });



  }
  handleSubmit()async{
    print('immmmhere');
    setState(() {
      isUploading=true;
    });
    await compressImage();
     String mediaurl= await uploadimage(img);
     createPostInFirestore(
         mediaUrl: mediaurl,
         Caption: caption.text,
         Location: location.text
     );
      caption.clear();
      location.clear();
      setState(() {
        img=null;
        file=null;
        isUploading=false;
        postId=Uuid().v4();
      });

  }

  buildUploadForm(){
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,color: Colors.white,),
          onPressed: clearimg,
        ),
        title: Text('Caption Post'
        ,
        style: TextStyle(
          color: Colors.white,
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.bold
        ),
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: isUploading?null:()=> handleSubmit(),
            child: Container(
              height: 30,
              width: 100,

              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32.0),
                color: Colors.blue
              ),

              child: Center(
                child: Text('Post',style:
                  TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0
                  ),
                ),
              ),
            ),
          )
        ],


      ),
      body:  ListView(
        children: <Widget>[
           isUploading?LinearProgressIndicator(
             valueColor: AlwaysStoppedAnimation<Color>(Colors.black26),
           ):Text(''),
          Padding(
            padding: const EdgeInsets.only(top:0),
            child: Container(
              height: 220,
              width: MediaQuery.of(context).size.width*.8,
              child: Center(
                child: AspectRatio(
                  aspectRatio: 16/9,
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          fit: BoxFit.cover,
                        image:  FileImage(File(file.path)),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top:10.0),

          ),
          ListTile(
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(
                  (widget.currentUser.photoUrl )
              ),

            ),
            title: Container(
              width: 250.0,
              child: TextField(
                controller: caption,
                decoration: InputDecoration(
                  hintText: 'Write a caption.....',
                  border: InputBorder.none
                ),
              ),
            ),


          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.pin_drop,color: Colors.red,size: 35,),
            title: Container(
              width: 250.0,
              child: TextField(
                controller: location,
                decoration: InputDecoration(
                  hintText: 'Where The Photo Is Taken',
                  border: InputBorder.none
                ),
              ),
            ),
          )
          ,
          Container(
            width: 200,
              height: 100,
            alignment: Alignment.center,
            child: RaisedButton.icon(
              label: Text('Use Current Location',
              style: TextStyle(
                color: Colors.white
              )


              ,),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              color: Colors.blue,
              onPressed:()=>print('tapped'),
              icon: Icon(
                Icons.my_location,
                color: Colors.white,
              ),

            ),
          )

        ],
      ),
    );
  }

//  getUserLocation() async{
//   Position position =await Geolocator().getCurrentPosition();
//   List<Placemark>placemarks=await Geolocator().placemarkFromCoordinates(position.latitude, position.longitude);
//
//   Placemark placemark=placemarks[0];
//
//   String formatAddress='${placemark.locality}, ${placemark.country}';
//
//   location.text=formatAddress;
//
//  }
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return file==null?buildSplashScreen():buildUploadForm();
  }
}
