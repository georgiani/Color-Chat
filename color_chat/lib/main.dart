import "package:flutter/material.dart";
import "package:scoped_model/scoped_model.dart";
import 'HomeScreen.dart';
import 'LoginDialog.dart';
import 'ModelAndServer/Model.dart';
import 'Routes/CreateRoom.dart';
import 'Routes/Lobby.dart';
import 'Routes/Room.dart';
import 'Routes/Users.dart';

void main() {
  runApp(ColorChat());
}

class ColorChat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: ColorChatBody(),
      ),
    );
  }
}

class ColorChatBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    chatModel.rootCtx = context;
    WidgetsBinding.instance.addPostFrameCallback((_) => showLogin());

    return ScopedModel<ColorChatModel>(
      model: chatModel,
      child: ScopedModelDescendant<ColorChatModel>(
        builder: (BuildContext ctx, Widget w, ColorChatModel c) {
          return MaterialApp(
            initialRoute: "/",
            routes: {
              "/Lobby" : (ctx) => Lobby(),
              "/Room" : (ctx) => Room(),
              "/Users" : (ctx) => Users(),
              "/CreateRoom" : (ctx) => CreateRoom(),
            },
            home: Home(),
          );
        },
      ),
    );
  }
}

Future<void> showLogin() async {
  await showDialog(
    context: chatModel.rootCtx,
    barrierDismissible: false,
    builder: (BuildContext dialogCtx) {
      return LoginDialog();
    }
  );
}