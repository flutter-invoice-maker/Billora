// ignore_for_file: deprecated_member_use
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:billora/src/features/dashboard/presentation/cubit/dashboard_cubit.dart';

import 'package:billora/src/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:billora/src/features/dashboard/domain/entities/report_params.dart';
import 'package:billora/src/features/dashboard/presentation/widgets/revenue_chart.dart';
import 'package:billora/src/features/dashboard/presentation/widgets/tags_pie_chart.dart';
import 'package:billora/src/core/utils/currency_formatter.dart';
import 'package:billora/src/features/tags/presentation/cubit/tags_cubit.dart';
import 'package:billora/src/core/di/injection_container.dart';
import 'package:billora/src/features/invoice/presentation/cubit/invoice_cubit.dart';
import 'package:billora/src/features/invoice/presentation/cubit/invoice_state.dart';
import 'package:billora/src/features/customer/presentation/cubit/customer_cubit.dart';
import 'package:billora/src/features/customer/presentation/cubit/customer_state.dart';
import 'package:billora/src/features/product/presentation/cubit/product_cubit.dart';
import 'package:billora/src/features/product/presentation/cubit/product_state.dart';
import 'package:billora/src/core/utils/snackbar_helper.dart';
import 'package:billora/src/features/home/presentation/widgets/app_scaffold.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with AutomaticKeepAliveClientMixin {
  int _selectedChartTab = 0; // 0 for Revenue, 1 for Tags
  bool _isRefreshing = false;
  bool _isInitialized = false;
  DateTime? _lastRefreshTime;

  // Keep alive to prevent rebuilding when switching tabs
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  void _initializePage() {
    if (_isInitialized) return;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      final dashboardState = context.read<DashboardCubit>().state;
      
      // Only load if not already loaded or loading
      if (dashboardState is! DashboardLoaded && dashboardState is! DashboardLoading) {
        context.read<DashboardCubit>().loadDashboardStats();
      }
      
      // Initialize other cubits only if needed
      _initializeOtherCubits();
      _isInitialized = true;
    });
  }

  void _initializeOtherCubits() {
    // Initialize customers
    final customerState = context.read<CustomerCubit>().state;
    customerState.when(
      loaded: (_) => null, // Already loaded
      initial: () => context.read<CustomerCubit>().fetchCustomers(),
      loading: () => null, // Already loading
      error: (_) => context.read<CustomerCubit>().fetchCustomers(),
    );

    // Initialize products
    final productState = context.read<ProductCubit>().state;
    productState.when(
      loaded: (_) => null, // Already loaded
      initial: () => context.read<ProductCubit>().fetchProducts(),
      loading: () => null, // Already loading
      error: (_) => context.read<ProductCubit>().fetchProducts(),
    );
  }

  void _refreshDashboard() {
    final now = DateTime.now();
    
    // Prevent multiple rapid refreshes (debounce)
    if (_lastRefreshTime != null && 
        now.difference(_lastRefreshTime!) < const Duration(milliseconds: 500)) {
      return;
    }
    
    if (!_isRefreshing && mounted) {
      setState(() {
        _isRefreshing = true;
        _lastRefreshTime = now;
      });
      
      context.read<DashboardCubit>().loadDashboardStats();
      
      // Reset refresh flag after delay
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          setState(() {
            _isRefreshing = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    return AppScaffold(
      currentTabIndex: 0,
      pageTitle: 'Home',
      body: SafeArea(
        child: MultiBlocListener(
          listeners: [
            // Only refresh dashboard when data changes, not on every state change
            BlocListener<InvoiceCubit, InvoiceState>(
              listener: (context, state) {
                state.when(
                  loaded: (invoices) {
                    // Only refresh if invoices actually changed and we're not already refreshing
                    if (invoices.isNotEmpty && !_isRefreshing) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) _refreshDashboard();
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
                    // Only refresh if customers actually changed
                    if (customers.isNotEmpty && !_isRefreshing && mounted) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) _refreshDashboard();
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
                    // Only refresh if products actually changed
                    if (products.isNotEmpty && !_isRefreshing) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) _refreshDashboard();
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
              return RefreshIndicator(
                onRefresh: () async => _refreshDashboard(),
                color: Colors.black,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextButton.icon(
                              onPressed: () => _showFilterPanel(),
                              icon: const Icon(Icons.tune),
                              label: const Text('Filter'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextButton.icon(
                              onPressed: () => _exportExcelReport(state is DashboardLoaded ? state : null),
                              icon: const Icon(Icons.file_download_outlined),
                              label: const Text('Export'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // Content based on state
                      _buildContent(state),
                      
                      const SizedBox(height: 24),
                      const Text('Quick Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => Navigator.pushNamed(context, '/enhanced-bill-scanner'),
                              icon: const Icon(Icons.document_scanner_outlined),
                              label: const Text('Scan'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => Navigator.pushNamed(context, '/invoice-form'),
                              icon: const Icon(Icons.receipt_long_outlined),
                              label: const Text('New Invoice'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent(DashboardState state) {
    if (state is DashboardLoading && !_isRefreshing) {
      // Show loading only for initial load, not for refresh
      return Column(
        children: [
          const SizedBox(height: 200),
          const Center(child: CircularProgressIndicator(color: Colors.black)),
          const SizedBox(height: 16),
          const Center(child: Text('Loading dashboard...')),
          const SizedBox(height: 200),
        ],
      );
    } else if (state is DashboardLoaded) {
      return Column(
        children: [
          // Show refresh indicator at top if refreshing
          if (_isRefreshing)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('Refreshing...', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          
          _buildStatsGrid(state.stats),
          const SizedBox(height: 12),
          _buildTabbedChartsSection(state.stats),
        ],
      );
    } else if (state is DashboardError) {
      return Column(
        children: [
          const SizedBox(height: 100),
          Center(
            child: Column(
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${state.message}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _refreshDashboard(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 100),
        ],
      );
    } else {
      return Column(
        children: [
          const SizedBox(height: 100),
          const Center(
            child: Column(
              children: [
                Icon(Icons.dashboard_outlined, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text('No data available'),
                SizedBox(height: 8),
                Text('Pull down to refresh', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(height: 100),
        ],
      );
    }
  }

  Widget _buildStatsGrid(DashboardStats stats) {
    final statsData = [
      {
        'title': 'Total Invoices',
        'value': stats.totalInvoices.toString(),
        'icon': Icons.receipt_long_rounded,
      },
      {
        'title': 'Total Revenue',
        'value': CurrencyFormatter.format(stats.totalRevenue),
        'icon': Icons.trending_up_rounded,
      },
      {
        'title': 'Average Value',
        'value': CurrencyFormatter.format(stats.averageValue),
        'icon': Icons.analytics_rounded,
      },
      {
        'title': 'New Customers',
        'value': stats.newCustomers.toString(),
        'icon': Icons.person_add_alt_1_rounded,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 2.2,
      ),
      itemCount: statsData.length,
      itemBuilder: (context, index) {
        final data = statsData[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Icon(data['icon'] as IconData, color: Colors.black),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(data['value'] as String, style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(data['title'] as String, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabbedChartsSection(DashboardStats stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Expanded(child: _buildTabButton('Revenue', Icons.trending_up_rounded, 0)),
              Expanded(child: _buildTabButton('Tags', Icons.pie_chart_rounded, 1)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _selectedChartTab == 0
              ? SizedBox(
                  key: const ValueKey('revenue_chart'),
                  height: 280,
                  child: RevenueChart(chartData: stats.revenueChartData),
                )
              : SizedBox(
                  key: const ValueKey('tags_chart'),
                  child: TagsPieChart(topTags: stats.topTags),
                ),
        ),
      ],
    );
  }

  Widget _buildTabButton(String title, IconData icon, int index) {
    final isSelected = _selectedChartTab == index;
    return InkWell(
      onTap: () => setState(() => _selectedChartTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.black),
            const SizedBox(width: 6),
            Text(title, style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.w600)),
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
      backgroundColor: Colors.white,
      builder: (context) => MultiBlocProvider(
        providers: [
          BlocProvider<TagsCubit>(
            create: (context) => sl<TagsCubit>(),
          ),
          BlocProvider<DashboardCubit>.value(
            value: dashboardCubit,
          ),
        ],
        child: const SizedBox(height: 400, child: Center(child: Text('Filters'))),
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
        title: const Text('Success!'),
        content: Text('File $fileName has been created successfully.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK')),
        ],
      ),
    );
  }

  void _showExportErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Report Error'),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK')),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    SnackBarHelper.showError(context, message: message);
  }

  void _downloadExcelFile(Uint8List excelData, String fileName) {
    SnackBarHelper.showSuccess(context, message: 'File $fileName has been created successfully!');
  }
}