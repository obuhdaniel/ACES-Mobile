import 'package:aces_uniben/config/app_theme.dart';
import 'package:aces_uniben/features/tools/journal/view_journal_list_screen.dart';
import 'package:aces_uniben/features/tools/pq/pq_screen.dart';
import 'package:aces_uniben/features/tools/timetable/view_timetable_screen.dart';
import 'package:aces_uniben/features/tools/todo/view_todo_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ToolsPage extends StatelessWidget {
  const ToolsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildToolCard(
              title: 'Time Table',
              description: 'Get familiar with the departmental Time table for your level',
              illustration: _buildTimeTableIllustration(),
              color: Colors.teal.shade600,
              onTap: () => _handleToolTap(context, 'Time Table'),
            ),
            
            const SizedBox(height: 20),
            
            _buildToolCard(
              title: 'To Do list',
              description: 'Plan your day and make sure you utilize it and avoid procrastination',
              illustration: _buildToDoListIllustration(),
              color: Colors.indigo.shade600,
              onTap: () => _handleToolTap(context, 'To Do List'),
            ),
            
            const SizedBox(height: 20),
            
            _buildToolCard(
              title: 'Journal',
              description: 'Jot down your daily and important points at any point in time',
              illustration: _buildJournalIllustration(),
              color: Colors.orange.shade600,
              onTap: () => _handleToolTap(context, 'Journal'),
            ),
            
            const SizedBox(height: 20),
            
            _buildToolCard(
              title: 'Past Questions',
              description: 'Practice Past Questions so that you can be prepared for exams',
              illustration: _buildPastQuestionsIllustration(),
              color: Colors.purple.shade600,
              onTap: () => _handleToolTap(context, 'Past Questions'),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      title: Text(
        'Tools',
        style: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppTheme.primaryTeal,
        ),
      ),
    );
  }

  Widget _buildToolCard({
    required String title,
    required String description,
    required Widget illustration,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryTeal,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        description,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: const Color(0XFF696984),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 120,
                    child: illustration,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeTableIllustration() {
    return Image.asset(
      'assets/images/tool-time.png',
      fit: BoxFit.contain,
    );
    
    
    }

  Widget _buildToDoListIllustration() {
    return Image.asset(
      'assets/images/tool-todo.png',
      fit: BoxFit.contain,
    );
  }

  Widget _buildChecklistItem(bool isChecked) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isChecked ? Colors.green.shade400 : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2),
          ),
          child: isChecked
              ? Icon(
                  Icons.check,
                  size: 6,
                  color: Colors.white,
                )
              : null,
        ),
        const SizedBox(width: 4),
        Container(
          width: 20,
          height: 2,
          decoration: BoxDecoration(
            color: Colors.grey.shade400,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ],
    );
  }

  Widget _buildJournalIllustration() {
    return Image.asset('assets/images/tool-journal.png', fit: BoxFit.contain);
  }

  Widget _buildPastQuestionsIllustration() {
    return Image.asset('assets/images/tool-pq.png', fit: BoxFit.contain);
  }

  void _handleToolTap(BuildContext context, String toolName) {
  
    if (toolName == 'Time Table') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => TimeTableScreen()));
    } else if (toolName == 'To Do List') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => TodoDisplayPage()));
    } else if (toolName == 'Journal') {
       Navigator.push(context, MaterialPageRoute(builder: (context) => const JournalListPage()));

    } else if (toolName == 'Past Questions') {
       Navigator.push(context, MaterialPageRoute(builder: (context) => PastQuestionsPage()));
    }
  }
}