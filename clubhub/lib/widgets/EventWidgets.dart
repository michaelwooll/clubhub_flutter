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
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:clubhub/models/DatabaseHelperFunctions.dart';



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
  bool _isLoaded = false;
  @override
  void initState() {
    super.initState();
    _handleEventListQuery();
    // Grab events club by club
    /*getClubIDsFollowed().then((value){
      for(var id in value){
        retrieveEventsForClub(id).then((events){
          // No events found
          if(events.length == 0){
            setState((){
              _isLoaded = true;
            });
          }// end if
          else{
            setState(() {
              _events += events;
              _isLoaded = false;
            });
          } // end else
        });
      }
    });*/
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
      for(var id in value){
        retrieveEventsForClub(id).then((events){
          // No events found
          if(events.length == 0){
            setState((){
              _isLoaded = true;
            });
          }// end if
          else{
            setState(() {
              _events += events;
              _isLoaded = false;
            });
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
              onPressed: (){
                String formatString = combineDateAndTime(date, time);
                DateTime d = DateTime.parse(formatString);
                createEvent(titleController.text, descController.text,widget.id,d);
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