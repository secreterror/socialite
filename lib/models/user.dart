import 'package:cloud_firestore/cloud_firestore.dart';

class User{

  String bio;
  String displayName;
  String email;
  String id;
  String photoUrl;
  String username;

  User({
    this.bio,
    this.displayName,
    this.email,
    this.id,
    this.photoUrl,
    this.username

});

  factory User.fromDocument(DocumentSnapshot  doc ){
    return User(
      id: doc['id'],
      email: doc['email'],
      username: doc['username'],
      bio:doc['bio'],
      displayName: doc['displayName'],
      photoUrl: doc['photoUrl']

    );
  }


}