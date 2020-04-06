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
  Event,
  User,
  XREF,
  Comment
}

abstract class DatabaseObject{
  String _collection; // collection inside firebase DB
  DatabaseType _type; /// Stores the [type] of database object. (Campus, Club, etc).
  String _documentID;
  DatabaseObject(this._collection, this._type);

  /// Getter to return [_collection] variable.
  /// [collection] refers to the collection name inside the DB
  String getCollection() => this._collection;
  
  /// Getter to return [_type] variable.
  DatabaseType getType() => this._type;
  

  /// Coverts calls into JSON object to allow for Firebase Storage
  /// This is overrided by every inherited class
  Map<String, dynamic> toJson (); 

  /// Helper function to write to cross reference table during saveToDatabase() calls
  /// this function is overwritten in models with many to many relationships
  Future<void> updateCrossReferenceTable(String documentID) async{
    return;
  }

  /// Uses the objects overrided [toJson()] function to add a document to the [_collection]
  /// Saved with [docID] if it is specified (this can be used to update an existing doc), else Firebase creates a unique ID for the document.
  Future<String> saveToDatabase({String docID = ""}) async{
    if(docID == ""){
      DocumentReference doc;
      try{
        Map<String,dynamic> json = toJson(); 
        json['type'] = EnumToString.parse(getType()); // Add the objects type to the json
        doc = await Firestore.instance.collection(_collection).add(json);
        _documentID = doc.documentID;
        updateCrossReferenceTable(doc.documentID);
        }
        catch(e){
          debugPrint("Error in saveToDatabase: " + e);
          return null;
        }
      return doc.documentID;
    } // end if
    else{
      try{
        Map<String,dynamic> json = toJson(); 
        json['type'] = EnumToString.parse(getType()); // Add the objects type to the json
        await Firestore.instance.collection(_collection).document(docID).setData(json);
        updateCrossReferenceTable(docID);
      }
      catch(e){
        debugPrint("Error in saveToDatabase: " + e);
        return "";
      }
      return docID;
    } // end else
  }

  String getDocID() => _documentID;
  void setDocID(String id){
    _documentID = id;
  }
}