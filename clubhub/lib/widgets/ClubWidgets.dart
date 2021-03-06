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
import 'package:clubhub/auth.dart';
import 'package:clubhub/views/clubProfile.dart';




/// [Stateless widget] that displays a clubs information in a [Card] format
///Used https://api.flutter.dev/flutter/material/Card-class.html for reference
class ClubCard extends StatelessWidget {
  final Club club; // Club object that will hold all the club data
  final Function callBack;
  const ClubCard({Key key, this.club, this.callBack}): super(key:key); 


  @override
  Widget build(BuildContext context){

    return InkWell(
      child: Center(
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
        ), // Card,
      ),
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context) => ClubProfile(club:club, callBack: callBack)));
      }
    );
  } // build
}

/// Stateful Widget that creates a ListView based on the current state of the [_clubs] list
class ClubList extends StatefulWidget{
  const ClubList({Key key}):super(key:key);

  @override
  _ClubListState createState() => new _ClubListState();
} 


class _ClubListState extends State<ClubList>{
  List<Club> _clubs; // State of the club list 
  int _filterIndex = 0;
  List<List<Club>> _clubMaster = new List(2); // Contains the club lists for each filter (0,1)
  List<Color> colors = [Colors.red,Colors.black];
  
  @override
  void initState() {
    super.initState();
    // Grab club list asynchonously then set state
    String campusID = UserInstance().getUser().getCampusID();
    retrieveAllClubs(campusID).then((value){
      setState(() {
        _clubMaster[_filterIndex] = value;
        _clubs = _clubMaster[_filterIndex];
      }
      ); 
    });
  }

/// This refresh handler will retrieve the most up to date clublist
/// and set the [_club] list state.
  Future<Null> _handleRefresh(int _filterIndex) async{
    setState(() {
      _clubs = null;
    });
    switch (_filterIndex) {
      case 0:{
        String campusID = UserInstance().getUser().getCampusID();
        List<Club> list = await retrieveAllClubs(campusID);
        setState(() {
          _clubMaster[_filterIndex] = list;
          _clubs = _clubMaster[_filterIndex];
        });
        break;
      }
      case 1:{
        List<Club> list = await getClubsFollowed();
        setState(() {
          _clubMaster[_filterIndex] = list;
          _clubs = _clubMaster[_filterIndex];
        });
        break;
      }
      default:{
        String campusID = UserInstance().getUser().getCampusID();
        List<Club> list = await retrieveAllClubs(campusID);
        setState(() {
          _filterIndex = 0;
          _clubMaster[_filterIndex] = list;
          _clubs = _clubMaster[_filterIndex];
        });
        break;
      }
    }
    return null;
  }
  
  void _filterCallBack(String value){
    setState(() {
      _clubs = filterClubSearch(_clubMaster[_filterIndex], value);    
    });
  }


  List<Club> filterClubSearch(List<Club> clubList, String filter){
    if(filter.isEmpty){
      return clubList;
    }
    List<Club> ret = [];
    for(var club in clubList){
      if(club.getName().toLowerCase().contains(filter.toLowerCase()) || club.getDescription().toLowerCase().contains(filter.toLowerCase())){
        ret.add(club);
      }
    }
    return ret;
  }

  @override

  Widget build(BuildContext context){
    //
    List<Widget> children = [];
    children.add(SearchBar(callback: _filterCallBack));
    ButtonBar buttons = new ButtonBar(children: 
      <Widget>[
        MaterialButton(
          child: Text(
            "All clubs",
            style: TextStyle(color: colors[0]),
            ),
          onPressed: (){ 
               setState(() {
                _clubs = null;
              });
            String campusID = UserInstance().getUser().getCampusID();
            retrieveAllClubs(campusID).then((value){
              setState(() {
                  _filterIndex = 0;
                  _clubMaster[_filterIndex] = value;
                  _clubs = _clubMaster[_filterIndex];
                  colors[_filterIndex] = Colors.red;
                  colors[1] = Colors.black;
                  //_clubs = filterClubSearch(_clubMaster[_filterIndex], _searchFilter);
                 // _clubs = value;
                }
              ); 
            });},
        ),
        MaterialButton(
          child: Text("Followed",
            style: TextStyle(color: colors[1]),
          ),
          onPressed: (){
            setState(() {
                _clubs = null;
            });
            getClubsFollowed().then((value){
              setState(() {
                 _filterIndex = 1;
                 _clubMaster[_filterIndex] = value;
                 _clubs = _clubMaster[_filterIndex];
                  colors[_filterIndex] = Colors.red;
                  colors[0] = Colors.black;
                 //_clubs = filterClubSearch(_clubMaster[_filterIndex], _searchFilter);
              });
            });},
        )
    ],
    alignment: MainAxisAlignment.center,
    );
    children.add(buttons);
    // If the list is currenty empty we are fetching from DB, Show load circle.
    if(_clubs == null){
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
        children.add(ClubCard(club: c, callBack: () =>_handleRefresh(_filterIndex)));
      } // end for
    }// end else
    
    return RefreshIndicator(
      child: Container(
        child: ListView(
          children: children,
        )
      ),
      onRefresh: () =>_handleRefresh(_filterIndex),
    );
  }// end build
}

class SearchBar extends StatefulWidget {
  const SearchBar({Key key, this.callback}):super(key:key);
  final Function callback;
  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final TextEditingController _controller =  new TextEditingController();
  _SearchBarState(){
    _controller.addListener((){
      widget.callback(_controller.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child:  TextField(
        controller: _controller,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search)
        ),
      )
    );
  }
}