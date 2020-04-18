import 'package:color_chat/Model.dart';
import 'package:flutter/material.dart';
import 'connection.dart' as conn;

final GlobalKey<FormState> _loginKey = new GlobalKey<FormState>();

class LoginDialog extends StatelessWidget {
  String _userName, _password;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      backgroundColor: Color(0xFF212D40),
      content: Container(
        height: 210,
        child: Form(
          key: _loginKey,
          child: Column(
            children: [
              Text(
                "Login",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
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
                style: TextStyle(
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  hintText: "User Name",
                  hintStyle: TextStyle(
                    color: Colors.white,
                  ),
                  labelText: "User Name",
                  labelStyle: TextStyle(
                    color: Colors.white,
                  ),
                  border: InputBorder.none,
                ),
              ),
              TextFormField(
                obscureText: true,
                validator: (String s) {
                  if (s.length == 0) {
                    return "Enter a password.";
                  }

                  return null;
                },
                onSaved: (String s) {
                  _password = s;
                },
                style: TextStyle(
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  hintText: "Password",
                  hintStyle: TextStyle(
                    color: Colors.white,
                  ),
                  labelText: "Password",
                  labelStyle: TextStyle(
                    color: Colors.white
                  ),
                  border: InputBorder.none,
                ),
              )
            ],
          ),
        ),
      ),
      actions: [
        FlatButton(
          child: Text("Log In"),
          textColor: Colors.white,
          onPressed: () {
            if (_loginKey.currentState.validate()) {
              _loginKey.currentState.save();

              conn.connectToServer(() {
                // after connecting it'll call this
                conn.validate(_userName, _password, (dataIn) async {
                  //after validating
                  // the .validate will throw back the callback
                  // with the response["status"] as argument which is a string
                  // defining the status of the validation
                  if (dataIn["status"] == "ok") {
                    // user exists, log in
                    chatModel.setUserName(_userName);
                    Navigator.of(chatModel.rootCtx).pop(); // pop the dialog
                    chatModel.setWelcomeMsg("Welcome back, $_userName!");
                  } else if (dataIn["status"] == "fail") {
                    // username exists and user is trying to register
                    // or password is wrong
                    Scaffold.of(chatModel.rootCtx).showSnackBar(
                      SnackBar(
                        content: Text("That username is already taken!"),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  } else if (dataIn["status"] == "created") {
                    // new user is registered so welcome him
                    // and initialize everything
                    
                    chatModel.setUserName(_userName);
                    Navigator.of(chatModel.rootCtx).pop();
                    chatModel.setWelcomeMsg("Welcome, $_userName");
                  }
                });
              });
            }
          },
        ),
      ],
    );
  }
}
