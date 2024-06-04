import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:valtr3/details.dart';
import 'dart:convert';

import 'package:valtr3/matches.dart';

void main() {
  runApp(const ValTR());
}

class ValTR extends StatelessWidget {
  const ValTR({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: const ValTRLogin(),
      initialRoute: '/',
      routes: {
        '/matches': (context) => const ValTRMatches(),
        '/details': (context) => const ValTRDetails(),
      },
    );
  }
}

class ValTRLogin extends StatefulWidget {
  const ValTRLogin({super.key});

  @override
  State<ValTRLogin> createState() => _ValTRLoginState();
}

class _ValTRLoginState extends State<ValTRLogin> {
  TextEditingController textController1 = TextEditingController();
  TextEditingController textController2 = TextEditingController();

  @override
  void dispose() {
    textController1.dispose();
    textController2.dispose();
    super.dispose();
  }

  void getInfos() {
    String username = textController1.text;
    String tag = textController2.text;
    http.get(Uri.parse('https://api.henrikdev.xyz/valorant/v1/account/$username/$tag')).then((response) {
      if (response.statusCode == 200) {
        var valorant = json.decode(response.body);
        Navigator.pushNamed(context, '/matches', arguments: valorant);
      } else {
        textController1.text = "Error";
        textController2.text = "";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Center(child: Text('ValTR'))),
      body: Column(
        children: [
          const SizedBox(height: 200),
          const Text('Please fill your details.'),
          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(child: TextField(controller: textController1, decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Username'))),
              const Text('#'),
              Expanded(child: TextField(controller: textController2, decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Tag'))),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: getInfos, child: const Text('Submit'))
        ],
      ),
    );
  }
}
