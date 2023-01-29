import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddTask extends StatefulWidget {
  const AddTask({Key? key}) : super(key: key);

  @override
  State<AddTask> createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  TextEditingController taskadd = TextEditingController();
  TextEditingController desadd = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent.shade200,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'ADD YOUR TASK',
            style: TextStyle(fontSize: 25),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                TextFormField(
                  keyboardType: TextInputType.multiline,
                  maxLines: 8,
                  minLines: 5,
                  controller: taskadd,
                  decoration: InputDecoration(
                      hintText: 'Add Task',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      )),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: desadd,
                  decoration: InputDecoration(
                      hintText: 'Add Description',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      )),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        submitData();
                      },
                      child: const Text('ADD'),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.deepPurpleAccent.shade200,
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> submitData() async {
    final titles = taskadd.text;
    final desc = desadd.text;
    final body = {
      "title": titles,
      "description": desc,
      "is_completed": false,
    };
    final url = 'http://api.nstack.in/v1/todos';
    final uri = Uri.parse(url);
    final response = await http.post(uri,
        body: jsonEncode(body),
        headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 201) {
      taskadd.text = '';
      desadd.text = '';
      showMessage('Creation success');
    } else {
      print('error');
    }
  }

  void showMessage(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
