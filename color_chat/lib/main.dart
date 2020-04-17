import "dart:io";
import "package:path/path.dart";
import "package:path_provider/path_provider.dart";
import "package:flutter/material.dart";
import "package:scoped_model/scoped_model.dart";
import 'HomeScreen.dart';
import 'LoginDialog.dart';
import 'Model.dart';

var credentials;
var exists;

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  start() async {
    chatModel.docsDir = await getApplicationDocumentsDirectory();

    // credentials = username and password
    var credentialsFile = File(join(chatModel.docsDir.path, "credentials"));
    exists = await credentialsFile.exists();

    if (exists) {
      credentials = await credentialsFile.readAsString();
    }

    runApp(ColorChat());
  }

  start();
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
    WidgetsBinding.instance.addPostFrameCallback((_) => executeAfterBuild());
    return ScopedModel<ColorChatModel>(
      model: chatModel,
      child: ScopedModelDescendant<ColorChatModel>(
        builder: (BuildContext ctx, Widget w, ColorChatModel c) {
          return MaterialApp(
            initialRoute: "/",
            // routes: {
            //   "/Lobby" : (ctx) => Lobby(),
            //   "/Room" : (ctx) => Room(),
            //   "/Users" : (ctx) => Users(),
            //   "/CreateRoom" : (ctx) => CreateRoom(),
            // },
            home: Home(),
          );
        },
      ),
    );
  }
}

Future<void> executeAfterBuild() async {
  if (exists) {
    List credentialsParts = credentials.split(",");
    LoginDialog().validateWithAlreadyStoredCredentials(credentialsParts[0],
      credentialsParts[1]);
  } else {
    await showDialog(
      context: chatModel.rootCtx,
      barrierDismissible: false,
      builder: (BuildContext dialogCtx) {
        return LoginDialog();
      }
    );
  }
}