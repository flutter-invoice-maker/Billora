import 'package:flutter/material.dart';
import '../widgets/animated_image_container.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _textAnimationController;
  late AnimationController _backgroundController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _backgroundAnimation;
  
  int _currentPage = 0;
  final int _totalPages = 3;
  
  final List<OnboardingSlide> _slides = [
    OnboardingSlide(
      title: "Transform Your Business",
      subtitle: "Smart Invoice Management",
      description: "Say goodbye to manual paperwork! Create, manage, and track invoices with lightning speed. Your business deserves better than spreadsheets.",
      imagePlaceholder: "assets/images/onboarding_1.png",
      primaryColor: Color(0xFF8B5FBF),
      secondaryColor: Color(0xFFB794F6),
    ),
    OnboardingSlide(
      title: "AI-Powered Scanning",
      subtitle: "Magic at Your Fingertips",
      description: "Just point your camera and watch the magic happen! Our AI reads your bills like a human, but faster and never gets tired. 99% accuracy guaranteed!",
      imagePlaceholder: "assets/images/onboarding_2.png",
      primaryColor: Color(0xFF7C3AED),
      secondaryColor: Color(0xFFA78BFA),
    ),
    OnboardingSlide(
      title: "Insights That Matter",
      subtitle: "Data-Driven Growth",
      description: "Turn numbers into stories! Get beautiful charts, smart predictions, and insights that actually help you make better business decisions.",
      imagePlaceholder: "assets/images/onboarding_3.png",
      primaryColor: Color(0xFF6D28D9),
      secondaryColor: Color(0xFF9F7AEA),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    _textAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 20000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textAnimationController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0.0), // Changed from vertical to horizontal slide
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textAnimationController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
    ));
    
    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.linear,
    ));

    // Start animations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _textAnimationController.forward();
      _backgroundController.repeat();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _textAnimationController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _navigateToLogin();
    }
  }

  void _skipOnboarding() {
    _navigateToLogin();
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacementNamed('/login');
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    _textAnimationController.reset();
    _textAnimationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final currentSlide = _slides[_currentPage];
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;
    
    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                                 colors: [
                   Colors.white,
                   currentSlide.secondaryColor.withValues(alpha: 0.05),
                   Colors.white,
                   currentSlide.primaryColor.withValues(alpha: 0.08),
                 ],
                stops: [
                  0.0,
                  0.3 + (_backgroundAnimation.value * 0.2),
                  0.7 + (_backgroundAnimation.value * 0.1),
                  1.0,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Top section with skip button - reduced height
                  _buildTopSection(isSmallScreen),
                  
                  // Main content - adjusted flex to fit screen
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: _onPageChanged,
                      itemCount: _totalPages,
                      itemBuilder: (context, index) {
                        return _buildSlide(_slides[index], index, isSmallScreen);
                      },
                    ),
                  ),
                  
                  // Bottom navigation - reduced height
                  _buildBottomNavigation(isSmallScreen),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopSection(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: isSmallScreen ? 4 : 8),
      height: isSmallScreen ? 60 : 80, // Reduced height
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side - Skip text (on slide 1 and 2)
          (_currentPage == 0 || _currentPage == 1)
              ? FadeTransition(
                  opacity: _fadeAnimation,
                  child: GestureDetector(
                    onTap: _skipOnboarding,
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: _slides[_currentPage].primaryColor.withValues(alpha: 0.7),
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
              : SizedBox(width: isSmallScreen ? 60 : 80), // Placeholder to maintain spacing
          
          // Center - Logo - reduced size
          FadeTransition(
            opacity: _fadeAnimation,
            child: Image.asset(
              'assets/icons/logo.png',
              height: isSmallScreen ? 60 : 70, // Reduced size
              width: isSmallScreen ? 60 : 70,
              fit: BoxFit.contain,
            ),
          ),
          
          // Right side - Navigation icon (only arrow for slide 1 and 2)
          _currentPage < _totalPages - 1
              ? FadeTransition(
                  opacity: _fadeAnimation,
                  child: GestureDetector(
                    onTap: _nextPage,
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: _slides[_currentPage].primaryColor,
                        size: isSmallScreen ? 20 : 24,
                    ),
                  ),
                )
              : SizedBox(width: isSmallScreen ? 60 : 80), // Placeholder to maintain spacing
        ],
      ),
    );
  }

  Widget _buildSlide(OnboardingSlide slide, int index, bool isSmallScreen) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              SizedBox(height: isSmallScreen ? 5 : 10),
              
              // Animated image container - reduced flex
              Expanded(
                flex: isSmallScreen ? 2 : 3, // Reduced flex for smaller screens
                child: Center(
                  child: AnimatedImageContainer(
                    imagePath: slide.imagePlaceholder,
                    fallbackIcon: _getIconForSlide(index),
                    placeholderText: _getPlaceholderText(index),
                    slideIndex: index,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Image picker will be implemented here'),
                          backgroundColor: slide.primaryColor,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              
              // Text content - adjusted flex and removed scroll
              Expanded(
                flex: isSmallScreen ? 2 : 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title - reduced font size
                    Text(
                      slide.title,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 24 : 28, // Reduced font size
                        fontWeight: FontWeight.bold,
                        color: slide.primaryColor,
                        height: 1.2,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    SizedBox(height: isSmallScreen ? 8 : 12),
                    
                    // Subtitle
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: isSmallScreen ? 6 : 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: [
                            slide.secondaryColor.withValues(alpha: 0.1),
                            slide.primaryColor.withValues(alpha: 0.05),
                          ],
                        ),
                      ),
                      child: Text(
                        slide.subtitle,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.w600,
                          color: slide.primaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    
                    SizedBox(height: isSmallScreen ? 12 : 16),
                    
                    // Description - reduced font size and padding
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16),
                      child: Text(
                        slide.description,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 13 : 15, // Reduced font size
                          color: const Color(0xFF64748B),
                          height: 1.5, // Reduced line height
                          letterSpacing: 0.1,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: isSmallScreen ? 4 : 5, // Limit lines for small screens
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation(bool isSmallScreen) {
    final currentSlide = _slides[_currentPage];
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: isSmallScreen ? 12.0 : 16.0),
      height: isSmallScreen ? 60 : 80, // Reduced height
      child: _currentPage == _totalPages - 1
          ? Center(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      currentSlide.primaryColor,
                      currentSlide.secondaryColor,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: currentSlide.primaryColor.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 30 : 40, vertical: isSmallScreen ? 12 : 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                    shadowColor: Colors.transparent,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Get Started',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: isSmallScreen ? 6 : 8),
                      Icon(
                        Icons.rocket_launch_rounded,
                        size: isSmallScreen ? 18 : 20,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            )
          : Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _totalPages,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOutCubic,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: _currentPage == index ? 32 : 12,
                    height: 12,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      gradient: _currentPage == index
                          ? LinearGradient(
                              colors: [
                                currentSlide.primaryColor,
                                currentSlide.secondaryColor,
                              ],
                            )
                          : null,
                      color: _currentPage == index
                          ? null
                          : currentSlide.primaryColor.withValues(alpha: 0.2),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  IconData _getIconForSlide(int pageIndex) {
    switch (pageIndex) {
      case 0:
        return Icons.dashboard_rounded;
      case 1:
        return Icons.document_scanner_rounded;
      case 2:
        return Icons.analytics_rounded;
      default:
        return Icons.dashboard_rounded;
    }
  }

  String _getPlaceholderText(int pageIndex) {
    switch (pageIndex) {
      case 0:
        return 'Dashboard Preview';
      case 1:
        return 'Smart Scanning';
      case 2:
        return 'Analytics Dashboard';
      default:
        return 'Beautiful Illustration';
    }
  }
}

class OnboardingSlide {
  final String title;
  final String subtitle;
  final String description;
  final String imagePlaceholder;
  final Color primaryColor;
  final Color secondaryColor;

  OnboardingSlide({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.imagePlaceholder,
    required this.primaryColor,
    required this.secondaryColor,
  });
}
