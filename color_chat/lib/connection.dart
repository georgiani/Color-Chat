import 'dart:convert';
import 'package:color_chat/Model.dart';
import 'package:flutter/material.dart';
import 'package:adhara_socket_io/adhara_socket_io.dart';

String serverURL = "http://192.168.1.155:80";
SocketIO _io;

void showPleaseWait() {
  showDialog(
      // it needs to display on the root context
      // because that's over all the other widgets
      context: chatModel.rootCtx,
      barrierDismissible: false,
      builder: (BuildContext dialogCtx) {
        return Dialog(
          child: Container(
            width: 150,
            height: 150,
            alignment: AlignmentDirectional.center,
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Column(
              children: [
                Center(
                  child: CircularProgressIndicator(
                    value: null,
                    strokeWidth: 10,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                    top: 20,
                  ),
                  child: Center(
                    child: Text(
                      "Please wait...",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      });
}

void hidePleaseWait() {
  Navigator.of(chatModel.rootCtx).pop(); // pop the dialog
}

void connectToServer(final Function callback) async {
  _io = await SocketIOManager().createInstance(SocketOptions(serverURL));
  _io.onConnect((dataIn) {
    // listen to the broadcasts (messages from the server)
    _io.on("newUser", newUser);
    _io.on("created", created);
    _io.on("closed", closed);
    _io.on("joined", joined);
    _io.on("left", left);
    _io.on("kicked", kicked);
    _io.on("invited", invited);
    _io.on("posted", posted);
    callback();
  });
  
  _io.connect();
}

//############### Server Code (sends messages to the server
// and gets back data. The server also broadcasts some messages
// that will be used by the Client Code methods)

void validate(
    final String inUserName, final String inPass, final Function callback) {
  showPleaseWait();

  // operation, dataIn, callBack
  _io.emitWithAck("validate", [
    {"userName": inUserName, "password": inPass}
  ]).then((dataIn) {
    hidePleaseWait(); // hide the dialog
    callback(dataIn[0]);
  });
}

// no dataIn for this message
void listRooms(final Function callback) {
  showPleaseWait();

  _io.emitWithAck("listRooms", // the method from the server
      [{}]).then(// the dataIn for it
      (dataIn) {
    // what I get back
    hidePleaseWait();
    callback(dataIn[0]); // use it somehow
  });
}

void listUsers(final Function callback) {
  showPleaseWait();

  _io.emitWithAck("listUsers", [{}]).then((dataIn) {
    hidePleaseWait();
    callback(dataIn[0]);
  });
}

void create(
    final String inRoomName,
    final String inDescription,
    final int inMaxPeople,
    final bool inPrivate,
    final String inCreator,
    final Function callback) {
  showPleaseWait();
  _io.emitWithAck("create", [
    {
      "roomName": inRoomName,
      "description": inDescription,
      "maxPeople": inMaxPeople,
      "private": inPrivate,
      "creator": inCreator
    }
  ]).then((dataIn) {
    // {status: "exists|created",
    // rooms: complete list of rooms with the new one if status == created}

    hidePleaseWait();
    callback(dataIn[0]);
  });
}

void join(
    final String inUserName, final String inRoomName, final Function callback) {
  showPleaseWait();

  _io.emitWithAck("join", [
    {"userName": inUserName, "roomName": inRoomName}
  ]).then((dataIn) {
    hidePleaseWait();
    callback(dataIn[0]);
  });
}

void post(final String inUserName, final String inRoomName,
    final String inMessage, final Function callback) {
  showPleaseWait();

  _io.emitWithAck("post", [
    {"userName": inUserName, "roomName": inRoomName, "message": inMessage}
  ]).then((dataIn) {
    hidePleaseWait();
    callback(dataIn[0]);
  });
}

void invite(final String inviterUserName, final String invitedUserName,
    final String inRoomName, final Function callback) {
  showPleaseWait();

  _io.emitWithAck("invite", [
    {
      "inviterUserName": inviterUserName,
      "roomName": inRoomName,
      "invitedUserName": invitedUserName
    }
  ]).then((dataIn) {
    hidePleaseWait();
    callback();
  });
}

void leave(
    final String inUserName, final String inRoomName, final Function callback) {
  showPleaseWait();

  _io.emitWithAck("leave", [
    {"userName": inUserName, "roomName": inRoomName}
  ]).then((dataIn) {
    hidePleaseWait();
    callback();
  });
}

void close(final String inRoomName, final Function callback) {
  showPleaseWait();

  _io.emitWithAck("close", [
    {"roomName": inRoomName}
  ]).then((dataIn) {
    hidePleaseWait();
    callback();
  });
}

void kick(
    final String inUserName, final String inRoomName, final Function callback) {
  showPleaseWait();

  _io.emitWithAck("kick", [
    {"userName": inUserName, "roomName": inRoomName}
  ]).then((dataIn) {
    hidePleaseWait();
    callback();
  });
}
//########### Client Message Handlers
// received from the server through broadcasts (all users)

// when a new user is created the server sends
// a complete list of the users, including the new one
// so it will be updated in the model
void newUser(dataIn) {
  Map<String, dynamic> payload = jsonDecode(dataIn);
  chatModel.setUsers(payload);
}

// when a new room is added
// the server sens a complete list
// of the rooms for updating it for the
// client
void created(dataIn) {
  Map<String, dynamic> payload = jsonDecode(dataIn);
  chatModel.setRooms(payload);
}

// when a room is closed
// the server sends an updated list
// of the rooms without the closed one.
void closed(dataIn) {
  Map<String, dynamic> payload = jsonDecode(dataIn);
  chatModel.setRooms(payload["rooms"]); // dataIn: {roomName, rooms}

  // Also if the user is in the room
  // he needs to be notified of this
  // so just kick him out of the room
  if (payload["roomName"] == chatModel.roomName) {
    // cleanup
    chatModel.removeInvite(payload["roomName"]);
    chatModel.setUsers({}); // empty the users list of the room
    chatModel.setRoomName(ColorChatModel.notInARoom);
    chatModel.disEnableRoom(false);
    chatModel.setWelcomeMsg("The room you were in was closed.");
    // goes to "/" then removes all the previous
    // routes until ModalRoute.withName("/") is true
    Navigator.of(chatModel.rootCtx)
        .pushNamedAndRemoveUntil("/", ModalRoute.withName("/"));
  }
}

// if the used joined the room, then add him
// to the list of users
void joined(dataIn) {
  Map<String, dynamic> payload = jsonDecode(dataIn);
  if (chatModel.roomName == payload["roomName"]) {
    chatModel.setUsers(payload["users"]);
  }
}

void left(dataIn) {
  Map<String, dynamic> payload = jsonDecode(dataIn);

  // he was in the room, and still is by the model
  // so update the list
  if (chatModel.roomName == payload["roomName"]) {
    chatModel.setUsers(payload["users"]);
  }
}

// dataIn rooms[dataIn.roomName]
void kicked(dataIn) {

  // cleanup because he will see the room
  // as closed
  chatModel.removeInvite(dataIn["roomName"]);
  chatModel.setUsers({});
  chatModel.setRoomName(ColorChatModel.notInARoom);
  chatModel.disEnableRoom(false);
  chatModel.setWelcomeMsg("You got kicked from the room.");

  // goes to "/" then removes all the previous
  // routes until ModalRoute.withName("/") is true
  Navigator.of(chatModel.rootCtx)
      .pushNamedAndRemoveUntil("/", ModalRoute.withName("/"));
}

//dataIn -> inviter, invited, room
void invited(dataIn) async {
  String roomName = dataIn["roomName"];
  String inviterName = dataIn["inviterUserName"];

  chatModel.addInvite(roomName);

  Scaffold.of(chatModel.rootCtx).showSnackBar(
    SnackBar(
      backgroundColor: Colors.amber,
      duration: Duration(seconds: 5),
      content:
          Text("You've been invited to the room $roomName by $inviterName. \n\n"
              "You can enter the room from the lobby screen."),
      action: SnackBarAction(
        label: "Ok",
        onPressed: () {},
      ),
    ),
  );
}

// dataIn -> user, message, room
void posted(dataIn) {
  if (chatModel.roomName == dataIn["roomName"] && chatModel.userName != dataIn["userName"]) {
    chatModel.addMessage(dataIn["userName"], dataIn["message"]);
  }
}
