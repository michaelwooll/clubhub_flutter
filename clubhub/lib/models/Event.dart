/// [File]: Event.dart
/// [Author]: Michael Wooll
/// 
/// [Description]: This holds the model that represents an Event.


import 'package:clubhub/models/DatabaseObject.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


/// Contains information about an [Event] that is associated with a club
class Event extends DatabaseObject{
  String _title;
  String _description;
  String _clubID; // ID of Club inside database
  DateTime _postTime; // Date and time when posted
  // photo

  Event(String collection , this._title, this._description, this._clubID, this._postTime):super(collection, DatabaseType.Event);
  Event.fromDocumentSnapshot(DocumentSnapshot ds):super("event", DatabaseType.Event){
    /* Do stuff */
    _title = ds["title"];
    _description = ds["description"];
    _clubID= ds ["clubID"];
    _postTime = DateTime.parse(ds["postTime"]);
  }

  String getTitle() => _title;
  String getDescription() => _description;
  DateTime getDateTime() => _postTime;
  String getClubID() => _clubID;

  Map<String, dynamic> toJson () => {
    'title': _title,
    'description' : _description,
    'clubID' : _clubID,
    'postTime' : _postTime.toString()
  };

}