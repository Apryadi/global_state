import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

/// GlobalState: menyimpan daftar penghitung
class GlobalState {
  static final GlobalState _instance = GlobalState._internal();
  
  factory GlobalState() => _instance;
  
  GlobalState._internal();

  List<Counter> counters = [];
}

class Counter {
  int value;
  String label;
  Color color;

  Counter({
    this.value = 0, 
    this.label = 'Counter', 
    Color? color,
  }) : color = color ?? Colors.primaries[GlobalState().counters.length % Colors.primaries.length];
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Global State Test',
      home: CounterListPage(),
    );
  }
}

class CounterListPage extends StatefulWidget {
  const CounterListPage({Key? key}) : super(key: key);

  @override
  _CounterListPageState createState() => _CounterListPageState();
}

class _CounterListPageState extends State<CounterListPage> {
  final GlobalState globalState = GlobalState();

  void _addCounter() {
    setState(() {
      globalState.counters.add(Counter());
    });
  }

  void _removeCounter(int index) {
    setState(() {
      globalState.counters.removeAt(index);
    });
  }

  void _updateOrder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final counter = globalState.counters.removeAt(oldIndex);
      globalState.counters.insert(newIndex, counter);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter List'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ReorderableListView(
              onReorder: _updateOrder,
              children: [
                for (int i = 0; i < globalState.counters.length; i++)
                  CounterTile(
                    key: ValueKey(i),
                    index: i,
                    counter: globalState.counters[i],
                    onRemove: _removeCounter,
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _addCounter,
              child: const Text('Add Counter'),
            ),
          ),
        ],
      ),
    );
  }
}

class CounterTile extends StatelessWidget {
  final int index;
  final Counter counter;
  final Function(int) onRemove;

  const CounterTile({
    required Key key,
    required this.index,
    required this.counter,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      key: ValueKey(index),
      margin: const EdgeInsets.symmetric(
        vertical: 8.0, 
        horizontal: 16.0,
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: counter.color,
          child: Text('${counter.value}'),
        ),
        title: Text(counter.label),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: () {
                counter.value--;
                (context as Element).markNeedsBuild();
              },
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                counter.value++;
                (context as Element).markNeedsBuild();
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => onRemove(index),
            ),
          ],
        ),
        onTap: () {
          _showEditDialog(context);
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    TextEditingController labelController = TextEditingController(
      text: counter.label,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Counter'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: labelController,
              decoration: const InputDecoration(
                labelText: 'Label',
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: Colors.primaries
                  .map((color) => GestureDetector(
                        onTap: () {
                          counter.color = color;
                          Navigator.pop(context);
                          (context as Element).markNeedsBuild();
                        },
                        child: CircleAvatar(backgroundColor: color),
                      ))
                  .toList(),
            )
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              counter.label = labelController.text;
              Navigator.pop(context);
              (context as Element).markNeedsBuild();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}