import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PanicAttackGuideScreen extends StatefulWidget {
  @override
  _PanicAttackGuideScreenState createState() => _PanicAttackGuideScreenState();
}

class _PanicAttackGuideScreenState extends State<PanicAttackGuideScreen> {
  List<bool> _isExpanded = [false, false, false, false, false, false];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Panic Attack Guide',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: 6,
          itemBuilder: (context, index) {
            return _buildGuideStep(
              context,
              [
                '1. Acknowledge the Attack',
                '2. Breathe Deeply',
                '3. Ground Yourself',
                '4. Use a Mantra',
                '5. Find a Comfortable Space',
                '6. Seek Support',
              ][index],
              [
                'Recognize that you are having a panic attack, not a heart attack. It is temporary and will pass.',
                'Focus on slow, deep breaths. Inhale for 4 seconds, hold for 4 seconds, exhale for 4 seconds.',
                'Use grounding techniques like naming 5 things you can see, 4 things you can touch, 3 things you can hear, 2 things you can smell, and 1 thing you can taste.',
                'Repeat calming phrases like "This is temporary," "I am safe," or "I will get through this."',
                'If possible, move to a quiet place and try to relax. Close your eyes if it helps.',
                'Reach out to someone you trust or a helpline for support if needed.',
              ][index],
              [
                Icons.check_circle_outline,
                Icons.air,
                Icons.grass,
                Icons.favorite_outline,
                Icons.chair_outlined,
                Icons.support_agent,
              ][index],
              _isExpanded[index],
              () {
                setState(() {
                  _isExpanded[index] = !_isExpanded[index];
                });
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildGuideStep(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    bool isExpanded,
    VoidCallback onTap,
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 40, color: Colors.teal),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 20,
                    color: Colors.teal,
                  ),
                ],
              ),
              if (isExpanded)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    description,
                    style: GoogleFonts.montserrat(fontSize: 14),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class AnxietyGuideScreen extends StatefulWidget {
  @override
  _AnxietyGuideScreenState createState() => _AnxietyGuideScreenState();
}

class _AnxietyGuideScreenState extends State<AnxietyGuideScreen> {
  List<bool> _isExpanded = [
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Anxiety Management Guide',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: 8,
          itemBuilder: (context, index) {
            return _buildGuideStep(
              context,
              [
                '1. Identify Your Triggers',
                '2. Practice Deep Breathing',
                '3. Challenge Negative Thoughts',
                '4. Engage in Physical Activity',
                '5. Practice Mindfulness',
                '6. Limit Caffeine and Alcohol',
                '7. Build a Support Network',
                '8. Seek Professional Help',
              ][index],
              [
                'Take note of situations or thoughts that make you feel anxious. Awareness is the first step in managing anxiety.',
                'Use deep breathing exercises to calm your mind and body. Try the 4-7-8 technique: inhale for 4 seconds, hold for 7 seconds, exhale for 8 seconds.',
                'Question and reframe negative or irrational thoughts. Ask yourself if they are realistic or helpful.',
                'Regular exercise can reduce anxiety symptoms. Even a short walk can help clear your mind and improve mood.',
                'Focus on the present moment. Techniques like meditation or mindful observation can help reduce anxiety.',
                'Caffeine and alcohol can increase anxiety symptoms. Try to limit your intake and notice the effects on your anxiety.',
                'Talk to friends, family, or support groups. Sharing your feelings can help alleviate anxiety.',
                'If anxiety becomes overwhelming, consider seeking support from a mental health professional.',
              ][index],
              [
                Icons.lightbulb_outline,
                Icons.air,
                Icons.psychology,
                Icons.directions_walk,
                Icons.self_improvement,
                Icons.local_cafe,
                Icons.group,
                Icons.support_agent,
              ][index],
              _isExpanded[index],
              () {
                setState(() {
                  _isExpanded[index] = !_isExpanded[index];
                });
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildGuideStep(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    bool isExpanded,
    VoidCallback onTap,
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 40, color: Colors.blueAccent),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 20,
                    color: Colors.blueAccent,
                  ),
                ],
              ),
              if (isExpanded)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    description,
                    style: GoogleFonts.montserrat(fontSize: 14),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
