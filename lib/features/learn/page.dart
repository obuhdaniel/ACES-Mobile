import 'package:aces_uniben/config/app_theme.dart';
import 'package:aces_uniben/features/learn/models/tech_category_model.dart';
import 'package:aces_uniben/features/learn/view_resources_page.dart';
import 'package:aces_uniben/features/profile/scheduler/learning_scheduler.dart' hide AppTheme;
import 'package:aces_uniben/providers/onboarding_provider.dart';
import 'package:aces_uniben/services/webview_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class TechLearningPage extends StatefulWidget {
  final bool? isSoftware;

  const TechLearningPage({Key? key, this.isSoftware}) : super(key: key);

  
  @override
  State<TechLearningPage> createState() => _TechLearningPageState();
}

class _TechLearningPageState extends State<TechLearningPage> {
  late String selectedCategory;
  bool _isLoading = true;
  @override
  void initState() {
    if (widget.isSoftware == null) {
      selectedCategory = 'Software';
    } else {
      
      selectedCategory = widget.isSoftware! ? 'Software' : 'Hardware';
    }

    _checkFirstTime();
    super.initState();
  }

    Future<void> _checkFirstTime() async {
    final firstTimeProvider = Provider.of<OnboardingProvider>(context, listen: false);
    await firstTimeProvider.initialize();
    setState(() {
      _isLoading = false;
    });
  }

  void _handleFirstTimeComplete() {
    final firstTimeProvider = Provider.of<OnboardingProvider>(context, listen: false);
    firstTimeProvider.setFirstTimeCompleted();
  }

