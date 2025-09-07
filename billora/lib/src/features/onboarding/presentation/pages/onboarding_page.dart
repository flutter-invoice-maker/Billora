import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class OnboardingPage extends StatefulWidget {
  final VoidCallback? onComplete;
  
  const OnboardingPage({super.key, this.onComplete});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> 
    with TickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _mainAnimationController;
  late final AnimationController _logoAnimationController;
  late final AnimationController _skipAnimationController;
  late final AnimationController _progressController;
  late final List<AnimationController> _textControllers;
  
  int _currentPage = 0;
  bool _showSkip = true;

  final List<_OnboardData> _slides = const [
    _OnboardData(
      headline: 'Welcome to',
      brandName: 'Billora',
      subtitle: 'Your Business Command Center',
      description: 'Transform the way you manage your business with our comprehensive platform designed for modern entrepreneurs.',
      keywords: ['Business', 'Management', 'Growth', 'Success'],
      icon: Icons.auto_awesome,
    ),
    _OnboardData(
      headline: 'Smart Invoice',
      brandName: 'Management',
      subtitle: 'Automate Your Workflow',
      description: 'Create professional invoices in seconds, track payments automatically, and never miss a deadline again.',
      keywords: ['Invoices', 'Tracking', 'Automation', 'Professional'],
      icon: Icons.receipt_long_outlined,
    ),
    _OnboardData(
      headline: 'Analytics &',
      brandName: 'Insights',
      subtitle: 'Data-Driven Decisions',
      description: 'Unlock the power of your business data with comprehensive analytics and predictive insights.',
      keywords: ['Analytics', 'Data', 'Insights', 'Intelligence'],
      icon: Icons.analytics_outlined,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _startInitialAnimations();
  }

  void _initializeControllers() {
    _pageController = PageController();
    
    _mainAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    
    _skipAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _textControllers = List.generate(
      6, // For different text elements
      (index) => AnimationController(
        duration: Duration(milliseconds: 400 + (index * 100)),
        vsync: this,
      ),
    );
  }

  void _startInitialAnimations() {
    _logoAnimationController.forward();
    _progressController.forward();
    
    // Start text animations with delays
    for (int i = 0; i < _textControllers.length; i++) {
      Future.delayed(Duration(milliseconds: 300 + (i * 150)), () {
        if (mounted) {
          _textControllers[i].forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _mainAnimationController.dispose();
    _logoAnimationController.dispose();
    _skipAnimationController.dispose();
    _progressController.dispose();
    for (final controller in _textControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      // Reset text animations for next page
      for (final controller in _textControllers) {
        controller.reset();
      }
      
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      // Complete onboarding and navigate to login
      widget.onComplete?.call();
    }
  }

  void _skipOnboarding() {
    // Complete onboarding and navigate to login
    widget.onComplete?.call();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
      _showSkip = index < _slides.length - 1;
    });
    
    _progressController.reset();
    _progressController.forward();
    
    // Start text animations for new page
    for (int i = 0; i < _textControllers.length; i++) {
      Future.delayed(Duration(milliseconds: 100 + (i * 120)), () {
        if (mounted) {
          _textControllers[i].forward();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final screenHeight = constraints.maxHeight;
            final isSmallScreen = screenHeight < 700;
            final isMobile = screenWidth < 600;
            
            return Column(
              children: [
                // Header
                _buildHeader(screenWidth, isSmallScreen, isMobile),
                
                // Main content
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: _slides.length,
                    itemBuilder: (context, index) => _OnboardSlide(
                      data: _slides[index],
                      screenWidth: screenWidth,
                      screenHeight: screenHeight,
                      isSmallScreen: isSmallScreen,
                      isMobile: isMobile,
                      pageIndex: index,
                      currentPage: _currentPage,
                      textControllers: _textControllers,
                    ),
                  ),
                ),
                
                // Bottom section
                _buildBottomSection(screenWidth, isSmallScreen, isMobile),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(double screenWidth, bool isSmallScreen, bool isMobile) {
    final logoSize = isSmallScreen ? 40.0 : (isMobile ? 44.0 : 50.0);
    final titleFontSize = isSmallScreen ? 22.0 : (isMobile ? 26.0 : 30.0);
    final skipFontSize = isSmallScreen ? 15.0 : (isMobile ? 16.0 : 17.0);
    final headerPadding = isMobile ? 24.0 : 32.0;
    
    return Container(
      padding: EdgeInsets.all(headerPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          AnimatedBuilder(
            animation: _logoAnimationController,
            builder: (context, child) {
              return Transform.scale(
                scale: Tween<double>(begin: 0.0, end: 1.0)
                    .animate(CurvedAnimation(
                      parent: _logoAnimationController,
                      curve: Curves.elasticOut,
                    )).value,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: logoSize,
                      height: logoSize,
                      child: Image.asset(
                        'assets/icons/logo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.auto_awesome,
                            color: Colors.black,
                            size: logoSize,
                          );
                        },
                      ),
                    ),
                    SizedBox(width: isMobile ? 8 : 12),
                    Text(
                      'Billora',
                      style: TextStyle(
                        color: const Color(0xFF1976D2),
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          
          // Skip button
          if (_showSkip)
            GestureDetector(
              onTap: _skipOnboarding,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 20,
                  vertical: isMobile ? 8 : 10,
                ),
                child: Text(
                  'Skip',
                  style: TextStyle(
                    color: const Color(0xFF1976D2),
                    fontSize: skipFontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomSection(double screenWidth, bool isSmallScreen, bool isMobile) {
    final buttonHeight = isSmallScreen ? 52.0 : (isMobile ? 56.0 : 60.0);
    final buttonFontSize = isSmallScreen ? 15.0 : (isMobile ? 16.0 : 18.0);
    final horizontalPadding = isMobile ? 24.0 : 32.0;
    final verticalPadding = isSmallScreen ? 20.0 : 24.0;
    
    return Container(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        verticalPadding,
        horizontalPadding,
        verticalPadding + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress indicator
          AnimatedBuilder(
            animation: _progressController,
            builder: (context, child) {
              return Container(
                height: 2,
                margin: EdgeInsets.only(bottom: isSmallScreen ? 24 : 32),
                child: Row(
                  children: List.generate(_slides.length, (index) {
                    final isActive = index == _currentPage;
                    final isPassed = index < _currentPage;
                    
                    return Expanded(
                      child: Container(
                        margin: EdgeInsets.only(
                          right: index < _slides.length - 1 ? 8 : 0,
                        ),
                        decoration: BoxDecoration(
                          color: isPassed ? const Color(0xFF1976D2) : Colors.grey[300],
                          borderRadius: BorderRadius.circular(1),
                        ),
                        child: isActive
                            ? FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: _progressController.value,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1976D2),
                                    borderRadius: BorderRadius.circular(1),
                                  ),
                                ),
                              )
                            : null,
                      ),
                    );
                  }),
                ),
              );
            },
          ),
          
          // Action button
          SizedBox(
            width: double.infinity,
            height: buttonHeight,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
                foregroundColor: Colors.white,
                elevation: 2,
                shadowColor: const Color(0xFF1976D2).withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _currentPage < _slides.length - 1 ? 'Continue' : 'Get Started',
                style: TextStyle(
                  fontSize: buttonFontSize,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardSlide extends StatefulWidget {
  final _OnboardData data;
  final double screenWidth;
  final double screenHeight;
  final bool isSmallScreen;
  final bool isMobile;
  final int pageIndex;
  final int currentPage;
  final List<AnimationController> textControllers;
  
  const _OnboardSlide({
    required this.data,
    required this.screenWidth,
    required this.screenHeight,
    required this.isSmallScreen,
    required this.isMobile,
    required this.pageIndex,
    required this.currentPage,
    required this.textControllers,
  });

  @override
  State<_OnboardSlide> createState() => _OnboardSlideState();
}

class _OnboardSlideState extends State<_OnboardSlide> 
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _iconController;
  late List<AnimationController> _keywordControllers;
  
  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _iconController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _keywordControllers = List.generate(
      4,
      (index) => AnimationController(
        duration: Duration(milliseconds: 600 + (index * 100)),
        vsync: this,
      ),
    );
    
    if (widget.pageIndex == widget.currentPage) {
      _startAnimations();
    }
  }

  void _startAnimations() {
    _slideController.forward();
    _iconController.forward();
    
    // Start keyword animations without bouncing
    for (int i = 0; i < _keywordControllers.length; i++) {
      Future.delayed(Duration(milliseconds: 400 + (i * 100)), () {
        if (mounted) {
          _keywordControllers[i].forward();
        }
      });
    }
  }

  @override
  void didUpdateWidget(_OnboardSlide oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentPage == widget.pageIndex && oldWidget.currentPage != widget.pageIndex) {
      _slideController.reset();
      _iconController.reset();
      for (final controller in _keywordControllers) {
        controller.reset();
      }
      _startAnimations();
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _iconController.dispose();
    for (final controller in _keywordControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.pageIndex == widget.currentPage;
    
    // Responsive sizing - larger text
    final headlineFontSize = widget.isSmallScreen 
        ? (widget.isMobile ? 40.0 : 44.0)
        : (widget.isMobile ? 52.0 : 60.0);
    final brandFontSize = widget.isSmallScreen 
        ? (widget.isMobile ? 48.0 : 52.0)
        : (widget.isMobile ? 60.0 : 70.0);
    final subtitleFontSize = widget.isSmallScreen 
        ? (widget.isMobile ? 18.0 : 20.0)
        : (widget.isMobile ? 22.0 : 26.0);
    final descriptionFontSize = widget.isSmallScreen 
        ? (widget.isMobile ? 15.0 : 16.0)
        : (widget.isMobile ? 17.0 : 19.0);
    final horizontalPadding = widget.isMobile ? 24.0 : 40.0;
    final iconSize = widget.isSmallScreen ? 60.0 : (widget.isMobile ? 72.0 : 80.0);
    
    return SingleChildScrollView(
      child: Container(
        width: widget.screenWidth,
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: widget.isSmallScreen ? 40 : 60),
            
            // Icon - minimal and clean
            AnimatedBuilder(
              animation: _iconController,
              builder: (context, child) {
                return Transform.scale(
                  scale: Tween<double>(begin: 0.0, end: 1.0)
                      .animate(CurvedAnimation(
                        parent: _iconController,
                        curve: Curves.elasticOut,
                      )).value,
                  child: Container(
                    margin: EdgeInsets.only(bottom: widget.isSmallScreen ? 32 : 48),
                    child: Icon(
                      widget.data.icon,
                      size: iconSize,
                      color: const Color(0xFF1976D2),
                    ),
                  ),
                );
              },
            ),
            
            // Headline with typewriter effect
            if (isActive)
              _TypewriterText(
                text: widget.data.headline,
                style: TextStyle(
                  fontSize: headlineFontSize,
                  fontWeight: FontWeight.w300,
                  color: Colors.grey.shade800,
                  height: 1.1,
                  letterSpacing: -1.0,
                ),
                delay: const Duration(milliseconds: 200),
              ),
            
            SizedBox(height: widget.isSmallScreen ? 4 : 8),
            
            // Brand name with emphasis
            if (isActive)
              _TypewriterText(
                text: widget.data.brandName,
                style: TextStyle(
                  fontSize: brandFontSize,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1976D2),
                  height: 1.0,
                  letterSpacing: -1.5,
                ),
                delay: const Duration(milliseconds: 600),
              ),
            
            SizedBox(height: widget.isSmallScreen ? 16 : 24),
            
            // Subtitle
            if (isActive)
              _TypewriterText(
                text: widget.data.subtitle,
                style: TextStyle(
                  fontSize: subtitleFontSize,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                  letterSpacing: -0.3,
                ),
                delay: const Duration(milliseconds: 1000),
              ),
            
            SizedBox(height: widget.isSmallScreen ? 24 : 32),
            
            // Description
            if (isActive)
              _TypewriterText(
                text: widget.data.description,
                style: TextStyle(
                  fontSize: descriptionFontSize,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade500,
                  height: 1.5,
                  letterSpacing: -0.1,
                ),
                delay: const Duration(milliseconds: 1400),
              ),
            
            SizedBox(height: widget.isSmallScreen ? 32 : 48),
            
            // Professional animation effects
            if (isActive)
              SizedBox(
                height: widget.isSmallScreen ? 80 : 100,
                width: double.infinity,
                child: _AnimationEffects(
                  slideIndex: widget.pageIndex,
                  isSmallScreen: widget.isSmallScreen,
                  isMobile: widget.isMobile,
                ),
              ),
            
            SizedBox(height: widget.isSmallScreen ? 40 : 60),
          ],
        ),
      ),
    );
  }
}

class _TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration delay;

  const _TypewriterText({
    required this.text,
    required this.style,
    this.delay = Duration.zero,
  });

  @override
  State<_TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<_TypewriterText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _characterCount;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: Duration(milliseconds: widget.text.length * 25 + 200),
      vsync: this,
    );
    
    _characterCount = IntTween(
      begin: 0,
      end: widget.text.length,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _characterCount,
      builder: (context, child) {
        final displayText = widget.text.substring(0, _characterCount.value);
        final showCursor = _characterCount.value < widget.text.length;
        
        return Text.rich(
          TextSpan(
            children: [
              TextSpan(text: displayText),
              if (showCursor)
                TextSpan(
                  text: '|',
                  style: widget.style.copyWith(
                    color: const Color(0xFF1976D2).withValues(alpha: 0.6),
                  ),
                ),
            ],
          ),
          style: widget.style,
          textAlign: TextAlign.left,
        );
      },
    );
  }
}

class _OnboardData {
  final String headline;
  final String brandName;
  final String subtitle;
  final String description;
  final List<String> keywords;
  final IconData icon;
  
  const _OnboardData({
    required this.headline,
    required this.brandName,
    required this.subtitle,
    required this.description,
    required this.keywords,
    required this.icon,
  });
}

class _AnimationEffects extends StatefulWidget {
  final int slideIndex;
  final bool isSmallScreen;
  final bool isMobile;

  const _AnimationEffects({
    required this.slideIndex,
    required this.isSmallScreen,
    required this.isMobile,
  });

  @override
  State<_AnimationEffects> createState() => _AnimationEffectsState();
}

class _AnimationEffectsState extends State<_AnimationEffects>
    with TickerProviderStateMixin {
  late AnimationController _effectController;
  late List<_Particle> _particles;
  late Timer? _particleTimer;

  @override
  void initState() {
    super.initState();
    
    _effectController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _initializeParticles();
    _startAnimation();
  }

  void _initializeParticles() {
    final particleCount = widget.isSmallScreen ? 8 : 12;
    _particles = List.generate(particleCount, (index) {
      return _Particle(
        slideIndex: widget.slideIndex,
        index: index,
        screenWidth: 300, // Will be updated in build
      );
    });
  }

  void _startAnimation() {
    _effectController.repeat();
    
    // Stagger particle animations
    _particleTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (mounted) {
        setState(() {
          for (var particle in _particles) {
            particle.reset();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _effectController.dispose();
    _particleTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Update particles with current screen width
    for (var particle in _particles) {
      particle.screenWidth = screenWidth;
    }

    return AnimatedBuilder(
      animation: _effectController,
      builder: (context, child) {
        return CustomPaint(
          painter: _EffectsPainter(
            particles: _particles,
            animationValue: _effectController.value,
            slideIndex: widget.slideIndex,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _Particle {
  late double x;
  late double y;
  late double velocityX;
  late double velocityY;
  late double size;
  late double opacity;
  late Color color;
  final int slideIndex;
  final int index;
  double screenWidth;

  _Particle({
    required this.slideIndex,
    required this.index,
    required this.screenWidth,
  }) {
    reset();
  }

  void reset() {
    final random = Random();
    
    switch (slideIndex) {
      case 0: // Welcome - Celebration stars
        x = random.nextDouble() * screenWidth;
        y = random.nextDouble() * 80 + 10;
        velocityX = (random.nextDouble() - 0.5) * 2;
        velocityY = random.nextDouble() * 2 + 1;
        size = random.nextDouble() * 3 + 1;
        opacity = random.nextDouble() * 0.7 + 0.3;
        color = const Color(0xFF1976D2).withValues(alpha: opacity * 0.6);
        break;
        
      case 1: // Invoice - Geometric dots
        x = random.nextDouble() * screenWidth;
        y = random.nextDouble() * 80 + 10;
        velocityX = (random.nextDouble() - 0.5) * 1.5;
        velocityY = random.nextDouble() * 1.5 + 0.5;
        size = random.nextDouble() * 2 + 1.5;
        opacity = random.nextDouble() * 0.5 + 0.2;
        color = const Color(0xFF1976D2).withValues(alpha: opacity * 0.4);
        break;
        
      case 2: // Analytics - Data points
        x = random.nextDouble() * screenWidth;
        y = random.nextDouble() * 80 + 10;
        velocityX = (random.nextDouble() - 0.5) * 1;
        velocityY = random.nextDouble() * 1 + 0.3;
        size = random.nextDouble() * 1.5 + 1;
        opacity = random.nextDouble() * 0.6 + 0.2;
        color = const Color(0xFF1976D2).withValues(alpha: opacity * 0.3);
        break;
    }
  }

  void update(double deltaTime) {
    x += velocityX * deltaTime * 60;
    y += velocityY * deltaTime * 60;
    opacity *= 0.99; // Fade out
    
    // Reset if out of bounds
    if (y > 100 || opacity < 0.1) {
      reset();
    }
  }
}

class _EffectsPainter extends CustomPainter {
  final List<_Particle> particles;
  final double animationValue;
  final int slideIndex;

  _EffectsPainter({
    required this.particles,
    required this.animationValue,
    required this.slideIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Update and draw particles
    for (var particle in particles) {
      particle.update(0.016); // ~60fps
      
      paint.color = particle.color;
      
      switch (slideIndex) {
        case 0: // Stars for welcome
          _drawStar(canvas, paint, particle.x, particle.y, particle.size);
          break;
        case 1: // Rectangles for invoice
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(
                center: Offset(particle.x, particle.y),
                width: particle.size * 2,
                height: particle.size * 2,
              ),
              Radius.circular(particle.size * 0.3),
            ),
            paint,
          );
          break;
        case 2: // Circles for analytics
          canvas.drawCircle(
            Offset(particle.x, particle.y),
            particle.size,
            paint,
          );
          break;
      }
    }

    // Draw connecting lines for analytics
    if (slideIndex == 2) {
      _drawConnectionLines(canvas, size);
    }
  }

  void _drawStar(Canvas canvas, Paint paint, double x, double y, double size) {
    final path = Path();
    final points = 5;
    final outerRadius = size;
    final innerRadius = size * 0.4;
    
    for (int i = 0; i < points * 2; i++) {
      final angle = (i * pi) / points;
      final radius = i.isEven ? outerRadius : innerRadius;
      final pointX = x + radius * cos(angle);
      final pointY = y + radius * sin(angle);
      
      if (i == 0) {
        path.moveTo(pointX, pointY);
      } else {
        path.lineTo(pointX, pointY);
      }
    }
    path.close();
    
    canvas.drawPath(path, paint);
  }

  void _drawConnectionLines(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1976D2).withValues(alpha: 0.1)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // Draw subtle grid lines
    final gridSpacing = 40.0;
    for (double i = 0; i < size.width; i += gridSpacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i, size.height),
        paint,
      );
    }
    
    for (double i = 0; i < size.height; i += gridSpacing) {
      canvas.drawLine(
        Offset(0, i),
        Offset(size.width, i),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

