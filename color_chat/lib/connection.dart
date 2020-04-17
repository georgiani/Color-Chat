import 'package:color_chat/Model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';

String serverURL = "http://192.168.9.42";
SocketIO _io;

void showPleaseWait() {
  showDialog(
    // it needs to display on the root context
    // because that's over all the other widgets
    context: chatModel.rootCtx, 
    barrierDismissible: false,
    builder: (BuildContext dialogCtx) {
      return Dialog(
        child: Container(
          width: 150,
          height: 150,
          alignment: AlignmentDirectional.center,
          decoration: BoxDecoration(
            color: Colors.blue,
          ),
          child: Column(
            children: [
              Center(
                child: CircularProgressIndicator(
                  value: null,
                  strokeWidth: 10,
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                  top: 20,
                ),
                child: Center(
                  child: Text(
                    "Please wait...",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  );
}

void hidePleaseWait() {
  Navigator.of(chatModel.rootCtx).pop(); // pop the dialog
}

void connectToServer(final BuildContext mainCtx, final Function callback) {
  _io = SocketIOManager().createSocketIO(
    serverURL,
    "/",
    query: "",
    socketStatusCallback: (dataIn) {
      if (dataIn == "connect") {
        _io.subscribe("newUser", newUser);
        _io.subscribe("created", created);
        _io.subscribe("closed", closed);
        _io.subscribe("joined", joined);
        _io.subscribe("left", left);
        _io.subscribe("kicked", kicked);
        _io.subscribe("invited", invited);
        _io.subscribe("posted", posted);
        callback();
      }
    }
  );
  _io.init();
  _io.connect();
}