import 'dart:convert';
import 'dart:ffi';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:todolist/addtask.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List items = [];
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    final response = await http
        .get(Uri.parse('https://api.nstack.in/v1/todos?page=1&limit=10'));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map;
      final result = json['items'] as List;
      setState(() {
        items = result;
      });
    }
  }

  bool select = false;
  TextEditingController taskadd = TextEditingController();
  TextEditingController desadd = TextEditingController();
  int count = 0;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepPurpleAccent.shade200,
          title: const Text('T O D O L I S T'),
          centerTitle: true,
        ),
        body: RefreshIndicator(
          onRefresh: getData,
          child: FutureBuilder(
            future: getData(),
            builder: (context, snapshot) {
              return ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index] as Map;
                  final id = item['_id'] as String;
                  return Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.deepPurple.shade200,
                          borderRadius: BorderRadius.circular(10)),
                      height: 60,
                      child: ListTile(
                        leading: Padding(
                          padding:
                              const EdgeInsets.only(bottom: 10.0, right: 10),
                          child: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text('${index + 1}'),
                            ),
                          ),
                        ),
                        title: Text(item['title']),
                        subtitle: Text(item['description']),
                        trailing: Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: InkWell(
                            onTap: () {
                              deleteTodo(id);
                            },
                            child: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                color: Colors.red.shade500,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.delete),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.deepPurpleAccent.shade200,
          shape: const RoundedRectangleBorder(),
          onPressed: () {
            // Navigator.push(context, MaterialPageRoute(builder: (context) => AddTask(),));
            showDialog(
              context: context,
              builder: (ctx) => Dialog(
                backgroundColor: Colors.white,
                child: Container(
                  height: 300,
                  width: 400,
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'A D D T A S K !',
                          style: TextStyle(color: Colors.black, fontSize: 20),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Form(
                          child: Column(
                            children: [
                              TextFormField(
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
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  // for adding the task to screen we use post api
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
        body: jsonEncode(body), headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 201) {
      taskadd.text = '';
      desadd.text = '';
      showMessage('Creation success');
    } else {
      showErrorMessage('Creation failed');
    }
  }

  Future<void> deleteTodo(String id) async {
    final url = 'https://api.nstack.in/v1/todos/$id';
    final uri = Uri.parse(url);
    final response = await http.delete(uri);
    if (response.statusCode == 200) {
      final filterd = items.where((element) => ['_id'] != id).toList();
      setState(() {
        items = filterd;
      });
    } else {}
  }

  void showMessage(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.green,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showErrorMessage(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
