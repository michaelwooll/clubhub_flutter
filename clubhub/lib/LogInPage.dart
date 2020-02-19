import 'package:clubhub/main.dart';
import 'package:flutter/material.dart';
import 'package:clubhub/models/DatabaseHelperFunctions.dart';
import 'package:clubhub/models/Campus.dart';


class LoginPage extends StatefulWidget{
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>{
  List<Campus> _campusList = [];
  Campus _selectedCampus;

  void initState() {
    super.initState();
    // Grab event list asynchonously then set state
    retrieveAllCampus().then((value){
      setState(() {
        _campusList = value;
        if(_campusList.isNotEmpty){
          _selectedCampus = _campusList[0];
        }
      }
      ); 
    });
  }
  @override
  Widget build(BuildContext context){
    List<Widget> children = [];
    if(_campusList.isEmpty){
      children.add(Text("Splash screen here"));
    }
    else{
      Text campusSelectText = new Text("Select your campus");

      DropdownButton campusSelect = new DropdownButton<Campus>(
          items: _campusList.map((Campus campus) {
            return new DropdownMenuItem<Campus>(
              value: campus,
              child: new Text(campus.getName())
            );
          }).toList(),
          onChanged: (Campus value){
            setState(() {
              _selectedCampus = value;
            });
          },
          value: _selectedCampus,
      );

      LoginWidget loginWidget = new LoginWidget(
        authType: _selectedCampus.getAuthType()
      ); // LoginWidget


      children.add(campusSelectText);
      children.add(campusSelect);
      children.add(loginWidget);
    } // end else
    return Scaffold(
      body: Center(
        child:Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: children
        )
      )
    );
  } // end build
}




class LoginWidget extends StatelessWidget {
  final Authentication_type authType;
  const LoginWidget({Key key, this.authType}):super(key:key);

  @override
  Widget build(BuildContext context){
    if(authType == Authentication_type.GoogleLogin){
      return(
        new RaisedButton(
          child: Text("Sign in with Google"),
          onPressed: (){
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context){
                  return MyHomePage(title: "Clubhub");
                }
              )
            );
          },
          )
      );
    }// end uif
    else{
      return(Text("No campus Login Widget Found"));
    }
  }
}