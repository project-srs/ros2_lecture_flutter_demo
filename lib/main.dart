import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'API Access Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var ws_channel =
      WebSocketChannel.connect(Uri.parse('ws://localhost:8010/mode'));
  var ip_text = "";

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
            Container(
              width: double.infinity,
              child: TextField(
                onChanged: (value){
                  ip_text = value;
                },
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                setState(() {
                  ws_channel = WebSocketChannel.connect(Uri.parse('ws://$ip_text:8010/mode'));
                });
              },
              child: const Text('connect'),
            ),
            StreamBuilder(
              stream: ws_channel.stream,
              builder: (context, snapshot) {
                var modeText = "not connect";
                if (snapshot.hasData) {
                  var jsonData = jsonDecode(snapshot.data);
                  modeText = 'mode: ' + jsonData['name'];
                }
                return Text(modeText);
              },
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final response = await http.post(
                    Uri.http('$ip_text:8010', '/mode'),
                    headers: <String, String>{
                      'Content-Type': 'application/json; charset=UTF-8',
                    },
                    body: jsonEncode(<String, String>{
                      'name': "Manual",
                      'comment': "manual by app"
                    }));
                print("response: " + response.body);
              },
              child: const Text('Manual Mode'),
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final response = await http.post(
                    Uri.http('$ip_text:8010', '/mode'),
                    headers: <String, String>{
                      'Content-Type': 'application/json; charset=UTF-8',
                    },
                    body: jsonEncode(<String, String>{
                      'name': "Hold",
                      'comment': "manual by app"
                    }));
                print("response: " + response.body);
              },
              child: const Text('Hold Mode'),
            ),
          ],
        ),
      ),
    );
  }
}