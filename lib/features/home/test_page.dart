import 'package:aces_uniben/services/webview_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TestPage extends StatelessWidget {
  final String baseurl = "https://xavierscript.github.io/ACES-MHS";
  static const Color primaryColor = Color(0xFF6DAEDB);

  final List<Map<String, dynamic>> tests = [
    {
      "name": "ADHD Test",
      "description": "Assess attention deficit symptoms",
      "imagePath": "assets/images/test-5.png",
      "endpoint": "adhd",
      "color": Color(0xFF7CB9E8),
    },
    {
      "name": "Anxiety Test",
      "description": "Evaluate anxiety levels",
      "imagePath": "assets/images/test-1.png",
      "endpoint": "anxiety",
      "color": Color(0xFF6DAEDB),
    },
    {
      "name": "Bipolar Test",
      "description": "Screen for bipolar disorder",
      "imagePath": "assets/images/test-2.png",
      "endpoint": "bipolar",
      "color": Color(0xFF5CA4D3),
    },
    {
      "name": "Depression Test",
      "description": "Check depression indicators",
      "imagePath": "assets/images/test-3.png",
      "endpoint": "depression",
      "color": Color(0xFF4B9ACB),
    },
    {
      "name": "PTSD Test",
      "description": "Evaluate trauma responses",
      "imagePath": "assets/images/test-4.png",
      "endpoint": "ptsd",
      "color": Color(0xFF3A90C3),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          "Mental Health Tests",
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Text(
              "Select a test to assess your mental well-being",
              style: GoogleFonts.poppins(
                color: Colors.black54,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                physics: BouncingScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: tests.length,
                itemBuilder: (context, index) {
                  final test = tests[index];
                  return _buildTestCard(context, test);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestCard(BuildContext context, Map<String, dynamic> test) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WebviewWidget(
              title: test['name'],
              url: "$baseurl/${test['endpoint']}",
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: test['color'].withOpacity(0.1),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: test['color'].withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                test['imagePath']!,
                height: 50,
                width: 50,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/images/test-2.png',
                    height: 50,
                    width: 50,
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            Text(
              test['name']!,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                test['description']!,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.black54,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
