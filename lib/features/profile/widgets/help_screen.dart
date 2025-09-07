import 'package:aces_uniben/config/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpFAQPage extends StatefulWidget {
  @override
  _HelpFAQPageState createState() => _HelpFAQPageState();
}

class _HelpFAQPageState extends State<HelpFAQPage> {
 final List<Map<String, String>> faqs = [
  {
    "question": "How do I set a learning reminder?",
    "answer":
        "You can set a learning reminder through the Learning Scheduler on the Profile. Choose a time that works for you, and the app will notify you daily.",
    "category": "Learning",
  },
  {
    "question": "Can I track my sleep with ACES MHS?",
    "answer":
        "Yes! The app allows you to log your sleep duration daily. You can view weekly and monthly sleep patterns in your Sleep Tracker.",
    "category": "Well-being",
  },
  {
    "question": "How does the  Journal work?",
    "answer":
        "The  Journal lets you write down your thoughts and feelings. You can use it to Even take down lecture notes",
    "category": "Journaling",
  },
  {
    "question": "Is my personal data safe?",
    "answer":
        "Absolutely. Your data is private and securely stored on your device. Nothing is shared except the information used to create your account",
    "category": "Privacy",
  },

  {
    "question": "What should I do if I want to delete my account?",
    "answer":
        "You can reset or delete your account by meeting any of  the ACES Admin. Be careful—this will permanently remove all your data from the app.",
    "category": "Account",
  },
  {
    "question": "Does ACES UNIBEN app work offline?",
    "answer":
        "Yes, most features like journaling, timetable, andtodo work offline. However, you would need internet to access blogs, resources e.tc.",
    "category": "General",
  },
];
   Map<String, List<Map<String, String>>> faqsByCategory = {};

  @override
  void initState() {
    super.initState();
    _categorizeFAQs();
  }

  void _categorizeFAQs() {
    for (final faq in faqs) {
      final category = faq['category']!;
      if (faqsByCategory.containsKey(category)) {
        faqsByCategory[category]!.add(faq);
      } else {
        faqsByCategory[category] = [faq];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          "Help & FAQs",
          style: GoogleFonts.nunito(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            Text(
              "Frequently Asked Questions",
              style: GoogleFonts.nunito(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: faqsByCategory.keys.length,
                itemBuilder: (context, index) {
                  final category = faqsByCategory.keys.toList()[index];
                  return _buildFAQExpansionTile(
                      category, faqsByCategory[category]!);
                },
              ),
            ),
            SizedBox(height: 16),
            TextButton.icon(
              onPressed: () =>
                  _launchURL("https://www.acesuniben.org"),
              icon: Icon(Icons.call, color: AppTheme.primaryTeal),
              label: Text(
                "Visit ACES WEBSITE for more Info.",
                style: GoogleFonts.nunito(
                  color: AppTheme.primaryTeal,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQExpansionTile(
      String category, List<Map<String, String>> categoryFAQs) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          collapsedBackgroundColor: Colors.white,
          backgroundColor: Colors.white,
          title: Text(
            category,
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          children: [
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: categoryFAQs.length,
              itemBuilder: (context, index) {
                final faq = categoryFAQs[index];
                return _buildFAQItem(faq['question']!, faq['answer']!);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            question,
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            answer,
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
