import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

class AuthServices{

  final GoogleSignIn _googleSignIn=GoogleSignIn();
  final FirebaseAuth _auth=FirebaseAuth.instance;
  final Firestore _db=Firestore.instance;

  Stream<FirebaseUser> user;
  Stream<Map<String,dynamic>>profile;

  PublishSubject loading= PublishSubject();

  AuthServices(){
//    user =Stream (_auth.onAuthStateChanged);
  }

  Future<FirebaseUser> googleSignIn() async{

  }

  void updateUserData(FirebaseUser user) async{

  }

//  void sign


}

final AuthServices authServices=AuthServices();
