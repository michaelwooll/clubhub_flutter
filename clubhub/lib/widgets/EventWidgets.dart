/// [File]: EventWidget.dart
/// [Author]: Michael Wooll
/// 
/// [Description]: This file contains all the methods to convert Event objects into Widgets that the application
/// will use
/// 
import 'package:clubhub/models/Event.dart';
import 'package:clubhub/models/DatabaseHelperFunctions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// [Stateless widget] that displays a clubs information in a [Card] format
///Used https://api.flutter.dev/flutter/material/Card-class.html for reference
class EventCard extends StatelessWidget {
  final Event event; // Club object that will hold all the club data
  const EventCard({Key key, this.event}): super(key:key); 

  @override
  Widget build(BuildContext context){
    return Center(
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.note),
              title: Text(event.getTitle()),
              subtitle: Text(event.getDescription())
            ) // ListTitle
          ], // End children widget
        ), // Column
      ), // Card
    ); // Center
  } // build
}


/// Stateful Widget that creates a ListView based on the current state of the [_clubs] list
class EventList extends StatefulWidget{
  const EventList({Key key}):super(key:key);

  @override
  _EventListState createState() => new _EventListState();
} 


class _EventListState extends State<EventList>{
  List<Event> _events = []; // State of the club list  
  @override
  void initState() {
    super.initState();
    // Grab club list asynchonously then set state
    retrieveAllEvents().then((value){
      setState(() {
        _events = value;
      }
      ); 
    });
  }

/// This refresh handler will retrieve the most up to date clublist
/// and set the [_club] list state.
  Future<Null> _handleRefresh() async{
    List<Event> list= await retrieveAllEvents();
    debugPrint(list.length.toString());
    setState(() {
      _events = list;
    });
    return null;
  }
  
  @override
  Widget build(BuildContext context){
    // 
    List<Widget> children = []; 
    // If the list is currenty empty we are fetching from DB, Show load circle.
    if(_events.isEmpty){
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
                child: Text('Fetching events...'),
              )
            )
      ];
    } // end if
    // Else we have data, build a list of ClubCard's
    else{
      for(var e in _events){
        children.add(EventCard(event: e));
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