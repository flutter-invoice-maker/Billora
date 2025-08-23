import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:billora/src/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:billora/src/core/di/injection_container.dart';
import 'package:billora/src/core/utils/currency_formatter.dart';
import 'package:billora/src/core/utils/number_formatter.dart';
import 'package:billora/src/features/dashboard/presentation/widgets/revenue_chart.dart';
import '../widgets/app_scaffold.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  final int _currentIndex = 0; // Home tab

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DashboardCubit>(
      create: (_) => sl<DashboardCubit>()..loadDashboardStats(),
      child: AppScaffold(
        currentTabIndex: _currentIndex,
        pageTitle: 'Home',
        headerBottom: const _HomeHeaderSearch(),
        body: SafeArea(
          top: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return RefreshIndicator(
                color: Colors.black, // Để đồng bộ màu refresh
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
                      _AIInsightsSection(constraints: constraints),
                      const SizedBox(height: 40),
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
                              color: Colors.black.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              d.icon,
                              color: Colors.black87,
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
                            color: Colors.black54,
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
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: _focusNode.hasFocus
                        ? Colors.black
                        : Colors.grey.shade300,
                    width: _focusNode.hasFocus ? 1.5 : 1,
                  ),
                ),
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
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        Icons.search,
                        color: _focusNode.hasFocus
                            ? Colors.black
                            : Colors.grey[600],
                        size: 20,
                      ),
                    ),
                    suffixIcon: _query.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _controller.clear();
                              setState(() => _query = '');
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Icon(
                                Icons.close,
                                color: Colors.grey[600],
                                size: 20,
                              ),
                            ),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  color: Colors.black,
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
                                  color: Colors.blue[600]!,
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
                                  color: Colors.green[600]!,
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
                                  color: Colors.purple[600]!,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Chart Area
                          Container(
                            height: 220,
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
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


class _RecentActivitiesSection extends StatelessWidget {
  final BoxConstraints constraints;

  const _RecentActivitiesSection({required this.constraints});

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
            Text(
              'See all',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
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
                  child: Column(
                    children: [
                      _ActivityRow(
                        icon: Icons.receipt_long,
                        text: 'Invoice #BL0012 created for Stellar Corp',
                        time: '10 min ago',
                        color: Colors.blue[600]!,
                        constraints: constraints,
                        isFirst: true,
                      ),
                      const _ActivityDivider(),
                      _ActivityRow(
                        icon: Icons.people,
                        text: 'New customer added: Apex Innovations',
                        time: '35 min ago',
                        color: Colors.green[600]!,
                        constraints: constraints,
                      ),
                      const _ActivityDivider(),
                      _ActivityRow(
                        icon: Icons.inventory_2,
                        text: 'Product stock updated: Widget Pro (+50 units)',
                        time: '1 hour ago',
                        color: Colors.orange[600]!,
                        constraints: constraints,
                        isLast: true,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
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
                    fontSize: constraints.maxWidth * 0.035,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: constraints.maxHeight * 0.005),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: constraints.maxWidth * 0.03,
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

class _AIInsightsSection extends StatefulWidget {
  final BoxConstraints constraints;

  const _AIInsightsSection({required this.constraints});

  @override
  State<_AIInsightsSection> createState() => _AIInsightsSectionState();
}

class _AIInsightsSectionState extends State<_AIInsightsSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.green[500],
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 8),
            const Text(
              'AI Insights',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 800),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 40 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(widget.constraints.maxWidth * 0.05),
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
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.green[400]!, Colors.green[600]!],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.lightbulb_outline,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      SizedBox(height: widget.constraints.maxHeight * 0.02),
                      Text(
                        'Smart Insight',
                        style: TextStyle(
                          fontSize: widget.constraints.maxWidth * 0.04,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                      SizedBox(height: widget.constraints.maxHeight * 0.015),
                      Text(
                        'Your customer "Global Traders" has increased purchases by 25% this month. Consider offering them a loyalty discount.',
                        style: TextStyle(
                          fontSize: widget.constraints.maxWidth * 0.035,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: widget.constraints.maxHeight * 0.025),
                      OutlinedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('AI Insights exploration coming soon!')),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade400),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          'Explore',
                          style: TextStyle(fontSize: widget.constraints.maxWidth * 0.035),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
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
            color: Colors.grey.shade400,
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