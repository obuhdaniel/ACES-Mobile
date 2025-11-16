import 'package:aces_uniben/config/app_theme.dart';
import 'package:aces_uniben/services/webview_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';



class ClassResourccesPage extends StatefulWidget {
  const ClassResourccesPage({super.key});

  @override
  State<ClassResourccesPage> createState() => _ClassResourccesPageState();
}

class _ClassResourccesPageState extends State<ClassResourccesPage>
    with TickerProviderStateMixin {
  final Color primaryColor = const Color(0xFF166D86);
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<ElaboarateLevel> levels = [

      //TODO: HANDLE 1100L SECOND SEMESTER LINK


       ElaboarateLevel(
      id: '100L',
      name: '100L',
     
      colors: [AppTheme.primaryTeal.withOpacity(0.6), AppTheme.primaryTeal],
      departments: [
        
        
        Departments(
        id: '1001',
        name: '100L 1st Semester',
       
        icon: '1st',
      
        link: 'https://drive.google.com/drive/folders/1wKZ5C60eviQCt0Bp42kvc1I2T2TjDvgQ',
        colors: [AppTheme.primaryTeal.withOpacity(0.6), AppTheme.primaryTeal],
      ),



      ]
    ),
   
   ElaboarateLevel(
      id: '200L',
      name: '200L',
     
      colors: [AppTheme.primaryTeal.withOpacity(0.6), AppTheme.primaryTeal],
      departments: [
        
        
        Departments(
        id: '2001',
        name: '200L 1st Semester',
       
        icon: '1st',
      
        link: 'https://drive.google.com/drive/folders/1RLLoQ1_u6ubDAH0CJ6R77eEgCR1-khuh',
        colors: [AppTheme.primaryTeal.withOpacity(0.6), AppTheme.primaryTeal],
      ),

       Departments(
        id: '2002',
        name: '200L 2nd Semester',
       
        icon: '2nd',
      
        link: 'https://drive.google.com/drive/folders/1aLetNYmTDqyhnnF9liw2MotftQOZtPi0',
        colors: [AppTheme.primaryTeal.withOpacity(0.6), AppTheme.primaryTeal],
      ),
    


      ]
    ),
     

   
   ElaboarateLevel(
      id: '300L',
      name: '300L',
     
      colors: [AppTheme.primaryTeal.withOpacity(0.6), AppTheme.primaryTeal],
      departments: [
        
        
        Departments(
        id: '3001',
        name: '300L 1st Semester',
       
        icon: '1st',
      
        link: 'https://drive.google.com/drive/folders/1DnWT-ht8Ic9kPQHqIz1dy30Umg2wy0xK',
        colors: [AppTheme.primaryTeal.withOpacity(0.6), AppTheme.primaryTeal],
      ),

       Departments(
        id: '3002',
        name: '300L 2nd Semester',
       
        icon: '2nd',
      
        link: 'https://drive.google.com/drive/folders/1rvVtLvptdaoOg3xA0w2Pal_EcQvrt5Zd',
        colors: [AppTheme.primaryTeal.withOpacity(0.6), AppTheme.primaryTeal],
      ),
    


      ]
    ),
  

   ElaboarateLevel(
      id: '400L',
      name: '400L',
     
      
      colors: [AppTheme.primaryTeal.withOpacity(0.6), AppTheme.primaryTeal],
      departments: [
        
        
        Departments(
        id: '4001',
        name: '400L 1st Semester',
       
        icon: '1st',
      
        link: 'https://drive.google.com/drive/folders/1MiGK2X4jUZo4wd_IqqB9YhT86ZpyvmWO',
        colors: [AppTheme.primaryTeal.withOpacity(0.6), AppTheme.primaryTeal],
      ),

      
    


      ]
    ),


     ElaboarateLevel(
      id: '500L',
      name: '500L',
     
      
      colors: [AppTheme.primaryTeal.withOpacity(0.6), AppTheme.primaryTeal],
      departments: [
        
        
        Departments(
        id: '5001',
        name: '500L 1st Semester',
       
        icon: '1st',
      
        link: 'https://drive.google.com/drive/folders/1OZkr983e3aIb9H8qwt5vmoQmujpYzCO0',
        colors: [AppTheme.primaryTeal.withOpacity(0.6), AppTheme.primaryTeal],
      ),

        Departments(
        id: '5001',
        name: '500L 1st Semester',
       
        icon: '2nd',
      
        link: 'https://drive.google.com/drive/folders/1xr_kn4ajGJ3w12W0Z_NqG2oLORdLvJoK',
        colors: [AppTheme.primaryTeal.withOpacity(0.6), AppTheme.primaryTeal],
      ),

      
    


      ]
    ),
  
  
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFAFAFA),
              Color(0xFFEFF6FF),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                _buildModernHeader(context),
                Expanded(
                  child: _buildLevelGrid(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

Widget _buildModernHeader(BuildContext context) {
  return PopScope(
    canPop: true,
    child: Container(
      margin: EdgeInsets.all(20.w),
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20.r, 
            offset: Offset(0, 8.h), 
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.grey.withOpacity(0.1)),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16.r),
                onTap: () => Navigator.pop(context),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: primaryColor,
                  size: 20.sp,
                ),
              ),
            ),
          ),
          const Spacer(),
          Column(
            children: [
              Text(
                "Resources",
                style:  GoogleFonts.poppins(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A1A),
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                "Choose your academic level",
                style:  GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const Spacer(),
          
        ],
      ),
    ),
  );
}
  Widget _buildLevelGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        physics: const BouncingScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        itemCount: levels.length,
        itemBuilder: (context, index) {
          return _buildLevelCard(levels[index], index);
        },
      ),
    );
  }
