/// [File]: LogInPage.dart
/// [Author]: Michael Wooll
/// 
/// [Description]: This file contains all the methods and widgets to create the Log-in page
/// 
/// 
import 'package:clubhub/main.dart';
import 'package:flutter/material.dart';
import 'package:clubhub/models/DatabaseHelperFunctions.dart';
import 'package:clubhub/models/Campus.dart';
import 'package:clubhub/auth.dart';


/// Root of the Log-in Page
class LoginPage extends StatefulWidget{
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>{
  List<Campus> _campusList = [];
  Campus _selectedCampus;
  bool _isAuthenticating = false;

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
    else if(_isAuthenticating){
      // Spin loading wheel for authenticating
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
                child: Text('Authenticating'),
              )
            )
      ];
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
        authType: _selectedCampus.getAuthType(),
        campusID: _selectedCampus.getID()
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



/// Returns the needed Sign In UI based on the Campus' specified [authType]
class LoginWidget extends StatelessWidget {
  final Authentication_type authType;
  final String campusID;

  const LoginWidget({Key key, this.authType, this.campusID}):super(key:key);

  @override
  Widget build(BuildContext context){
    switch (authType) {
      case Authentication_type.GoogleLogin: {
        return(
          new RaisedButton(
            child: Text("Sign in with Google"),
            onPressed: (){
              signInWithGoogle(campusID).then((u){
                if(u != false){ // signInWithGoogle returned a valid user
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context){
                        return MyHomePage(title: "Clubhub", user: u);
                      }
                    )
                  );
                }// end if
                else{ // signInWithGoogle failed
                
                } // end else
              }); // end .then()
            }, // end onPressed
          )
        );// return
      }

      default:{
        return(Text("No campus Login Widget Found"));
      } // end default
    } // end Switch
  } // end build
}

