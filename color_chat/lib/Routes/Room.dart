import 'package:color_chat/AppDrawer.dart';
import 'package:color_chat/ModelAndServer/Model.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:color_chat/ModelAndServer/connection.dart' as conn;

class Room extends StatefulWidget {
  @override
  _RoomState createState() => _RoomState();
}

class _RoomState extends State<Room> {
  String _msg;
  final ScrollController _controller = ScrollController();
  final TextEditingController _msgController = TextEditingController();

  inviteUser(final BuildContext ctx) {
    conn.listUsers((users) {
      chatModel.setUsers(users);
      showDialog(
          context: chatModel.rootCtx,
          builder: (dialogCtx) {
            return ScopedModel<ColorChatModel>(
              model: chatModel,
              child: ScopedModelDescendant<ColorChatModel>(
                builder: (ctx, w, c) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: Text("Select user to invite"),
                    content: Container(
                      width: double.maxFinite,
                      height: double.maxFinite / 2,
                      child: ListView.builder(
                        itemCount: chatModel.users.length,
                        itemBuilder: (listCtx, idx) {
                          var user = chatModel.users[idx];

                          if (user["userName"] ==
                              chatModel.userName) // if it's me
                          {
                            return Container(); // nothing
                          }

                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(width: 1, color: Colors.black),
                            ),
                            child: GestureDetector(
                              child: Center(
                                child: Text(
                                  user["userName"],
                                  style: TextStyle(fontSize: 15),
                                ),
                              ),
                              onTap: () {
                                conn.invite(chatModel.userName, user["userName"], chatModel.roomName, () {
                                  Navigator.of(ctx).pop();
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            );
          });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<ColorChatModel>(
      model: chatModel,
      child: ScopedModelDescendant<ColorChatModel>(
        builder: (ctx, w, c) {
          return Scaffold(
            resizeToAvoidBottomPadding: false,
            drawer: AppDrawer(),
            appBar: AppBar(
              backgroundColor: Color(0xFFD66853),
              title: Text(chatModel.roomName),
              actions: [
                PopupMenuButton(
                  onSelected: (val) {
                    if (val == "invite") {
                      inviteUser(ctx);
                    } else if (val == "leave") {
                      conn.leave(chatModel.userName, chatModel.roomName, () {
                        chatModel.removeInvite(chatModel.roomName);
                        chatModel.setUsers({});
                        chatModel.setRoomName(ColorChatModel.notInARoom);
                        chatModel.disEnableRoom(false);
                        Navigator.of(ctx).pushNamedAndRemoveUntil(
                            "/", ModalRoute.withName("/"));
                      });
                    } else if (val == "close") {
                      conn.close(chatModel.roomName, () {
                        Navigator.of(ctx).pushNamedAndRemoveUntil(
                            "/", ModalRoute.withName("/"));
                      });
                    }
                  },
                  itemBuilder: (popupCtx) {
                    return <PopupMenuEntry<String>>[
                      PopupMenuItem(
                        value: "leave",
                        child: Text("Leave Room"),
                      ),
                      PopupMenuItem(
                        value: "invite",
                        child: Text("Invite User"),
                      ),
                      PopupMenuDivider(),
                      PopupMenuItem(
                        value: "close",
                        child: Text("Close Room"),
                        enabled: chatModel.admin,
                      ),
                    ];
                  },
                ),
              ],
            ),
            body: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _controller,
                    itemCount: chatModel.messages.length,
                    itemBuilder: (msgCtx, idx) {
                      Map msg = chatModel.messages[idx];
                      return Container(
                        color: msg["color"],
                        child: ListTile(
                          subtitle: Text(msg["userName"]),
                          title: Text(msg["message"]),
                        ),
                      );
                    },
                  ),
                ),
                Divider(),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    children: [
                      Flexible(
                        child: TextField(
                          controller: _msgController,
                          onChanged: (String s) {
                            setState(() {
                              _msg = s;
                            });
                          },
                          decoration: InputDecoration.collapsed(
                            hintText: "Enter Message",
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(2, 0, 2, 0),
                        child: IconButton(
                          icon: Icon(Icons.send),
                          color: Color(0xFFD66853),
                          onPressed: () {
                            conn.post(
                                chatModel.userName, chatModel.roomName, _msg, chatModel.chatColor,
                                (dataIn) {
                              if (dataIn["status"] == "ok") {
                                chatModel.addMessage(chatModel.userName, _msg, chatModel.chatColor);
                                _controller.jumpTo(
                                  _controller.position.maxScrollExtent,
                                );
                                _msgController.text = "";
                              }
                            });
                          },
                        ),
                      ),
                    ],
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
