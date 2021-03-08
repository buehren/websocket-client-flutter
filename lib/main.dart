import 'dart:async';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    const String _webSocketUrl = String.fromEnvironment('WS_URL', defaultValue: 'ws://echo.websocket.org/');

    return MaterialApp(
      title: 'Flutter Websocket Client',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Websocket Client', webSocketUrl: _webSocketUrl),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  final String webSocketUrl;

  MyHomePage({Key? key, required this.title, required this.webSocketUrl})
      : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  StreamController<String> _streamController = StreamController<String>();
  WebSocketChannel? _channel;
  String _lastReceivedMessage = "";
  bool _hasStartedConnect = false;

  @override
  void initState() {
    super.initState();
    _connect();
  }

  void _sendMessage() {
    _counter++;
    print("Sending message #$_counter to WebSocket sink");
    _channel?.sink.add("Message #$_counter from Flutter to WebSocket");
  }

  _wserror(err) async {
    print(new DateTime.now().toString() + " Connection error: $err");
    await _connect();
  }

  _wsdone() async {
    print(new DateTime.now().toString() + " Connection done");
    await _connect();
  }

  _connect() async {
    if (_hasStartedConnect) {
      // reconnect delay
      await Future.delayed(Duration(seconds: 4));
    }

    setState(() {
      print(new DateTime.now().toString() +
          " Starting connection attempt to " +
          widget.webSocketUrl +
          " ...");

      _channel = WebSocketChannel.connect(Uri.parse(widget.webSocketUrl));

      _hasStartedConnect = true;
    });

    _channel?.stream.listen(
        (data) {
            print("Received data: $data");
            setState(() {
              _lastReceivedMessage = data;
            });
            _streamController.add(data);
        },
        onDone: _wsdone,
        onError: _wserror,
        cancelOnError: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Last received message from ${widget.webSocketUrl}:',
            ),
            Text(
              '$_lastReceivedMessage',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _sendMessage,
        tooltip: 'Send message',
        child: Icon(Icons.send),
      ),
    );
  }
}
