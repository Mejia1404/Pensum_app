import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/task.dart';
import '../../../services/notification_service.dart';
import '../widgets/calendar_strip.dart';
import '../widgets/task_card.dart';
import '../widgets/add_task_dialog.dart';

class TasksScreen extends StatefulWidget {
  final bool isDark;

  const TasksScreen({
    super.key,
    required this.isDark,
  });

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  List<Task> _tasks = [];
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();
  late NotificationService _notificationService;

  @override
  void initState() {
    super.initState();
    _notificationService = NotificationService();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = prefs.getStringList('user_tasks') ?? [];

      final List<Task> loadedTasks = [];
      for (final t in tasksJson) {
        try {
          loadedTasks.add(Task.fromJson(jsonDecode(t)));
        } catch (e) {
          debugPrint('❌ Error decodificando tarea: $e');
        }
      }

      setState(() {
        _tasks = loadedTasks;
        _isLoading = false;
      });

      _rescheduleNotifications();
    } catch (e) {
      debugPrint('❌ Error cargando tareas: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _rescheduleNotifications() async {
    for (final task in _tasks) {
      if (!task.isCompleted && task.enableNotification) {
        try {
          await _notificationService.scheduleTaskNotification(task);
        } catch (e) {
          debugPrint('❌ Error reprogramando notificación: $e');
        }
      }
    }
  }

  Future<void> _saveTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = _tasks.map((t) => jsonEncode(t.toJson())).toList();
      await prefs.setStringList('user_tasks', tasksJson);
    } catch (e) {
      debugPrint('❌ Error guardando tareas: $e');
    }
  }

  Future<void> _addTask(Task task) async {
    setState(() => _tasks.add(task));
    await _saveTasks();

    if (task.enableNotification) {
      await _notificationService.scheduleTaskNotification(task);
      if (mounted) {
        _showSnackbar('${task.title} agregada', isSuccess: true);
      }
    }
  }

  Future<void> _editTask(Task oldTask, Task newTask) async {
    final index = _tasks.indexWhere((t) => t.id == oldTask.id);
    if (index != -1) {
      setState(() => _tasks[index] = newTask);
      await _saveTasks();
      await _notificationService.updateTaskNotification(oldTask, newTask);

      if (mounted) {
        _showSnackbar('${newTask.title} actualizada', isSuccess: true);
      }
    }
  }

  void _toggleTask(String id) {
    setState(() {
      final index = _tasks.indexWhere((t) => t.id == id);
      if (index != -1) {
        _tasks[index] = _tasks[index].copyWith(
          isCompleted: !_tasks[index].isCompleted,
        );

        if (_tasks[index].isCompleted) {
          _notificationService.cancelNotification(id);
        } else if (_tasks[index].enableNotification) {
          _notificationService.scheduleTaskNotification(_tasks[index]);
        }
      }
    });
    _saveTasks();
  }

  Future<void> _deleteTask(String id) async {
    final taskTitle = _tasks.firstWhere((t) => t.id == id).title;

    setState(() => _tasks.removeWhere((t) => t.id == id));
    await _saveTasks();
    await _notificationService.cancelNotification(id);

    if (mounted) {
      _showSnackbar('$taskTitle eliminada', isSuccess: false);
    }
  }

  void _showSnackbar(String message, {required bool isSuccess}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (isSuccess ? AppColors.success : AppColors.error).withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isSuccess ? Icons.check_rounded : Icons.delete_rounded,
                color: isSuccess ? AppColors.success : AppColors.error,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: widget.isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: widget.isDark ? AppColors.darkCard : AppColors.lightCard,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  List<Task> get _tasksForSelectedDate {
    return _tasks
        .where((t) =>
            t.dueDate.year == _selectedDate.year &&
            t.dueDate.month == _selectedDate.month &&
            t.dueDate.day == _selectedDate.day)
        .toList()
      ..sort((a, b) => a.dueDateTime.compareTo(b.dueDateTime));
  }

  String _formatMonthYear(DateTime date) {
    try {
      return DateFormat('MMMM, y', 'es_ES').format(date);
    } catch (e) {
      return DateFormat('MMMM, y').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatMonthYear(_selectedDate),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: widget.isDark
                          ? AppColors.textDarkSecondary
                          : AppColors.textLightSecondary,
                    ),
                  ),
                  Text(
                    'Calendario',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: widget.isDark
                          ? AppColors.textDarkPrimary
                          : AppColors.textLightPrimary,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => _showAddTaskDialog(context),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Calendario horizontal
        CalendarStrip(
          selectedDate: _selectedDate,
          onDateSelected: (date) => setState(() => _selectedDate = date),
          isDark: widget.isDark,
        ),

        const SizedBox(height: 24),

        // Encabezado de lista
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Agenda del día',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: widget.isDark
                      ? AppColors.textDarkPrimary
                      : AppColors.textLightPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_tasksForSelectedDate.length} tareas',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Lista de tareas
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : _tasksForSelectedDate.isEmpty
                  ? _EmptyState(isDark: widget.isDark)
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                      itemCount: _tasksForSelectedDate.length,
                      itemBuilder: (context, index) {
                        final task = _tasksForSelectedDate[index];
                        return TaskCard(
                          task: task,
                          isDark: widget.isDark,
                          onToggle: () => _toggleTask(task.id),
                          onDelete: () => _deleteTask(task.id),
                          onEdit: () => _showEditTaskDialog(context, task),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withOpacity(0.3),
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Material(
            type: MaterialType.transparency,
            child: SingleChildScrollView(
              child: AddTaskDialog(onTaskAdded: _addTask),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 8 * animation.value,
            sigmaY: 8 * animation.value,
          ),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          ),
        );
      },
    );
  }

  void _showEditTaskDialog(BuildContext context, Task task) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withOpacity(0.3),
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Material(
            type: MaterialType.transparency,
            child: SingleChildScrollView(
              child: AddTaskDialog(
                taskToEdit: task,
                onTaskAdded: (editedTask) => _editTask(task, editedTask),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 8 * animation.value,
            sigmaY: 8 * animation.value,
          ),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isDark;

  const _EmptyState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.event_note_rounded,
              color: AppColors.accent,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Sin tareas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Toca el botón + para agregar una tarea',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
            ),
          ),
        ],
      ),
    );
  }
}
