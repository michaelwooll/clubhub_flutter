/// [File]: DatabaseObject.dart
/// [Author]: Michael Wooll
/// 
/// [Description]: This holds the model that represents a Club.


import 'package:clubhub/models/DatabaseObject.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';


class Club extends DatabaseObject{
  String _name;
  String _description;
  bool _exclusive;
  String _campusID;
  // photo
  // schedule
  // userList
  // adminList



  Club(String collection , this._name, this._description, this._exclusive, this._campusID):super(collection, DatabaseType.Club);
  Club.fromDocumentSnapshot(DocumentSnapshot ds):super("club", DatabaseType.Club){
    /* Do stuff */
    _name = ds["name"];
    _description = ds["description"];
    _exclusive = ds ["exclusive"];
    _campusID = ds["campusID"];
  }

  String getName() => _name;

  String getDescription() => _description;

  bool isExclusive() => _exclusive;

  Map<String, dynamic> toJson () => {
    'name': _name,
    'description' : _description,
    'exclusive' : _exclusive,
    'campusID' : _campusID
  };

}