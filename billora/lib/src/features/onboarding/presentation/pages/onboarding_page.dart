import 'package:flutter/material.dart';
import 'dart:math' as math;

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> 
    with TickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _mainAnimationController;
  late final AnimationController _logoAnimationController;
  late final AnimationController _particleController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _logoRotation;
  late final Animation<double> _logoScale;
  int _currentPage = 0;

  final List<_OnboardData> _slides = const [
    _OnboardData(
      title: 'Welcome to Billora',
      subtitle: 'Your Business Command Center',
      description: 'Transform the way you manage your business with our comprehensive invoice and customer management platform. Built for modern entrepreneurs who demand excellence.',
      features: [
        'Seamless invoice creation and tracking',
        'Advanced customer relationship management',
        'Real-time business analytics and insights',
        'Multi-platform synchronization'
      ],
      icon: Icons.auto_awesome,
      accentColor: Color(0xFF6366F1),
    ),
    _OnboardData(
      title: 'Smart Invoice Management',
      subtitle: 'Automate Your Workflow',
      description: 'Create professional invoices in seconds, track payments automatically, and never miss a deadline. Our intelligent system learns from your patterns to make suggestions.',
      features: [
        'AI-powered invoice templates',
        'Automatic payment reminders',
        'Multi-currency support',
        'PDF generation and email integration'
      ],
      icon: Icons.receipt_long_outlined,
      accentColor: Color(0xFF10B981),
    ),
    _OnboardData(
      title: 'Insights & Control',
      subtitle: 'Data-Driven Decisions',
      description: 'Unlock the power of your business data with comprehensive analytics, custom reports, and predictive insights that help you grow smarter.',
      features: [
        'Interactive dashboard with real-time metrics',
        'Custom report generation',
        'Predictive cash flow analysis',
        'Performance trend tracking'
      ],
      icon: Icons.analytics_outlined,
      accentColor: Color(0xFFF59E0B),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    _mainAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainAnimationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
    ));
    
    _logoRotation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.elasticOut,
    ));
    
    _logoScale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));
    
    _startAnimations();
  }

  void _startAnimations() {
    _mainAnimationController.forward();
    _logoAnimationController.forward();
    _particleController.repeat();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _mainAnimationController.dispose();
    _logoAnimationController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Animated background particles
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, child) {
              return CustomPaint(
                painter: ParticlePainter(_particleController.value),
                size: Size(screenWidth, screenHeight),
              );
            },
          ),
          
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: screenHeight - MediaQuery.of(context).padding.top,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        // Enhanced header
                        Container(
                          height: screenHeight * 0.12,
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 48.0 : 24.0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedBuilder(
                                animation: _logoAnimationController,
                                builder: (context, child) {
                                  return Transform.rotate(
                                    angle: _logoRotation.value,
                                    child: Transform.scale(
                                      scale: _logoScale.value,
                                      child: Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Image.asset(
                                          'assets/icons/logo.png',
                                          fit: BoxFit.contain,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              decoration: BoxDecoration(
                                                color: Colors.black,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: const Icon(
                                                Icons.auto_awesome,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Billora',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: isTablet ? 22 : 20,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Enhanced content area
                        Expanded(
                          child: PageView.builder(
                            controller: _pageController,
                            onPageChanged: (i) => setState(() => _currentPage = i),
                            itemCount: _slides.length,
                            itemBuilder: (context, index) => _OnboardCard(
                              data: _slides[index],
                              isTablet: isTablet,
                              pageIndex: index,
                            ),
                          ),
                        ),
                        
                        // Enhanced bottom section
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 48.0 : 24.0,
                            vertical: 24.0,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Enhanced page indicators
                              SizedBox(
                                height: 32,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(_slides.length, (i) {
                                    final active = i == _currentPage;
                                    return AnimatedContainer(
                                      duration: const Duration(milliseconds: 400),
                                      curve: Curves.easeInOutCubic,
                                      margin: const EdgeInsets.symmetric(horizontal: 8),
                                      height: active ? 8 : 6,
                                      width: active ? 40 : 6,
                                      decoration: BoxDecoration(
                                        color: active 
                                            ? _slides[_currentPage].accentColor
                                            : Colors.grey[300],
                                        borderRadius: BorderRadius.circular(4),
                                        boxShadow: active ? [
                                          BoxShadow(
                                            color: _slides[_currentPage].accentColor.withValues(alpha: 0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ] : null,
                                      ),
                                    );
                                  }),
                                ),
                              ),
                              
                              const SizedBox(height: 32),
                              
                              // Enhanced next button
                              SizedBox(
                                width: double.infinity,
                                height: isTablet ? 64 : 56,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.1),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: _nextPage,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: Text(
                                      _currentPage < _slides.length - 1 ? 'Next' : 'Get Started',
                                      style: TextStyle(
                                        fontSize: isTablet ? 18 : 16,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardCard extends StatefulWidget {
  final _OnboardData data;
  final bool isTablet;
  final int pageIndex;
  
  const _OnboardCard({
    required this.data,
    required this.isTablet,
    required this.pageIndex,
  });

  @override
  State<_OnboardCard> createState() => _OnboardCardState();
}

class _OnboardCardState extends State<_OnboardCard>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _staggerController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _iconAnimation;
  late List<Animation<double>> _featureAnimations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    
    _iconAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));
    
    _featureAnimations = List.generate(
      widget.data.features.length,
      (index) => Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _staggerController,
        curve: Interval(
          index * 0.1,
          0.6 + (index * 0.1),
          curve: Curves.easeOutCubic,
        ),
      )),
    );
    
    _controller.forward();
    _staggerController.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final iconSize = widget.isTablet ? 120.0 : 100.0;
    
    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: widget.isTablet ? 48.0 : 24.0,
            vertical: 20.0,
          ),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Enhanced icon container
                    AnimatedBuilder(
                      animation: _iconAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _iconAnimation.value,
                          child: Container(
                            width: iconSize,
                            height: iconSize,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: widget.data.accentColor.withValues(alpha: 0.2),
                                  blurRadius: 30,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: widget.data.title == 'Welcome to Billora' 
                                ? Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(28),
                                      border: Border.all(
                                        color: Colors.grey[200]!,
                                        width: 1,
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(20),
                                    child: Image.asset(
                                      'assets/icons/logo.png',
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            color: Colors.black,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Icon(
                                            widget.data.icon,
                                            size: widget.isTablet ? 60 : 50,
                                            color: Colors.white,
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                : Container(
                                    decoration: BoxDecoration(
                                      color: widget.data.accentColor,
                                      borderRadius: BorderRadius.circular(28),
                                    ),
                                    child: Icon(
                                      widget.data.icon,
                                      size: widget.isTablet ? 60 : 50,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
                    
                    SizedBox(height: screenHeight * 0.04),
                    
                    // Enhanced title and subtitle
                    Column(
                      children: [
                        Text(
                          widget.data.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: widget.isTablet ? 32 : 28,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                            height: 1.1,
                            letterSpacing: -0.8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.data.subtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: widget.isTablet ? 18 : 16,
                            fontWeight: FontWeight.w600,
                            color: widget.data.accentColor,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: screenHeight * 0.025),
                    
                    // Enhanced description
                    Text(
                      widget.data.description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: widget.isTablet ? 16 : 14,
                        height: 1.5,
                        letterSpacing: -0.1,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    
                    SizedBox(height: screenHeight * 0.03),
                    
                    // Animated feature list
                    Column(
                      children: widget.data.features.asMap().entries.map((entry) {
                        final index = entry.key;
                        final feature = entry.value;
                        
                        return AnimatedBuilder(
                          animation: _featureAnimations[index],
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(
                                0,
                                20 * (1 - _featureAnimations[index].value),
                              ),
                              child: Opacity(
                                opacity: _featureAnimations[index].value,
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: widget.data.accentColor.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: widget.data.accentColor.withValues(alpha: 0.1),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: widget.data.accentColor,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          feature,
                                          style: TextStyle(
                                            color: Colors.grey[700],
                                            fontSize: widget.isTablet ? 14 : 13,
                                            fontWeight: FontWeight.w500,
                                            height: 1.3,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
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
}

class ParticlePainter extends CustomPainter {
  final double animationValue;

  ParticlePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 15; i++) {
      final x = (size.width * (i * 0.1 + 0.1) + 
                 math.sin(animationValue * 2 * math.pi + i) * 30) % size.width;
      final y = (size.height * (i * 0.08 + 0.1) + 
                 math.cos(animationValue * 2 * math.pi + i) * 20) % size.height;
      
      canvas.drawCircle(
        Offset(x, y),
        2 + math.sin(animationValue * 4 * math.pi + i) * 1,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _OnboardData {
  final String title;
  final String subtitle;
  final String description;
  final List<String> features;
  final IconData icon;
  final Color accentColor;
  
  const _OnboardData({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.features,
    required this.icon,
    required this.accentColor,
  });
}