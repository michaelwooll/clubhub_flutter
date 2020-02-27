/// [File]: Club.dart
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
  String _imgURL;
  String _clubID;
  // photo
  // schedule
  // userList
  // adminList



  Club(String collection , this._name, this._description, this._exclusive, this._campusID, this._imgURL):super(collection, DatabaseType.Club);
  Club.fromDocumentSnapshot(DocumentSnapshot ds):super("club", DatabaseType.Club){
    _name = ds["name"];
    _description = ds["description"];
    _exclusive = ds ["exclusive"];
    _campusID = ds["campusID"];
    _imgURL = ds["img_url"];
    _clubID = ds.documentID;
  }

  String getName() => _name;

  String getDescription() => _description;

  String getShortDescription(){
    if(_description.length > 100){
      String ret = _description.substring(0,99);
      ret += "...";
      return ret;
    }
    else{
      return _description;
    }
  }

  String getImgURL() => _imgURL;

  bool isExclusive() => _exclusive;

  String getClubID() => _clubID;

  Map<String, dynamic> toJson () => {
    'name': _name,
    'description' : _description,
    'exclusive' : _exclusive,
    'campusID' : _campusID
  };
}