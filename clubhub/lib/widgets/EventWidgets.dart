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

/// [Stateless widget] that displays an events information in a [Card] format
///Used https://api.flutter.dev/flutter/material/Card-class.html for reference
class EventCard extends StatelessWidget {
  final Event event; // Event object that will hold all the event data
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


/// Stateful Widget that creates a ListView based on the current state of the [_events] list
class EventList extends StatefulWidget{
  const EventList({Key key}):super(key:key);

  @override
  _EventListState createState() => new _EventListState();
} 


class _EventListState extends State<EventList>{
  List<Event> _events = []; // State of the event list  
  @override
  void initState() {
    super.initState();
    //createFakeEvent();
    // Grab events club by club
    retrieveAllClubIDs().then((value){
      for(var id in value){
        retrieveEventsForClub(id).then((events){
          setState(() {
            _events += events;
          });
        });
      }
    });
  }

/// This refresh handler will retrieve the most up to date eventlist
/// and set the [_events] list state.
  Future<Null> _handleRefresh() async{
    setState(() {
      _events = [];
    });

    retrieveAllClubIDs().then((value){
      for(var id in value){
        retrieveEventsForClub(id).then((events){
          setState(() {
            _events += events;
          });
        });
      }
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
    // Else we have data, build a list of EventCard's
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