import 'package:db_practice/home_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IntroductionScreen extends StatefulWidget {
  final Function() onCompleted;

  const IntroductionScreen({Key? key, required this.onCompleted}) : super(key: key);

  @override
  State<IntroductionScreen> createState() => _IntroductionScreenState();
}

class _IntroductionScreenState extends State<IntroductionScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<IntroPage> _pages = [
    IntroPage(
      title: "Welcome to Notes",
      subtitle: "Your thoughts, organized beautifully",
      description: "Capture ideas, make lists, and never forget important moments with our intuitive note-taking app.",
      icon: Icons.lightbulb_outline,
      gradient: [Color(0xFF667eea), Color(0xFF764ba2)],
      animation: "welcome",
    ),
    IntroPage(
      title: "Pin Important Notes",
      subtitle: "Keep what matters most at the top",
      description: "Pin your most important notes to keep them easily accessible and never lose track of priority items.",
      icon: Icons.push_pin_outlined,
      gradient: [Color(0xFFf093fb), Color(0xFFf5576c)],
      animation: "pin",
    ),
    IntroPage(
      title: "Search & Organize",
      subtitle: "Find anything in seconds",
      description: "Powerful search functionality helps you locate any note instantly, making organization effortless.",
      icon: Icons.search_outlined,
      gradient: [Color(0xFF4facfe), Color(0xFF00f2fe)],
      animation: "search",
    ),
    IntroPage(
      title: "Start Writing",
      subtitle: "Your digital notebook awaits",
      description: "Ready to transform how you capture and organize your thoughts? Let's get started on your journey!",
      icon: Icons.edit_note_outlined,
      gradient: [Color(0xFF43e97b), Color(0xFF38f9d7)],
      animation: "start",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onCompleted();
    }
  }

  void _skipIntro() {
    widget.onCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
              _animationController.reset();
              _animationController.forward();
            },
            itemBuilder: (context, index) {
              return _buildPage(_pages[index], index);
            },
          ),

          // Skip button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 20,
            child: TextButton(
              onPressed: _skipIntro,
              child: Text(
                'Skip',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // Bottom navigation
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: _buildBottomNavigation(),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(IntroPage page, int index) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: page.gradient,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(flex: 2),

              // Animated Icon
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildAnimatedIcon(page.icon, page.animation),
                ),
              ),

              SizedBox(height: 60),

              // Title
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    page.title,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'BethEllen',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Subtitle
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    page.subtitle,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              SizedBox(height: 32),

              // Description
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    page.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.8),
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedIcon(IconData icon, String animationType) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 1000),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 50,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomNavigation() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Page indicators
          Row(
            children: List.generate(
              _pages.length,
                  (index) => AnimatedContainer(
                duration: Duration(milliseconds: 300),
                margin: EdgeInsets.only(right: 8),
                width: _currentPage == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? Colors.white
                      : Colors.white.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),

          // Next/Get Started button
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: _pages[_currentPage].gradient[0],
                elevation: 8,
                shadowColor: Colors.black.withOpacity(0.3),
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    _currentPage == _pages.length - 1
                        ? Icons.rocket_launch
                        : Icons.arrow_forward,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class IntroPage {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final List<Color> gradient;
  final String animation;

  IntroPage({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.gradient,
    required this.animation,
  });
}

// Usage in your main app:
// Add this to your main.dart or wherever you handle first-time user experience

class AppWrapper extends StatefulWidget {
  @override
  _AppWrapperState createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  bool _showIntro = true; // You can get this from SharedPreferences

  @override
  void initState() {
    super.initState();
    _checkFirstTime();
  }

  void _checkFirstTime() async {
    // Check if this is the first time opening the app
    // You can use SharedPreferences for this
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstTime = prefs.getBool('first_time') ?? true;
    setState(() {
      _showIntro = isFirstTime;
    });
  }

  void _completeIntro() async {
    // Mark intro as completed
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_time', false);

    setState(() {
      _showIntro = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showIntro) {
      return IntroductionScreen(onCompleted: _completeIntro);
    } else {
      return HomePage(); // Replace with your main notes app widget
    }
  }
}

// Placeholder for your main app
// class YourMainNotesApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Notes App')),
//       body: Center(child: Text('Your main notes app goes here')),
//     );
//   }
// }