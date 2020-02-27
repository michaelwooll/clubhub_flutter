/// [File]: User.dart
/// [Author]: Michael Wooll
/// 
/// [Description]: This holds the model that represents a User


import 'package:clubhub/models/DatabaseObject.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Model to represent a [User]
class User extends DatabaseObject{
  String _name;
  String _email;
  DateTime _created;
  String _campusID;
  String _imgURL; // Default to null
  String _id;

  User(String collection, this._name, this._email, this._created, this._campusID, this._id):super(collection, DatabaseType.User);
  User.fromDocumentSnapshot(DocumentSnapshot ds):super("user", DatabaseType.User){
    _name = ds["name"];
    _email = ds["email"];
    _created = ds["created"].toDate();
    _campusID = ds["campusID"];
    _imgURL = ds["imgURL"];
    _id = ds.documentID;
  }


  String getFullName() => _name;
  String getEmail() => _email;
  DateTime getCreated() => _created;
  String getCampusID() => _campusID;
  String getImgURL() => _imgURL;
  String getID() => _id;



  Map<String, dynamic> toJson () => {
    'name': _name,
    'email' : _email,
    'created' : _created,
    'campusID': _campusID,
    'imgURL': _imgURL
  };

}