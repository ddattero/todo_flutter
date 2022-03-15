import 'task.dart';

class TaskStack {
  List<Task> stack;

  TaskStack() : stack = [];

  void push(Task t) {
    //adds this task to the list
    stack.add(t);

    //removes items from the stack if there are more than 20
    if (stack.length > 20) {
      stack.removeAt(0);
    }
  }

  Task pop() {
    //idx of last item
    int idx = stack.length - 1;

    //gets the last item in the list
    Task t = stack[idx];

    stack.removeAt(idx);

    return t;
  }

  Task top() {
    return stack[stack.length - 1];
  }

  void remove(Task t) {
    stack.remove(t);
  }

  int size() {
    return stack.length;
  }
}
