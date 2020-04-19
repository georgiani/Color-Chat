import 'package:color_chat/ModelAndServer/Model.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'ModelAndServer/connection.dart' as conn;

List drawerColors = [
  0xFF364156,
  0xFF485265,
  0xFF5A6374,
  0xFF6C7484,
  0xFF7F8693,
];

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModel<ColorChatModel>(
      model: chatModel,
      child: ScopedModelDescendant<ColorChatModel>(
        builder: (ctx, w, c) {
          return Drawer(
            child: Column(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    color: Color(drawerColors[0]),
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: ListTile(
                        title: Text(
                          chatModel.userName,
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        subtitle: Text(
                          chatModel.roomName == ColorChatModel.notInARoom
                              ? chatModel.roomName
                              : "Room: ${chatModel.roomName}",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    color: Color(drawerColors[1]),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: ListTile(
                        leading: Icon(Icons.list),
                        title: Text(
                          "Lobby",
                          style: TextStyle(color: Colors.white),
                        ),
                        onTap: () {
                          Navigator.of(ctx).pushNamedAndRemoveUntil(
                            "/Lobby",
                            ModalRoute.withName("/"),
                          );

                          conn.listRooms((rooms) {
                            chatModel.setRooms(rooms);
                          });
                        },
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    color: Color(drawerColors[2]),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: ListTile(
                        leading: Icon(Icons.message),
                        title: Text(
                          "Current Room",
                          style: TextStyle(color: Colors.white),
                        ),
                        onTap: () {
                          Navigator.of(ctx).pushNamedAndRemoveUntil(
                            "/Room",
                            ModalRoute.withName("/"),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    color: Color(drawerColors[3]),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: ListTile(
                        leading: Icon(Icons.people),
                        title: Text(
                          "User List",
                          style: TextStyle(color: Colors.white),
                        ),
                        onTap: () {
                          Navigator.of(ctx).pushNamedAndRemoveUntil(
                            "/Users",
                            ModalRoute.withName("/"),
                          );

                          conn.listUsers((users) {
                            chatModel.setUsers(users);
                          });
                        },
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Container(
                    color: Color(drawerColors[4]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
