/// [File]: DatabaseObject.dart
/// [Author]: Michael Wooll
/// 
/// [Description]: This holds the model that represents a Campus.
 
import 'package:clubhub/models/DatabaseObject.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';


/// [Authentication type] that is associated with a campus' login 
enum Authentication_type{
  GoogleLogin
}
/// Contains information of a particular school [Campus]
/// Such as the [_name] of the campus as well as the specified [_auth]orization type.
class Campus extends DatabaseObject{
  String _name;
  Authentication_type _auth;
  String _id;

  Campus(String collection, this._name, this._auth,this._id):super(collection, DatabaseType.Campus);
  Campus.fromDocumentSnapshot(DocumentSnapshot ds):super("campus", DatabaseType.Campus){
    _name = ds["name"];
    _auth = EnumToString.fromString(Authentication_type.values, ds["auth"]);
    _id = ds.documentID;
  }

  String getName() => _name;

  Authentication_type getAuthType() => _auth;

  String getID() => _id;


  Map<String, dynamic> toJson () => {
    'name' : _name,
    'auth' : EnumToString.parse(_auth)
  };
}
