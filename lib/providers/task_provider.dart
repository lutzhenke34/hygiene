import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/task_service.dart';

final taskProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final service = TaskService();
  return service.getTasks();
});