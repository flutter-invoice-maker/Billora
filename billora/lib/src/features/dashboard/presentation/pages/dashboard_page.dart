// ignore_for_file: deprecated_member_use
import 'dart:typed_data';
import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:billora/src/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:billora/src/features/dashboard/domain/entities/date_range.dart';
import 'package:billora/src/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:billora/src/features/dashboard/domain/entities/report_params.dart';
import 'package:billora/src/features/dashboard/presentation/widgets/filter_panel.dart';
import 'package:billora/src/features/dashboard/presentation/widgets/revenue_chart.dart';
import 'package:billora/src/features/dashboard/presentation/widgets/tags_pie_chart.dart';
import 'package:billora/src/features/dashboard/presentation/widgets/stats_card.dart';
import 'package:billora/src/core/utils/currency_formatter.dart';
import 'package:billora/src/features/tags/presentation/cubit/tags_cubit.dart';
import 'package:billora/src/core/di/injection_container.dart';
import 'package:billora/src/features/invoice/presentation/cubit/invoice_cubit.dart';
import 'package:billora/src/features/invoice/presentation/cubit/invoice_state.dart';
import 'package:billora/src/features/customer/presentation/cubit/customer_cubit.dart';
import 'package:billora/src/features/customer/presentation/cubit/customer_state.dart';
import 'package:billora/src/features/product/presentation/cubit/product_cubit.dart';
import 'package:billora/src/features/product/presentation/cubit/product_state.dart';
import 'package:billora/src/features/home/presentation/widgets/app_scaffold.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with TickerProviderStateMixin {
  late AnimationController _bannerController;
  late AnimationController _floatingIconsController;
  late PageController _pageController;
  int _currentBannerIndex = 0;
  bool _isRefreshing = false;
  int _selectedChartTab = 0; // 0 for Revenue, 1 for Tags

  final List<Map<String, dynamic>> _bannerData = [
    {
      'title': 'Dashboard Analytics',
      'subtitle': 'Monitor your business performance in real-time',
      'icon': Icons.analytics_rounded,
      'gradient': [const Color(0xFF667eea), const Color(0xFF764ba2)],
    },
    {
      'title': 'Revenue Insights',
      'subtitle': 'Track income trends and financial growth',
      'icon': Icons.trending_up_rounded,
      'gradient': [const Color(0xFF4facfe), const Color(0xFF00f2fe)],
    },
    {
      'title': 'Business Intelligence',
      'subtitle': 'Make data-driven decisions for success',
      'icon': Icons.insights_rounded,
      'gradient': [const Color(0xFFF093FB), const Color(0xFFF5576C)],
    },
  ];

  @override
  void initState() {
    super.initState();
    
    _bannerController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
    
    _floatingIconsController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _pageController = PageController();
    
    // Auto-slide banner
    Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          _currentBannerIndex = (_currentBannerIndex + 1) % _bannerData.length;
        });
        _pageController.animateToPage(
          _currentBannerIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Load dashboard data immediately when component is mounted
    final dashboardState = context.read<DashboardCubit>().state;
    if (dashboardState is! DashboardLoaded && dashboardState is! DashboardLoading) {
      context.read<DashboardCubit>().loadDashboardStats();
      context.read<CustomerCubit>().fetchCustomers();
      context.read<ProductCubit>().fetchProducts();
    }
  }

  void _refreshDashboard() {
    if (!_isRefreshing && mounted) {
      _isRefreshing = true;
      
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          context.read<DashboardCubit>().loadDashboardStats();
        }
      });
      
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          _isRefreshing = false;
        }
      });
    }
  }

  @override
  void dispose() {
    _bannerController.dispose();
    _floatingIconsController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildFloatingIcons() {
    return AnimatedBuilder(
      animation: _floatingIconsController,
      builder: (context, child) {
        return Stack(
          children: [
            // Dashboard-themed floating icons
            ...List.generate(8, (index) {
              final icons = [
                Icons.trending_up_outlined,
                Icons.bar_chart_outlined,
                Icons.pie_chart_outline,
                Icons.analytics_outlined,
                Icons.insights_outlined,
                Icons.data_usage_outlined,
                Icons.show_chart_outlined,
                Icons.assessment_outlined,
              ];
              
              final double animationValue = _floatingIconsController.value;
              final double offsetX = 50 + (index * 45) +
                  math.sin((animationValue * 2 * math.pi) + (index * 0.8)) * 30;
              final double offsetY = 50 + (index * 35) +
                  math.cos((animationValue * 2 * math.pi) + (index * 0.6)) * 40;
              
              return Positioned(
                left: offsetX % MediaQuery.of(context).size.width,
                top: offsetY % (MediaQuery.of(context).size.height * 0.7),
                child: Opacity(
                  opacity: 0.15,
                  child: Icon(
                    icons[index],
                    size: 24 + (index % 3) * 8,
                    color: Colors.white,
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentTabIndex: 0,
      pageTitle: 'Dashboard',
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              const Color(0xFFB794F6).withValues(alpha: 0.08),
              Colors.white,
              const Color(0xFF8B5FBF).withValues(alpha: 0.12),
              const Color(0xFF7C3AED).withValues(alpha: 0.06),
            ],
            stops: [0.0, 0.25, 0.5, 0.75, 1.0],
          ),
        ),
        child: Stack(
          children: [
            _buildFloatingIcons(),
            SafeArea(
              child: MultiBlocListener(
                listeners: [
                  BlocListener<InvoiceCubit, InvoiceState>(
                    listener: (context, state) {
                      state.when(
                        loaded: (invoices) {
                          if (invoices.isNotEmpty && !_isRefreshing) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _refreshDashboard();
                            });
                          }
                        },
                        initial: () {},
                        loading: () {},
                        error: (message) {},
                      );
                    },
                  ),
                  BlocListener<CustomerCubit, CustomerState>(
                    listener: (context, state) {
                      state.maybeWhen(
                        loaded: (customers) {
                          if (customers.isNotEmpty && !_isRefreshing && mounted) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted) {
                                _refreshDashboard();
                              }
                            });
                          }
                        },
                        orElse: () {},
                      );
                    },
                  ),
                  BlocListener<ProductCubit, ProductState>(
                    listener: (context, state) {
                      state.when(
                        loaded: (products) {
                          if (products.isNotEmpty && !_isRefreshing) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _refreshDashboard();
                            });
                          }
                        },
                        initial: () {},
                        loading: () {},
                        error: (message) {},
                      );
                    },
                  ),
                ],
                child: BlocConsumer<DashboardCubit, DashboardState>(
                  listener: (context, state) {
                    if (state is ExportSuccess) {
                      _downloadExcelFile(state.excelData, state.fileName);
                      _showExportSuccessDialog(state.fileName);
                    } else if (state is ExportError) {
                      _showExportErrorDialog(state.message);
                    } else if (state is DashboardError) {
                      _showErrorSnackBar(state.message);
                    }
                  },
                  builder: (context, state) {
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildHeroBanner(state is DashboardLoaded ? state : null),
                          _buildQuickActions(),
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF8F9FA),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(25),
                                topRight: Radius.circular(25),
                              ),
                            ),
                            child: Column(
                              children: [
                                if (state is DashboardLoading) ...[
                                  const SizedBox(height: 100),
                                  const Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Color(0xFF667EEA),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 100),
                                ] else if (state is DashboardLoaded) ...[
                                  const SizedBox(height: 20),
                                  _buildStatsGrid(state.stats),
                                  const SizedBox(height: 8),
                                  _buildTabbedChartsSection(state.stats),
                                  const SizedBox(height: 20),
                                ] else if (state is DashboardError) ...[
                                  const SizedBox(height: 50),
                                  Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.error_outline,
                                          size: 64,
                                          color: Colors.red,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Error: ${state.message}',
                                          style: const TextStyle(fontSize: 16),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 16),
                                        ElevatedButton(
                                          onPressed: () {
                                            context.read<DashboardCubit>().loadDashboardStats();
                                          },
                                          child: const Text('Retry'),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 50),
                                ] else ...[
                                  const SizedBox(height: 100),
                                  const Center(
                                    child: Text('No data available'),
                                  ),
                                  const SizedBox(height: 100),
                                ],
                                // Bottom padding for floating tabbar
                                const SizedBox(height: 120),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Keep all other methods the same as before...
  Widget _buildHeroBanner(DashboardLoaded? state) {
    return Container(
      height: 180,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.2 * 255).round()),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentBannerIndex = index;
                });
              },
              itemCount: _bannerData.length,
              itemBuilder: (context, index) {
                final banner = _bannerData[index];
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: banner['gradient'],
                    ),
                  ),
                  child: Stack(
                    children: [
                      _buildFloatingIcons(),
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withAlpha((0.2 * 255).round()),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    banner['icon'],
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        banner['title'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        banner['subtitle'],
                                        style: TextStyle(
                                          color: Colors.white.withAlpha((0.9 * 255).round()),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (state != null) ...[
                              const SizedBox(height: 16),
                              // Date Range Display
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withAlpha((0.2 * 255).round()),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.calendar_today_rounded,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          state.currentDateRange.label ?? 'Custom Range',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          _formatDateRange(state.currentDateRange),
                                          style: TextStyle(
                                            color: Colors.white.withAlpha((0.8 * 255).round()),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _bannerData.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentBannerIndex == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentBannerIndex == index
                          ? Colors.white
                          : Colors.white.withAlpha((0.5 * 255).round()),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _buildQuickActionButton(
              icon: Icons.tune,
              label: 'Filter',
              onTap: () => _showFilterPanel(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildQuickActionButton(
              icon: Icons.file_download_outlined,
              label: 'Export',
              onTap: () => _exportExcelReport(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.1 * 255).round()),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: const Color(0xFF667eea),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF667eea),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(DashboardStats stats) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isTablet = screenWidth > 600;
        final isLargePhone = screenWidth > 400;
        
        int crossAxisCount;
        double childAspectRatio;
        double spacing;
        
        if (isTablet) {
          crossAxisCount = 4;
          childAspectRatio = 1.8;
          spacing = 8;
        } else if (isLargePhone) {
          crossAxisCount = 2;
          childAspectRatio = 2.2;
          spacing = 6;
        } else {
          crossAxisCount = 2;
          childAspectRatio = 2.0;
          spacing = 4;
        }

        final statsData = [
          {
            'title': 'Total Invoices',
            'value': stats.totalInvoices.toString(),
            'icon': Icons.receipt_long_rounded,
            'color': const Color(0xFF667EEA),
          },
          {
            'title': 'Total Revenue',
            'value': CurrencyFormatter.format(stats.totalRevenue),
            'icon': Icons.trending_up_rounded,
            'color': const Color(0xFF48BB78),
          },
          {
            'title': 'Average Value',
            'value': CurrencyFormatter.format(stats.averageValue),
            'icon': Icons.analytics_rounded,
            'color': const Color(0xFFED8936),
          },
          {
            'title': 'New Customers',
            'value': stats.newCustomers.toString(),
            'icon': Icons.person_add_alt_1_rounded,
            'color': const Color(0xFF9F7AEA),
          },
        ];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
              childAspectRatio: childAspectRatio,
            ),
            itemCount: statsData.length,
            itemBuilder: (context, index) {
              final data = statsData[index];
              return TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 600 + (index * 150)),
                tween: Tween(begin: 0.0, end: 1.0),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: StatsCard(
                      title: data['title'] as String,
                      value: data['value'] as String,
                      icon: data['icon'] as IconData,
                      color: data['color'] as Color,
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTabbedChartsSection(DashboardStats stats) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withAlpha((0.95 * 255).round()),
            const Color(0xFFF7FAFC).withAlpha((0.9 * 255).round()),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.1 * 255).round()),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFE2E8F0).withAlpha((0.5 * 255).round()),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Tab Header
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9).withAlpha((0.8 * 255).round()),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFE2E8F0).withAlpha((0.6 * 255).round()),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildTabButton(
                    'Revenue Chart',
                    Icons.trending_up_rounded,
                    0,
                  ),
                ),
                Expanded(
                  child: _buildTabButton(
                    'Tag Distribution',
                    Icons.pie_chart_rounded,
                    1,
                  ),
                ),
              ],
            ),
          ),
          
          // Chart Content
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.05, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: _selectedChartTab == 0
                  ? _buildRevenueChartContent(stats)
                  : _buildTagsChartContent(stats),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, IconData icon, int index) {
    final isSelected = _selectedChartTab == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedChartTab = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.all(3),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                )
              : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF667EEA).withAlpha((0.3 * 255).round()),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : const Color(0xFF4A5568),
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : const Color(0xFF4A5568),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueChartContent(DashboardStats stats) {
    return SizedBox(
      key: const ValueKey('revenue_chart'),
      height: 280,
      child: RevenueChart(chartData: stats.revenueChartData),
    );
  }

  Widget _buildTagsChartContent(DashboardStats stats) {
    return Container(
      key: const ValueKey('tags_chart'),
      child: TagsPieChart(topTags: stats.topTags),
    );
  }

  // Add all the other methods (showFilterPanel, exportExcelReport, etc.) here...
  void _showFilterPanel() {
    final dashboardCubit = context.read<DashboardCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MultiBlocProvider(
        providers: [
          BlocProvider<TagsCubit>(
            create: (context) => sl<TagsCubit>(),
          ),
          BlocProvider<DashboardCubit>.value(
            value: dashboardCubit,
          ),
        ],
        child: const FilterPanel(),
      ),
    );
  }

  void _exportExcelReport([DashboardLoaded? state]) {
    final currentState = state ?? context.read<DashboardCubit>().state;
    if (currentState is DashboardLoaded) {
      final params = ReportParams(
        dateRange: currentState.currentDateRange,
        tagFilters: currentState.currentTagFilters,
      );
      context.read<DashboardCubit>().exportExcelReport(params);
    }
  }

  void _showExportSuccessDialog(String fileName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withAlpha((0.2 * 255).round()),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Success!',
              style: TextStyle(
                color: Color(0xFF2D3748),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Text(
          'File $fileName has been created successfully.',
          style: const TextStyle(
            color: Color(0xFF4A5568),
          ),
        ),
        actions: [
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF667EEA),
                  Color(0xFF764BA2),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Text(
                    'OK',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
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

  void _showExportErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withAlpha((0.2 * 255).round()),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Export Report Error',
              style: TextStyle(
                color: Color(0xFF2D3748),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(
            color: Color(0xFF4A5568),
          ),
        ),
        actions: [
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF667EEA),
                  Color(0xFF764BA2),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Text(
                    'OK',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
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

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _downloadExcelFile(Uint8List excelData, String fileName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'File $fileName has been created successfully!',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  String _formatDateRange(DateRange dateRange) {
    final startDate = dateRange.startDate;
    final endDate = dateRange.endDate;
    return '${_formatDate(startDate)} - ${_formatDate(endDate)}';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
