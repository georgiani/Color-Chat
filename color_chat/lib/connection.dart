import 'dart:convert';
import 'package:color_chat/Model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';

String serverURL = "http://192.168.1.1:8080";
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

void connectToServer(final Function callback) {
  _io = SocketIOManager().createSocketIO(serverURL, "/", query: "",
      socketStatusCallback: (dataIn) {
    if (dataIn == "connect") {
      // listen to the broadcasts (messages from the server)
      _io.subscribe("newUser", newUser);
      _io.subscribe("created", created);
      _io.subscribe("closed", closed);
      _io.subscribe("joined", joined);
      _io.subscribe("left", left);
      _io.subscribe("kicked", kicked);
      _io.subscribe("invited", invited);
      _io.subscribe("posted", posted);
      callback();
    }
  });
  _io.init();
  _io.connect();
}

//############### Server Code (sends messages to the server
// and gets back data. The server also broadcasts some messages
// that will be used by the Client Code methods)

void validate(
    final String inUserName, final String inPass, final Function callback) {
  showPleaseWait();

  // operation, dataIn, callBack
  _io.sendMessage(
      "validate",
      "{ \"userName\" : \"$inUserName\", "
          "  \"password\" : \"$inPass\" }", (dataIn) {
    // when the server finishes
    Map<String, dynamic> response =
        jsonDecode(dataIn); // decode the data given back in
    // the callback (that is also json)
    hidePleaseWait(); // hide the dialog
    callback(response["status"]);
  });
}

// no dataIn for this message
void listRooms(final Function callback) {
  showPleaseWait();

  _io.sendMessage(
      "listRooms", // the method from the server
      "{}", // the dataIn for it
      (dataIn) {
    // what I get back
    Map<String, dynamic> response =
        jsonDecode(dataIn); // decode the json response
    hidePleaseWait();
    callback(response); // use it somehow
  });
}

void listUsers(final Function callback) {
  showPleaseWait();

  _io.sendMessage("listUsers", "{}", (dataIn) {
    Map<String, dynamic> response = jsonDecode(dataIn);
    hidePleaseWait();
    callback(response);
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

  _io.sendMessage(
      "create",
      "{ \"roomName\" : \"$inRoomName\", "
          "  \"description\" : \"$inDescription\", "
          "  \"maxPeople\" : \"$inMaxPeople\", "
          "  \"private\" : \"$inPrivate\", "
          "  \"creator\" : \"$inCreator\" }", (dataIn) {
    Map<String, dynamic> response =
        jsonDecode(dataIn); // {status: "exists|created",
    // rooms: complete list of rooms with the new one if status == created}
    hidePleaseWait();
    callback(response);
  });
}

void join(
    final String inUserName, final String inRoomName, final Function callback) {
  showPleaseWait();

  _io.sendMessage(
      "join",
      "{ \"userName\" : \"$inUserName\","
          "  \"roomName\" : \"$inRoomName\" }", (dataIn) {
    Map<String, dynamic> results = jsonDecode(dataIn);
    hidePleaseWait();
    callback(results);
  });
}

void post(final String inUserName, final String inRoomName,
    final String inMessage, final Function callback) {
  showPleaseWait();

  _io.sendMessage(
      "post",
      "{ \"userName\" : \"$inUserName\","
          "  \"roomName\" : \"$inRoomName\","
          "  \"message\" : \"$inMessage\" }", (dataIn) {
    Map<String, dynamic> results = jsonDecode(dataIn);
    hidePleaseWait();
    callback(results["status"]);
  });
}

void invite(final String inviterUserName, final String invitedUserName,
    final String inRoomName, final Function callback) {
  showPleaseWait();

  _io.sendMessage(
      "invite",
      "{ \"inviterUserName\" : \"$inviterUserName\","
          "  \"roomName\" : \"$inRoomName\","
          "  \"invitedUserName\" : \"$invitedUserName\" }", (dataIn) {
    hidePleaseWait();
  });
}

void leave(
    final String inUserName, final String inRoomName, final Function callback) {
  showPleaseWait();

  _io.sendMessage(
      "leave",
      "{ \"userName\" : \"$inUserName\","
          "  \"roomName\" : \"$inRoomName\" }", (dataIn) {
    hidePleaseWait();
  });
}

void close(final String inRoomName, final Function callback) {
  showPleaseWait();

  _io.sendMessage("close", "{ \"roomName\" : \"$inRoomName\" }", (dataIn) {
    hidePleaseWait();
  });
}

void kick(
    final String inUserName, final String inRoomName, final Function callback) {
  showPleaseWait();

  _io.sendMessage(
      "kick",
      "{ \"userName\" : \"$inUserName\","
          "  \"roomName\" : \"$inRoomName\" }", (dataIn) {
    hidePleaseWait();
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
  Map<String, dynamic> payload = jsonDecode(dataIn);

  // cleanup because he will see the room
  // as closed
  chatModel.removeInvite(payload["roomName"]);
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
  Map<String, dynamic> payload = jsonDecode(dataIn);

  String roomName = payload["roomName"];
  String inviterName = payload["inviterUserName"];

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
  Map<String, dynamic> payload = jsonDecode(dataIn);
  if (chatModel.roomName == payload["roomName"]) {
    chatModel.addMessage(payload["userName"], payload["message"]);
  }
}
