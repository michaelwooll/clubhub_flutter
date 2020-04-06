
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clubhub/auth.dart';
import 'package:clubhub/models/DatabaseHelperFunctions.dart';
import 'package:clubhub/models/User.dart';

/// [File]: Comment.dart
/// [Author]: Michael Wooll
/// 
/// [Description]: This holds the model that represents a Comment.


import 'package:clubhub/models/DatabaseObject.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';


class Comment extends DatabaseObject{
  String _userID;
  String _content;
  DateTime _postTime;
  int _likes;

  Comment(String collection, this._content):super(collection, DatabaseType.Comment){
    _postTime = DateTime.now();
    _likes = 0;
    _userID = UserInstance().getUser().getID();
  }

  Comment.fromDocumentSnapshot(DocumentSnapshot ds):super("Comment", DatabaseType.Comment){
    _userID = ds["userID"];
    _content= ds["content"];
    _postTime = ds["postTime"].toDate(); 
    _likes = ds["likes"];
    setDocID(ds.documentID);
  
  }

  void like(){
    _likes++;
  }

  String getContent() => _content;
  String getUserID() => _userID;
  DateTime getPostTime() => _postTime;
  int getLikes() => _likes;

    String getDateString(){
    return new DateFormat().add_yMMMd().format(_postTime);
  }

  String getTimeString(){
    return new DateFormat().add_jm().format(_postTime);
  }


  Future<User> getUser() async {
    DocumentSnapshot ds = await Firestore.instance.collection("users")
    .document(_userID)
    .snapshots()
    .first;
    return createDatabaseObjectFromReference(DatabaseType.User, ds);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "userID" : _userID,
      "content" : _content,
      "postTime": _postTime,
      "likes": _likes
    };
  }
}



Future<bool> createComment(String eventID, Comment c) async{
      try{
      String id = await c.saveToDatabase();
      Firestore.instance
      .collection("XREF_EVENT_COMMENT")
      .add({
        "event": eventID,
        "comment": id
      });
    }catch(e){
      debugPrint("Error adding comment" + e.toString());
      return false;
    }
    return true;
}