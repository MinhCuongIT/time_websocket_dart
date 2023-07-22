import 'dart:async';
import 'dart:io';

import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_web_socket/shelf_web_socket.dart' as ws;
import 'package:web_socket_channel/web_socket_channel.dart';

void execute() {
  // Create a WebSocket handler that will be called for each new connection.
  var handler = ws.webSocketHandler(handleWebSocket);

  // Create a Shelf handler for handling normal HTTP requests.
  var shelfHandler = const shelf.Pipeline().addHandler(handler);

  // Create and start the server.
  var port = 8081;
  io.serve(shelfHandler, InternetAddress.anyIPv4, port).then((server) {
    print('Serving at ws://${server.address.host}:${server.port}');
  });
}

void handleWebSocket(WebSocketChannel webSocket) {
  print('Client connected.');

  // Create a periodic timer to send the current date and time to the client every second.
  Timer.periodic(Duration(seconds: 1), (timer) {
    var dateTimeNow = DateTime.now().toIso8601String();
    webSocket.sink.add(dateTimeNow);
  });

  // Listen for incoming messages from the client (optional).
  webSocket.stream.listen((message) {
    print('Received message: $message');
  }, onDone: () {
    print('Client disconnected.');
  });
}
