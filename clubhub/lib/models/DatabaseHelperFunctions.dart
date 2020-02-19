/// [File]: DatabaseHelperFunctions.dart
/// [Author]: Michael Wooll
/// 
/// [Description]: This holds functions that interact with the Firebase database, but are not related to a specific model.


/*************** TODO *******************
 * Create getter functions for Club model
 */

import 'package:clubhub/models/DatabaseObject.dart';
import 'package:clubhub/models/Campus.dart';
import 'package:clubhub/models/Club.dart';
import 'package:clubhub/models/Event.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import 'dart:math';


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
    case DatabaseType.Event: {
      return Event.fromDocumentSnapshot(ds);
    }
    default: {
      debugPrint("Desired type not found. Failed to create a database object from reference. Returning null");
      return null;
    }
  }
}

Future<List<Campus>> retrieveAllCampus() async{
  List<Campus> campusList = [];
  final QuerySnapshot result = await Firestore.instance
  .collection("campus")
  .getDocuments();
  
  for(var ds in result.documents){
    campusList.add(createDatabaseObjectFromReference(DatabaseType.Campus,ds));
  }
  return campusList;
}


/*  TODO FIX! 
* Add description!
* Currently uses a tempID to query
* Add a global Campus class when user is signed in
*/
Future<List<Club>> retrieveAllClubs() async{
  List<Club> clubList = [];
  String tempID = "MzMsjEsaAIBTeWbcCsio";
  final QuerySnapshot result = await Firestore.instance
  .collection("club")
  .where("campusID", isEqualTo: tempID)
  .getDocuments();
  
  for(var ds in result.documents){
    clubList.add(createDatabaseObjectFromReference(DatabaseType.Club,ds));
  }
  return clubList;
}


/* Event Helper functions */
Future<List<Event>> retrieveEventsForClub(String clubID) async {
  List<Event> eventList = [];

  final QuerySnapshot result = await Firestore.instance
  .collection("event")
  .where("clubID", isEqualTo:clubID)
  .getDocuments();

  for(var ds in result.documents){
    eventList.add(createDatabaseObjectFromReference(DatabaseType.Event, ds));
  }

  return eventList;
}

Future<List<Event>> retrieveAllEvents() async{
  createFakeEvent();
  List<String> cludID = [];
  List<Event> events = [];
  final QuerySnapshot result = await Firestore.instance
  .collection("club")
  .getDocuments();

  for(var ds in result.documents){
    cludID.add(ds.documentID);
  }

  for(var id in cludID){
    List<Event> e = await retrieveEventsForClub(id);
    for(var item in e){
      events.add(item);
    }
  }
  return events;
}

 Future<void> createFakeEvent() async{
    String id = await doesDocumentExist("club", "name", "Fake club1");
    Random random = new Random();
    String eName = "Event" + random.nextInt(500).toString();
    Event e = new Event("event",eName,"This is a description about the club event! Wow sounds like fun!",id,DateTime.now());
    e.saveToDatabase();
    debugPrint("here");
    List<Event> x = await retrieveEventsForClub(id);
    for (var event in x){
      debugPrint(event.getTitle());
    }
  }

/*
  void _addChicoDB() async{
    // Check if Chico already exists
    final docDoesExist = await doesDocumentExist("campus", "name", "CSU Chico");
    if(docDoesExist != ""){
      debugPrint("CSU Chico already exists, the ID is: " + docDoesExist);
    }
    else{
      var x = new Campus("campus", "CSU Chico", Authentication_type.GoogleLogin);
      bool success = await x.saveToDatabase();
      if(success){
        debugPrint("document created");
      }
    }
  }

    void _addFakeClubDB(String name, String desc) async{
    // grab chicos ID
    String schoolID = await doesDocumentExist("campus", "name", "CSU Chico");
    // Check if Club already exists
    final docDoesExist = await doesDocumentExist("club", "name", name);
    if(docDoesExist != ""){
      debugPrint("Fake club already exists, the ID is: " + docDoesExist);
    }
    else{
      var x = new Club("club", name, desc, false, schoolID);
      bool success = await x.saveToDatabase();
      if(success){
        debugPrint("document created");
      }
    }
    debugPrint("Heres a list of the clubs");
    // Check all documents
    List<Club> clubs = await retrieveAllClubs();
    for(var item in clubs){
      debugPrint(item.toJson().toString());
    }
    debugPrint("End list!");

  }

  void _testCreateObject() async{
    final QuerySnapshot result = await Firestore.instance
    .collection("campus")
    .where("name", isEqualTo: "CSU Chico")
    .limit(1)
    .getDocuments();
    DocumentSnapshot x = result.documents[0];

    Campus y = createDatabaseObjectFromReference(DatabaseType.Campus,x);
    if(y == null){
      debugPrint("null");
    }else{
      debugPrint(y.toJson().toString());
    }

  }
  void _testClubCreate() async{
    final QuerySnapshot result = await Firestore.instance
    .collection("club")
    .where("name", isEqualTo: "Fake club")
    .limit(1)
    .getDocuments();
    DocumentSnapshot x = result.documents[0];

    Club y = createDatabaseObjectFromReference(DatabaseType.Club,x);
    if(y == null){
      debugPrint("null");
    }else{
      debugPrint(y.toJson().toString());
    }

  }
  */