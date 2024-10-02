import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const String ENDPOINT = 'https://todoapp-api.apps.k8s.gu.se';

class Todo {
  String? id;
  String title;
  String? done;

  Todo(this.title, this.done, {this.id});

  // Fabriksmetod för att skapa ett Todo-objekt från JSON-data
  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      json['title'],
      json['done'].toString(),
      id: json['id'],
    );
  }

  // Konverterar ett Todo-objekt till JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'done': done,
    };
  }
}

// Funktion för att registrera och hämta en ny API-nyckel från servern
Future<String> getApiKey() async {
  final response = await http.get(Uri.parse('$ENDPOINT/register'));

  if (response.statusCode == 200) {
    return response.body; // Returnerar API-nyckeln från svaret
  } else {
    throw Exception('Failed to get API key'); // Felhantering om det misslyckas
  }
}

// Sparar API-nyckeln lokalt med SharedPreferences
Future<void> saveApiKey(String apiKey) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('api_key', apiKey); // Spara API-nyckeln
}

// Hämtar en sparad API-nyckel från SharedPreferences
Future<String?> getSavedApiKey() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('api_key'); // Returnerar API-nyckeln om den finns
}

// Hämtar alla uppgifter från API:t med hjälp av API-nyckeln
Future<List<Todo>> getTodos(String apiKey) async {
  final response = await http.get(Uri.parse('$ENDPOINT/todos?key=$apiKey'));

  if (response.statusCode == 200) {
    List<dynamic> data = jsonDecode(response.body);
    // Konverterar varje JSON-objekt till ett Todo-objekt och returnerar en lista
    return data.map((json) => Todo.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load todos'); // Felhantering
  }
}

// Skickar en ny uppgift till API:t för att lägga till den på servern
Future<void> addTodoToAPI(String apiKey, Todo todo) async {
  // Skapa en JSON utan id, eftersom id genereras av API:t
  final todoWithoutId = {
    'title': todo.title,
    'done': todo.done,
  };

  // Skickar POST-förfrågan för att lägga till uppgiften på servern
  final response = await http.post(
    Uri.parse('$ENDPOINT/todos?key=$apiKey'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode(todoWithoutId), // Skicka Todo som JSON
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to add todo'); // Felhantering om det misslyckas
  }
}
