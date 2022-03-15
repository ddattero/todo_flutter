class Task {
  String title;
  String notes;

  //time the task was created
  final timeAdded = DateTime.now();

  //time the task was completed
  late DateTime? timeCompleted;

  //whether the task is complete or not
  bool status = false;

  Task(this.title, this.notes);
  Task.withoutNotes(this.title) : notes = "";

  //makes the completion status true and sets completion time
  void complete() {
    status = true;
    timeCompleted = DateTime.now();
  }

  //makes the completion status false and removes completion time
  void uncomplete() {
    status = false;
    timeCompleted = null;
  }
}
