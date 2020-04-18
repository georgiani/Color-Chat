import 'package:color_chat/AppDrawer.dart';
import 'package:color_chat/Model.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:color_chat/connection.dart' as conn;

class CreateRoom extends StatefulWidget {
  @override
  _CreateRoomState createState() => _CreateRoomState();
}

// stateful because of the switches and things
class _CreateRoomState extends State<CreateRoom> {
  String _title, _description;
  bool _private = false;
  int _maxPeople = 25;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return ScopedModel<ColorChatModel>(
      model: chatModel,
      child: ScopedModelDescendant<ColorChatModel>(
        builder: (ctx, w, c) {
          return Scaffold(
            resizeToAvoidBottomPadding: false,
            appBar: AppBar(
              backgroundColor: Color(0xFFD66853),
              title: Text("Create Room"),
            ),
            drawer: AppDrawer(),
            bottomNavigationBar: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              child: SingleChildScrollView(
                child: Row(
                  children: [
                    FlatButton(
                      child: Text("Cancel"),
                      onPressed: () {
                        FocusScope.of(ctx)
                            .requestFocus(FocusNode()); // close the keyboard
                        Navigator.of(ctx).pop(); // go to the previous screen
                      },
                    ),
                    Spacer(),
                    FlatButton(
                      child: Text("Save"),
                      onPressed: () {
                        if (!_formKey.currentState.validate()) {
                          return;
                        } // don't do
                        // anything if the data isn't ok

                        _formKey.currentState.save();

                        conn.create(_title, _description, _maxPeople, _private,
                            chatModel.userName, (dataIn) {
                          if (dataIn["status"] == "created") {
                            chatModel.setRooms(dataIn["rooms"]);
                            FocusScope.of(ctx)
                                .requestFocus(FocusNode()); // close keyboard
                            Navigator.of(ctx).pop();
                          } else {
                            // exists
                            Scaffold.of(ctx).showSnackBar(
                              SnackBar(
                                content: Text(
                                    "There is already a room with this name"),
                                backgroundColor: Color(0xFFDB504A),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            body: Form(
              key: _formKey,
              child: ListView(
                children: [
                  ListTile(
                    leading: Icon(Icons.subject),
                    title: TextFormField(
                      decoration: InputDecoration(
                        hintText: "Name",
                      ),
                      validator: (String s) {
                        if (s.length == 0 || s.length > 14) {
                          return "Please enter a name shorter than 14 characters";
                        }

                        return null;
                      },
                      onSaved: (String s) {
                        setState(() {
                          _title = s;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.description),
                    title: TextFormField(
                      decoration: InputDecoration(
                        hintText: "Description",
                      ),
                      onSaved: (String s) {
                        setState(() {
                          _description = s;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: Row(
                      children: [
                        Text("Max\nPeople"),
                        Slider(
                          min: 0,
                          max: 50,
                          value: _maxPeople * 1.0,
                          onChanged: (val) {
                            setState(() {
                              _maxPeople = val.truncate();
                            });
                          },
                        ),
                      ],
                    ),
                    trailing: Text(
                      _maxPeople.toString(),
                    ),
                  ),
                  ListTile(
                    title: Row(
                      children: [
                        Text("Private"),
                        Switch(
                          value: _private,
                          onChanged: (val) {
                            setState(() {
                              _private = val;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
