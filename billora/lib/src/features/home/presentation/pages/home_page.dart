import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:billora/src/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:billora/src/core/utils/currency_formatter.dart';
import 'package:billora/src/core/utils/number_formatter.dart';
import 'package:billora/src/features/dashboard/presentation/widgets/revenue_chart.dart';
import 'package:billora/src/core/services/activity_service.dart';
import 'package:billora/src/core/services/data_refresh_service.dart';
import 'package:billora/src/features/home/presentation/widgets/activity_history_popup.dart';
import 'package:billora/src/features/home/presentation/widgets/ai_insight_ranking_widget.dart';
import '../widgets/app_scaffold.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  final int _currentIndex = 0; // Home tab

  @override
  Widget build(BuildContext context) {
    // Load dashboard stats when HomePage is built
    context.read<DashboardCubit>().loadDashboardStats();
    
    return AppScaffold(
      currentTabIndex: _currentIndex,
      pageTitle: 'Home',
      headerBottom: const _HomeHeaderSearch(),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return RefreshIndicator(
              color: Colors.blue[700], // Thay đổi màu refresh thành xanh dương
              backgroundColor: Colors.white,
              onRefresh: () async {
                context.read<DashboardCubit>().loadDashboardStats();
              },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DashboardPreviewWireframe(constraints: constraints),
                      const SizedBox(height: 32),
                      _RecentActivitiesSection(constraints: constraints),
                      const SizedBox(height: 32),
                      const AIInsightRankingWidget(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
    );
  }
}

class _HomeHeaderSearch extends StatefulWidget implements PreferredSizeWidget {
  const _HomeHeaderSearch();

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  State<_HomeHeaderSearch> createState() => _HomeHeaderSearchState();
}

class _HomeHeaderSearchState extends State<_HomeHeaderSearch>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  String _query = '';
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  final List<_Destination> _destinations = const [
    _Destination(
        label: 'Customers',
        icon: Icons.people_outline,
        route: '/customers',
        keywords: ['customer', 'khách', 'cust', 'khach']),
    _Destination(
        label: 'Products',
        icon: Icons.inventory_2_outlined,
        route: '/products',
        keywords: ['product', 'sản phẩm', 'prod', 'san pham']),
    _Destination(
        label: 'Invoices',
        icon: Icons.receipt_long_outlined,
        route: '/invoices',
        keywords: ['invoice', 'hóa đơn', 'inv', 'hoa don']),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _removeOverlay();
    _controller.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus) {
      _animationController.forward();
      _showOverlay();
    } else {
      _animationController.reverse();
      _removeOverlay();
    }
  }

  void _showOverlay() {
    if (_overlayEntry != null) return;
    _overlayEntry = _buildOverlay();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _buildOverlay() {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return OverlayEntry(builder: (_) => const SizedBox());
    
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    return OverlayEntry(
      builder: (context) {
        final filtered = _filterSuggestions(_query);
        if (filtered.isEmpty) return const SizedBox.shrink();
        
        return Positioned(
          left: position.dx + 20,
          top: position.dy + size.height,
          width: size.width - 40,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            shadowColor: Colors.black.withValues(alpha: 0.15),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240),
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  thickness: 0.5,
                  color: Colors.grey.shade200,
                  indent: 60,
                ),
                itemBuilder: (context, index) {
                  final d = filtered[index];
                  return InkWell(
                    onTap: () {
                      _controller.clear();
                      _query = '';
                      _removeOverlay();
                      _focusNode.unfocus();
                      Navigator.pushReplacementNamed(context, d.route);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50, // Thay đổi màu nền icon thành xanh dương nhạt
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              d.icon,
                              color: Colors.blue[700], // Thay đổi màu icon thành xanh dương
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              d.label,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.north_east,
                            color: Colors.grey.shade500,
                            size: 16,
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
      },
    );
  }

  List<_Destination> _filterSuggestions(String q) {
    if (q.isEmpty) return _destinations;
    final lq = q.toLowerCase();
    return _destinations
        .where((d) =>
            d.label.toLowerCase().contains(lq) ||
            d.keywords.any((k) => k.toLowerCase().contains(lq)))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: CompositedTransformTarget(
        link: _layerLink,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: _focusNode.hasFocus
                        ? Colors.blue[700]!
                        : Colors.grey.shade300,
                    width: _focusNode.hasFocus ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 16),
                      child: Icon(Icons.search, color: Colors.black54, size: 20),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          decoration: InputDecoration(
                            hintText: 'Search...',
                            hintStyle: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                            ),
                            border: InputBorder.none,          
                            enabledBorder: InputBorder.none,   
                            focusedBorder: InputBorder.none,   
                            filled: false,                     
                            isCollapsed: true,
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: Colors.black87,
                          ),
                          onChanged: (value) {
                            setState(() => _query = value);
                            if (_overlayEntry != null) {
                              _removeOverlay();
                              _showOverlay();
                            }
                          },
                          onSubmitted: (value) {
                            final first = _filterSuggestions(value).firstOrNull;
                            if (first != null) {
                              _removeOverlay();
                              _focusNode.unfocus();
                              Navigator.pushReplacementNamed(context, first.route);
                            }
                          },
                        ),
                      ),
                    ),
                    if (_query.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: GestureDetector(
                          onTap: () {
                            _controller.clear();
                            setState(() => _query = '');
                          },
                          child: Icon(
                            Icons.close,
                            color: Colors.grey[600],
                            size: 20,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Destination {
  final String label;
  final IconData icon;
  final String route;
  final List<String> keywords;
  const _Destination(
      {required this.label,
      required this.icon,
      required this.route,
      required this.keywords});
}

extension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

class _DashboardPreviewWireframe extends StatelessWidget {
  final BoxConstraints constraints;

  const _DashboardPreviewWireframe({required this.constraints});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Overview',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.black,
                letterSpacing: -0.5,
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/dashboard'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue[700], // Thay đổi màu button từ đen thành xanh dương
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View all',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        BlocBuilder<DashboardCubit, DashboardState>(
          builder: (context, state) {
            final stats = state is DashboardLoaded ? state.stats : null;
            return TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 800),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade100),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Stats Row
                          Row(
                            children: [
                              Expanded(
                                child: _StatItem(
                                  title: 'Invoices',
                                  value: stats != null 
                                      ? NumberFormatter.format(stats.totalInvoices)
                                      : '0',
                                  icon: Icons.receipt_long,
                                  color: Colors.blue[600]!, // Giữ màu xanh dương
                                ),
                              ),
                              const _VerticalDivider(),
                              Expanded(
                                child: _StatItem(
                                  title: 'Revenue',
                                  value: stats != null
                                      ? CurrencyFormatter.formatUSDCompact(stats.totalRevenue, null)
                                      : '\$0',
                                  icon: Icons.trending_up,
                                  color: Colors.blue[800]!, // Thay đổi màu Revenue thành xanh dương đậm
                                ),
                              ),
                              const _VerticalDivider(),
                              Expanded(
                                child: _StatItem(
                                  title: 'Customers',
                                  value: stats != null 
                                      ? NumberFormatter.format(stats.newCustomers)
                                      : '0',
                                  icon: Icons.people,
                                  color: Colors.blue[500]!, // Thay đổi màu Customers thành xanh dương nhạt
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Chart Area
                          Container(
                            height: 220,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: stats != null && stats.revenueChartData.isNotEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: RevenueChart(chartData: stats.revenueChartData),
                                    )
                                  : _EmptyChartPlaceholder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.grey.shade200,
    );
  }
}

class _StatItem extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}


class _RecentActivitiesSection extends StatefulWidget {
  final BoxConstraints constraints;

  const _RecentActivitiesSection({required this.constraints});

  @override
  State<_RecentActivitiesSection> createState() => _RecentActivitiesSectionState();
}

class _RecentActivitiesSectionState extends State<_RecentActivitiesSection> {
  final ActivityService _activityService = ActivityService();

  @override
  void initState() {
    super.initState();
    _activityService.addListener(_onActivitiesChanged);
    
    // Refresh all data from Firestore
    DataRefreshService().refreshAllData();
  }


  @override
  void dispose() {
    _activityService.removeListener(_onActivitiesChanged);
    super.dispose();
  }

  void _onActivitiesChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _showActivityHistory(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const ActivityHistoryPopup(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black,
                letterSpacing: -0.3,
              ),
            ),
            GestureDetector(
              onTap: () => _showActivityHistory(context),
              child: Text(
                'See all',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue[600], // Thay đổi màu "See all" thành xanh dương
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 600),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 30 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade100),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _buildActivitiesList(),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActivitiesList() {
    final activities = _activityService.activities.take(3).toList();
    
    if (activities.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.history,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No recent activities',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your activities will appear here',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        for (int i = 0; i < activities.length; i++) ...[
          _ActivityRow(
            icon: activities[i].icon,
            text: activities[i].description,
            time: activities[i].timeAgo,
            color: activities[i].color,
            constraints: widget.constraints,
            isFirst: i == 0,
            isLast: i == activities.length - 1,
          ),
          if (i < activities.length - 1) const _ActivityDivider(),
        ],
      ],
    );
  }
}

class _ActivityDivider extends StatelessWidget {
  const _ActivityDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.only(left: 72),
      color: Colors.grey.shade100,
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final String time;
  final Color color;
  final BoxConstraints constraints;
  final bool isFirst;
  final bool isLast;

  const _ActivityRow({
    required this.icon,
    required this.text,
    required this.time,
    required this.color,
    required this.constraints,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        isFirst ? 20 : 16,
        20,
        isLast ? 20 : 16,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    fontSize: math.max(14, constraints.maxWidth * 0.035), // Minimum 14px
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: math.max(4, constraints.maxHeight * 0.005)),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: math.max(12, constraints.maxWidth * 0.03), // Minimum 12px
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: Colors.grey[400],
            size: constraints.maxWidth * 0.04,
          ),
        ],
      ),
    );
  }
}


class _EmptyChartPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.trending_up_outlined,
            size: 32,
            color: Colors.blue.shade300, // Thay đổi màu icon placeholder thành xanh dương
          ),
          const SizedBox(height: 8),
          Text(
            'No data available',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}