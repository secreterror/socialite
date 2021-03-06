
import 'package:flutter/material.dart';
import 'package:social/pages/post_screen.dart';
import 'package:social/widget/custom_img.dart';
import 'package:social/widget/post.dart';
class PostTile extends StatelessWidget {

  final Post post;
  PostTile({this.post});

  showpost(context){
    Navigator.push(context, MaterialPageRoute(builder: (context)=>
        PostScreen(postId:post.postId,userId:post.ownerId )
    ));

  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ()=>showpost(context),
      child: cachedNetworkImage(post.mediaUrl),




    );
  }
}
