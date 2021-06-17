import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:unihub_app/controllers/comment_controller.dart';
import 'package:unihub_app/models/comment.dart';
import 'package:unihub_app/models/feedPublication.dart';
import 'package:unihub_app/widgets/commentSection.dart';
import 'package:http/http.dart' as http;
import 'package:unihub_app/widgets/feedPostSection.dart';
import 'package:unihub_app/screens/login/login.dart';

class CommentsScreen extends StatefulWidget {
  final FeedPublication feedPublication;
  final String username;
  CommentsScreen(this.feedPublication, this.username);
  CommentState createState() => CommentState();
}

class CommentState extends State<CommentsScreen> {
  List<Comment> commentsList;

  final TextEditingController contentController = TextEditingController();

  Future<List<Comment>> getAllComments(feedId) async {
    http.Response response =
        await CommentController().getComments(this.widget.feedPublication.id);
    List<Comment> preCommentList = [];
    for (var comment in jsonDecode(response.body)) {
      print(comment.toString());
      preCommentList.add(Comment.fromMap(comment));
    }
    print(preCommentList.toSet().toString());
    return preCommentList;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Comment>>(
        future: getAllComments(this.widget.feedPublication.id),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Scaffold(
                appBar: AppBar(
                  title: Text("Feed"),
                  leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.blue,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                body: SafeArea(
                    child: ListView.builder(
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        itemCount: snapshot.data.length,
                        itemBuilder: (context, index) {
                          if (snapshot.data.reversed
                                  .elementAt(index)
                                  .username ==
                              this.widget.username) {
                            this.commentsList =
                                new List<Comment>.from(snapshot.data.reversed);
                            return new Column(children: [
                              FeedPost(this.widget.feedPublication,
                                  this.widget.username),
                              Dismissible(
                                  key: ObjectKey(
                                      this.commentsList.elementAt(index)),
                                  child: new CommentWidget(
                                      this.commentsList.elementAt(index),
                                      this.widget.username),
                                  confirmDismiss: (direction) {
                                    if (this
                                            .commentsList
                                            .elementAt(index)
                                            .username ==
                                        this.widget.username) {
                                      return showDeletePostAlertDialog(
                                          context, index);
                                    } else {
                                      return null;
                                    }
                                  },
                                  onDismissed: (direction) {})
                            ]);
                          } else {
                            return new Column(children: [
                              FeedPost(this.widget.feedPublication,
                                  this.widget.username),
                              CommentWidget(
                                  snapshot.data.reversed.elementAt(index),
                                  this.widget.username)
                            ]);
                          }
                        })),
                floatingActionButton: FloatingActionButton(
                  heroTag: "btnAddFeed",
                  child: Icon(Icons.add),
                  onPressed: () {
                    showNewPostAlertDialog(context);
                  },
                ));
          } else {
            return Scaffold(
                appBar: AppBar(
                  title: Text("Feed"),
                ),
                body: Container(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                /*child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [Text('No posts available')],
              )),*/
                floatingActionButton: FloatingActionButton(
                  heroTag: "btnAddFeed",
                  child: Icon(Icons.add),
                  onPressed: () {
                    showNewPostAlertDialog(context);
                  },
                ));
          }
        });
  }

  showNewPostAlertDialog(BuildContext context) {
    contentController.text = '';
    // set up the buttons
    Widget submitButton = TextButton(
        child: Text("Create new post"),
        onPressed: () async {
          //Submit post
          http.Response response = await CommentController().addComment(
              this.widget.username,
              contentController.text,
              DateTime.now().toString(),
              this.widget.feedPublication.id);
          if (response.statusCode == 200) {
            createToast('Comment correctly uploaded', Colors.green);
            setState(() {
              commentsList.insert(
                  0, Comment.fromMap(jsonDecode(response.body)));
            });
            Navigator.pop(context);
          }
        });

    Widget dismissButton = TextButton(
      child: Text("Discard post"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
        backgroundColor: Colors.white,
        insetPadding: EdgeInsets.all(10),
        title: Text("New Post"),
        content: Stack(
          children: [
            Container(
                width: MediaQuery.of(context).size.width / 2,
                child: TextFormField(
                  controller: contentController,
                  keyboardType: TextInputType.multiline,
                  minLines: 4,
                  maxLines: null,
                  maxLength: 240,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(bottom: 3),
                    labelText: "What's happening?",
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                )),
          ],
        ),
        actions: [dismissButton, submitButton]);

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showDeletePostAlertDialog(BuildContext context, int index) {
    // set up the buttons
    Widget submitButton = TextButton(
      child: Text("Yes"),
      onPressed: () async {
        //delete post
        await CommentController()
            .deleteComment(this.commentsList.elementAt(index).id)
            .whenComplete(() {
          setState(() {
            this.commentsList.removeAt(index);
          });
          Navigator.pop(context);
        });
      },
    );
    Widget dismissButton = TextButton(
      child: Text("No"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
        content: Text('Are you sure that you want to delete this post?'),
        actions: [dismissButton, submitButton]);

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
