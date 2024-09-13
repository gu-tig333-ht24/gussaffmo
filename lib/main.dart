import 'package:flutter/material.dart';
import 'ny_uppgift.dart';

void main() {
  runApp(MyApp());
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
  final bool isCompleted;

  Aktivitet(this.syssla, this.isCompleted);
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Aktivitet> aktiviteter = [
    Aktivitet('Städa rum', true),
    Aktivitet('Äta mat', false),
    Aktivitet('Träna', true),
    Aktivitet('Läsa bok', false),
    Aktivitet('Träffa kungen', false),
    Aktivitet('Tvätta kläder', false),
    Aktivitet('Städa badrum', false),
    Aktivitet('Bli biljonär', false),
    Aktivitet('Laga mat', false),
    Aktivitet('Gå på bio', false),
    Aktivitet('Hoppa fallskärm', false),
    Aktivitet('Besöka en vän', false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Stack(
          children: [
            const Center(
              child: Text(
                'To-Do List',
                style: TextStyle(
                  fontSize: 40,
                ),
              ),
            ),
            Positioned(
              child: Align(
                alignment: Alignment.centerRight,
                child: PopupMenuButton<String>(
                  onSelected: (value) {},
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem<String>(
                      value: 'all',
                      child: Text('All'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'done',
                      child: Text('Done'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'undone',
                      child: Text('Undone'),
                    ),
                  ],
                  icon: const Icon(
                    Icons.menu,
                    size: 50,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 18, top: 15),
        child: ListView.builder(
          itemCount: aktiviteter.length,
          itemBuilder: (context, index) {
            final aktivitet = aktiviteter[index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            aktivitet.isCompleted ? Colors.blue : Colors.white,
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
                    const SizedBox(width: 10),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            aktivitet.syssla,
                            style: const TextStyle(fontSize: 25),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(right: 20),
                            child: Icon(
                              Icons.close,
                              color: Colors.black,
                              size: 30,
                            ),
                          )
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
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTaskPage()),
          );
        },
        tooltip: 'Lägg till uppgift',
        backgroundColor: const Color.fromARGB(255, 33, 150, 243),
        foregroundColor: Colors.white,
        child: Icon(Icons.add),
      ),
    );
  }
}