Widget _buildLevelCard(ElaboarateLevel level, int index) {
  return TweenAnimationBuilder<double>(
    duration: Duration(milliseconds: 300 + (index * 100)),
    tween: Tween(begin: 0.0, end: 1.0),
    builder: (context, value, child) {
      return Transform.translate(
        offset: Offset(0, 30.h * (1 - value)),
        child: Opacity(
          opacity: value,
          child: child,
        ),
      );
    },
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24.r),
          onTap: () => _navigateToSemesters(level),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
               
                /// Icon
                Container(
                  width: 56.w,
                  height: 56.w,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: level.colors),
                    borderRadius: BorderRadius.circular(18.r),
                    boxShadow: [
                      BoxShadow(
                        color: level.colors.first.withOpacity(0.3),
                        blurRadius: 12.r,
                        offset: Offset(0, 6.h),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.description_rounded,
                    color: Colors.white,
                    size: 28.sp,
                  ),
                ),

                SizedBox(height: 16.h),

                /// Level name
                Text(
                  level.name,
                  style:  GoogleFonts.poppins(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),

                SizedBox(height: 8.h),

                /// File info
              
            

                SizedBox(height: 4.h),

                // /// Size info
                // Row(
                //   children: [
                //     Icon(
                //       Icons.storage_rounded,
                //       size: 16.sp,
                //       color: Colors.grey[600],
                //     ),
                //     SizedBox(width: 4.w),
                //     Text(
                //       level.size,
                //       style:  GoogleFonts.poppins(
                //         fontSize: 14.sp,
                //         color: Colors.grey[600],
                //         fontWeight: FontWeight.w500,
                //       ),
                //     ),
                //   ],
                // ),
             
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
  void _navigateToSemesters(ElaboarateLevel level) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            SemesterSelectionPage(level: level),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;
          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }
}

class SemesterSelectionPage extends StatefulWidget {
  final ElaboarateLevel level;

  const SemesterSelectionPage({super.key, required this.level});

  @override
  State<SemesterSelectionPage> createState() => _SemesterSelectionPageState();
}

class _SemesterSelectionPageState extends State<SemesterSelectionPage>
    with TickerProviderStateMixin {
  final Color primaryColor = const Color(0xFF166D86);
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

    void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFAFAFA),
              Color(0xFFF3E8FF),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: _buildSemesterList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
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
                '${widget.level.name} Resources',
                style:  GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              Text(
                'Select semester to access',
                style:  GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const Spacer(),
          
        ],
      ),
    );
  }

  Widget _buildSemesterList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          
          // Semester Cards
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: widget.level.departments.length, // First and second semester
              itemBuilder: (context, index) {
                return _buildSemesterCard(widget.level.departments[index], index);
              },
            ),
          ),
          
          // Footer Info
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.blue.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.info_outline_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Tip',
                        style:  GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.blue[900],
                        ),
                      ),
                      Text(
                        'All files will open in Google Drive. Make sure you\'re logged in.',
                        style:  GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSemesterCard(Departments semester, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + (index * 200)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () => _openGoogleDrive(semester.link),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  // Semester Icon
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: semester.colors),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: semester.colors.first.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        semester.icon,
                        style:  GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 20),
                  
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          semester.name,
                          style:  GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1A1A1A),
                          ),
                        ),
                        // Text(
                        //   semester.description,
                        //   style:  GoogleFonts.poppins(
                        //     fontSize: 14,
                        //     color: Colors.grey[600],
                        //   ),
                        // ),
                        
                        // const SizedBox(height: 12),
                        // Row(
                        //   children: [
                        //     Container(
                        //       padding: const EdgeInsets.symmetric(
                        //         horizontal: 12,
                        //         vertical: 6,
                        //       ),
                        //       decoration: BoxDecoration(
                        //         color: Colors.grey[100],
                        //         borderRadius: BorderRadius.circular(20),
                        //       ),
                        //       child: Row(
                        //         mainAxisSize: MainAxisSize.min,
                        //         children: [
                        //           Icon(
                        //             Icons.folder_rounded,
                        //             size: 14,
                        //             color: Colors.grey[600],
                        //           ),
                        //           const SizedBox(width: 4),
                        //           Text(
                        //             '${semester.files} Files',
                        //             style:  GoogleFonts.poppins(
                        //               fontSize: 12,
                        //               fontWeight: FontWeight.w600,
                        //               color: Colors.grey[700],
                        //             ),
                        //           ),
                        //         ],
                        //       ),
                        //     ),
                            
                        //   ],
                        // ),
                      ],
                    ),
                  ),
                  
                  // Action Button
                  Column(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: semester.colors),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: semester.colors.first.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.open_in_new_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Open Drive',
                        style:  GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openGoogleDrive(String url) async {
    Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => WebviewWidget(
                    url: url,
                    title: 'Elaborate',
                  )),
        );
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style:  GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

// Data Models
class ElaboarateLevel {
  final String id;
  final String name;
  final List<Color> colors;
  final List<Departments> departments;

  ElaboarateLevel({
    required this.id,
    required this.name,
    required this.colors,
    required this.departments
  });
}

class Departments {
  final String id;
  final String name;
  final String icon;
  final String link;
  final List<Color> colors;

  Departments({
    required this.id,
    required this.name,
    required this.icon,
    required this.link,
    required this.colors,
  });
}