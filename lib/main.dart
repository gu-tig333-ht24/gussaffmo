import 'package:flutter/material.dart';
import 'new_task.dart';
import 'package:provider/provider.dart';
import 'api.dart'; // Import your API file

/// Model for each task
class Task {
  final String? id;
  final String title;
  bool isCompleted;

  Task(this.title, this.isCompleted, {this.id});
}

/// Provider class - manages the list of tasks and filtering
class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  String _filter = 'all';

  List<Task> get tasks => _filteredTasks();
  String get filter => _filter;

  /// Add new task to the list and the API
  Future<void> addTask(String title) async {
    // Fetch the API key
    String? apiKey = await getSavedApiKey();
    if (apiKey == null) {
      apiKey = await getApiKey();
      await saveApiKey(apiKey);
    }

    // Create and add the task to the server without id
    final newTodo = Todo(
      title,
      false.toString(), // Task starts as not done
    );

    try {
      final addedTodo = await addTodoToAPI(apiKey, newTodo); // Fetch from API
      _tasks.add(Task(addedTodo.title, addedTodo.done == 'true',
          id: addedTodo.id)); // Add with ID received from server
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to add task to the server.');
    }
  }

  /// Toggles the completion status of a task and updates the server
  Future<void> toggleComplete(int index) async {
    _tasks[index].isCompleted = !_tasks[index].isCompleted;

    // Fetch the API key
    String? apiKey = await getSavedApiKey();
    if (apiKey == null) {
      apiKey = await getApiKey();
      await saveApiKey(apiKey);
    }

    // Update the task on server
    final todoToUpdate = Todo(
      _tasks[index].title,
      _tasks[index].isCompleted ? 'true' : 'false',
      id: _tasks[index].id,
    );

    try {
      await updateTodoInAPI(apiKey, todoToUpdate);
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to update task on the server.');
    }
  }

  /// Removes task from the list and API
  Future<void> removeTask(int index) async {
    // Fetch the API key
    String? apiKey = await getSavedApiKey();
    if (apiKey == null) {
      apiKey = await getApiKey();
      await saveApiKey(apiKey);
    }

    final taskToRemove = _tasks[index];

    try {
      await deleteTodoFromAPI(apiKey, taskToRemove.id!); // Remove using ID
      _tasks.removeAt(index); // Remove locally
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to delete task from the server.');
    }
  }

  /// Sets filter for the task list
  void setFilter(String newFilter) {
    _filter = newFilter;
    notifyListeners();
  }

  /// Filters tasks based on current filter
  List<Task> _filteredTasks() {
    if (_filter == 'done') {
      return _tasks.where((task) => task.isCompleted).toList();
    } else if (_filter == 'undone') {
      return _tasks.where((task) => !task.isCompleted).toList();
    }
    return _tasks;
  }

  /// Fetches tasks from the server and updates the local list
  Future<void> fetchTasks() async {
    // Fetch the API key
    String? apiKey = await getSavedApiKey();
    if (apiKey == null) {
      apiKey = await getApiKey();
      await saveApiKey(apiKey);
    }

    try {
      // Fetch tasks from the server
      final todos = await getTodos(apiKey);

      _tasks = todos
          .map((todo) => Task(todo.title, todo.done == 'true', id: todo.id))
          .toList();
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to fetch tasks from the server.');
    }
  }
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => TaskProvider()..fetchTasks(), // Fetch tasks on start
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
                context.read<TaskProvider>().setFilter(value);
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
          itemCount: taskProvider.tasks.length,
          itemBuilder: (context, index) {
            final task = taskProvider.tasks[index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        context.read<TaskProvider>().toggleComplete(index);
                      },
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: task.isCompleted ? Colors.blue : Colors.white,
                          border: Border.all(color: Colors.black),
                        ),
                        child: Center(
                          child: task.isCompleted
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
                            task.title,
                            style: TextStyle(
                              fontSize: 25,
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              color:
                                  task.isCompleted ? Colors.grey : Colors.black,
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
                                context.read<TaskProvider>().removeTask(index);
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
            context.read<TaskProvider>().addTask(newTask);
          }
        },
        tooltip: 'Add Task',
        backgroundColor: const Color.fromARGB(255, 33, 150, 243),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
