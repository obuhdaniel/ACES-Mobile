import 'package:aces_uniben/config/app_theme.dart';
import 'package:aces_uniben/features/tools/todo/add_todo_screen.dart';
import 'package:aces_uniben/features/tools/todo/models/todo_model.dart';
import 'package:aces_uniben/features/tools/todo/providers/todo_providers.dart';
import 'package:aces_uniben/features/tools/todo/services/todo_db_helper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class TodoDisplayPage extends StatefulWidget {
  const TodoDisplayPage({super.key});

  @override
  State<TodoDisplayPage> createState() => _TodoDisplayPageState();
}

class _TodoDisplayPageState extends State<TodoDisplayPage> {
  final Color primaryColor = const Color(0xFF166D86);
  final Color textColor = const Color(0xFF2F327D);

  DateTime selectedDate = DateTime.now();
  List<Todo> _todos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTodosForDate(selectedDate);
     _refreshHomeStats(); 
  }

  Future<void> _loadTodosForDate(DateTime date) async {
    setState(() => _isLoading = true);
    try {
      final todos = await TodoDBHelper.getTodosByDate(date);
      setState(() {
        _todos = todos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading todos: $e')),
      );
    }
  }

  void _refreshHomeStats() {
  // Refresh the home screen stats when todo page loads
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final todoProvider = Provider.of<TodoProvider>(context, listen: false);
    todoProvider.refreshStats();
  });
}

  Future<void> _deleteTodo(Todo todo) async {
    try {
      await TodoDBHelper.deleteTodo(todo.id!);
      await _loadTodosForDate(selectedDate);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Todo deleted successfully')),
      );
      _refreshHomeStats();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting todo: $e')),
      );
    }
  }

  Future<void> _toggleTodoCompletion(Todo todo) async {
    try {
      await TodoDBHelper.toggleTodoCompletion(todo.id!, !todo.isCompleted);
      await _loadTodosForDate(selectedDate);
      _refreshHomeStats();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating todo: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Generate dates for the current week
    final today = DateTime.now();
    final weekDates = List<DateTime>.generate(
      7,
      (index) => DateTime(today.year, today.month, today.day + index),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey[50]!,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Modern Header with glassmorphism effect
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: primaryColor.withOpacity(0.2),
                          width: 1.5,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => Navigator.pop(context),
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: primaryColor,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Column(
                      children: [
                        Text(
                          "My Tasks",
                          style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1A1A1A),
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          "${_todos.where((t) => !t.isCompleted).length} pending",
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [primaryColor, primaryColor.withOpacity(0.8)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTodoPage()),
          );
                          }, // Add new task
                          child: const Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Modern Date Selector with improved design
              Container(
                height: 100,
                margin: const EdgeInsets.only(bottom: 20),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: weekDates.length,
                  itemBuilder: (context, index) {
                    final date = weekDates[index];
                    final isSelected = date == selectedDate;
                    final isToday = _isToday(date);

                    return GestureDetector(
                      onTap: () {
                        setState(() => selectedDate = date);
                        _loadTodosForDate(date);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        width: 70,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? primaryColor
                              : Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isToday
                                ? primaryColor.withOpacity(0.3)
                                : Colors.grey.withOpacity(0.1),
                            width: isToday ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isSelected
                                  ? primaryColor.withOpacity(0.3)
                                  : Colors.black.withOpacity(0.04),
                              blurRadius: isSelected ? 12 : 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _formatMonth(date),
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white.withOpacity(0.9)
                                    : Colors.grey[600],
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white.withOpacity(0.2)
                                    : (isToday ? primaryColor.withOpacity(0.1) : Colors.transparent),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  date.day.toString(),
                                  style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected
                                        ? Colors.white
                                        : (isToday ? primaryColor : const Color(0xFF1A1A1A)),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _formatWeekday(date),
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? Colors.white.withOpacity(0.8)
                                    : Colors.grey[500],
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Task List with modern cards
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _isLoading
                      ? Center(
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                                strokeWidth: 3,
                              ),
                            ),
                          ),
                        )
                      : _todos.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          primaryColor.withOpacity(0.1),
                                          primaryColor.withOpacity(0.05),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Icon(
                                      Icons.check_circle_outline_rounded,
                                      size: 60,
                                      color: primaryColor.withOpacity(0.6),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    "All done for today! 🎉",
                                    style: GoogleFonts.inter(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF1A1A1A),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "No tasks scheduled for ${_formatDate(selectedDate)}",
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 24),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTodoPage()),
          );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: primaryColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(30),
                                        border: Border.all(
                                          color: primaryColor.withOpacity(0.2),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.add_rounded,
                                            size: 18,
                                            color: primaryColor,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            "Tap to add a new task",
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: primaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: _todos.length,
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                final todo = _todos[index];
                                return _buildModernTaskCard(todo, index);
                              },
                            ),
                ),
              ),
            ],
          ),
        ),
      ),

      // Add this method for building modern task cards
      
      // Floating action button
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTodoPage()),
          );
          if (result == true) {
            await _loadTodosForDate(selectedDate);
            _refreshHomeStats();
          }
        },
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }


  Widget _buildModernTaskCard(Todo todo, int index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: todo.isCompleted 
                  ? Colors.green.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                _toggleTodoCompletion(todo);

                //TODO: DELETE TASK AFTER EXPIRE
              },
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // Custom Checkbox
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: todo.isCompleted ? Colors.green : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: todo.isCompleted ? Colors.green : Colors.grey[300]!,
                          width: 2,
                        ),
                      ),
                      child: todo.isCompleted
                          ? const Icon(
                              Icons.check_rounded,
                              size: 16,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    
                    // Task Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            todo.title,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: todo.isCompleted 
                                  ? Colors.grey[500] 
                                  : const Color(0xFF1A1A1A),
                              decoration: todo.isCompleted 
                                  ? TextDecoration.lineThrough 
                                  : null,
                            ),
                          ),
                          if (todo.description?.isNotEmpty == true) ...[
                            const SizedBox(height: 4),
                            Text(
                              todo.description!,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: todo.isCompleted 
                                    ? Colors.grey[400] 
                                    : Colors.grey[600],
                                decoration: todo.isCompleted 
                                    ? TextDecoration.lineThrough 
                                    : null,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          if (todo.endTime != null) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: 12,
                                    color: primaryColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatTime(todo.endTime!),
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    // Priority Indicator
                   
                  ],
                ),
              ),
            ),
          ),
        );
      }

      // Helper method for priority colors


      // Helper method to check if date is today
      bool _isToday(DateTime date) {
        final now = DateTime.now();
        return date.year == now.year && 
               date.month == now.month && 
               date.day == now.day;
      }
  // Helper functions
  String _formatMonth(DateTime date) {
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
                    "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return months[date.month - 1];
  }

  String _formatWeekday(DateTime date) {
    const days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
    return days[date.weekday % 7];
  }

  String _formatDate(DateTime date) {
    return '${_formatWeekday(date)}, ${date.day} ${_formatMonth(date)}';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}