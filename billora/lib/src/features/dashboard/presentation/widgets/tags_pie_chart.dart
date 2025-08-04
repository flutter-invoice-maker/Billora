import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:billora/src/features/dashboard/domain/entities/tag_revenue.dart';

class TagsPieChart extends StatefulWidget {
  final List<TagRevenue> topTags;

  const TagsPieChart({
    super.key,
    required this.topTags,
  });

  @override
  State<TagsPieChart> createState() => _TagsPieChartState();
}

class _TagsPieChartState extends State<TagsPieChart> with TickerProviderStateMixin {
  int _touchedIndex = -1;
  int _clickedIndex = -1; // Để track phần tử được click
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width >= 768;
    final isMobile = screenSize.width < 600;

    if (widget.topTags.isEmpty) {
      return _buildEmptyState(context, isDark, isMobile);
    }

    final validTags = widget.topTags.where((tag) => 
      tag.revenue > 0 && tag.tagName.isNotEmpty
    ).toList();

    if (validTags.isEmpty) {
      return _buildEmptyState(context, isDark, isMobile, isEmpty: false);
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: double.infinity, // Đảm bảo chiều rộng tối đa
              constraints: BoxConstraints(
                minHeight: isMobile ? 400 : 350,
                maxHeight: isTablet ? 600 : (isMobile ? 700 : 500), // Tăng chiều cao
                minWidth: double.infinity, // Đảm bảo chiều rộng tối thiểu
              ),
              margin: EdgeInsets.all(isMobile ? 8 : 12), // Giảm margin để có thêm không gian
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark 
                    ? [
                        const Color(0xFF1E1E1E),
                        const Color(0xFF2D2D2D),
                      ]
                    : [
                        Colors.white,
                        const Color(0xFFFAFAFA),
                      ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: isDark 
                      ? Colors.black.withValues(alpha: 0.3)
                      : Colors.black.withValues(alpha: 0.1),
                    offset: const Offset(0, 8),
                    blurRadius: 24,
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: isDark 
                      ? Colors.white.withValues(alpha: 0.02)
                      : Colors.white.withValues(alpha: 0.8),
                    offset: const Offset(0, -2),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ],
                border: Border.all(
                  color: isDark 
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.05),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 16 : 20), // Giảm padding
                  child: isTablet 
                    ? _buildTabletLayout(context, validTags, isDark)
                    : _buildMobileLayout(context, validTags, isDark),
                ),
              ),
            ),
          ),
        );
      },
    );
  }


  Widget _buildEmptyState(BuildContext context, bool isDark, bool isMobile, {bool isEmpty = true}) {
    return Container(
      width: double.infinity,
      height: isMobile ? 300 : 350,
      margin: EdgeInsets.all(isMobile ? 8 : 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark 
            ? [const Color(0xFF1E1E1E), const Color(0xFF2D2D2D)]
            : [Colors.white, const Color(0xFFFAFAFA)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: (isDark ? Colors.grey[700] : Colors.grey[200])?.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.pie_chart_outline_rounded,
                size: 48,
                color: isDark ? Colors.grey[500] : Colors.grey[400],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isEmpty ? 'No tag data' : 'No valid data',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontSize: isMobile ? 16 : 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Data will appear when information is available',
              style: TextStyle(
                color: isDark ? Colors.grey[500] : Colors.grey[500],
                fontSize: isMobile ? 13 : 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, List<TagRevenue> validTags, bool isDark) {
    return Column(
      children: [
        // Chart section - tăng tỷ lệ
        Expanded(
          flex: 3,
          child: _buildAnimatedPieChart(validTags),
        ),
        const SizedBox(height: 16),
        // Legend
        _buildModernLegend(context, validTags, isDark, true),
        const SizedBox(height: 16),
        // Details - responsive theo nội dung
        _buildScrollableDetails(context, validTags, isDark, true),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context, List<TagRevenue> validTags, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chart section
        Expanded(
          flex: 3,
          child: _buildAnimatedPieChart(validTags),
        ),
        const SizedBox(width: 24),
        // Right panel - responsive theo nội dung
        Expanded(
          flex: 2, // Giảm flex để không chiếm quá nhiều không gian
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildModernLegend(context, validTags, isDark, false),
              const SizedBox(height: 20),
              _buildScrollableDetails(context, validTags, isDark, false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedPieChart(List<TagRevenue> validTags) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1500),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: PieChart(
            PieChartData(
              sections: _buildAnimatedSections(validTags, value),
              centerSpaceRadius: 50, // Giảm để có thêm không gian cho chart
              sectionsSpace: 2,
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      _touchedIndex = -1;
                      return;
                    }
                    
                    final touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                    _touchedIndex = touchedIndex;
                    
                    // Chỉ cập nhật _clickedIndex khi có tap/click
                    if (event is FlTapUpEvent) {
                      _clickedIndex = _clickedIndex == touchedIndex ? -1 : touchedIndex;
                    }
                  });
                },
              ),
            ),
          ),
        );
      },
    );
  }

  List<PieChartSectionData> _buildAnimatedSections(List<TagRevenue> validTags, double animationValue) {
    return validTags.asMap().entries.map((entry) {
      final index = entry.key;
      final tag = entry.value;
      final color = _getModernTagColor(index);
      final isTouched = index == _touchedIndex;
      final isClicked = index == _clickedIndex;
      final radius = (isTouched ? 85.0 : 75.0) * animationValue; // Giảm radius
      
      return PieChartSectionData(
        color: color,
        value: tag.revenue * animationValue,
        title: isClicked ? '${tag.percentage.toStringAsFixed(1)}%' : '', // Chỉ hiển thị % khi click
        radius: radius,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          shadows: [
            Shadow(
              color: Colors.black54,
              offset: Offset(1, 1),
              blurRadius: 2,
            ),
          ],
        ),
        borderSide: BorderSide(
          color: Colors.white.withValues(alpha: 0.2),
          width: 2,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color,
            color.withValues(alpha: 0.7),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildModernLegend(BuildContext context, List<TagRevenue> validTags, bool isDark, bool isMobile) {
    return SizedBox(
      width: double.infinity, // Đảm bảo chiều rộng tối đa
      child: Wrap(
        spacing: isMobile ? 6 : 8, // Giảm spacing
        runSpacing: isMobile ? 6 : 8,
        alignment: isMobile ? WrapAlignment.center : WrapAlignment.start,
        children: validTags.asMap().entries.map((entry) {
          final index = entry.key;
          final tag = entry.value;
          final color = _getModernTagColor(index);
          final isSelected = index == _clickedIndex;
          
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 10 : 12, // Giảm padding
              vertical: isMobile ? 6 : 8,
            ),
            decoration: BoxDecoration(
              gradient: isSelected
                ? LinearGradient(
                    colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.1)],
                  )
                : null,
              color: isSelected ? null : color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16), // Giảm border radius
              border: Border.all(
                color: isSelected ? color : color.withValues(alpha: 0.3),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  offset: const Offset(0, 4),
                  blurRadius: 12,
                ),
              ] : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: isMobile ? 10 : 12, // Giảm kích thước
                  height: isMobile ? 10 : 12,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withValues(alpha: 0.7)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.4),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: isMobile ? 6 : 8), // Giảm spacing
                Text(
                  tag.tagName,
                  style: TextStyle(
                    fontSize: isMobile ? 11 : 12, // Giảm font size
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildScrollableDetails(BuildContext context, List<TagRevenue> validTags, bool isDark, bool isMobile) {
    // Chỉ hiển thị chi tiết nếu có tag được chọn
    if (_clickedIndex == -1) {
      return Container(
        width: double.infinity,
        constraints: BoxConstraints(
          minHeight: isMobile ? 80 : 100,
          maxHeight: isMobile ? 120 : 140,
        ),
        decoration: BoxDecoration(
          color: (isDark ? Colors.grey[800] : Colors.grey[50])?.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
          ),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 16 : 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.touch_app_rounded,
                  size: isMobile ? 24 : 28,
                  color: isDark ? Colors.grey[500] : Colors.grey[400],
                ),
                const SizedBox(height: 8),
                Text(
                  'Select a tag to see details',
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Hiển thị chi tiết của tag được chọn
    final selectedTag = validTags[_clickedIndex];
    final selectedColor = _getModernTagColor(_clickedIndex);

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: isMobile ? 140 : 160,
        maxHeight: isMobile ? 220 : 260,
      ),
      decoration: BoxDecoration(
        color: (isDark ? Colors.grey[800] : Colors.grey[50])?.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            child: Row(
              children: [
                Icon(
                  Icons.analytics_rounded,
                  size: isMobile ? 16 : 18,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Details - ${selectedTag.tagName}',
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 12 : 16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: double.infinity,
                padding: EdgeInsets.all(isMobile ? 16 : 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      selectedColor.withValues(alpha: 0.15),
                      selectedColor.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: selectedColor.withValues(alpha: 0.4),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: selectedColor.withValues(alpha: 0.2),
                      offset: const Offset(0, 6),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: isMobile ? 16 : 18,
                          height: isMobile ? 16 : 18,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [selectedColor, selectedColor.withValues(alpha: 0.7)]),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: selectedColor.withValues(alpha: 0.4),
                                offset: const Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            selectedTag.tagName,
                            style: TextStyle(
                              fontSize: isMobile ? 16 : 18,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [selectedColor, selectedColor.withValues(alpha: 0.8)]),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: selectedColor.withValues(alpha: 0.3),
                                offset: const Offset(0, 2),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Text(
                            '${selectedTag.percentage.toStringAsFixed(1)}%',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDetailItem(
                            icon: Icons.attach_money_rounded,
                            label: 'Revenue',
                            value: _formatCurrency(selectedTag.revenue),
                            color: selectedColor,
                            isDark: isDark,
                            isMobile: isMobile,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDetailItem(
                            icon: Icons.receipt_rounded,
                            label: 'Invoice',
                            value: '${selectedTag.invoiceCount}',
                            color: selectedColor,
                            isDark: isDark,
                            isMobile: isMobile,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
    required bool isMobile,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 6 : 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: isMobile ? 12 : 14,
                color: color,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: isMobile ? 9 : 10,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: isMobile ? 11 : 12,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(1)}B';
    } else if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
  }

  Color _getModernTagColor(int index) {
    final colors = [
      const Color(0xFF667eea), // Modern Blue
      const Color(0xFF764ba2), // Deep Purple
      const Color(0xFFf093fb), // Pink Gradient
      const Color(0xFFf5576c), // Coral Red
      const Color(0xFF4facfe), // Sky Blue
      const Color(0xFF00f2fe), // Cyan
      const Color(0xFF43e97b), // Fresh Green
      const Color(0xFF38f9d7), // Mint Teal
      const Color(0xFFfa709a), // Rose Pink
      const Color(0xFFfee140), // Golden Yellow
      const Color(0xFF9bafd9), // Soft Blue
      const Color(0xFF103783), // Navy Blue
    ];
    return colors[index % colors.length];
  }
}