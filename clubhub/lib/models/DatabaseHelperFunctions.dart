/// [File]: DatabaseHelperFunctions.dart
/// [Author]: Michael Wooll
/// 
/// [Description]: This holds functions that interact with the Firebase database, but are not related to a specific model.

/*************** TODO *******************
 * Add all model types to createDatabaseObjectFromReference function
 * Create getter functions for Club model
 */

import 'package:clubhub/models/DatabaseObject.dart';
import 'package:clubhub/models/Campus.dart';
import 'package:clubhub/models/Club.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

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

/// Creates a Database object of [desiredType] given a DocumentSnapshot, [ds].
/// This is used to translate from database documents to dart objects.
/// 
/// Returns a [DatabaseObject] unless the [desiredType] does not match the type of the [ds].
/// In the case that they do not match, return null.
/// 
DatabaseObject createDatabaseObjectFromReference(DatabaseType desiredType, DocumentSnapshot ds){
  if(ds["type"] != EnumToString.parse(desiredType)){
    debugPrint("Desired type is != to DocumentSnapshot type. Cannot create database object. Returning null");
    return null;
  }
  switch(desiredType){
    case DatabaseType.Campus: {
      return Campus.fromDocumentSnapshot(ds);
    }
    case DatabaseType.Club: {
      return Club.fromDocumentSnapshot(ds); 
    }
    default: {
      debugPrint("Desired type not found. Failed to create a database object from reference. Returning null");
      return null;
    }
  }
}