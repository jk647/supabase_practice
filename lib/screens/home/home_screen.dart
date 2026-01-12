import 'package:flutter/material.dart';
import 'package:supabase_practice/screens/auth/login_screen.dart';
import 'package:supabase_practice/screens/auth/services/auth_services.dart';
import 'package:supabase_practice/screens/home/models/task_model.dart';
import 'package:supabase_practice/screens/home/services/task_service.dart';
import 'package:supabase_practice/screens/home/widgets/task_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  final _taskService = TaskService();
  final _authService = AuthService();

  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Work',
    'Personal',
    'Shopping',
    'Health',
  ];

  List<Task> _allTasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    try {
      final tasks = await _taskService.getTasks();
      if (mounted) {
        setState(() {
          _allTasks = tasks;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnackBar('Failed to load tasks: $e', isError: true);
      }
    }
  }

  List<Task> get _filteredTasks {
    var tasks = _selectedCategory == 'All'
        ? _allTasks
        : _allTasks.where((t) => t.category == _selectedCategory).toList();

    if (_searchController.text.isNotEmpty) {
      tasks = tasks
          .where(
            (t) => t.title.toLowerCase().contains(
              _searchController.text.toLowerCase(),
            ),
          )
          .toList();
    }

    tasks.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return 0;
    });

    return tasks;
  }

  void _showAddTaskDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    String selectedCat = 'Work';
    bool isAdding = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Add New Task',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Title',
                  labelStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFF0A0A0A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFF0A0A0A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedCat,
                dropdownColor: const Color(0xFF1A1A1A),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Category',
                  labelStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFF0A0A0A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: _categories.where((c) => c != 'All').map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat));
                }).toList(),
                onChanged: (val) => setDialogState(() => selectedCat = val!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isAdding ? null : () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: isAdding
                  ? null
                  : () async {
                      if (titleController.text.isNotEmpty) {
                        setDialogState(() => isAdding = true);

                        try {
                          final newTask = Task(
                            title: titleController.text.trim(),
                            description: descController.text.trim(),
                            category: selectedCat,
                            isCompleted: false,
                            isPinned: false,
                          );

                          await _taskService.addTask(newTask);

                          if (mounted) {
                            Navigator.pop(ctx);
                            _showSnackBar('Task added successfully!');
                            _loadTasks();
                          }
                        } catch (e) {
                          setDialogState(() => isAdding = false);
                          if (mounted) {
                            _showSnackBar(
                              'Failed to add task: $e',
                              isError: true,
                            );
                          }
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF7DF27),
                foregroundColor: Colors.black,
              ),
              child: isAdding
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    )
                  : const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout() async {
    try {
      await _authService.signOut();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    } catch (e) {
      _showSnackBar('Failed to logout: $e', isError: true);
    }
  }

  Future<void> _toggleTaskCompletion(Task task) async {
    try {
      await _taskService.toggleTaskCompletion(task.id!, !task.isCompleted);
      _loadTasks();
    } catch (e) {
      _showSnackBar('Failed to update task: $e', isError: true);
    }
  }

  Future<void> _toggleTaskPin(Task task) async {
    try {
      await _taskService.toggleTaskPin(task.id!, !task.isPinned);
      _loadTasks();
    } catch (e) {
      _showSnackBar('Failed to pin task: $e', isError: true);
    }
  }

  Future<void> _deleteTask(Task task) async {
    try {
      await _taskService.deleteTask(task.id!);
      _showSnackBar('Task deleted successfully!');
      _loadTasks();
    } catch (e) {
      _showSnackBar('Failed to delete task: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : const Color(0xFFF7DF27),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'My Tasks',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFFF7DF27)),
            onPressed: _loadTasks,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFFF7DF27)),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFF7DF27)),
            )
          : Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search tasks...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFFF7DF27),
                      ),
                      filled: true,
                      fillColor: const Color(0xFF1A1A1A),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                // Categories
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _categories.length,
                    itemBuilder: (ctx, i) {
                      final cat = _categories[i];
                      final isSelected = cat == _selectedCategory;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          onSelected: (_) =>
                              setState(() => _selectedCategory = cat),
                          backgroundColor: const Color(0xFF1A1A1A),
                          selectedColor: const Color(0xFFF7DF27),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.black : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // Tasks List
                Expanded(
                  child: _filteredTasks.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.task_alt,
                                size: 80,
                                color: Colors.grey[800],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No tasks yet',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredTasks.length,
                          itemBuilder: (ctx, i) {
                            final task = _filteredTasks[i];
                            return TaskCard(
                              task: task,
                              onToggle: () => _toggleTaskCompletion(task),
                              onPin: () => _toggleTaskPin(task),
                              onDelete: () => _deleteTask(task),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        backgroundColor: const Color(0xFFF7DF27),
        child: const Icon(Icons.add, color: Colors.black, size: 32),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
