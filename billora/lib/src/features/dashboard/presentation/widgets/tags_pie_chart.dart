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
  int _clickedIndex = -1;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
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
              width: double.infinity,
              constraints: BoxConstraints(
                minHeight: isMobile ? 300 : 280, // Reduced height
                maxHeight: isTablet ? 450 : (isMobile ? 500 : 400), // More compact
                minWidth: double.infinity,
              ),
              margin: EdgeInsets.all(isMobile ? 4 : 6), // Reduced margin
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
                borderRadius: BorderRadius.circular(20), // Reduced from 24
                boxShadow: [
                  BoxShadow(
                    color: isDark
                       ? Colors.black.withAlpha(80)
                      : Colors.black.withAlpha(25),
                    offset: const Offset(0, 6), // Reduced from 8
                    blurRadius: 20, // Reduced from 24
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: isDark
                       ? Colors.white.withAlpha(5)
                      : Colors.white.withAlpha(200),
                    offset: const Offset(0, -1),
                    blurRadius: 6,
                    spreadRadius: 0,
                  ),
                ],
                border: Border.all(
                  color: isDark
                     ? Colors.white.withAlpha(25)
                    : Colors.black.withAlpha(15),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 12 : 14), // Reduced padding
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
      height: isMobile ? 250 : 280, // More compact
      margin: EdgeInsets.all(isMobile ? 4 : 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
             ? [const Color(0xFF1E1E1E), const Color(0xFF2D2D2D)]
            : [Colors.white, const Color(0xFFFAFAFA)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withAlpha(25) : Colors.black.withAlpha(15),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20), // Reduced from 24
              decoration: BoxDecoration(
                color: (isDark ? Colors.grey[700] : Colors.grey[200])?.withAlpha(120),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.pie_chart_outline_rounded,
                size: 40, // Reduced from 48
                color: isDark ? Colors.grey[500] : Colors.grey[400],
              ),
            ),
            const SizedBox(height: 12), // Reduced from 16
            Text(
              isEmpty ? 'No tag data' : 'No valid data',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontSize: isMobile ? 14 : 16, // Reduced
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6), // Reduced from 8
            Text(
              'Data will appear when information is available',
              style: TextStyle(
                color: isDark ? Colors.grey[500] : Colors.grey[500],
                fontSize: isMobile ? 11 : 12, // Reduced
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
        // Chart section - more compact
        Expanded(
          flex: 2, // Reduced from 3
          child: _buildAnimatedPieChart(validTags),
        ),
        const SizedBox(height: 10), // Reduced from 16
        // Legend - more compact
        _buildCompactLegend(context, validTags, isDark, true),
        const SizedBox(height: 10), // Reduced from 16
        // Details - more compact
        _buildCompactDetails(context, validTags, isDark, true),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context, List<TagRevenue> validTags, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chart section
        Expanded(
          flex: 2, // Reduced from 3
          child: _buildAnimatedPieChart(validTags),
        ),
        const SizedBox(width: 16), // Reduced from 24
        // Right panel
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCompactLegend(context, validTags, isDark, false),
              const SizedBox(height: 14), // Reduced from 20
              _buildCompactDetails(context, validTags, isDark, false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedPieChart(List<TagRevenue> validTags) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1200),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.85 + (0.15 * value), // More compact scale
          child: PieChart(
            PieChartData(
              sections: _buildAnimatedSections(validTags, value),
              centerSpaceRadius: 35, // Reduced from 50
              sectionsSpace: 1, // Reduced from 2
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  // Prevent mouse tracker errors by checking if widget is still mounted
                  if (!mounted) return;
                  
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      _touchedIndex = -1;
                      return;
                    }
                                        
                    final touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                    
                    // Validate index bounds to prevent errors
                    if (touchedIndex < 0 || touchedIndex >= validTags.length) {
                      _touchedIndex = -1;
                      return;
                    }
                    
                    _touchedIndex = touchedIndex;
                                        
                    // Only update _clickedIndex when there's a tap/click
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
      final radius = (isTouched ? 70.0 : 60.0) * animationValue; // More compact radius
            
      return PieChartSectionData(
        color: color,
        value: tag.revenue * animationValue,
        title: isClicked ? '${tag.percentage.toStringAsFixed(1)}%' : '',
        radius: radius,
        titleStyle: const TextStyle(
          fontSize: 12, // Reduced from 14
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
          color: Colors.white.withAlpha(50),
          width: 1.5, // Reduced from 2
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color,
            color.withAlpha(180),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildCompactLegend(BuildContext context, List<TagRevenue> validTags, bool isDark, bool isMobile) {
    return SizedBox(
      width: double.infinity,
      child: Wrap(
        spacing: isMobile ? 4 : 6, // More compact spacing
        runSpacing: isMobile ? 4 : 6,
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
              horizontal: isMobile ? 8 : 10, // More compact padding
              vertical: isMobile ? 4 : 6,
            ),
            decoration: BoxDecoration(
              gradient: isSelected
                ? LinearGradient(
                    colors: [color.withAlpha(50), color.withAlpha(25)],
                  )
                : null,
              color: isSelected ? null : color.withAlpha(25),
              borderRadius: BorderRadius.circular(12), // More compact radius
              border: Border.all(
                color: isSelected ? color : color.withAlpha(80),
                width: isSelected ? 1.5 : 1,
              ),
              boxShadow: isSelected ? [
                BoxShadow(
                  color: color.withAlpha(80),
                  offset: const Offset(0, 2),
                  blurRadius: 8,
                ),
              ] : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: isMobile ? 8 : 10, // More compact size
                  height: isMobile ? 8 : 10,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withAlpha(180)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withAlpha(100),
                        offset: const Offset(0, 1),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: isMobile ? 4 : 6), // More compact spacing
                Text(
                  tag.tagName,
                  style: TextStyle(
                    fontSize: isMobile ? 10 : 11, // More compact font
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

  Widget _buildCompactDetails(BuildContext context, List<TagRevenue> validTags, bool isDark, bool isMobile) {
    // Show hint if no tag selected
    if (_clickedIndex == -1) {
      return Container(
        width: double.infinity,
        constraints: BoxConstraints(
          minHeight: isMobile ? 60 : 70, // More compact
          maxHeight: isMobile ? 90 : 100,
        ),
        decoration: BoxDecoration(
          color: (isDark ? Colors.grey[800] : Colors.grey[50])?.withAlpha(120),
          borderRadius: BorderRadius.circular(12), // More compact radius
          border: Border.all(
            color: isDark ? Colors.white.withAlpha(25) : Colors.black.withAlpha(15),
          ),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 12 : 14), // More compact padding
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.touch_app_rounded,
                  size: isMobile ? 20 : 22, // More compact icon
                  color: isDark ? Colors.grey[500] : Colors.grey[400],
                ),
                const SizedBox(height: 6), // More compact spacing
                Text(
                  'Select a tag to see details',
                  style: TextStyle(
                    fontSize: isMobile ? 10 : 12, // More compact font
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

    // Show selected tag details
    // Validate clicked index to prevent errors
    if (_clickedIndex < 0 || _clickedIndex >= validTags.length) {
      _clickedIndex = -1; // Reset to valid state
      return Container(
        width: double.infinity,
        constraints: BoxConstraints(
          minHeight: isMobile ? 60 : 70,
          maxHeight: isMobile ? 90 : 100,
        ),
        decoration: BoxDecoration(
          color: (isDark ? Colors.grey[800] : Colors.grey[50])?.withAlpha(120),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.white.withAlpha(25) : Colors.black.withAlpha(15),
          ),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 12 : 14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.touch_app_rounded,
                  size: isMobile ? 20 : 22,
                  color: isDark ? Colors.grey[500] : Colors.grey[400],
                ),
                const SizedBox(height: 6),
                Text(
                  'Select a tag to see details',
                  style: TextStyle(
                    fontSize: isMobile ? 10 : 12,
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
    
    final selectedTag = validTags[_clickedIndex];
    final selectedColor = _getModernTagColor(_clickedIndex);
    
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: isMobile ? 100 : 120, // More compact
        maxHeight: isMobile ? 160 : 180,
      ),
      decoration: BoxDecoration(
        color: (isDark ? Colors.grey[800] : Colors.grey[50])?.withAlpha(120),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white.withAlpha(25) : Colors.black.withAlpha(15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(isMobile ? 10 : 12), // More compact padding
            child: Row(
              children: [
                Icon(
                  Icons.analytics_rounded,
                  size: isMobile ? 14 : 16, // More compact icon
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
                const SizedBox(width: 6), // More compact spacing
                Expanded(
                  child: Text(
                    'Details - ${selectedTag.tagName}',
                    style: TextStyle(
                      fontSize: isMobile ? 12 : 14, // More compact font
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
              padding: EdgeInsets.all(isMobile ? 10 : 12), // More compact padding
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: double.infinity,
                padding: EdgeInsets.all(isMobile ? 12 : 14), // More compact padding
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      selectedColor.withAlpha(40),
                      selectedColor.withAlpha(15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selectedColor.withAlpha(100),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: selectedColor.withAlpha(50),
                      offset: const Offset(0, 4),
                      blurRadius: 12,
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
                          width: isMobile ? 12 : 14, // More compact size
                          height: isMobile ? 12 : 14,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [selectedColor, selectedColor.withAlpha(180)]),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: selectedColor.withAlpha(100),
                                offset: const Offset(0, 1),
                                blurRadius: 3,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8), // More compact spacing
                        Expanded(
                          child: Text(
                            selectedTag.tagName,
                            style: TextStyle(
                              fontSize: isMobile ? 14 : 16, // More compact font
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // More compact
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [selectedColor, selectedColor.withAlpha(200)]),
                            borderRadius: BorderRadius.circular(8), // More compact radius
                            boxShadow: [
                              BoxShadow(
                                color: selectedColor.withAlpha(80),
                                offset: const Offset(0, 1),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Text(
                            '${selectedTag.percentage.toStringAsFixed(1)}%',
                            style: const TextStyle(
                              fontSize: 12, // More compact font
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10), // More compact spacing
                    Row(
                      children: [
                        Expanded(
                          child: _buildCompactDetailItem(
                            icon: Icons.attach_money_rounded,
                            label: 'Revenue',
                            value: _formatCurrency(selectedTag.revenue),
                            color: selectedColor,
                            isDark: isDark,
                            isMobile: isMobile,
                          ),
                        ),
                        const SizedBox(width: 8), // More compact spacing
                        Expanded(
                          child: _buildCompactDetailItem(
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

  Widget _buildCompactDetailItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
    required bool isMobile,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 4 : 6), // More compact padding
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(6), // More compact radius
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: isMobile ? 10 : 12, // More compact icon
                color: color,
              ),
              const SizedBox(width: 3), // More compact spacing
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: isMobile ? 8 : 9, // More compact font
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 1), // More compact spacing
          Text(
            value,
            style: TextStyle(
              fontSize: isMobile ? 10 : 11, // More compact font
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
