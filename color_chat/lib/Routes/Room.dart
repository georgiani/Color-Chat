import 'package:color_chat/AppDrawer.dart';
import 'package:color_chat/Model.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:color_chat/connection.dart' as conn;

class Room extends StatefulWidget {
  @override
  _RoomState createState() => _RoomState();
}

class _RoomState extends State<Room> {
  bool _expanded = false;
  String _msg;
  final ScrollController _controller = ScrollController();
  final TextEditingController _msgController = TextEditingController();

  _inviteOrKick(final BuildContext ctx, final String option) {}

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
                      _inviteOrKick(ctx, "invite");
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
                    } else if (val == "kick") {
                      _inviteOrKick(ctx, "kick");
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
                      PopupMenuItem(
                        value: "kick",
                        child: Text("Kick User"),
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
                        color: Color(0xFFE3B505),
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
                  padding: const EdgeInsets.all(8.0),
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
                                chatModel.userName, chatModel.roomName, _msg,
                                (dataIn) {
                              if (dataIn["status"] == "ok") {
                                chatModel.addMessage(chatModel.userName, _msg);
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
