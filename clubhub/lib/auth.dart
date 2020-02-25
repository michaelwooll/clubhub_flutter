/// [File]: auth.dart
/// [Author]: Michael Wooll
/// 
/// [Description]:This file contains all the methods for user authentication
/// 
/// 
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clubhub/models/User.dart';


final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();
/// Used to sign in with google for a specific campus with [campusID]
/// https://stackoverflow.com/questions/59790087/flutter-firebase-google-sign-in-not-working-stops-after-account-selection was used as reference
Future<dynamic> signInWithGoogle(String campusID) async {
  try{
      final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final AuthResult authResult = await _auth.signInWithCredential(credential);
      final FirebaseUser user = authResult.user;

      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);

      final FirebaseUser currentUser = await _auth.currentUser();
      assert(user.uid == currentUser.uid);

      User u = await authUserWithDB(user,campusID);
      return u;
  }
  catch(e){
    debugPrint("Error signing in: " + e.toString());
    return false;
  }
}

/// Called after sign in to authenticates a user, [u], logging in to a specific campus with [campusID]
Future<User> authUserWithDB(FirebaseUser u, String campusID) async{
  // See if user exists
  final DocumentSnapshot result = await Firestore.instance.collection("users").document(u.uid).get();
  if(result.exists){
    // Check if logging in to correct school
    if(result.data["campusID"] != campusID){
      throw "Incorrect user for campus";
    }
    return User.fromDocumentSnapshot(result);
  }else{ // User does not exist, create the user.
    User newUser = new User("users", u.displayName,u.email, DateTime.now(), campusID);
    newUser.saveToDatabase(docID: u.uid);
    return newUser;
  }
}

/// Signs out of google
Future<void> signOutGoogle() async{
  await googleSignIn.signOut();
}