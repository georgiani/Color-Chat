import 'package:color_chat/AppDrawer.dart';
import 'package:color_chat/Model.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:color_chat/connection.dart' as conn;

class Lobby extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModel<ColorChatModel>(
      model: chatModel,
      child: ScopedModelDescendant<ColorChatModel>(
        builder: (ctx, w, c) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Color(0xFFD66853),
              title: Text("Lobby"),
            ),
            drawer: AppDrawer(),
            floatingActionButton: FloatingActionButton(
              backgroundColor: Color(0xFFC35F4C),
              child: Icon(Icons.add_box),
              onPressed: () {
                Navigator.of(ctx).pushNamed("/CreateRoom");
              },
            ),
            body: chatModel.rooms.length == 0
                ? Center(
                    child: Text("There are no rooms..."),
                  )
                : ListView.builder(
                    itemCount: chatModel.rooms.length,
                    itemBuilder: (ctx, idx) {
                      Map room = chatModel.rooms[idx];
                      String roomName = room["roomName"];

                      return ListTile(
                        leading: room["private"]
                            ? Icon(Icons.lock_outline)
                            : Icon(Icons.lock_open),
                        title: Text(roomName),
                        subtitle: Text(room["description"]),
                        onTap: () {
                          if (room["private"] &&
                              !chatModel.invites.containsKey(roomName) &&
                              room["creator"] != chatModel.userName) {
                            Scaffold.of(ctx).showSnackBar(
                              SnackBar(
                                content: Text(
                                    "You don't have invitations for this room"),
                                duration: Duration(seconds: 2),
                                backgroundColor: Color(0xFFDB504A),
                              ),
                            );
                          } else {
                            conn.join(chatModel.userName, roomName, (dataIn) {
                              if (dataIn["status"] == "joined") {
                                chatModel.setRoomName(dataIn["room"]["roomName"]);
                                chatModel.setUsers(dataIn["room"]["users"]);
                                chatModel.disEnableRoom(true);
                                chatModel.clearMessages();

                                if(dataIn["room"]["creator"] == chatModel.userName) {
                                  chatModel.setAdmin(true);
                                } else {
                                  chatModel.setAdmin(false);
                                }

                                Navigator.pushNamed(ctx, "/Room");
                              } else if (dataIn["status"] == "full") {
                                Scaffold.of(ctx).showSnackBar(
                                  SnackBar(
                                    backgroundColor: Color(0xFFDB504A),
                                    duration: Duration(seconds: 2),
                                    content: Text("This room is full."),
                                  ),
                                );
                              }
                            });
                          }
                        },
                      );
                    },
                  ),
          );
        },
      ),
    );
  }
}