  final Map<String, List<TechCategory>> categories = {
    'Software': [
      TechCategory('App\nDevelopment', Icons.flutter_dash, Colors.orange,
          resources: [
            // Cross-platform & mobile
            TechResource(
                title: 'Harvard Mobile App Development with React Native',
                url:
                    'https://www.edx.org/learn/react-native/harvard-university-cs50-s-mobile-app-development-with-react-native',
                type: 'course'),
            TechResource(
                title: 'Flutter Documentation',
                url: 'https://docs.flutter.dev',
                type: 'docs'),

            TechResource(
                title: 'React Native Docs',
                url: 'https://reactnative.dev/docs',
                type: 'docs'),
            // Android + Kotlin
            TechResource(
                title: 'Android Developers (Guides & API)',
                url: 'https://developer.android.com',
                type: 'docs'),
            TechResource(
                title: 'Kotlin Docs',
                url: 'https://kotlinlang.org/docs/home.html',
                type: 'docs'),
            TechResource(
                title: 'Kotlin Apprentice Book',
                url:
                    'https://store.raywenderlich.com/products/kotlin-apprentice',
                type: 'book'),
            TechResource(
                title: 'Lets build an Android browser with Mozilla components',
                type: 'video',
                url:
                    'https://www.youtube.com/watch?v=9apPcuuvUzc&list=PLRJ4pSIA9DGtamE77FNiLj_TZkAFS9OSb&index=7'),
            TechResource(
                title: 'Hands-On Data Structures and Algorithms with Kotlin ',
                url: 'https://www.amazon.com/gp/product/B07DTG2629',
                type: 'link'),
            TechResource(
                title: 'CodingWithMitch courses',
                url: 'http://codingwithmitch.com/',
                type: 'course'),

            TechResource(
                title: 'Android Kotlin Guides',
                url: 'https://developer.android.com/kotlin',
                type: 'guide'),
            // iOS + Swift
            TechResource(
                title: 'Swift Language Reference',
                url: 'https://developer.apple.com/documentation/swift',
                type: 'docs'),
            TechResource(
                title: 'SwiftUI Documentation',
                url: 'https://developer.apple.com/documentation/swiftui',
                type: 'docs'),
            TechResource(
                title: 'Apple Human Interface Guidelines',
                url:
                    'https://developer.apple.com/design/human-interface-guidelines/',
                type: 'guide'),
            // Tooling
            TechResource(
                title: 'Xcode Overview',
                url: 'https://developer.apple.com/xcode/',
                type: 'docs'),
            TechResource(
                title: 'Gradle (Build Tool) Docs',
                url: 'https://docs.gradle.org/current/userguide/userguide.html',
                type: 'docs'),
          ],
          imagePath: 'assets/images/flutter.png'),
      TechCategory('Web\nDevelopment', 'JS', Colors.green,
          imagePath: 'assets/images/js.png',
          resources: [
            // Core web

            TechResource(
                title: 'The Odin Project',
                url: 'https://theodinproject.com',
                type: 'course'),
            TechResource(
                title: 'Full-Stack Open',
                url: 'https://fullstackopen.com/en',
                type: 'course'),
            TechResource(
                title: 'The Valley of Code',
                url: 'https://thevalleyofcode.com',
                type: 'course'),
            TechResource(
                title: 'MDN Web Docs (HTML/CSS/JS)',
                url: 'https://developer.mozilla.org/',
                type: 'docs'),
            TechResource(
                title: 'web.dev: Learn Web Fundamentals',
                url: 'https://web.dev/learn',
                type: 'guide'),
            TechResource(
                title: 'Can I use (Browser Support)',
                url: 'https://caniuse.com/',
                type: 'tool'),
            // Frameworks
            TechResource(
                title: 'React Docs',
                url: 'https://react.dev/learn',
                type: 'docs'),
            TechResource(
                title: 'Next.js Docs',
                url: 'https://nextjs.org/docs',
                type: 'docs'),
            TechResource(
                title: 'Angular Docs',
                url: 'https://angular.dev/',
                type: 'docs'),
            TechResource(
                title: 'Vue.js Guide',
                url: 'https://vuejs.org/guide/introduction.html',
                type: 'docs'),
            TechResource(
                title: 'Svelte Docs',
                url: 'https://svelte.dev/docs',
                type: 'docs'),
            // Language & runtime
            TechResource(
                title: 'TypeScript Handbook',
                url: 'https://www.typescriptlang.org/docs/handbook/intro.html',
                type: 'docs'),
            TechResource(
                title: 'Node.js Docs',
                url: 'https://nodejs.org/en/docs',
                type: 'docs'),
            TechResource(
                title: 'Google Cloud Skills',
                url: 'https://www.cloudskillsboost.google/course_templates/155',
                type: 'course'),
            TechResource(
                title: 'Azure Cloud Course',
                url:
                    'https://www.mygreatlearning.com/academy/learn-for-free/courses/azure-course',
                type: 'course'),
          ]),
      TechCategory('Cyber Security', Icons.lock, Colors.red,
          imagePath: 'assets/images/cyber.png',
          resources: [
            TechResource(
                title: 'Cybersecurity Essentials',
                url:
                    'https://learn.microsoft.com/en-us/training/modules/prepare-child-cybersecurity-essentials/',
                type: 'course'),
            TechResource(
                title: 'Cykea Cybersecurity Resources',
                url: 'https://www.cykea.com/',
                type: 'resource'),
            TechResource(
                title: 'Cisco Cybersecurity Course',
                url: 'https://www.netacad.com/',
                type: 'course'),
            TechResource(
                title: 'Great Learning Cybersecurity',
                url:
                    'https://www.mygreatlearning.com/academy/learn-for-free/courses/introduction-to-cyber-security',
                type: 'course'),
            TechResource(
                title: 'Cybersecurity Essentials',
                url:
                    'https://learn.microsoft.com/en-us/training/modules/prepare-child-cybersecurity-essentials/',
                type: 'course'),
            TechResource(
                title: 'Cykea Cybersecurity Resources',
                url: 'https://www.cykea.com/',
                type: 'resource'),
            TechResource(
                title: 'Cisco Cybersecurity Course',
                url: 'https://www.netacad.com/',
                type: 'course'),
            TechResource(
                title: 'Great Learning Cybersecurity',
                url:
                    'https://www.mygreatlearning.com/academy/learn-for-free/courses/introduction-to-cyber-security',
                type: 'course'),
            TechResource(
                title: 'OWASP Top 10',
                url: 'https://owasp.org/www-project-top-ten/',
                type: 'guide'),
            TechResource(
                title: 'MITRE ATT&CK®',
                url: 'https://attack.mitre.org/',
                type: 'framework'),
            TechResource(
                title: 'NIST Cybersecurity Framework (CSF 2.0)',
                url: 'https://www.nist.gov/cyberframework',
                type: 'framework'),
            TechResource(
                title: 'TryHackMe',
                url: 'https://tryhackme.com/',
                type: 'course'),
            TechResource(
                title: 'Hack The Box',
                url: 'https://www.hackthebox.com/',
                type: 'lab'),
            TechResource(
                title: 'Nmap Reference Guide',
                url: 'https://nmap.org/book/man-briefoptions.html',
                type: 'docs'),
            TechResource(
                title: 'Burp Suite Docs',
                url: 'https://portswigger.net/burp/documentation',
                type: 'docs'),
            TechResource(
                title: 'Kali Linux Docs',
                url: 'https://www.kali.org/docs/',
                type: 'docs'),
            TechResource(
                title: 'CIS Benchmarks',
                url: 'https://www.cisecurity.org/cis-benchmarks',
                type: 'guide'),
          ]),
      TechCategory('Product Design', Icons.apps, Colors.blue,
          imagePath: 'assets/images/figma.png',
          resources: [
            TechResource(
                title: 'Material Design 3',
                url: 'https://m3.material.io/',
                type: 'guide'),
            TechResource(
                title: 'Apple Human Interface Guidelines',
                url:
                    'https://developer.apple.com/design/human-interface-guidelines/',
                type: 'guide'),
            TechResource(
                title: 'Fluent Design System',
                url: 'https://developer.microsoft.com/en-us/fluentui',
                type: 'guide'),
            TechResource(
                title: 'WCAG 2.2 (Accessibility)',
                url: 'https://www.w3.org/WAI/standards-guidelines/wcag/',
                type: 'standard'),
            TechResource(
                title: 'WAI-ARIA Authoring Practices',
                url: 'https://www.w3.org/WAI/ARIA/apg/',
                type: 'guide'),
            TechResource(
                title: 'Figma Help Center',
                url: 'https://help.figma.com/hc/en-us',
                type: 'docs'),
            TechResource(
                title: 'Nielsen Norman Group (UX Research)',
                url: 'https://www.nngroup.com/articles/',
                type: 'guide'),
            TechResource(
                title: 'Design System – USWDS',
                url: 'https://designsystem.digital.gov/',
                type: 'guide'),
          ]),
      TechCategory('AI/ML', Icons.psychology, Colors.teal,
          imagePath: 'assets/images/ai.png',
          resources: [
            TechResource(
                title: 'Introduction to Azure Machine Learning',
                url:
                    'https://learn.microsoft.com/en-us/training/modules/intro-to-azure-ml/',
                type: 'course'),
            TechResource(
                title: 'Introduction to MLOps',
                url:
                    'https://learn.microsoft.com/en-us/training/paths/introduction-machine-learn-operations/',
                type: 'course'),
            TechResource(
                title: 'Understand data science for machine learning',
                url:
                    'https://learn.microsoft.com/en-us/training/paths/understand-machine-learning/',
                type: 'course'),
            TechResource(
                title: 'Google\'s ML Crash Course',
                url:
                    'https://developers.google.com/machine-learning/crash-course',
                type: 'course'),
            TechResource(
                title: 'Stanford ML YouTube Playlist',
                url:
                    'https://youtube.com/playlist?list=PLoROMvodv4rMiGQp3WXShtMGgzqpfVfbU',
                type: 'video'),
            TechResource(
                title: 'Kaggle Learning Platform',
                url: 'https://www.kaggle.com',
                type: 'platform'),
            TechResource(
                title: 'Python for beginners',
                url:
                    'https://learn.microsoft.com/en-us/training/paths/beginner-python/',
                type: 'course'),
            TechResource(
                title: 'Create and manage projects in Python',
                url:
                    'https://learn.microsoft.com/en-us/training/modules/python-create-manage-projects/',
                type: 'course'),
            TechResource(
                title: 'TensorFlow',
                url: 'https://www.tensorflow.org/',
                type: 'docs'),
            TechResource(
                title: 'PyTorch',
                url: 'https://pytorch.org/docs/stable/index.html',
                type: 'docs'),
            TechResource(
                title: 'scikit-learn User Guide',
                url: 'https://scikit-learn.org/stable/user_guide.html',
                type: 'docs'),
            TechResource(
                title: 'Keras', url: 'https://keras.io/', type: 'docs'),
            TechResource(
                title: 'JAX',
                url: 'https://jax.readthedocs.io/en/latest/',
                type: 'docs'),
            TechResource(
                title: 'Hugging Face Transformers',
                url: 'https://huggingface.co/docs/transformers/index',
                type: 'docs'),
            TechResource(
                title: 'fast.ai', url: 'https://docs.fast.ai/', type: 'docs'),
            TechResource(
                title: 'OpenAI API Docs',
                url: 'https://platform.openai.com/docs',
                type: 'docs'),
            TechResource(
                title: 'Google Cloud Skills',
                url: 'https://www.cloudskillsboost.google/course_templates/155',
                type: 'course'),
            TechResource(
                title: 'Azure Cloud Course',
                url:
                    'https://www.mygreatlearning.com/academy/learn-for-free/courses/azure-course',
                type: 'course'),
          ]),
      TechCategory('Data Science', Icons.storage, Colors.purple,
          imagePath: 'assets/images/datascience.png',
          resources: [
            TechResource(
                title: 'Python for beginners',
                url:
                    'https://learn.microsoft.com/en-us/training/paths/beginner-python/',
                type: 'course'),
            TechResource(
                title: 'Create and manage projects in Python',
                url:
                    'https://learn.microsoft.com/en-us/training/modules/python-create-manage-projects/',
                type: 'course'),
            TechResource(
                title: 'Introduction to data for machine learning',
                url:
                    'https://learn.microsoft.com/en-us/training/modules/introduction-to-data-for-machine-learning/',
                type: 'course'),
            TechResource(
                title: 'Introduction to data analytics on Azure',
                url:
                    'https://learn.microsoft.com/en-us/training/paths/introduction-data-analytics-azure/',
                type: 'course'),
            TechResource(
                title: 'Data analysis with Power BI',
                url:
                    'https://learn.microsoft.com/en-us/training/paths/prepare-data-power-bi/',
                type: 'course'),
            TechResource(
                title: 'Harvard Data Science Courses',
                url: 'https://pll.harvard.edu/subject/data-science',
                type: 'course'),
            TechResource(
                title: 'SQL fundamentals',
                url:
                    'https://learn.microsoft.com/en-us/training/paths/azure-sql-fundamentals/',
                type: 'course'),
            TechResource(
                title: 'pandas',
                url: 'https://pandas.pydata.org/docs/',
                type: 'docs'),
            TechResource(
                title: 'NumPy',
                url: 'https://numpy.org/doc/stable/',
                type: 'docs'),
            TechResource(
                title: 'Matplotlib',
                url: 'https://matplotlib.org/stable/',
                type: 'docs'),
            TechResource(
                title: 'Jupyter',
                url: 'https://docs.jupyter.org/en/latest/',
                type: 'docs'),
            TechResource(
                title: 'Apache Spark',
                url: 'https://spark.apache.org/docs/latest/',
                type: 'docs'),
            TechResource(
                title: 'PostgreSQL Docs',
                url: 'https://www.postgresql.org/docs/',
                type: 'docs'),
            TechResource(
                title: 'Apache Airflow',
                url: 'https://airflow.apache.org/docs/',
                type: 'docs'),
            TechResource(
                title: 'dbt (Data Build Tool)',
                url: 'https://docs.getdbt.com/',
                type: 'docs'),
            TechResource(
                title: 'Kaggle Learn',
                url: 'https://www.kaggle.com/learn',
                type: 'course'),
          ]),
    ],
    'Hardware': [
      TechCategory(
          'Circuit\nDesign',
          Icons.memory,
          imagePath: 'assets/images/schematic.png',
          Colors.orange,
          resources: [
            TechResource(
                title: 'LTspice (Analog Devices)',
                url:
                    'https://www.analog.com/en/resources/design-tools-and-calculators/ltspice-simulator.html',
                type: 'tool'),
            TechResource(
                title: 'ngspice',
                url: 'http://ngspice.sourceforge.net/docs.html',
                type: 'docs'),
            TechResource(
                title: 'Texas Instruments Reference Designs',
                url: 'https://www.ti.com/reference-designs/index.html',
                type: 'guide'),
            TechResource(
                title: 'Falstad Circuit Simulator',
                url: 'https://www.falstad.com/circuit/',
                type: 'tool'),
            TechResource(
                title: 'MIT OCW – Circuits & Electronics',
                url:
                    'https://ocw.mit.edu/courses/6-002-circuits-and-electronics-spring-2007/',
                type: 'course'),
            TechResource(
                title: 'All About Circuits – Textbook',
                url: 'https://www.allaboutcircuits.com/textbook/',
                type: 'guide'),
          ]),
      TechCategory('IoT\nDevelopment', Icons.router, Colors.green, resources: [
        TechResource(
            title: 'Arduino Docs',
            url: 'https://docs.arduino.cc/',
            type: 'docs'),
        TechResource(
            title: 'ESP-IDF (Espressif) Docs',
            url: 'https://docs.espressif.com/projects/esp-idf/en/latest/',
            type: 'docs'),
        TechResource(
            title: 'Raspberry Pi Documentation',
            url: 'https://www.raspberrypi.com/documentation/',
            type: 'docs'),
        TechResource(
            title: 'MQTT (OASIS Standard)',
            url: 'https://mqtt.org/',
            type: 'standard'),
        TechResource(
            title: 'Eclipse Paho (MQTT Clients)',
            url: 'https://www.eclipse.org/paho/',
            type: 'docs'),
        TechResource(
            title: 'AWS IoT Core Docs',
            url: 'https://docs.aws.amazon.com/iot/',
            type: 'docs'),
        TechResource(
            title: 'Azure IoT Docs',
            url: 'https://learn.microsoft.com/azure/iot-fundamentals/',
            type: 'docs'),
        TechResource(
            title: 'Node-RED Docs',
            url: 'https://nodered.org/docs/',
            type: 'docs'),
      ]),
      TechCategory('Robotics', Icons.smart_toy, Colors.red, resources: [
        TechResource(
            title: 'ROS 2 Documentation',
            url: 'https://docs.ros.org/en/rolling/',
            type: 'docs'),
        TechResource(
            title: 'OpenCV Docs',
            url: 'https://docs.opencv.org/master/',
            type: 'docs'),
        TechResource(
            title: 'Gazebo Sim Docs',
            url: 'https://gazebosim.org/docs',
            type: 'docs'),
        TechResource(
            title: 'MoveIt 2 Docs',
            url: 'https://moveit.picknik.ai/main/index.html',
            type: 'docs'),
        TechResource(
            title: 'PX4 Autopilot Docs',
            url: 'https://docs.px4.io/main/en/',
            type: 'docs'),
        TechResource(
            title: 'NVIDIA Isaac Sim Docs',
            url: 'https://docs.nvidia.com/isaac/isaac-sim/',
            type: 'docs'),
      ]),
      TechCategory('Electronics', Icons.electrical_services, Colors.blue,
          imagePath: 'assets/images/diode.png',
          resources: [
            TechResource(
                title: 'All About Circuits – Textbook',
                url: 'https://www.allaboutcircuits.com/textbook/',
                type: 'guide'),
            TechResource(
                title: 'Electronics-Tutorials.ws',
                url: 'https://www.electronics-tutorials.ws/',
                type: 'guide'),
            TechResource(
                title: 'MIT OCW – Circuits & Electronics',
                url:
                    'https://ocw.mit.edu/courses/6-002-circuits-and-electronics-spring-2007/',
                type: 'course'),
            TechResource(
                title: 'Digi-Key TechForum/Guides',
                url: 'https://forum.digikey.com/c/guides/36',
                type: 'guide'),
            TechResource(
                title: 'Analog Devices University',
                url:
                    'https://www.analog.com/en/education/education-library/university-program.html',
                type: 'guide'),
            TechResource(
                title: 'TI Training',
                url: 'https://www.ti.com/training.html',
                type: 'course'),
          ]),
      TechCategory('Embedded\nSystems', Icons.computer, Colors.teal,
          resources: [
            TechResource(
                title: 'Two Wheeled Drive Car with a Robotic Arm',
                url:
                    'https://www.instructables.com/Two-Wheeled-Drive-Car-With-a-Robotic-Arm/',
                type: 'docs'),
            TechResource(
                title: 'FreeRTOS Docs',
                url: 'https://www.freertos.org/Documentation/RTOS_book.html',
                type: 'docs'),
            TechResource(
                title: 'Zephyr RTOS Docs',
                url: 'https://docs.zephyrproject.org/latest/',
                type: 'docs'),
            TechResource(
                title: 'ARM Cortex-M TRMs',
                url: 'https://developer.arm.com/documentation/',
                type: 'docs'),
            TechResource(
                title: 'STM32Cube HAL Docs',
                url:
                    'https://www.st.com/en/embedded-software/stm32cube-mcu-packages.html',
                type: 'docs'),
            TechResource(
                title: 'PlatformIO Docs',
                url: 'https://docs.platformio.org/en/latest/',
                type: 'docs'),
            TechResource(
                title: 'Embedded Rust Book',
                url: 'https://docs.rust-embedded.org/book/',
                type: 'guide'),
            TechResource(
                title: 'ESP-IDF (Espressif) Docs',
                url: 'https://docs.espressif.com/projects/esp-idf/en/latest/',
                type: 'docs'),
          ]),
      TechCategory('PCB Design', Icons.account_tree, Colors.purple,
          imagePath: 'assets/images/pcb.png',
          resources: [
            TechResource(
                title: 'KiCad Documentation',
                url: 'https://docs.kicad.org/',
                type: 'docs'),
            TechResource(
                title: 'Altium Designer Documentation',
                url: 'https://www.altium.com/documentation/altium-designer',
                type: 'docs'),
            TechResource(
                title: 'Fusion 360 Electronics Docs',
                url:
                    'https://help.autodesk.com/view/fusion360/ENU/courses/Electronics',
                type: 'docs'),
            TechResource(
                title: 'IPC Standards (Overview)',
                url: 'https://www.ipc.org/standards',
                type: 'standard'),
            TechResource(
                title: 'OSH Park Design Rules (KiCad/EAGLE)',
                url: 'https://docs.oshpark.com/services/',
                type: 'guide'),
            TechResource(
                title: 'JLCPCB Capabilities',
                url: 'https://jlcpcb.com/capabilities/pcb-capabilities',
                type: 'guide'),
            TechResource(
                title: 'Saturn PCB Toolkit',
                url: 'https://saturnpcb.com/saturn-pcb-toolkit/',
                type: 'tool'),
          ]),
    ],
  };
  bool get isHardwareCategory => selectedCategory == 'Hardware';

