

import 'package:clubhub/models/Club.dart';
/// [File]: Event.dart
/// [Author]: Michael Wooll
/// 
/// [Description]: This holds the model that represents an Event.


import 'package:clubhub/models/DatabaseObject.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:clubhub/auth.dart';


/// Contains information about an [Event] that is associated with a club
class Event extends DatabaseObject{
  String _title;
  String _description;
  String _clubID; // ID of Club inside database
  DateTime _date;
  DateTime _postTime; // Date and time when posted
  // photo

  Event(String collection , this._title, this._description, this._clubID, this._date):super(collection, DatabaseType.Event){
    _postTime = DateTime.now();
  }
  Event.fromDocumentSnapshot(DocumentSnapshot ds):super("event", DatabaseType.Event){
    /* Do stuff */
    _title = ds["title"];
    _description = ds["description"];
    _clubID= ds ["clubID"];
    _postTime = DateTime.parse(ds["postTime"]);
    _date = ds["date"].toDate();
    setDocID(ds.documentID);
  }

  String getTitle() => _title;
  String getDescription() => _description;
  DateTime getDateTime() => _date;
  String getClubID() => _clubID;

  String getDateString(){
    return new DateFormat().add_yMMMd().format(_date);
  }

  String getTimeString(){
    return new DateFormat().add_jm().format(_date);
  }


  Map<String, dynamic> toJson () => {
    'title': _title,
    'description' : _description,
    'clubID' : _clubID,
    'postTime' : _postTime.toString(),
    'date': _date
  };
}

Future<bool> followEvent(String userID, Event event) async{
      try{
      String id = event.getDocID();
      Firestore.instance
      .collection("XREF_USER_EVENT")
      .add({
        "user": userID,
        "event": id
      });
    }catch(e){
      debugPrint("Error follwing event" + e.toString());
      return false;
    }
    return true;
}

Future<bool> userFollowsEvent(Event event) async {
  try{
    String uid = UserInstance().getUser().getID();
    QuerySnapshot doc = await Firestore.instance
    .collection("XREF_USER_EVENT")
    .where("user", isEqualTo: uid)
    .where("event", isEqualTo: event.getDocID())
    .getDocuments();
    return doc.documents.isNotEmpty;
  }
  catch(e){
      debugPrint("Error checking if user follows event" + e.toString());
      return false;
  }
}

  Future<bool> unfollowEvent(String userID, Event event) async{
    try{
      QuerySnapshot doc = await Firestore.instance
      .collection("XREF_USER_EVENT")
      .where("user", isEqualTo: userID)
      .where("event", isEqualTo: event.getDocID())
      .getDocuments();
      doc.documents.forEach((d){
        d.reference.delete();
      });
    }catch(e){
      debugPrint("Error unfollowing event:" + e.toString());
    }
    return userFollowsEvent(event);
  }

 Future<Map<DateTime, List>> getUsersEvents() async {
   Map<DateTime,List> results = {};
   try{
     QuerySnapshot doc = await Firestore.instance
     .collection("XREF_USER_EVENT")
     .where("user", isEqualTo:UserInstance().getUser().getID())
     .getDocuments();
     for(var doc in doc.documents){
       // get event by id
      DocumentSnapshot eventReference = await Firestore.instance
      .collection("event")
       .document(doc.data["event"])
       .snapshots()
       .first;
       debugPrint(doc.data["event"]);
        Event e = new Event.fromDocumentSnapshot(eventReference);
        DateTime date = DateTime(e.getDateTime().year,e.getDateTime().month,e.getDateTime().day);
        if(results[date] == null){
          results[date] = [];
        }
        DocumentSnapshot clubReference = await Firestore.instance
        .collection("club")
        .document(e.getClubID())
        .snapshots()
        .first;
        Club club = Club.fromDocumentSnapshot(clubReference);
        debugPrint("Adding: " + e.getTitle() + "on: " + date.toString());
        results[date].add({"event" : e, "club" : club});
       // Add to map
     }
   }
   catch(e){
      debugPrint("Error following club:" + e.toString());
   }
   return results;
 }

