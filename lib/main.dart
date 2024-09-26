import 'package:flutter/material.dart';
import 'ny_uppgift.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class TaskProvider extends ChangeNotifier {
  final List<Aktivitet> _aktiviteter = [];

  List<Aktivitet> get aktiviteter => _aktiviteter;

  void addAktivitet(String syssla) {
    _aktiviteter.add(Aktivitet(syssla, false));
    notifyListeners();
  }

  void toggleComplete(int index) {
    _aktiviteter[index].isCompleted = !_aktiviteter[index].isCompleted;
    notifyListeners();
  }

  void removeAktivitet(int index) {
    _aktiviteter.removeAt(index);
    notifyListeners();
  }
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => TaskProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class Aktivitet {
  final String syssla;
  bool isCompleted;

  Aktivitet(this.syssla, this.isCompleted);
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String filter = 'all'; // För att hålla koll på valt filter

  // Metod för att filtrera aktiviteter baserat på filtret
  List<Aktivitet> _filteredTasks(List<Aktivitet> aktiviteter) {
    if (filter == 'done') {
      return aktiviteter.where((aktivitet) => aktivitet.isCompleted).toList();
    } else if (filter == 'undone') {
      return aktiviteter.where((aktivitet) => !aktivitet.isCompleted).toList();
    }
    return aktiviteter; // Returnera alla uppgifter om filter är 'all'
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'To-Do List',
          style: TextStyle(fontSize: 40),
          textAlign: TextAlign.center,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: PopupMenuButton<String>(
              onSelected: (value) {
                setState(() {
                  filter = value; // Uppdatera filtret baserat på valet
                });
              },
              itemBuilder: (BuildContext context) {
                return ['All', 'Done', 'Undone'].map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice.toLowerCase(),
                    child: Text(choice),
                  );
                }).toList();
              },
              icon: const Icon(
                Icons.menu,
                size: 35,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 18, top: 15),
        child: ListView.builder(
          itemCount: _filteredTasks(taskProvider.aktiviteter)
              .length, // Använd filtrerade uppgifter
          itemBuilder: (context, index) {
            final aktivitet = _filteredTasks(taskProvider.aktiviteter)[index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        taskProvider.toggleComplete(index);
                      },
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: aktivitet.isCompleted
                              ? Colors.blue
                              : Colors.white,
                          border: Border.all(color: Colors.black),
                        ),
                        child: Center(
                          child: aktivitet.isCompleted
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 24,
                                )
                              : const SizedBox.shrink(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            aktivitet.syssla,
                            style: TextStyle(
                              fontSize: 25,
                              decoration: aktivitet.isCompleted
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              color: aktivitet.isCompleted
                                  ? Colors.grey
                                  : Colors.black,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.black,
                                size: 30,
                              ),
                              onPressed: () {
                                taskProvider.removeAktivitet(index);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newTask = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTaskPage()),
          );

          if (newTask != null && newTask.isNotEmpty) {
            taskProvider.addAktivitet(newTask);
          }
        },
        tooltip: 'Lägg till uppgift',
        backgroundColor: const Color.fromARGB(255, 33, 150, 243),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