  @override
  Widget build(BuildContext context) {

    final firstTimeProvider = Provider.of<OnboardingProvider>(context);

    // Show loading while checking first time status
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    // Show reminder page if it's the first time
    if (firstTimeProvider.isFirstTime) {
      return QuickReminderSetupScreen(
          onContinue: _handleFirstTimeComplete,
        isSoftware: widget.isSoftware ?? true,
      );
    }
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _buildHeader(),
            ),
            SliverToBoxAdapter(
              child: _buildHeroBanner(),
            ),
            _buildTechGrid(),
            SliverToBoxAdapter(
              child: _buildRoadmapSection(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedCategory,
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.teal,
                ),
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.teal,
                ),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedCategory = newValue;
                    });
                  }
                },
                items: categories.keys
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: !isHardwareCategory
              ? [
                  const Color(0xff166D86),
                  const Color(0xFF166D86),
                ]
              : [
                  const Color(0xffB2FFB2),
                  const Color(0xffB2FFB2),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
     child: LayoutBuilder(
  builder: (context, constraints) {
    final isSmallScreen = constraints.maxWidth < 400;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Text section
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isHardwareCategory
                    ? 'Learn Hardware with Ease'
                    : 'Master Programming with Ease',
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 20 : 24,
                  fontWeight: FontWeight.bold,
                  color: isHardwareCategory
                      ? AppTheme.primaryTeal
                      : AppTheme.lightGreen,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose and learn based on your tech niche',
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 14 : 18,
                  color: isHardwareCategory
                      ? AppTheme.textColor
                      : Colors.white.withOpacity(0.9),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),

        // Image section
        Flexible(
          flex: 1,
          child: SizedBox(
            height: isSmallScreen ? 140 : 180,
            child: Image.asset(
              isHardwareCategory
                  ? 'assets/images/learn-hard.png'
                  : 'assets/images/learn-soft.png',
              fit: BoxFit.contain,
              alignment: Alignment.center,
            ),
          ),
        ),
      ],
    );
  },
),
 );
  }

  Widget _buildTechGrid() {
    final currentCategories = categories[selectedCategory] ?? [];
    
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 0,
        childAspectRatio: 0.9,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final category = currentCategories[index];
          return _buildTechCard(category);
        },
        childCount: currentCategories.length,
      ),
    );
  }

  Widget _buildTechCard(TechCategory category) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TechResourcesPage(
                category: category,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon container
              (category.imagePath != null)
                  ? Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: category.color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: category.color.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(
                            12), // 👈 gives breathing space like icon
                        child: Image.asset(
                          category.imagePath!,
                          fit: BoxFit.contain, // 👈 prevents stretching
                        ),
                      ),
                    )
                  : Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: category.color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: category.color.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: category.isText
                          ? Center(
                              child: Text(
                                category.name,
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : Icon(
                              category.iconData,
                              color: Colors.white,
                              size: 28,
                            ),
                    ),

              const SizedBox(height: 16),

              // Category name
              Text(
                category.name,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textColor,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoadmapSection(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => WebviewWidget(
                    url: 'https://roadmap.sh/',
                    title: 'Personalized Roadmap',
                  )),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primaryTeal, AppTheme.primaryTeal.withOpacity(0.6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.map, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Roadmap',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Follow a step-by-step roadmap to guide your learning journey.',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => WebviewWidget(
                            url: 'https://roadmap.sh/',
                            title: 'Personalized Roadmap',
                          )),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue.shade600,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.arrow_forward, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'View Roadmap',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}