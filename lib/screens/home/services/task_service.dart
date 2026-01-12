import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_practice/screens/home/models/task_model.dart';

class TaskService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get current user's ID
  String? get _userId => _supabase.auth.currentUser?.id;

  // Fetch all tasks for current user
  Future<List<Task>> getTasks() async {
    try {
      final response = await _supabase
          .from('tasks')
          .select()
          .eq('user_id', _userId!)
          .order('created_at', ascending: false);

      return (response as List).map((json) => Task.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch tasks: $e');
    }
  }

  // Stream tasks (real-time updates)
  Stream<List<Task>> streamTasks() {
    if (_userId == null) {
      return Stream.value([]);
    }

    return _supabase
        .from('tasks')
        .stream(primaryKey: ['id'])
        .eq('user_id', _userId!)
        .order('created_at', ascending: false)
        .map((data) => data.map((json) => Task.fromJson(json)).toList());
  }

  // Add new task
  Future<Task> addTask(Task task) async {
    try {
      final data = {...task.toJson(), 'user_id': _userId};

      final response = await _supabase
          .from('tasks')
          .insert(data)
          .select()
          .single();

      return Task.fromJson(response);
    } catch (e) {
      throw Exception('Failed to add task: $e');
    }
  }

  // Update task
  Future<Task> updateTask(Task task) async {
    try {
      final response = await _supabase
          .from('tasks')
          .update(task.toJson())
          .eq('id', task.id!)
          .select()
          .single();

      return Task.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }

  // Toggle task completion
  Future<void> toggleTaskCompletion(String taskId, bool isCompleted) async {
    try {
      await _supabase
          .from('tasks')
          .update({'is_completed': isCompleted})
          .eq('id', taskId);
    } catch (e) {
      throw Exception('Failed to toggle task: $e');
    }
  }

  // Toggle task pin
  Future<void> toggleTaskPin(String taskId, bool isPinned) async {
    try {
      await _supabase
          .from('tasks')
          .update({'is_pinned': isPinned})
          .eq('id', taskId);
    } catch (e) {
      throw Exception('Failed to pin task: $e');
    }
  }

  // Delete task
  Future<void> deleteTask(String taskId) async {
    try {
      await _supabase.from('tasks').delete().eq('id', taskId);
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }

  // Get tasks by category
  Future<List<Task>> getTasksByCategory(String category) async {
    try {
      final response = await _supabase
          .from('tasks')
          .select()
          .eq('user_id', _userId!)
          .eq('category', category)
          .order('created_at', ascending: false);

      return (response as List).map((json) => Task.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch tasks by category: $e');
    }
  }

  // Search tasks
  Future<List<Task>> searchTasks(String query) async {
    try {
      final response = await _supabase
          .from('tasks')
          .select()
          .eq('user_id', _userId!)
          .ilike('title', '%$query%')
          .order('created_at', ascending: false);

      return (response as List).map((json) => Task.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to search tasks: $e');
    }
  }
}
