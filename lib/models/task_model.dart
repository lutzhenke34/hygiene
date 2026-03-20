class TaskModel {
  final String id;
  final String title;
  final String status;

  TaskModel({
    required this.id,
    required this.title,
    required this.status,
  });

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'],
      title: map['title'],
      status: map['status'],
    );
  }
}