
/// [File]: main.dart
/// [Author]: Michael Wooll
/// 
/// [Description]: Main file that contains the app
/// 

import 'package:clubhub/views/logInPage.dart';
import 'package:clubhub/widgets/CommentWidgets.dart';
import 'package:flutter/material.dart';
import 'package:clubhub/widgets/ClubWidgets.dart';
import 'package:clubhub/widgets/EventWidgets.dart';
import 'package:clubhub/auth.dart';
import 'package:clubhub/views/calendarPage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
        home: LoginPage() 
    );
  }
}


class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _pageIndex= 0;

  void _onItemTapped(int index) {
    setState(() {
      _pageIndex = index;
    });
  }



  Widget getWidgetOption(int index){
    if(index >= _widgetOptions.length){
      return null;
    }
    else {
      return _widgetOptions.elementAt(index);
    }
  }

  static List<Widget> _widgetOptions = <Widget>[
    EventList(),
    CalendarPage(),
    ClubList(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title + ". Welcome " + UserInstance().getUser().getFullName()),
      ),
      body: Center(
        child: _widgetOptions[_pageIndex]
      ),
      bottomNavigationBar: 
      BottomNavigationBar(
        currentIndex: _pageIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.format_list_bulleted ),
              title: Text('Feed'),
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              title: Text('Calendar'),
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.search),
              title: Text('Search'),
          ),
        ],
        )
    );
  }
}