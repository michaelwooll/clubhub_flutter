import 'package:clubhub/auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:clubhub/models/Club.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clubhub/widgets/EventWidgets.dart';



class ClubProfile extends StatelessWidget {
  final Club club;
  final Function callBack;
  const ClubProfile({Key key, this.club, this.callBack}):super(key:key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(club.getImgURL()),
            FollowButton(clubID: club.getClubID(), callBack: callBack),
            RaisedButton(child:Text("Create event:"),
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
            Text(club.getName()),
            Text(club.getDescription())
          ]
        ),
      )
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
    // TODO: implement initState
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

