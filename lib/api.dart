import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const String ENDPOINT = 'https://todoapp-api.apps.k8s.gu.se';

class Todo {
  String? id;
  String title;
  String? done; // "true" eller "false"

  Todo(this.title, this.done, {this.id});

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      json['title'],
      json['done'].toString(),
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'done': done,
    };
  }
}

// Funktion för att registrera och hämta en ny API-nyckel från servern
Future<String> getApiKey() async {
  print('Försöker hämta API-nyckel...');
  final response = await http.get(Uri.parse('$ENDPOINT/register'));

  if (response.statusCode == 200) {
    print('API-nyckel hämtad: ${response.body}'); // Logga nyckeln i konsolen
    return response.body;
  } else {
    throw Exception('Misslyckades med att hämta API-nyckel');
  }
}

// Sparar API-nyckeln lokalt med SharedPreferences
Future<void> saveApiKey(String apiKey) async {
  print('Sparar API-nyckel: $apiKey'); // Logga att nyckeln sparas
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('api_key', apiKey);
  print('API-nyckel sparad.');
}

// Hämtar en sparad API-nyckel från SharedPreferences
Future<String?> getSavedApiKey() async {
  print('Försöker hämta sparad API-nyckel...');
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? apiKey = prefs.getString('api_key');
  if (apiKey != null) {
    print('Sparad API-nyckel hittad: $apiKey'); // Logga nyckeln om den finns
  } else {
    print('Ingen sparad API-nyckel hittad.');
  }
  return apiKey;
}

// Hämtar alla uppgifter från API:t med hjälp av API-nyckeln
Future<List<Todo>> getTodos(String apiKey) async {
  print(
      'Hämtar uppgifter med API-nyckel: $apiKey'); // Logga att uppgifter hämtas
  final response = await http.get(Uri.parse('$ENDPOINT/todos?key=$apiKey'));

  if (response.statusCode == 200) {
    List<dynamic> data = jsonDecode(response.body);
    print('Uppgifter hämtade: ${data.length} uppgifter.');
    // Logga status för varje uppgift
    List<Todo> todos = data.map((json) => Todo.fromJson(json)).toList();
    for (var todo in todos) {
      print(
          'Uppgift: ${todo.title}, Status: ${todo.done == "true" ? "Done" : "Undone"}');
    }
    return todos;
  } else {
    throw Exception('Misslyckades med att hämta uppgifter');
  }
}

// Skickar en ny uppgift till API:t för att lägga till den på servern
Future<void> addTodoToAPI(String apiKey, Todo todo) async {
  final todoWithoutId = {
    'title': todo.title,
    'done': todo.done,
  };

  print(
      'Lägger till uppgift: ${todo.title}, Status: ${todo.done == "true" ? "Done" : "Undone"}');
  final response = await http.post(
    Uri.parse('$ENDPOINT/todos?key=$apiKey'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode(todoWithoutId),
  );

  if (response.statusCode == 200) {
    print('Uppgift tillagd: ${todo.title}');
  } else {
    throw Exception('Misslyckades med att lägga till uppgift');
  }
}

Future<void> deleteTodoFromAPI(String apiKey, String title) async {
  final response = await http.delete(
    Uri.parse('$ENDPOINT/todos/$title?key=$apiKey'),
    headers: {'Content-Type': 'application/json'},
  );

  if (response.statusCode != 200) {
    throw Exception('Kunde inte ta bort uppgiften från servern');
  }
}

Future<void> updateTodoInAPI(String apiKey, String title, String done) async {
  final response = await http.put(
    Uri.parse('$ENDPOINT/todos?key=$apiKey'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'title': title,
      'done': done,
    }),
  );

  if (response.statusCode != 200) {
    throw Exception('Kunde inte uppdatera uppgiften på servern');
  }
}
