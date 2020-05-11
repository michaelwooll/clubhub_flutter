import 'package:clubhub/auth.dart';
/// [File]: EventWidget.dart
/// [Author]: Michael Wooll
/// 
/// [Description]: This file contains all the methods to convert Event objects into Widgets that the application
/// will use
/// 
import 'package:clubhub/models/Event.dart';
import 'package:clubhub/models/DatabaseHelperFunctions.dart';
import 'package:clubhub/views/eventPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:clubhub/models/Club.dart';
import 'package:clubhub/widgets/CommentWidgets.dart';


import 'CommentWidgets.dart';



/// [Stateless widget] that displays an events information in a [Card] format
///Used https://api.flutter.dev/flutter/material/Card-class.html for reference
class EventCard extends StatelessWidget {
  final Event event; // Event object that will hold all the event data
  final Club club;
  const EventCard({Key key, this.event, this.club}): super(key:key); 

  @override
  Widget build(BuildContext context){
    return Center(
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
              ),
              onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventCardLarge(club: club,event: event, callBack: (){}
                    )
                    )
                  ),
            )
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
  Map<String, Club> _clubs = {};
  bool _isLoaded = false;
  @override
  void initState() {
    super.initState();
    _handleEventListQuery();
  }

/// This refresh handler will retrieve the most up to date eventlist
/// and set the [_events] list state.
  Future<Null> _handleRefresh() async{
    setState(() {
      _events = [];
      _isLoaded = false;
    });
  
    _handleEventListQuery();
    return null;
  }
  
  Future<Null> _handleEventListQuery() async{
    getClubIDsFollowed().then((value){
      if(value.isEmpty){
        setState(() {
          _isLoaded = true;
        });
      }
      for(var id in value){
        retrieveEventsForClub(id).then((events){
          // No events found
          if(events.length == 0){
            setState((){
              _isLoaded = true;
            });
          }// end if
          else{
            // Check if club is already in map
            if(!_clubs.containsKey(id)){ // If it IS not in map
              // Get club and place into map
              getClubFromID(id).then((club){
                _events += events;
                _events.sort((b,a) => a.getDateTime().compareTo(b.getDateTime()));
                setState(() {
                  _isLoaded = false;
                  _clubs[id] = club;
                });
              });
            }
            else{
              _events += events;
              _events.sort((b,a) => a.getDateTime().compareTo(b.getDateTime()));
              setState(() {
                _isLoaded = false;
              });
            }

          } // end else
        });
      }
    });
  }

  @override
  Widget build(BuildContext context){
    // 
    List<Widget> children = []; 
    // If the list is currenty empty we are fetching from DB, Show load circle.
    if(_events.isEmpty && !_isLoaded){
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
    // No events were found and the query came back with no results
    else if(_events.isEmpty && _isLoaded){
          children = <Widget>[
            const Padding(
              padding: EdgeInsets.only(top: 100),
            ),
            Center(
              child: SizedBox(
              child: Text("No results"),
              width: 100,
              height: 100,
            )
            ),
      ];
    }
    // Else we have data, build a list of EventCard's
    else{
      for(var e in _events){
        children.add(EventCard(event: e, club: _clubs[e.getClubID()]));
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



class EventForm extends StatefulWidget {
  final id;
  const EventForm(this.id,{Key key}):super(key:key);

  @override
  _EventFormState createState() => _EventFormState();
}

class _EventFormState extends State<EventForm> {
  final dateController = TextEditingController(); 
  final timeController = TextEditingController(); 
  final titleController = TextEditingController();
  final descController = TextEditingController();

  DateTime date;
  DateTime time;
  @override
  Widget build(BuildContext context) {
      return Form(
        child: Column(
          children: <Widget>[
            Text("Create an Event!"),
            TextFormField(
              decoration: const InputDecoration(
                labelText: "Title"
              ),
              controller: titleController,
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: "Description"
              ),
              controller: descController,
              keyboardType: TextInputType.multiline,
              minLines: 1,//Normal textInputField will be displayed
              maxLines: 5,// when user presses enter it will adapt to it
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: "Date"
              ),
              controller: dateController,
              onTap: (){
                // Below line stops keyboard from appearing
                FocusScope.of(context).requestFocus(new FocusNode());
                // Show date picker
                DatePicker.showDatePicker(context,
                  minTime: DateTime.now(),
                  onConfirm: (d) {
                    date = d;
                    dateController.text = DateFormat.yMMMd().format(d);
                  }
                );
              
            },),
            TextFormField(
              decoration: const InputDecoration(
                labelText: "Time"
              ),
              controller: timeController,
              onTap: (){
                // Below line stops keyboard from appearing
                FocusScope.of(context).requestFocus(new FocusNode()); 
                // Show time picker
                DatePicker.showTime12hPicker(context,
                  onConfirm: (t){
                    time = t;
                    timeController.text = DateFormat.jm().format(t);
                  }
                );
              }
            ),
            RaisedButton(
              child: Text("Submit!"),
               color: Colors.redAccent,
              shape: RoundedRectangleBorder(
             borderRadius: new BorderRadius.circular(20.0)
           ),
              onPressed: (){
                String formatString = combineDateAndTime(date, time);
                DateTime d = DateTime.parse(formatString);
                createEvent(titleController.text, descController.text,widget.id,d);
                Navigator.pop(context);
              },
            )
          ]
        )
      ); 
  }
}


String combineDateAndTime(DateTime date, DateTime time){

  String year,month,day,hour,minute,result;
  year = date.year.toString();
  if(date.month < 10){
    month = "0" + date.month.toString();
  }else{
    month = date.month.toString();
  }

  if(date.day < 10){
    day = "0" + date.day.toString();
  }
  else{
    day = date.day.toString();
  }
  if(time.hour < 10){
    hour = "0" + time.hour.toString();
  }
  else{
    hour = time.hour.toString();
  }

  if(time.minute < 10){
    minute = "0" + time.minute.toString();
  }
  else{
    minute = time.minute.toString();

  }
  result = year + "-" + month + "-" + day + " " + hour + ":" + minute + ":00";
  return (year + "-" + month + "-" + day + " " + hour + ":" + minute + ":00");
}


class EventCardBody extends StatelessWidget {
  final event;
  EventCardBody(this.event, {Key key}):super(key:key);
  @override
  Widget build(BuildContext context) {
    return Column(
        children: <Widget>[
         SizedBox(
            child: FollowEventButton(event: event),
            width: 200,
            height: 25,
          ),
        
          Text(event.getDescription()),
          GestureDetector(
            child:  Text(
              "See comments",
              style: TextStyle(color: Colors.blue)
            ),
            onTap:(){ showDialog(
              context: context,
              builder: (BuildContext context){
                return AlertDialog(content: CommentList(event.getDocID()));
              }
              );
            }
          )
        ]
      );
  }
}


class FollowEventButton extends StatefulWidget {
  final Event event;
  final Function callBack;
 // final Function callBack;
  FollowEventButton({this.event, this.callBack});
  @override
  _FollowEventButton createState() => _FollowEventButton();
}

class _FollowEventButton extends State<FollowEventButton> {
  bool isFollowed;
  @override
  void initState() {
    super.initState();
    userFollowsEvent(widget.event).then((value){
      setState(() {
        isFollowed = value;
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    if(isFollowed == null){
      children.add(
        RaisedButton(
          onPressed: (){}
        )
      );
    }
    else if(!isFollowed){
      children.add(
        FlatButton(
          child: Text("Add to calendar!"),
          color: Colors.lightGreen,  
          splashColor: Colors.greenAccent,
          onPressed: (){
           followEvent(UserInstance().getUser().getID(),widget.event).then((value){
             setState(() {
               isFollowed = value;
             });
             widget.callBack();
           });
          }
        )
      );
    }
    else{
      children.add(
        FlatButton(
          child: Text("Remove from calendar"),
          color: Colors.red,  
          splashColor: Colors.redAccent,
          onPressed: (){
            unfollowEvent(UserInstance().getUser().getID(),widget.event).then((value){
              setState(() {
                isFollowed = value;
              });
              widget.callBack();
            });
          }
        )
      );
    }
    return Container(
      child: children[0]
    );
  }
}