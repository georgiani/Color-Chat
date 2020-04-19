import 'package:color_chat/AppDrawer.dart';
import 'package:color_chat/ModelAndServer/Model.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class Users extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModel<ColorChatModel>(
      model: chatModel,
      child: ScopedModelDescendant<ColorChatModel>(
        builder: (ctx, w, c) {
          return Scaffold(
            drawer: AppDrawer(),
            appBar: AppBar(
              backgroundColor: Color(0xFFD66853),
              title: Text("User List"),
            ),
            body: GridView.builder(
              itemCount: chatModel.users.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              itemBuilder: (ctx, idx) {
                Map user = chatModel.users[idx];
                return Padding(
                  padding: const EdgeInsets.all(10),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: GridTile(
                        child: Center(
                          child: Icon(
                            Icons.person_outline,
                          ),
                        ),
                        footer: Text(
                          user["userName"],
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
