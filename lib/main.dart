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

  //layout of main page
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

  //adds task to the list if it is a valid title for a task
  void _addTask(String title) {
    if (title.isEmpty) {
      return;
    }
    Task t = Task.withoutNotes(title);
    setState(() {
      _todoList.add(t);
    });
    _textFieldController.clear();
  }

  //adds the given task to the complete list as well as the
  //undo stack
  void _addCompleted(Task t) {
    setState(() {
      _completedList.add(t);
      _undoStack.push(t);
    });
  }

  //NOT CURRENTLY WORKING
  //if there is anything in the stack then the top item
  //is popped and that task is removed from completed and
  //added to the todo
  void _undo() {
    setState(() {
      if (_undoStack.size() > 0) {
        Task t = _undoStack.pop();
        _completedList.remove(t);
        _todoList.add(t);
      }
    });
  }

  //changes of the status of the given task to the new status
  void _setTask(Task t, bool? newStatus) {
    if (newStatus != t.status) {
      if (t.status) {
        //makes task not complete and removes it from the completed list
        //and the undo stack and adds it to the todo list
        t.uncomplete();
        _completedList.remove(t);
        _undoStack.remove(t);
        _todoList.add(t);
      } else {
        //completes the task, removes it from todo and adds it
        //to undo and completed
        t.complete();
        _todoList.remove(t);
        _completedList.add(t);
        _undoStack.push(t);
      }
    }
  }

  //creates the checkbox list for each task
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

  //goes through the todo and completed list and gets the widgets
  //to put in the list view
  List<Widget> _getItems() {
    //list that will hold all the widgets to be displayed
    final List<Widget> _todoWidgets = <Widget>[];

    //sorts lists based on the time the task was created
    _todoList.sort(((a, b) => a.timeAdded.compareTo(b.timeAdded)));
    _completedList
        .sort(((a, b) => a.timeCompleted!.compareTo(b.timeCompleted!)));

    //removes expired tasks
    _removeExpiredCompleted();

    //gets tasks in todo list
    for (Task t in _todoList) {
      _todoWidgets.add(_buildTask(t));
    }

    //gets tasks in completed list
    for (Task t in _completedList) {
      _todoWidgets.add(_buildTask(t));
    }

    return _todoWidgets;
  }

  //removes all the tasks from completed that are more than
  //10 seconds old
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
