import 'package:color_chat/ModelAndServer/Model.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'AppDrawer.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModel<ColorChatModel>(
      model: chatModel,
      child: ScopedModelDescendant<ColorChatModel>(
        builder: (BuildContext ctx, Widget w, ColorChatModel c) {
          return Scaffold(
            drawer: AppDrawer(),
            appBar: AppBar(
              backgroundColor: Color(0xFFD66853),
              title: Text("Color Chat"),
            ),
            body: Center(
              child: Text(
                chatModel.welcomeMsg,
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
