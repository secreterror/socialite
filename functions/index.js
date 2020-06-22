const functions = require('firebase-functions');
const admin=require('firebase-admin');
admin.initializeApp();

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });

exports.onCreateFollower= functions.firestore
    .document("/followers/{userId}/userFollowers/{followerId}")
    .onCreate(async (snapshot,context)=>{

    console.log('follower created ',snapshot.data());
    console.log('herer');

     const userId=context.params.userId;
     const followerId=context.params.followerId;



    // get followed users post
        const followedUserPostRef=admin
        .firestore()
        .collection('posts')
        .doc(userId)
        .collection('userpost');
    // get following users timeline

        const timelinePostRef=admin
        .firestore()
        .collection('timeline')
        .doc(followerId)
        .collection('timelinePosts');

     const querysnapshot=await followedUserPostRef.get();

     console.log(querysnapshot);


     console.log('hereeeee');
     querysnapshot.forEach(doc =>{

     console.log('entered in loop');
     if(doc.exists){
     console.log('yha bhi aa gya bhai');

        const postId=doc.id;
        const postData=doc.data();
        timelinePostRef.doc(postId).set(postData);
     }
     });

 });

 exports.onDeleteFollower =functions.firestore
 .document("/followers/{userId}/userFollowers/{followerId}")
 .onDelete(async (snapshot,context)=>{

      const userId=context.params.userId;
      const followerId=context.params.followerId;

      console.log('entered');

      const timelinePostRef = admin
      .firestore()
      .collection('timeline')
      .doc(followerId)
      .collection('timelinePosts')
      .where("ownerId","==",userId);

      console.log('im here tooo');

     const querysnapshot =await timelinePostRef.get();

     console.log(querysnapshot);
     console.log('below');

     querysnapshot.forEach((doc)=>{

     console.log('im here');

     if(doc.exists){
        doc.ref.delete();
     }
     });

 });
// when a post is created add to timeline of each post owner
 exports.onCreatePost=functions.firestore.document('/posts/{userId}/userpost/{postId}')
 .onCreate(async (snapshot,context)=>{
        const postCreated=snapshot.data();

        const userId=context.params.userId;
        const postId=context.params.postId

        // get all the follower of user
        const userFollowersRef= admin.firestore()
        .collection('followers')
        .doc(userId)
        .collection('userFollowers');


       const querysnapshot= await userFollowersRef.get();

       // add new post to each follower timeline

       querysnapshot.forEach(doc=>{

       const followerId=doc.id;

       admin.firestore()
       .collection('timeline')
       .doc(followerId)
       .collection('timelinePosts')
       .doc(postId)
       .set(postCreated);


       });
 });

 exports.onUpdatePost=functions.firestore
 .document('/posts/{userId}/userpost/{postId}')
 .onUpdate(async (change,context)=>{

            const postUpdated= change.after.data();

            const userId=context.params.userId;
            const postId=context.params.postId

            // get all the follower of user
            const userFollowersRef= admin.firestore()
            .collection('followers')
            .doc(userId)
            .collection('userFollowers');

            const querysnapshot= await userFollowersRef.get();

            querysnapshot.forEach(doc=>{

           const followerId=doc.id;

           admin.firestore()
           .collection('timeline')
           .doc(followerId)
           .collection('timelinePosts')
           .doc(postId)
           .get().then(doc=>{

           if(doc.exists){
           doc.ref.update(postUpdated);
           }
           })


           });


 })

 exports.onDeletePost=functions.firestore
.document('/posts/{userId}/userpost/{postId}')
.onDelete(async (snapshot,context)=>{
        const userId=context.params.userId;
        const postId=context.params.postId

         const userFollowersRef= admin.firestore()
        .collection('followers')
        .doc(userId)
        .collection('userFollowers');



        const querysnapshot= await userFollowersRef.get();

        querysnapshot.forEach(doc=>{

           const followerId=doc.id;

           admin.firestore()
           .collection('timeline')
           .doc(followerId)
           .collection('timelinePosts')
           .doc(postId)
           .get().then(doc=>{

           if(doc.exists){
           doc.ref.delete();
           }
           })


        });

})

exports.onCreateActivityFeedItem=functions.firestore
        .document('/feed/{userId}/feedItems/{activityFeedItem}')
        .onCreate(async (snapshot,context)=>{
        console.log('activity feed',snapshot.data());

        // get user connected to feed
        const userId=context.params.userId;
        const userRef=admin.firestore()
        .doc(`users/${userId}`);

        const doc=await userRef.get();

        //once we have user .check if they have a notification token

        const androidNotificationToken=doc.data().androidNotificationToken;
        const createdActivityFeedItem=snapshot.data();
        if(androidNotificationToken){
        //send notification
        sendNotification(androidNotificationToken,createdActivityFeedItem);
        }else{

        console.log('no token for user ,cant send the notification ')
        }


        function sendNotification(androidNotificationToken,activityFeedItem){
        let body;

        switch(activityFeedItem.type){

        case "comment":
            body=`${activityFeedItem.username} replied: ${activityFeedItem.comment}`;
            break;
        case "like":
             body=`${activityFeedItem.username} liked your post`;
             break;
        case "follow":
             body=`${activityFeedItem.username} started following you`;
             break;
        default:
            break;


        }


        const message={
        notification:{body},
        token:androidNotificationToken,
        data:{recipient:userId}
        };


        admin.
        messaging()
        .send(message)
        .then(response=>{
          // response is a message id string
        console.log('successfully sent message',response);
        })
        .catch(err=>{

        console.log('error sending message ',err);
        })


        }



        });

