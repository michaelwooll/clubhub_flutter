import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:enum_to_string/enum_to_string.dart';

/// [Author]: Michael Wooll
/// 
/// [Description]: This file will contain the dart classes that will resemble
/// documents inside Firstore database


/// Enumeration to represent all the [Database types] that extend off the abstract DatabaseObject class
enum DatabaseType{
  Campus,
  Club,
  Event
}

/// [Authentication type] that is associated with a campus' login 
enum Authentication_type{
  GoogleLogin
}

abstract class DatabaseObject{
  String _collection; // collection inside firebase DB
  DatabaseType _type; /// Stores the [type] of database object. (Campus, Club, etc).
  DatabaseObject(this._collection, this._type);

  /// Getter to return [_collection] variable.
  /// [collection] refers to the collection name inside the DB
  String getCollection() => this._collection;
  
  /// Getter to return [_type] variable.
  DatabaseType getType() => this._type;
  
  /// Coverts calls into JSON object to allow for Firebase Storage
  /// This is overrided by every inherited class
  Map<String, dynamic> toJson (); 

  /// Uses the objects overrided [toJson()] function to add a document to the [_collection]
  Future<bool> saveToDatabase() async{
    try{
      Firestore.instance.collection(_collection).add(toJson());
    }catch(e){
      debugPrint("Error in saveToDatabase: " + e);
      return false;
    }
    return true;
  }
}

/// Contains information of a particular school [Campus]
/// Such as the [_name] of the campus as well as the specified [_auth]orization type.
class Campus extends DatabaseObject{
  String _name;
  Authentication_type _auth;

  Campus(String collection, this._name, this._auth):super(collection, DatabaseType.Campus);

  String getName() => _name;

  Authentication_type getAuthType() => _auth;

  
  Map<String, dynamic> toJson () => {
    'name' : _name,
    'auth' : _auth.toString(),
    'type': EnumToString.parse(getType())
  };
}


/// Checks if document exists in Firebase Cloudstore instance. Used to ensure there are no duplicate's in DB.
/// 
/// Returns the documentID, if a document in a [collection] has a [key] property that stores [value]
/// Else returns empty string 
/// 
Future<String> doesDocumentExist(String collection, String key, String value) async {
  final QuerySnapshot result = await Firestore.instance
  .collection(collection)
  .where(key, isEqualTo: value)
  .limit(1)
  .getDocuments();
  if (result.documents.length != 0){
    return result.documents[0].documentID;
  }
  else{
    return "";
  }
}