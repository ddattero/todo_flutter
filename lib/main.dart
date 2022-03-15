import 'package:flutter/material.dart';
import 'dart:async';
import 'task.dart';
import 'taskStack.dart';

void main() {
  runApp(Todo());
}

class Todo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: TaskList());
  }
}

class TaskList extends StatefulWidget {
  @override
  _TaskListState createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  //stores tasks that arent complete
  final List<Task> _todoList = <Task>[];

  /*
  stores completed tasks
  completed tasks are removed after 30 seconds of being completed
  */
  final List<Task> _completedList = <Task>[];

  //stack to store tasks changed to completed
  final TaskStack _undoStack = TaskStack();

  final TextEditingController _textFieldController = TextEditingController();

  late Timer timer;

  //refreshes the list once a second
  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(
        const Duration(seconds: 1), (Timer t) => setState(() {}));
  }

  //removes timer when app is quit
  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      body: Column(children: [
        Expanded(child: ListView(children: _getItems())),
        Container(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
            child: TextField(
                controller: _textFieldController,
                decoration: InputDecoration(
                    fillColor: Colors.white,
                    hintText: "Task title",
                    suffixIcon: IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        _addTask(_textFieldController.text);
                      },
                    ))))
      ]),
      floatingActionButton: FloatingActionButton(
          onPressed: () => _undo(),
          tooltip: 'Undo Completion',
          child: const Icon(Icons.undo)),
    );
  }

  void _addTask(String title) {
    print(title);
    if (title.isEmpty) {
      return;
    }
    Task t = Task.withoutNotes(title);
    setState(() {
      _todoList.add(t);
    });
    _textFieldController.clear();
  }

  void _addCompleted(Task t) {
    setState(() {
      _completedList.add(t);
      _undoStack.push(t);
    });
  }

  void _undo() {
    setState(() {
      if (_undoStack.size() > 0) {
        Task t = _undoStack.pop();
        _completedList.remove(t);
        _todoList.add(t);
      }
    });
  }

  void _setTask(Task t, bool? newStatus) {
    if (newStatus != t.status) {
      if (t.status) {
        t.uncomplete();
        _completedList.remove(t);
        _undoStack.remove(t);
        _todoList.add(t);
      } else {
        t.complete();
        _todoList.remove(t);
        _completedList.add(t);
        _undoStack.push(t);
      }
    }
  }

  Widget _buildTask(Task t) {
    var bgcolor = Colors.white;
    if (t.status) {
      bgcolor = Colors.grey;
    }

    return CheckboxListTile(
      title: Text(t.title),
      tileColor: bgcolor,
      value: t.status,
      onChanged: (bool? newVal) {
        setState(() {
          _setTask(t, newVal);
        });
      },
    );
  }

  List<Widget> _getItems() {
    final List<Widget> _todoWidgets = <Widget>[];

    _todoList.sort(((a, b) => a.timeAdded.compareTo(b.timeAdded)));
    _completedList
        .sort(((a, b) => a.timeCompleted!.compareTo(b.timeCompleted!)));

    _removeExpiredCompleted();

    for (Task t in _todoList) {
      _todoWidgets.add(_buildTask(t));
    }

    for (Task t in _completedList) {
      _todoWidgets.add(_buildTask(t));
    }

    return _todoWidgets;
  }

  void _removeExpiredCompleted() {
    int secondsForExpire = 10;
    List<Task> toRemove = <Task>[];

    for (Task t in _completedList) {
      final diff = DateTime.now().difference(t.timeCompleted!);
      if (diff.inSeconds >= secondsForExpire) {
        toRemove.add(t);
      }
    }

    for (Task t in toRemove) {
      _completedList.remove(t);
    }
  }
}
