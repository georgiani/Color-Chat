import 'package:color_chat/Model.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'connection.dart' as conn;
import 'package:path/path.dart';
import 'dart:io';

class LoginDialog extends StatelessWidget {

  static final GlobalKey<FormState> _loginKey = new GlobalKey<FormState>();
  String _userName, _password;

  @override
  Widget build(BuildContext context) {
    return ScopedModel<ColorChatModel> (
      model: chatModel,
      child: ScopedModelDescendant<ColorChatModel>(
        builder: (BuildContext ctx, Widget w, ColorChatModel c) {
          return AlertDialog(
            content: Container(
              height: 220,
              child: Form(
                key: _loginKey,
                child: Column(
                  children: [
                    Text(
                      "Enter a username and password\nto register "
                      "or to login",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Theme.of(chatModel.rootCtx).accentColor,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      validator: (String s) {
                        if (s.length == 0) {
                          return "Enter a username.";
                        }

                        return null;
                      },
                      onSaved: (String s) {
                        _userName = s;
                      },
                      decoration: InputDecoration(
                        hintText: "User Name",
                        labelText: "User Name",
                      ),
                    ),
                    TextFormField(
                      validator: (String s) {
                        if (s.length == 0) {
                          return "Enter a password.";
                        }

                        return null;
                      },
                      onSaved: (String s) {
                        _password = s;
                      },
                      decoration: InputDecoration(
                        hintText: "Password",
                        labelText: "Password",
                      ),
                    )
                  ],
                ),
              ),
            ),
            actions: [
              FlatButton(
                child: Text("Log In"),
                onPressed: () {
                  if (_loginKey.currentState.validate()) {
                    _loginKey.currentState.save();

                    conn.connectToServer(
                      () { // after connecting it'll call this
                        conn.validate(_userName, _password, (status) async { //after validating
                          // the .validate will throw back the callback
                          // with the response["status"] as argument which is a string
                          // defining the status of the validation
                          if (status == "ok") {
                            // user exists, log in
                            chatModel.setUserName(_userName);
                            Navigator.of(chatModel.rootCtx).pop(); // pop the dialog
                            chatModel.setWelcomeMsg("Welcome back, $_userName!");
                          } else if (status == "fail") {
                            // username exists and user is trying to register
                            // or password is wrong
                            Scaffold.of(chatModel.rootCtx).showSnackBar(
                              SnackBar(
                                content: Text("That username is already taken!"),
                                duration: Duration(seconds: 3),
                              ),
                            );
                          } else if (status == "created") { 
                            // new user is registered so welcome him
                            // and initialize everything

                            // get the file containing users
                            var credentialsFile = File(join(chatModel.docsDir.path, "credentials"));
                            
                            // write the new user credentials in it
                            await credentialsFile.writeAsString(
                              "$_userName,$_password",
                            );
                            chatModel.setUserName(_userName);
                            Navigator.of(chatModel.rootCtx).pop();
                            chatModel.setWelcomeMsg("Welcome, $_userName");
                          }
                        });
                      }
                    );
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void validateWithAlreadyStoredCredentials(final String inUserName, final String inPass) {
    conn.connectToServer(
      () { // connected succesfully, begin validation
        conn.validate(inUserName, inPass, (status) {
          if (status == "ok" || status == "created") { // if the server is restarted
            // it'll consider the user as "created"
            chatModel.setUserName(inUserName);
            chatModel.setWelcomeMsg("Welcome back, $inUserName!");
          } else if (status == "fail") { // the server restarted and the username was taken
            showDialog(
              context: chatModel.rootCtx,
              barrierDismissible: false,
              builder: (BuildContext ctx) {
                return AlertDialog(
                  content: Text(
                    "The server has restarded and in the meanwhile"
                    " your username was talen.\n\n Please restart ColorChat and "
                    "choose a different username."
                  ),
                  actions: [
                    FlatButton(
                      child: Text("OK"),
                      onPressed: () {
                        var credentialsFile = File(join(chatModel.docsDir.path, "credentials"));
                        credentialsFile.deleteSync(); // delete the file to prevent a loophole
                        exit(0);
                      },
                    ),
                  ],
                );
              }
            );
          }
        });
      }
    );
  }
}