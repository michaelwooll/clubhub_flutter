import 'package:clubhub/auth.dart';
/// [File]: calendarPage.dart
/// [Author]: Michael Wooll
/// 
/// [Description]: This file contains all the methods and widgets to create the calendarPage
/// 
/// 
import 'package:clubhub/main.dart';
import 'package:clubhub/models/Event.dart';
import 'package:clubhub/views/eventPage.dart';import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';


class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage>  with TickerProviderStateMixin{
  Map<DateTime, List> _events = {};
  List _selectedEvents;
  DateTime _selectedDay = DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day);
  AnimationController _animationController;
  CalendarController _calendarController = new CalendarController();
  void initState() {
    super.initState();
    _selectedEvents = _events[_selectedDay] ?? [];
    getUsersEvents().then((eventList){
      setState((){
        _events = eventList;
        _selectedEvents = _events[_selectedDay] ?? [];
      });
    });
  
    _calendarController = CalendarController();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _animationController.forward();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          // Switch out 2 lines below to play with TableCalendar's settings
          //-----------------------
          _buildTableCalendar(),
          // _buildTableCalendarWithBuilders(),
          const SizedBox(height: 8.0),
          //_buildButtons(),
          const SizedBox(height: 8.0),
          Expanded(child: _buildEventList()),
        ],
      ),
    );
  }

    // Simple TableCalendar configuration (using Styles)
  Widget _buildTableCalendar() {
    return TableCalendar(
      calendarController: _calendarController,
      events: _events,
      holidays: {},
      weekendDays: [], // Forces the weekend to NOT be orange
      locale: 'en_us',
      startingDayOfWeek: StartingDayOfWeek.monday,
      calendarStyle: CalendarStyle(
        selectedColor: Colors.red[800],
        todayColor: Colors.red[200],
        markersColor: Colors.blue,
        outsideDaysVisible: false,
      ),
      headerStyle: HeaderStyle(
        formatButtonVisible: false // Disables the format (month,2 week, 1 week buttoh)
      ),
        onDaySelected: onDaySelected,
    //  onVisibleDaysChanged: _onVisibleDaysChanged,
     // onCalendarCreated: _onCalendarCreated,
    );
  }

   Widget _buildButtons() {
    final dateTime = DateTime.now();

    return Column(
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            RaisedButton(
              child: Text('Month'),
              onPressed: () {
                setState(() {
                  _calendarController.setCalendarFormat(CalendarFormat.month);
                });
              },
            ),
            RaisedButton(
              child: Text('2 weeks'),
              onPressed: () {
                setState(() {
                  _calendarController.setCalendarFormat(CalendarFormat.twoWeeks);
                });
              },
            ),
            RaisedButton(
              child: Text('Week'),
              onPressed: () {
                setState(() {
                  _calendarController.setCalendarFormat(CalendarFormat.week);
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 8.0),
        RaisedButton(
          child: Text('Set day ${dateTime.day}-${dateTime.month}-${dateTime.year}'),
          onPressed: () {
            _calendarController.setSelectedDay(
              DateTime(dateTime.year, dateTime.month, dateTime.day),
              runCallback: true,
            );
          },
        ),
      ],
    );
  }
  void onDaySelected(DateTime day,List events){
    setState(() {
      _selectedDay = DateTime(day.year,day.month,day.day);
      _selectedEvents = events;
    });

  }
  Widget _buildEventList() {
    return ListView(
      children: _selectedEvents
          .map((item) => Container(
                decoration: BoxDecoration(
                  border: Border.all(width: 0.8),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: ListTile(
                  leading: CircleAvatar(
                  backgroundImage: NetworkImage(item["club"].getImgURL()),
                  minRadius: 25,
                  maxRadius: 30,
                ),
                  title: Text(item["event"].getTitle()),
                  trailing: Text(item["event"].getTimeString()),
                  subtitle: Text(item["club"].getName()),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventCardLarge(club: item["club"],event: item["event"], callBack:(){
                           getUsersEvents().then((eventList){
                            setState((){
                              _events = eventList;     
                               _selectedEvents = _events[_selectedDay] ?? [];
                            });
                          });
                      } )
                    )
                  ),
                ),
              ))
          .toList(),
    );
  }
}
