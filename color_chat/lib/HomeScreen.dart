import 'package:color_chat/Model.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModel<ColorChatModel>(
      model: chatModel,
      child: ScopedModelDescendant<ColorChatModel> (
        builder: (BuildContext ctx, Widget w, ColorChatModel c) {
          return Scaffold(
            drawer: Drawer(),
            appBar: AppBar(
              title: Text("Color Chat"),
            ),
            body: Center(
              child: Text(chatModel.welcomeMsg),
            ),
          );
        },
      ),
    );
  }
}