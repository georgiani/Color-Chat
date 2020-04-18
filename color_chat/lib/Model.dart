import 'dart:io';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class ColorChatModel extends Model {
  BuildContext rootCtx; // used for dialogs
  Directory docsDir;
  String welcomeMsg = "Welcome to ColorChat";
  
  // reffered to user using the client
  String userName = "";
  Map invites = {};

  // all of these refer to the current room
  String roomName = notInARoom;
  bool roomEnabled = false;
  List roomUsers = [];
  List messages;
  bool admin;
  
  // lists for this session
  List users;
  List rooms;

  // static things
  static final String notInARoom = "Not currently in a room";

  // methods
  void setUserName(String inUserName) {
    this.userName = inUserName;
    notifyListeners();
  }

  void setRoomName(String inRoomName) {
    this.roomName = inRoomName;
    notifyListeners();
  }

  void setWelcomeMsg(String s) {
    this.welcomeMsg = s;
    notifyListeners();
  }

  void setAdmin(bool state) {
    this.admin = state;
    notifyListeners();
  }

  void disEnableRoom(bool state) {
    this.roomEnabled = state;
    notifyListeners();
  }

  void addMessage(final String inUser, final String inMsg) {
    this.messages.add({"userName": inUser, "message": inMsg});
    notifyListeners();
  }

  void setRooms(final Map inRoomsList) {
    List tmpRooms = [];

    for (String r in inRoomsList.keys) {
      tmpRooms.add(inRoomsList[r]);
    }

    this.rooms = tmpRooms;
    notifyListeners();
  }

  void setUsers(final Map inUsersList) {
    List tmpUsers = [];

    for (String u in inUsersList.keys) {
      tmpUsers.add(inUsersList[u]);
    }

    this.users = tmpUsers;
    notifyListeners();
  }

  void addInvite(final String inRoomName) {
    this.invites[inRoomName] = true; // now the user
    // can access the specified room
    notifyListeners();
  }

  void removeInvite(final String inRoomName) {
    this.invites.remove(inRoomName);
    notifyListeners();
  }

  void clearMessages() {
    this.messages = [];
  }
}

ColorChatModel chatModel = ColorChatModel();