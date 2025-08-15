import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math' as math;
import 'dart:async';
import 'package:billora/src/features/suggestions/presentation/cubit/suggestions_cubit.dart';
import 'package:billora/src/features/tags/presentation/cubit/tags_cubit.dart';
import 'package:billora/src/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:billora/src/core/di/injection_container.dart';
import 'package:billora/src/core/utils/currency_formatter.dart';
import '../widgets/app_scaffold.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final int _currentIndex = -1;
  final ScrollController _scrollController = ScrollController();

  // Animation controllers
  late AnimationController _invoiceController;
  late AnimationController _contentController;
  late AnimationController _floatingController;
  late AnimationController _tabController;
  late AnimationController _cursorController;

  // Animations
  late Animation<Offset> _invoiceSlideAnimation;
  late Animation<double> _invoiceScaleAnimation;
  late Animation<double> _invoiceRotationAnimation;
  late Animation<double> _contentFadeAnimation;

  // Floating elements
  late List<FloatingElement> _floatingIcons;

  // Tab rotation and typewriter
  int _currentTabIndex = 0;
  Timer? _tabTimer;
  Timer? _typewriterTimer;
  String _displayedText = '';
  final bool _showCursor = true;
  bool _isTyping = false;
  bool _showInvoice = false;
  
  final List<Map<String, dynamic>> _tabData = [
    {
      'icon': Icons.speed,
      'title': 'Fast Processing',
      'color': const Color(0xFF4CAF50),
      'content': 'Lightning-fast invoice generation with advanced algorithms. Process hundreds of invoices in seconds with our optimized system. Save time and increase productivity with automated workflows and smart templates.',
    },
    {
      'icon': Icons.security,
      'title': 'Secure & Safe',
      'color': const Color(0xFF2196F3),
      'content': 'Bank-level security with end-to-end encryption. Your financial data is protected with military-grade security protocols. Compliance with international security standards guaranteed for peace of mind.',
    },
    {
      'icon': Icons.analytics,
      'title': 'Smart Analytics',
      'color': const Color(0xFFFF9800),
      'content': 'Advanced business insights and reporting tools. Track your revenue, analyze customer patterns, and make data-driven decisions. Real-time dashboards and custom reports available 24/7.',
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize controllers
    _invoiceController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _contentController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );

    _tabController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _cursorController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _setupAnimations();
    _initializeFloatingElements();
    _startTabRotation();

    // Scroll listener for invoice animation
    _scrollController.addListener(_onScroll);

    // Start animations
    _floatingController.repeat();
    _cursorController.repeat(reverse: true);
    
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _contentController.forward();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Load dashboard stats if not already loaded
    final dashboardState = context.read<DashboardCubit>().state;
    if (dashboardState is! DashboardLoaded) {
      context.read<DashboardCubit>().loadDashboardStats();
    }
    
  }

  void _onScroll() {
    final scrollOffset = _scrollController.offset;
    final maxScroll = _scrollController.position.maxScrollExtent;
    
    // Show invoice when scrolled to bottom 70%
    if (scrollOffset > maxScroll * 0.7 && !_showInvoice) {
      setState(() {
        _showInvoice = true;
      });
      _invoiceController.forward();
    } else if (scrollOffset <= maxScroll * 0.7 && _showInvoice) {
      setState(() {
        _showInvoice = false;
      });
      _invoiceController.reset();
    }
  }

  void _startTabRotation() {
    _startTypewriter(_tabData[_currentTabIndex]['content']);
  }

  void _startTypewriter(String text) {
    _displayedText = '';
    _isTyping = true;
    
    int charIndex = 0;
    _typewriterTimer?.cancel();
    _typewriterTimer = Timer.periodic(const Duration(milliseconds: 80), (timer) {
      if (charIndex < text.length && mounted) {
        setState(() {
          _displayedText = text.substring(0, charIndex + 1);
        });
        charIndex++;
      } else {
        timer.cancel();
        _isTyping = false;
        
        // Wait 5 seconds after typing is complete before switching to next tab
        _tabTimer?.cancel();
        _tabTimer = Timer(const Duration(seconds: 5), () {
          if (mounted) {
            setState(() {
              _currentTabIndex = (_currentTabIndex + 1) % _tabData.length;
            });
            _tabController.forward().then((_) {
              _tabController.reset();
            });
            _startTypewriter(_tabData[_currentTabIndex]['content']);
          }
        });
      }
    });
  }

  void _setupAnimations() {
    _invoiceSlideAnimation = Tween<Offset>(
      begin: const Offset(1.5, 0.3),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _invoiceController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
    ));

    _invoiceScaleAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _invoiceController,
      curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
    ));

    _invoiceRotationAnimation = Tween<double>(
      begin: 0.5,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _invoiceController,
      curve: const Interval(0.0, 0.9, curve: Curves.easeOutBack),
    ));

    _contentFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOut,
    ));
  }

  void _initializeFloatingElements() {
    _floatingIcons = List.generate(6, (index) {
      return FloatingElement(
        icon: _getFloatingIcon(index),
        color: _getIconColor(index),
        startX: math.Random().nextDouble(),
        startY: math.Random().nextDouble(),
        speedX: (math.Random().nextDouble() - 0.5) * 0.2,
        speedY: (math.Random().nextDouble() - 0.5) * 0.15,
        size: 30 + (index % 3) * 10,
        rotationSpeed: (math.Random().nextDouble() - 0.5) * 1.5,
      );
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        if (!_floatingController.isAnimating) {
          _floatingController.repeat();
        }
        if (!_cursorController.isAnimating) {
          _cursorController.repeat(reverse: true);
        }
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _floatingController.stop();
        _cursorController.stop();
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    _invoiceController.dispose();
    _contentController.dispose();
    _floatingController.dispose();
    _tabController.dispose();
    _cursorController.dispose();
    _tabTimer?.cancel();
    _typewriterTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SuggestionsCubit>(create: (_) => sl<SuggestionsCubit>()),
        BlocProvider<TagsCubit>(create: (_) => sl<TagsCubit>()),
        BlocProvider<DashboardCubit>(create: (_) => sl<DashboardCubit>()),
      ],
      child: AppScaffold(
        currentTabIndex: _currentIndex,
        body: _buildHomepage(),
      ),
    );
  }

  Widget _buildHomepage() {
    return Stack(
      children: [
        // Main content
        SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              // Banner section with GIF and welcome text
              _buildBannerSection(),
              
              // Content sections
              _buildContentSections(),
              
              // 3D Invoice at bottom of content
              _build3DInvoiceSection(),
              
              const SizedBox(height: 140), // Space for bottom nav and FAB
            ],
          ),
        ),
        
        // Floating elements
        _buildFloatingElements(),
      ],
    );
  }

  Widget _buildBannerSection() {
    return SizedBox(
      height: 280,
      width: double.infinity,
      child: Stack(
        children: [
          // GIF Background - Always show
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            child: SizedBox(
              height: 280,
              width: double.infinity,
              child: Image.asset(
                'assets/images/homepage.gif',
                fit: BoxFit.cover,
                gaplessPlayback: true,
                filterQuality: FilterQuality.medium,
              ),
            ),
          ),
          
          // Overlay
          Container(
            height: 280,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.3),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.5),
                ],
              ),
            ),
          ),
          
          // Welcome text inside banner - Moved closer to bottom
          Positioned(
            bottom: 20, // Changed from 60 to 20
            left: 0,
            right: 0,
            child: Column(
              children: [
                const Text(
                  'Welcome to Billora',
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black54,
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                const Text(
                  'Professional Invoice Management',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    shadows: [
                      Shadow(
                        color: Colors.black54,
                        blurRadius: 8,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentSections() {
    return AnimatedBuilder(
      animation: _contentController,
      builder: (context, child) {
        return Opacity(
          opacity: _contentFadeAnimation.value,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                
                // Rotating feature tabs
                _buildRotatingFeatureTabs(),
                
                const SizedBox(height: 20),
                
                // Stats section
                _buildStatsSection(),
                
                const SizedBox(height: 20),
                
                // Quick actions
                _buildQuickActions(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRotatingFeatureTabs() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.4, // Responsive height based on screen
          child: Column(
            children: [
              // Tab icons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_tabData.length, (index) {
                  final isActive = index == _currentTabIndex;
                  final tabData = _tabData[index];
                  
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive ? tabData['color'] : Colors.grey.shade200,
                      boxShadow: isActive ? [
                        BoxShadow(
                          color: tabData['color'].withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ] : null,
                    ),
                    child: Icon(
                      tabData['icon'],
                      color: isActive ? Colors.white : Colors.grey.shade500,
                      size: 28,
                    ),
                  );
                }),
              ),
              
              const SizedBox(height: 20),
              
              // Content card with lined paper only for text content
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title area (no lines) - Clean background
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _tabData[_currentTabIndex]['color'],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _tabData[_currentTabIndex]['title'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Content area with lined paper background
                      Expanded(
                        child: SizedBox(
                          width: double.infinity,
                          child: Stack(
                            children: [
                              // Lined paper background only for content area
                              CustomPaint(
                                painter: LinedPaperPainter(),
                                size: Size.infinite,
                              ),
                              
                              // Red margin line
                              Positioned(
                                left: 40,
                                top: 0,
                                bottom: 0,
                                child: Container(
                                  width: 2,
                                  color: Colors.red.withValues(alpha: 0.3),
                                ),
                              ),
                              
                              // Text content positioned to align with lines
                              Positioned.fill(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(50, 0, 20, 20),
                                  child: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // First line starts at exact line position
                                        const SizedBox(height: 18), // Offset to align with first line
                                        RichText(
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: _displayedText,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.black87,
                                                  height: 1.867, // Exact line height to match 28px spacing
                                                  fontFamily: 'monospace',
                                                ),
                                              ),
                                              // Blinking cursor
                                              if (_isTyping || _showCursor)
                                                WidgetSpan(
                                                  child: AnimatedBuilder(
                                                    animation: _cursorController,
                                                    builder: (context, child) {
                                                      return Opacity(
                                                        opacity: _isTyping ? 1.0 : _cursorController.value,
                                                        child: Container(
                                                          width: 2,
                                                          height: 20,
                                                          color: _tabData[_currentTabIndex]['color'],
                                                          margin: const EdgeInsets.only(left: 2),
                                                        ),
                                                      );
                                                    },
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
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsSection() {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              const Text(
                'Your Business at a Glance',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildStatItem(
                    state is DashboardLoaded 
                        ? state.stats.totalInvoices.toString()
                        : '0',
                    'Invoices',
                    Icons.receipt_long,
                    const Color(0xFF667eea),
                  ),
                  _buildStatItem(
                    state is DashboardLoaded 
                        ? CurrencyFormatter.format(state.stats.totalRevenue)
                        : '₹0',
                    'Revenue',
                    Icons.trending_up,
                    const Color(0xFF4CAF50),
                  ),
                  _buildStatItem(
                    state is DashboardLoaded 
                        ? state.stats.newCustomers.toString()
                        : '0',
                    'Customers',
                    Icons.people,
                    const Color(0xFF2196F3),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/bill-scanner'),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B35),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF6B35).withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.document_scanner,
                        color: Colors.white,
                        size: 32,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Scan Bill',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Quick scan & process',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/invoices'),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.add_circle,
                        color: Colors.white,
                        size: 32,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'New Invoice',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Create from scratch',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/enhanced-bill-scanner'),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade600, Colors.purple.shade600],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.shade600.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.smart_toy,
                  color: Colors.white,
                  size: 32,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI-Powered Bill Scanner',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Advanced OCR with intelligent data extraction',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white70,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/scan-library'),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade600, Colors.red.shade600],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.shade600.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.library_books,
                  color: Colors.white,
                  size: 32,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Scan Library',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Manage and organize scanned documents',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white70,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingElements() {
    return AnimatedBuilder(
      animation: _floatingController,
      builder: (context, child) {
        final screenSize = MediaQuery.of(context).size;
        return Stack(
          children: _floatingIcons.map((element) {
            final time = _floatingController.value * 2 * math.pi;
            final x = (element.startX + element.speedX * _floatingController.value) % 1.0;
            final y = (element.startY + element.speedY * _floatingController.value) % 1.0;
            
            final floatX = x * screenSize.width + math.sin(time + element.startX * 8) * 15;
            final floatY = y * screenSize.height + math.cos(time + element.startY * 8) * 12;

            return Positioned(
              left: floatX - element.size / 2,
              top: floatY - element.size / 2,
              child: Transform.rotate(
                angle: time * element.rotationSpeed,
                child: Container(
                  width: element.size,
                  height: element.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: element.color.withValues(alpha: 0.3),
                  ),
                  child: Icon(
                    element.icon,
                    color: Colors.white.withValues(alpha: 0.6),
                    size: element.size * 0.4,
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _build3DInvoiceSection() {
    return AnimatedBuilder(
      animation: _invoiceController,
      builder: (context, child) {
        return SizedBox(
          height: 280,
          width: double.infinity,
          child: Center(
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateX(_invoiceRotationAnimation.value * 0.3)
                ..rotateY(_invoiceRotationAnimation.value * 0.2)
                ..rotateZ(_invoiceRotationAnimation.value * 0.1),
              child: Transform.scale(
                scale: _invoiceScaleAnimation.value,
                child: SlideTransition(
                  position: _invoiceSlideAnimation,
                  child: Container(
                    width: 200,
                    height: 250,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          height: 60,
                          decoration: const BoxDecoration(
                            color: Color(0xFF667eea),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'INVOICE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Billora Inc.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ...List.generate(6, (index) {
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 6),
                                    height: 3,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                    width: double.infinity - (index % 2) * 40,
                                  );
                                }),
                                const Spacer(),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFF4CAF50),
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Helper methods
  IconData _getFloatingIcon(int index) {
    final icons = [
      Icons.attach_money,
      Icons.credit_card,
      Icons.trending_up,
      Icons.calculate,
      Icons.payment,
      Icons.receipt_long,
    ];
    return icons[index % icons.length];
  }

  Color _getIconColor(int index) {
    final colors = [
      const Color(0xFF667eea),
      const Color(0xFF4CAF50),
      const Color(0xFFFF9800),
      const Color(0xFFE91E63),
      const Color(0xFF2196F3),
      const Color(0xFF9C27B0),
    ];
    return colors[index % colors.length];
  }
}

// Custom painter for lined paper background
class LinedPaperPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.2)
      ..strokeWidth = 1;

    // Draw horizontal lines starting from the top with exact 28px spacing
    const lineSpacing = 28.0; // Exact spacing to match text line height
    const startY = 28.0; // Start position to align with text baseline
    
    for (double y = startY; y < size.height - 10; y += lineSpacing) {
      canvas.drawLine(
        Offset(20, y),
        Offset(size.width - 20, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Data class
class FloatingElement {
  final IconData icon;
  final Color color;
  final double startX;
  final double startY;
  final double speedX;
  final double speedY;
  final double size;
  final double rotationSpeed;

  FloatingElement({
    required this.icon,
    required this.color,
    required this.startX,
    required this.startY,
    required this.speedX,
    required this.speedY,
    required this.size,
    required this.rotationSpeed,
  });
}
