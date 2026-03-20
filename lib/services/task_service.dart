import '../core/supabase_client.dart';

class TaskService {
  Future<List<Map<String, dynamic>>> getTasks() async {
    final response = await supabase.from('tasks').select();
    return response;
  }
}