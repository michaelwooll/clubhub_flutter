/// [File]: ClubWidgets.dart
/// [Author]: Michael Wooll
/// 
/// [Description]: This file contains all the methods to convert Club objects into Widgets that the application
/// will use
/// 
import 'package:clubhub/models/Club.dart';
import 'package:clubhub/models/DatabaseHelperFunctions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// [Stateless widget] that displays a clubs information in a [Card] format
///Used https://api.flutter.dev/flutter/material/Card-class.html for reference
class ClubCard extends StatelessWidget {
  final Club club; // Club object that will hold all the club data
  const ClubCard({Key key, this.club}): super(key:key); 

  @override
  Widget build(BuildContext context){
    return Center(
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Image.network(club.getImgURL()),
              title: Text(club.getName()),
              subtitle: Text(club.getShortDescription())
            ) // ListTitle
          ], // End children widget
        ), // Column
      ), // Card
    ); // Center
  } // build
}


/// Stateful Widget that creates a ListView based on the current state of the [_clubs] list
class ClubList extends StatefulWidget{
  const ClubList({Key key}):super(key:key);

  @override
  _ClubListState createState() => new _ClubListState();
} 


class _ClubListState extends State<ClubList>{
  List<Club> _clubs = []; // State of the club list  
  @override
  void initState() {
    super.initState();
    // Grab club list asynchonously then set state
    retrieveAllClubs().then((value){
      setState(() {
        _clubs = value;
      }
      ); 
    });
  }

/// This refresh handler will retrieve the most up to date clublist
/// and set the [_club] list state.
  Future<Null> _handleRefresh() async{
    List<Club> list= await retrieveAllClubs();
    debugPrint(list.length.toString());
    setState(() {
      _clubs = list;
    });
    return null;
  }
  
  @override
  Widget build(BuildContext context){
    // 
    List<Widget> children = []; 
    // If the list is currenty empty we are fetching from DB, Show load circle.
    if(_clubs.isEmpty){
      children = <Widget>[
            const Padding(
              padding: EdgeInsets.only(top: 100),
            ),
            Center(
              child: SizedBox(
              child: CircularProgressIndicator(),
              width: 100,
              height: 100,
            )
            ),
            const Padding(
              padding: EdgeInsets.only(top: 20),
              child: Center(
                child: Text('Fetching clubs...'),
              )
            )
      ];
    } // end if
    // Else we have data, build a list of ClubCard's
    else{
      for(var c in _clubs){
        children.add(ClubCard(club: c));
      } // end for
    }// end else
    
    return RefreshIndicator(
      child: Container(
        child: ListView(
          children: children,
        )
      ),
      onRefresh: _handleRefresh,
    );
  }// end build
}
