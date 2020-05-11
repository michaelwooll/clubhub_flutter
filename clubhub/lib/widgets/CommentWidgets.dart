import 'package:clubhub/models/Comment.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:clubhub/models/DatabaseHelperFunctions.dart';
import 'package:clubhub/models/User.dart';



class CommentCard extends StatelessWidget {
  final Comment comment;
  final User user;
  const CommentCard({Key key, this.comment, this.user}):super(key:key);
  @override
  Widget build(BuildContext context) {
    return(
      ListTile(
        leading: CircleAvatar(
          backgroundImage:NetworkImage(user.getImgURL()),
          backgroundColor: Colors.white,
        ),
        title: Text(
          user.getFullName(),
          style: TextStyle(fontWeight: FontWeight.bold)
          ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              comment.getDateString() + " at " + comment.getTimeString(),
              style: TextStyle(color: Colors.red)
              ),
            Text(
              comment.getContent(),
              style: TextStyle(fontWeight: FontWeight.normal, color: Colors.black)),
           ],
        )
        //subtitle: Row(children: <Widget>[Icon(Icons.thumb_up, size: 15,),Text(comment.getLikes().toString())],),
      ))
    ;
  }
}

class CommentList extends StatefulWidget {
  final eventID;
  const CommentList(this.eventID,{Key key}):super(key:key);
  @override
  _CommentListState createState() => _CommentListState();
}

class _CommentListState extends State<CommentList> {
  List<Comment> commentList = [];
  Map<String,User> users = {}; 
  bool isLoaded = false;

  @override
  void initState() {
    super.initState();
    _handleCommentListQuery();
  }
  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];

    if(commentList.isEmpty && !isLoaded){ // Have not retireve anything
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
                child: Text('Fetching comments...'),
              )
            )
      ];
    } // end if
    else{
      children.add(CommentBar(widget.eventID,_refreshList));
      for(var c in commentList){
        children.add(CommentCard(comment: c, user: users[c.getUserID()]));
      }
    }
    return Expanded(child: ListView(children: children));

  }


  Future<void> _handleCommentListQuery() async {
    List<Comment> comms = await retrieveCommentsForEvent(widget.eventID);
    for(var c in comms){
      if(!users.containsKey(c.getUserID())){
        User u = await c.getUser();
        users[c.getUserID()] = u;
      }
    }
    setState(() {
      isLoaded = true;
      commentList += comms;
    });
  }

    Future<void> _refreshList() async {
    List<Comment> comms = await retrieveCommentsForEvent(widget.eventID);
    for(var c in comms){
      if(!users.containsKey(c.getUserID())){
        User u = await c.getUser();
        users[c.getUserID()] = u;
      }
    }
    commentList = [];
    setState(() {
      isLoaded = true;
      commentList += comms;
    });
  }
}

class CommentBar extends StatelessWidget {
  final id;
  final contentController = TextEditingController();
  final callBack;
  CommentBar(this.id, this.callBack, {Key key}):super(key:key);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: contentController,
            decoration: const InputDecoration(
              labelText: "Make a comment!"
            ),
          ),
          FlatButton(
              child: Text("Submit"),
              onPressed: (){
                if(contentController.text != ""){
                   Comment comment = new Comment("comment", contentController.text);
                  createComment(id, comment).then((success){
                    FocusScope.of(context).requestFocus(FocusNode());
                    if(success){
                      callBack();
                    }
                  });
                }   
              },
            )
        ],
      )
    );
  }
}