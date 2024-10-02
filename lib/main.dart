import 'package:flutter/material.dart';
import 'new_task.dart';
import 'package:provider/provider.dart';
import 'api.dart'; // Importera din api-fil

// Modellen för varje aktivitet
class Aktivitet {
  final String syssla;
  bool isCompleted;

  Aktivitet(this.syssla, this.isCompleted);
}

// Provider-klassen som hanterar listan av aktiviteter och filtrering
class AktivitetProvider with ChangeNotifier {
  List<Aktivitet> _aktiviteter = [];
  String _filter = 'all';

  List<Aktivitet> get aktiviteter => _filteredTasks();
  String get filter => _filter;

  void addTask(String syssla) async {
    // Hämta API-nyckeln
    String? apiKey = await getSavedApiKey();
    if (apiKey == null) {
      apiKey = await getApiKey();
      await saveApiKey(apiKey);
    }

    // Skapa och lägg till uppgiften på servern
    final newTodo = Todo(
      syssla,
      'false',
    );

    await addTodoToAPI(apiKey, newTodo);

    // Uppdatera den lokala listan
    _aktiviteter.add(Aktivitet(syssla, false));
    notifyListeners();
  }

  void toggleComplete(int index) {
    _aktiviteter[index].isCompleted = !_aktiviteter[index].isCompleted;
    notifyListeners();
  }

  void removeTask(int index) {
    _aktiviteter.removeAt(index);
    notifyListeners();
  }

  void setFilter(String newFilter) {
    _filter = newFilter;
    notifyListeners();
  }

  List<Aktivitet> _filteredTasks() {
    if (_filter == 'done') {
      return _aktiviteter.where((aktivitet) => aktivitet.isCompleted).toList();
    } else if (_filter == 'undone') {
      return _aktiviteter.where((aktivitet) => !aktivitet.isCompleted).toList();
    }
    return _aktiviteter;
  }

  Future<void> fetchTasks() async {
    // Hämta API-nyckeln
    String? apiKey = await getSavedApiKey();
    if (apiKey == null) {
      apiKey = await getApiKey();
      await saveApiKey(apiKey);
    }

    // Hämta uppgifter från servern
    final todos = await getTodos(apiKey);

    // Uppdatera lokala listan
    _aktiviteter = todos
        .map((todo) => Aktivitet(todo.title, todo.done == 'true'))
        .toList();
    notifyListeners();
  }
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) =>
          AktivitetProvider()..fetchTasks(), // Hämta uppgifter vid start
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

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final aktivitetProvider = context.watch<AktivitetProvider>();

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
                context.read<AktivitetProvider>().setFilter(value);
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
          itemCount: aktivitetProvider.aktiviteter.length,
          itemBuilder: (context, index) {
            final aktivitet = aktivitetProvider.aktiviteter[index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        context.read<AktivitetProvider>().toggleComplete(index);
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
                                context
                                    .read<AktivitetProvider>()
                                    .removeTask(index);
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
            context.read<AktivitetProvider>().addTask(newTask);
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
