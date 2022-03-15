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

  //
  final TaskStack _undoStack = TaskStack();

  final TextEditingController _textFieldController = TextEditingController();

  late Timer timer;
  @override

  //refreshes the list once a second
  void initState() {
    super.initState();
    timer = Timer.periodic(
        const Duration(seconds: 1), (Timer t) => setState(() {}));
  }

  //removes timer when app is quit
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Tasks')),
        body: ListView(children: _getItems()),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
                onPressed: () => _undo(),
                tooltip: 'Undo Completion',
                child: Icon(Icons.undo)),
            SizedBox(height: 10),
            FloatingActionButton(
                onPressed: () => _displayDialog(context),
                tooltip: 'Add Item',
                child: Icon(Icons.add))
          ],
        ));
  }

  void _addTask(Task t) {
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
      Task t = _undoStack.pop();
      _completedList.remove(t);
      _todoList.add(t);
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

  Future<void> _displayDialog(BuildContext context) async {
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Add a task to your list'),
            content: TextField(
              controller: _textFieldController,
              decoration: const InputDecoration(hintText: 'Enter task here'),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('ADD'),
                onPressed: () {
                  Navigator.of(context).pop();
                  _addTask(Task.withoutNotes(_textFieldController.text));
                },
              ),
              TextButton(
                child: const Text('CANCEL'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
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
