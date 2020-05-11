

import 'package:clubhub/models/Club.dart';
import 'package:clubhub/models/Event.dart';
import 'package:clubhub/widgets/CommentWidgets.dart';
import 'package:clubhub/widgets/EventWidgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';




class EventPage extends StatelessWidget {
  final Event event;
  EventPage({this.event});
  @override
  Widget build(BuildContext context) {
    return Container(
      
    );
  }
}
/*
/// [Stateless widget] that displays an events information in a [Card] format
///Used https://api.flutter.dev/flutter/material/Card-class.html for reference
class EventCardLarge extends StatelessWidget {
  final Event event; // Event object that will hold all the event data
  final Club club;
  const EventCardLarge({Key key, this.event, this.club}): super(key:key); 
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(),
      body: Center(
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(club.getImgURL()),
                minRadius: 25,
                maxRadius: 30,
              ),
              title: Text(
                club.getName(),
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold,color: Colors.blueGrey)
                ),
              subtitle: Text(
                event.getTitle(),
                style: TextStyle(fontSize: 18, color: Colors.black)
              ),
              trailing:  Column(
                children: <Widget>[
                  Text("Event",
                    style: TextStyle(color: Colors.blue)
                  ),
                  Text(event.getDateString(),
                    style: TextStyle(color: Colors.blueGrey)
                  
                  ),
                  Text(event.getTimeString(),
                    style: TextStyle(color: Colors.blueGrey)),
                ]
              )
            ),
            Text(club.getDescription()), 
          ],
   // End children widget
        ), // Column
      ), // Card
    )  // Center
    ); // Scaffold
  } // build
}*/



/// [Stateless widget] that displays an events information in a [Card] format
///Used https://api.flutter.dev/flutter/material/Card-class.html for reference
class EventCardLarge extends StatelessWidget {
  final Event event; // Event object that will hold all the event data
  final Club club;
  final Function callBack;
  const EventCardLarge({Key key, this.event, this.club, this.callBack}): super(key:key); 
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: 
        
Column(
  children: <Widget>[
    Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(club.getImgURL()),
                minRadius: 25,
                maxRadius: 30,
              ),
              title: Text(
                club.getName(),
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold,color: Colors.blueGrey)
                ),
              subtitle: Text(
                event.getTitle(),
                style: TextStyle(fontSize: 18, color: Colors.black)
              ),
              trailing:  Column(
                children: <Widget>[
                  Text("Event",
                    style: TextStyle(color: Colors.blue)
                  ),
                  Text(event.getDateString(),
                    style: TextStyle(color: Colors.blueGrey)
                  
                  ),
                  Text(event.getTimeString(),
                    style: TextStyle(color: Colors.blueGrey)),
                ]
              )
            ),
            FollowEventButton(event:event, callBack: callBack),
            Padding(
              child:  Text(
              event.getDescription(),
              style: TextStyle(fontSize: 15),
            ),
              padding: EdgeInsets.all(15)
            )
            
          ],
   // End children widget
        )
        ), // Column
      ),
      CommentList(event.getDocID())
  ]
)
      ) // Center
    ); // Scaffold
  } // build
}