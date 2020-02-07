/// [File]: DatabaseObject.dart
/// [Author]: Michael Wooll
/// 
/// [Description]: This holds the abrstract class that all database models will extend from.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:enum_to_string/enum_to_string.dart';

/// Enumeration to represent all the [Database types] that extend off the abstract DatabaseObject class
enum DatabaseType{
  Campus,
  Club,
  Event
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
      Map<String,dynamic> json = toJson(); 
      json['type'] = EnumToString.parse(getType()); // Add the objects type to the json
      Firestore.instance.collection(_collection).add(json);
    }catch(e){
      debugPrint("Error in saveToDatabase: " + e);
      return false;
    }
    return true;
  }
}
