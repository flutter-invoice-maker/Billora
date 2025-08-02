// ignore_for_file: deprecated_member_use

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:billora/src/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:billora/src/features/dashboard/domain/entities/date_range.dart';
import 'package:billora/src/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:billora/src/features/dashboard/domain/entities/report_params.dart';
import 'package:billora/src/features/dashboard/presentation/widgets/filter_panel.dart';
import 'package:billora/src/features/dashboard/presentation/widgets/revenue_chart.dart';
import 'package:billora/src/features/dashboard/presentation/widgets/tags_pie_chart.dart';
import 'package:billora/src/core/utils/currency_formatter.dart';
import 'package:billora/src/core/utils/localization_helper.dart';
import 'package:billora/src/features/tags/presentation/cubit/tags_cubit.dart';
import 'package:billora/src/core/di/injection_container.dart';
import 'package:billora/src/features/invoice/presentation/cubit/invoice_cubit.dart';
import 'package:billora/src/features/invoice/presentation/cubit/invoice_state.dart';
import 'package:billora/src/features/customer/presentation/cubit/customer_cubit.dart';
import 'package:billora/src/features/customer/presentation/cubit/customer_state.dart';
import 'package:billora/src/features/product/presentation/cubit/product_cubit.dart';
import 'package:billora/src/features/product/presentation/cubit/product_state.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Load initial dashboard data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardCubit>().loadDashboardStats();
      _animationController.forward();
    });
  }

  void _refreshDashboard() {
    if (!_isRefreshing && mounted) {
      _isRefreshing = true;
      
      // Debounce refresh calls
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          context.read<DashboardCubit>().loadDashboardStats();
        }
      });
      
      // Reset flag after a longer delay
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          _isRefreshing = false;
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh dashboard when returning to this page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshDashboard();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDarkMode ? const Color(0xFF0A0E27) : const Color(0xFFF8FAFF),
      appBar: _buildAppBar(isDarkMode),
      body: MultiBlocListener(
        listeners: [
          // Listen to invoice changes and refresh dashboard
          BlocListener<InvoiceCubit, InvoiceState>(
            listener: (context, state) {
              state.when(
                loaded: (invoices) {
                  // Only refresh if we have invoices and not already refreshing
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
          // Listen to customer changes
          BlocListener<CustomerCubit, CustomerState>(
            listener: (context, state) {
              state.maybeWhen(
                loaded: (customers) {
                  // Only refresh if we have customers and not already refreshing
                  if (customers.isNotEmpty && !_isRefreshing) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _refreshDashboard();
                    });
                  }
                },
                orElse: () {},
              );
            },
          ),
          // Listen to product changes
          BlocListener<ProductCubit, ProductState>(
            listener: (context, state) {
              state.when(
                loaded: (products) {
                  // Only refresh if we have products and not already refreshing
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
            if (state is DashboardLoading) {
              return _buildLoadingWidget(isDarkMode);
            } else if (state is DashboardLoaded) {
              return _buildDashboardContent(state, isDarkMode);
            } else if (state is DashboardError) {
              return _buildErrorWidget(state.message, isDarkMode);
            } else if (state is ExportLoading) {
              final currentState = context.read<DashboardCubit>().state;
              if (currentState is DashboardLoaded) {
                return _buildDashboardContent(currentState, isDarkMode, showExportOverlay: true);
              } else {
                return _buildLoadingWidget(isDarkMode);
              }
            } else if (state is ExportSuccess) {
              final currentState = context.read<DashboardCubit>().state;
              if (currentState is DashboardLoaded) {
                return _buildDashboardContent(currentState, isDarkMode);
              } else {
                return _buildEmptyState(isDarkMode);
              }
            } else if (state is ExportError) {
              final currentState = context.read<DashboardCubit>().state;
              if (currentState is DashboardLoaded) {
                return _buildDashboardContent(currentState, isDarkMode);
              } else {
                return _buildErrorWidget(state.message, isDarkMode);
              }
            }
            return _buildEmptyState(isDarkMode);
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDarkMode) {
    return AppBar(
      elevation: 0,
      backgroundColor: isDarkMode ? const Color(0xFF1A1F3A) : Colors.white,
      foregroundColor: isDarkMode ? Colors.white : const Color(0xFF2D3748),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF667EEA),
                  const Color(0xFF764BA2),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.dashboard,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            LocalizationHelper.of(context).dashboard,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 22,
              color: isDarkMode ? Colors.white : const Color(0xFF2D3748),
            ),
          ),
        ],
      ),
      actions: [
        _buildActionButton(
          icon: Icons.tune,
          onPressed: () => _showFilterPanel(),
          isDarkMode: isDarkMode,
        ),
        const SizedBox(width: 8),
        _buildActionButton(
          icon: Icons.file_download_outlined,
          onPressed: () => _exportExcelReport(),
          isDarkMode: isDarkMode,
        ),
        const SizedBox(width: 16),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                isDarkMode ? Colors.white24 : Colors.black12,
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    required bool isDarkMode,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDarkMode 
                  ? Colors.white.withOpacity(0.1) 
                  : const Color(0xFFF7FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDarkMode 
                    ? Colors.white.withOpacity(0.15) 
                    : const Color(0xFFE2E8F0),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              size: 20,
              color: isDarkMode ? Colors.white : const Color(0xFF4A5568),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingWidget(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1A1F3A) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: isDarkMode 
                      ? Colors.black.withOpacity(0.3) 
                      : Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      const Color(0xFF667EEA),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Đang tải dữ liệu...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : const Color(0xFF4A5568),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1A1F3A) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: isDarkMode 
                      ? Colors.black.withOpacity(0.3) 
                      : Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  size: 64,
                  color: const Color(0xFF667EEA),
                ),
                const SizedBox(height: 16),
                Text(
                  'Không có dữ liệu',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : const Color(0xFF4A5568),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent(
    DashboardLoaded state,
    bool isDarkMode, {
    bool showExportOverlay = false,
  }) {
    return Stack(
      children: [
        FadeTransition(
          opacity: _fadeAnimation,
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: _buildDateRangeDisplay(state.currentDateRange, isDarkMode),
                ),
              ),
              
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: _buildStatsCards(state.stats, isDarkMode),
                ),
              ),
              
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: _buildChartsSection(state.stats, isDarkMode),
                ),
              ),
              
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverToBoxAdapter(
                  child: _buildExportButton(state, isDarkMode),
                ),
              ),
            ],
          ),
        ),
        if (showExportOverlay) _buildExportOverlay(isDarkMode),
      ],
    );
  }

  Widget _buildExportOverlay(bool isDarkMode) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1A1F3A) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    const Color(0xFF667EEA),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Đang tạo báo cáo Excel...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : const Color(0xFF4A5568),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Vui lòng đợi trong giây lát',
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.white60 : const Color(0xFF718096),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateRangeDisplay(DateRange dateRange, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [
                  const Color(0xFF1A1F3A),
                  const Color(0xFF2D3748),
                ]
              : [
                  Colors.white,
                  const Color(0xFFF7FAFC),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDarkMode 
                ? Colors.black.withOpacity(0.3) 
                : Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: isDarkMode 
              ? Colors.white.withOpacity(0.1) 
              : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF667EEA),
                  const Color(0xFF764BA2),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF667EEA).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.calendar_today_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Khoảng thời gian',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white60 : const Color(0xFF718096),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateRange.label ?? 'Custom Range',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDarkMode ? Colors.white : const Color(0xFF2D3748),
                  ),
                ),
                Text(
                  _formatDateRange(dateRange),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white70 : const Color(0xFF4A5568),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(DashboardStats stats, bool isDarkMode) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > 600;
        final isMobile = constraints.maxWidth < 400;
        final crossAxisCount = isTablet ? 4 : (isMobile ? 1 : 2);
        final childAspectRatio = isTablet ? 1.4 : (isMobile ? 3.0 : 1.3);
        
        final statsData = [
          {
            'title': 'Tổng hóa đơn',
            'value': stats.totalInvoices.toString(),
            'icon': Icons.receipt_long_rounded,
            'gradient': [const Color(0xFF667EEA), const Color(0xFF764BA2)],
            'shadowColor': const Color(0xFF667EEA),
          },
          {
            'title': 'Tổng doanh thu',
            'value': CurrencyFormatter.format(stats.totalRevenue),
            'icon': Icons.trending_up_rounded,
            'gradient': [const Color(0xFF48BB78), const Color(0xFF38A169)],
            'shadowColor': const Color(0xFF48BB78),
          },
          {
            'title': 'Giá trị TB',
            'value': CurrencyFormatter.format(stats.averageValue),
            'icon': Icons.analytics_rounded,
            'gradient': [const Color(0xFFED8936), const Color(0xFFDD6B20)],
            'shadowColor': const Color(0xFFED8936),
          },
          {
            'title': 'Khách hàng mới',
            'value': stats.newCustomers.toString(),
            'icon': Icons.person_add_alt_1_rounded,
            'gradient': [const Color(0xFF9F7AEA), const Color(0xFF805AD5)],
            'shadowColor': const Color(0xFF9F7AEA),
          },
        ];
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: statsData.length,
          itemBuilder: (context, index) {
            final data = statsData[index];
            return _buildEnhancedStatsCard(
              title: data['title'] as String,
              value: data['value'] as String,
              icon: data['icon'] as IconData,
              gradient: data['gradient'] as List<Color>,
              shadowColor: data['shadowColor'] as Color,
              isDarkMode: isDarkMode,
            );
          },
        );
      },
    );
  }

  Widget _buildEnhancedStatsCard({
    required String title,
    required String value,
    required IconData icon,
    required List<Color> gradient,
    required Color shadowColor,
    required bool isDarkMode,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [
                  const Color(0xFF1A1F3A),
                  const Color(0xFF2D3748),
                ]
              : [
                  Colors.white,
                  const Color(0xFFF7FAFC),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDarkMode 
                ? Colors.black.withOpacity(0.3) 
                : shadowColor.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: isDarkMode 
              ? Colors.white.withOpacity(0.1) 
              : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white70 : const Color(0xFF718096),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: gradient),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: shadowColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: isDarkMode ? Colors.white : const Color(0xFF2D3748),
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsSection(DashboardStats stats, bool isDarkMode) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > 600;
        final revenueChartHeight = isTablet ? 300.0 : 250.0;
        
        return Column(
          children: [
            _buildChartCard(
              title: 'Biểu đồ doanh thu',
              icon: Icons.trending_up_rounded,
              gradient: [const Color(0xFF48BB78), const Color(0xFF38A169)],
              height: revenueChartHeight,
              isDarkMode: isDarkMode,
              child: RevenueChart(chartData: stats.revenueChartData),
            ),
            
            const SizedBox(height: 20),
            
            _buildChartCard(
              title: 'Phân bố theo tag',
              icon: Icons.pie_chart_rounded,
              gradient: [const Color(0xFF667EEA), const Color(0xFF764BA2)],
              height: null, // Cho phép pie chart tự động điều chỉnh chiều cao
              isDarkMode: isDarkMode,
              child: TagsPieChart(topTags: stats.topTags),
            ),
          ],
        );
      },
    );
  }

  Widget _buildChartCard({
    required String title,
    required IconData icon,
    required List<Color> gradient,
    double? height,
    required bool isDarkMode,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [
                  const Color(0xFF1A1F3A),
                  const Color(0xFF2D3748),
                ]
              : [
                  Colors.white,
                  const Color(0xFFF7FAFC),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDarkMode 
                ? Colors.black.withOpacity(0.3) 
                : Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: isDarkMode 
              ? Colors.white.withOpacity(0.1) 
              : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradient),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: gradient.first.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode ? Colors.white : const Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          height != null 
            ? SizedBox(
                height: height,
                child: child,
              )
            : child,
        ],
      ),
    );
  }

  Widget _buildExportButton(DashboardLoaded state, bool isDarkMode) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF667EEA),
            const Color(0xFF764BA2),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _exportExcelReport(state),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.file_download_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Xuất báo cáo Excel',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String message, bool isDarkMode) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1A1F3A) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isDarkMode 
                  ? Colors.black.withOpacity(0.3) 
                  : Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Có lỗi xảy ra',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDarkMode ? Colors.white : const Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.white70 : const Color(0xFF718096),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF667EEA),
                    const Color(0xFF764BA2),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF667EEA).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    context.read<DashboardCubit>().loadDashboardStats();
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    child: Text(
                      'Thử lại',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF1A1F3A) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Thành công!',
              style: TextStyle(
                color: isDarkMode ? Colors.white : const Color(0xFF2D3748),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Text(
          'File $fileName đã được tạo thành công.',
          style: TextStyle(
            color: isDarkMode ? Colors.white70 : const Color(0xFF4A5568),
          ),
        ),
        actions: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF667EEA),
                  const Color(0xFF764BA2),
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF1A1F3A) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Lỗi xuất báo cáo',
              style: TextStyle(
                color: isDarkMode ? Colors.white : const Color(0xFF2D3748),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(
            color: isDarkMode ? Colors.white70 : const Color(0xFF4A5568),
          ),
        ),
        actions: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF667EEA),
                  const Color(0xFF764BA2),
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
                'File $fileName đã được tạo thành công!',
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