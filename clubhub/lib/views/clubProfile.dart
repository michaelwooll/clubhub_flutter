import 'package:clubhub/auth.dart';
import 'package:clubhub/views/eventPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:clubhub/models/Club.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clubhub/widgets/EventWidgets.dart';


final String admin = "k3DR2RS31BQO0BGwnxmePegLNn62";

class ClubProfile extends StatelessWidget {
  final Club club;
  final Function callBack;
  const ClubProfile({Key key, this.club, this.callBack}):super(key:key);
  @override
  Widget build(BuildContext context) {
    bool isVisible = false;
    if(UserInstance().getUser().getID() == admin){
      isVisible = true;
    }
    debugPrint(UserInstance().getUser().getDocID());
    return Scaffold(
      appBar: AppBar(),
     // backgroundColor: Colors.white,
      body: Center(
        child: Column(
         // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClubProfilePicture(clubID: club.getClubID(), callBack: callBack,clubImg: club.getImgURL(),clubName: club.getName(),),
          //  Image.network(club.getImgURL()),
          //  FollowButton(clubID: club.getClubID(), callBack: callBack),
          Visibility(
            visible: isVisible,
            child:  RaisedButton(child:Text("Create event"),
             color: Colors.redAccent,
              shape: RoundedRectangleBorder(
             borderRadius: new BorderRadius.circular(20.0)
           ),
              onPressed: (){
                showDialog(context: context,
                  builder: (BuildContext context){
                    return AlertDialog(
                      content: EventForm(club.getClubID())
                    );
                  }
                );
              },
            ),
            )
           ,
            Padding(
              padding: EdgeInsets.all(10),
              child:  Text(
                club.getName(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold
                ),
                textAlign: TextAlign.center,
            ),
            ),
           
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Text(
                    club.getDescription(),
                    style: TextStyle(
                      fontSize: 15,
                    )
                  )
                )
              )
            )
          ]
        ),
      )
    );
  }
}

class ClubProfilePicture extends StatefulWidget {
  final String clubID;
  final Function callBack;
  final String clubImg;
  final String clubName;
  const ClubProfilePicture({this.clubID, this.callBack, this.clubImg, this.clubName});
  @override
  _ClubProfilePictureState createState() => _ClubProfilePictureState();
}

class _ClubProfilePictureState extends State<ClubProfilePicture> {
  int followers = 0;
  @override
  Widget build(BuildContext context) {
    followCount(widget.clubID).then((count){
      setState(() {
        followers = count;
      });
    });
    return Row(
     // mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(20),
          child:Container(
            width: 125,
            height: 125,
            decoration: new BoxDecoration(
              shape: BoxShape.circle,
              image: new DecorationImage(
                fit: BoxFit.cover,
                image: new NetworkImage(widget.clubImg)
              )
            ),
          )
        ),
        Column(
          children: <Widget>[
            FollowButton(clubID: widget.clubID, callBack: widget.callBack),
            Text(followers.toString() + " Followers"),
          ]
        )
      ],  
    );
  }
}

class FollowButton extends StatefulWidget {
  final String clubID;
  final Function callBack;
  FollowButton({this.clubID, this.callBack});
  @override
  _FollowButtonState createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  bool isFollowed;
  @override
  void initState() {
   
    super.initState();
    doesFollow(widget.clubID).then((value){
      setState(() {
        isFollowed = value;
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    if(isFollowed == null){
      children.add(
        RaisedButton(
          onPressed: (){}
        )
      );
    }
    else if(!isFollowed){
      children.add(
        RaisedButton(
          color: Colors.redAccent,
          shape: RoundedRectangleBorder(
             borderRadius: new BorderRadius.circular(20.0)
           ),
          child: Text("Follow"),
          onPressed: (){
           followClub(widget.clubID).then((value){
             setState(() {
               isFollowed = value;
             });
             widget.callBack();
           });
          }
        )
      );
    }
    else{
      children.add(
        RaisedButton(
          child: Text("Unfollow"),
           color: Colors.redAccent,
          shape: RoundedRectangleBorder(
             borderRadius: new BorderRadius.circular(20.0)
           ),
          onPressed: (){
            unfollowClub(widget.clubID).then((value){
              setState(() {
                isFollowed = value;
              });
              widget.callBack();
            });
          }
        )
      );
    }
    return Container(
      child: children[0]
    );
  }
}


Future<bool> followClub(String clubID) async{
    try{
      String uid = UserInstance().getUser().getID();
      Firestore.instance
      .collection("follows")
      .add({
        "user": uid,
        "club":clubID
      });
    }catch(e){
      debugPrint("Error following club:" + e.toString());
    }
    return doesFollow(clubID);
  }

  Future<bool> unfollowClub(String clubID) async{
    try{
      String uid = UserInstance().getUser().getID();
      QuerySnapshot doc = await Firestore.instance
      .collection("follows")
      .where("user", isEqualTo: uid)
      .where("club", isEqualTo: clubID)
      .getDocuments();
      doc.documents.forEach((d){
        d.reference.delete();
      });
    }catch(e){
      debugPrint("Error following club:" + e.toString());
    }
    return doesFollow(clubID);
  }

  Future<bool> doesFollow(String clubID) async {
    String uid = UserInstance().getUser().getID();
    QuerySnapshot doc = await Firestore.instance
    .collection("follows")
    .where("user", isEqualTo: uid)
    .where("club", isEqualTo: clubID)
    .getDocuments();
    return doc.documents.isNotEmpty;
  }

Future<int> followCount(String clubID) async {
  QuerySnapshot doc = await Firestore.instance
  .collection("follows")
  .where("club", isEqualTo:clubID).
  getDocuments();

  return doc.documents.length;
}
