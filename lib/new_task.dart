import 'package:flutter/material.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  _AddTaskPageState createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TextEditingController _controller = TextEditingController();

  void _addTask() {
    String newTask = _controller.text;
    if (newTask.isNotEmpty) {
      Navigator.pop(context, newTask);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'To-Do List',
          style: TextStyle(fontSize: 40),
        ),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'Add task',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey,
                      ),
                    ),
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 20),
                  ),
                  onSubmitted: (value) {
                    _addTask();
                  },
                ),
              ],
            ),
          ),
          Positioned(
              top: 80,
              child: FloatingActionButton.extended(
                onPressed: _addTask,
                backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                icon: const Icon(
                  Icons.add,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
                label: const Text(
                  'ADD',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
