/// [File]: Event.dart
/// [Author]: Michael Wooll
/// 
/// [Description]: This holds the model that represents an Event.


import 'package:clubhub/models/DatabaseObject.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';


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
  DateTime getDateTime() => _postTime;
  String getClubID() => _clubID;

  String getDateString(){
    return new DateFormat().add_yMMMd().format(_postTime);
  }

  String getTimeString(){
    return new DateFormat().add_jm().format(_postTime);
  }


  Map<String, dynamic> toJson () => {
    'title': _title,
    'description' : _description,
    'clubID' : _clubID,
    'postTime' : _postTime.toString(),
    'date': _date
  };

}