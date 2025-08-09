import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:billora/src/features/dashboard/domain/entities/chart_data_point.dart';

class RevenueChart extends StatefulWidget {
  final List<ChartDataPoint> chartData;

  const RevenueChart({
    super.key,
    required this.chartData,
  });

  @override
  State<RevenueChart> createState() => _RevenueChartState();
}

class _RevenueChartState extends State<RevenueChart>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late ZoomPanBehavior _zoomPanBehavior;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeInOut),
    ));
    _zoomPanBehavior = ZoomPanBehavior(
      enablePinching: true,
      enablePanning: true,
      enableMouseWheelZooming: true,
      enableDoubleTapZooming: true,
      enableSelectionZooming: false,
      maximumZoomLevel: 1.0,
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
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final isMobile = size.width < 400;

    // Responsive font sizes
    final titleFontSize = isTablet ? 16.0 : (isMobile ? 12.0 : 14.0);
    final labelFontSize = isTablet ? 13.0 : (isMobile ? 10.0 : 11.0);
    final legendFontSize = isTablet ? 14.0 : (isMobile ? 11.0 : 12.0);

    // Dynamic margin based on screen size
    final chartMargin = EdgeInsets.all(isTablet ? 20.0 : (isMobile ? 8.0 : 12.0));

    if (widget.chartData.isEmpty) {
      return _buildEmptyState(isDark, isTablet);
    }

    // Process data to reduce zeros and add scaling notation
    final processedData = _processChartData(widget.chartData);
    final scalingFactor = _getScalingFactor(widget.chartData);
    final scalingText = _getScalingText(scalingFactor);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Column(
              children: [
                // Scaling notation
                if (scalingText.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      scalingText,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: labelFontSize - 1,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white60 : const Color(0xFF64748B),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                
                // Chart
                Expanded(
                  child: SfCartesianChart(
                    margin: chartMargin,
                    plotAreaBorderWidth: 0,
                    backgroundColor: Colors.transparent,
                    enableAxisAnimation: true,
                    
                    // Enhanced Primary X Axis
                    primaryXAxis: DateTimeAxis(
                      dateFormat: _getDateFormat(widget.chartData),
                      intervalType: _getIntervalType(widget.chartData),
                      majorGridLines: MajorGridLines(
                        width: 0.8,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.2)
                            : Colors.black.withValues(alpha: 0.15),
                        dashArray: const [3, 6],
                      ),
                      minorGridLines: MinorGridLines(
                        width: 0.4,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.black.withValues(alpha: 0.08),
                        dashArray: const [2, 4],
                      ),
                      axisLine: AxisLine(
                        width: 1.5,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.4)
                            : Colors.black.withValues(alpha: 0.3),
                      ),
                      labelStyle: TextStyle(
                        color: isDark ? Colors.white70 : const Color(0xFF64748B),
                        fontSize: labelFontSize,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                      title: AxisTitle(
                        text: 'Time',
                        textStyle: TextStyle(
                          color: isDark ? Colors.white60 : const Color(0xFF475569),
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    
                    // Enhanced Primary Y Axis
                    primaryYAxis: NumericAxis(
                      labelFormat: '{value}',
                      numberFormat: _getCurrencyFormat(scalingFactor),
                      majorGridLines: MajorGridLines(
                        width: 0.8,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.2)
                            : Colors.black.withValues(alpha: 0.15),
                        dashArray: const [4, 8],
                      ),
                      minorGridLines: MinorGridLines(
                        width: 0.4,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.black.withValues(alpha: 0.08),
                      ),
                      axisLine: AxisLine(
                        width: 1.5,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.4)
                            : Colors.black.withValues(alpha: 0.3),
                      ),
                      labelStyle: TextStyle(
                        color: isDark ? Colors.white70 : const Color(0xFF64748B),
                        fontSize: labelFontSize,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                      title: AxisTitle(
                        text: 'Revenue (\$)',
                        textStyle: TextStyle(
                          color: isDark ? Colors.white60 : const Color(0xFF475569),
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    
                    // Chart Series
                    series: _buildChartSeries(processedData, isDark, isTablet),
                    
                    // Tooltip
                    tooltipBehavior: TooltipBehavior(
                      enable: true,
                      duration: 2000,
                      animationDuration: 200,
                      canShowMarker: true,
                      header: '',
                      format: 'point.x : point.y',
                      color: isDark
                          ? const Color(0xFF1E293B)
                          : Colors.white,
                      textStyle: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                        fontSize: labelFontSize + 1,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                      opacity: 0.95,
                    ),
                    
                    // Modern Legend
                    legend: Legend(
                      isVisible: !isMobile,
                      position: LegendPosition.bottom,
                      alignment: ChartAlignment.center,
                      borderColor: Colors.transparent,
                      backgroundColor: Colors.transparent,
                      textStyle: TextStyle(
                        color: isDark ? Colors.white70 : const Color(0xFF64748B),
                        fontSize: legendFontSize,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.4,
                      ),
                      iconHeight: isTablet ? 16 : 12,
                      iconWidth: isTablet ? 16 : 12,
                      padding: isTablet ? 16 : 12,
                      itemPadding: isTablet ? 12 : 8,
                    ),
                    
                    // Enhanced Zoom Pan Behavior
                    zoomPanBehavior: _zoomPanBehavior,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<ChartDataPoint> _processChartData(List<ChartDataPoint> originalData) {
    if (originalData.isEmpty) return originalData;
    
    final scalingFactor = _getScalingFactor(originalData);
    
    return originalData.map((point) => ChartDataPoint(
      date: point.date,
      value: point.value / scalingFactor, label: '',
    )).toList();
  }

  double _getScalingFactor(List<ChartDataPoint> data) {
    if (data.isEmpty) return 1.0;
    
    final maxValue = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    
    if (maxValue >= 1000000000) {
      return 1000000000; // Billions
    } else if (maxValue >= 1000000) {
      return 1000000; // Millions
    } else if (maxValue >= 1000) {
      return 1000; // Thousands
    }
    
    return 1.0;
  }

  String _getScalingText(double scalingFactor) {
    if (scalingFactor >= 1000000000) {
      return 'Values in Billions (\$B)';
    } else if (scalingFactor >= 1000000) {
      return 'Values in Millions (\$M)';
    } else if (scalingFactor >= 1000) {
      return 'Values in Thousands (\$K)';
    }
    
    return '';
  }

  List<CartesianSeries> _buildChartSeries(List<ChartDataPoint> data, bool isDark, bool isTablet) {
    final primaryGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF667EEA).withValues(alpha: 0.2),
        const Color(0xFF764BA2).withValues(alpha: 0.1),
        const Color(0xFF667EEA).withValues(alpha: 0.025),
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    return [
      // Background Area Series
      AreaSeries<ChartDataPoint, DateTime>(
        dataSource: data,
        xValueMapper: (ChartDataPoint data, _) => data.date,
        yValueMapper: (ChartDataPoint data, _) => data.value,
        name: 'Revenue Area',
        gradient: primaryGradient,
        borderWidth: 0,
        borderColor: Colors.transparent,
        animationDuration: 1500,
        animationDelay: 500,
      ),
      
      // Main Line Series
      LineSeries<ChartDataPoint, DateTime>(
        dataSource: data,
        xValueMapper: (ChartDataPoint data, _) => data.date,
        yValueMapper: (ChartDataPoint data, _) => data.value,
        name: 'Revenue',
        color: const Color(0xFF667EEA),
        width: isTablet ? 3.0 : 2.5,
        markerSettings: MarkerSettings(
          isVisible: true,
          height: isTablet ? 8 : 6,
          width: isTablet ? 8 : 6,
          color: const Color(0xFF667EEA),
          borderWidth: 2,
          borderColor: Colors.white,
        ),
        animationDuration: 1500,
        animationDelay: 300,
      ),
      
      // Trend Line Series (Dashed)
      LineSeries<ChartDataPoint, DateTime>(
        dataSource: data,
        xValueMapper: (ChartDataPoint data, _) => data.date,
        yValueMapper: (ChartDataPoint data, _) => data.value * 0.95, // Slightly below main line
        name: 'Trend',
        color: const Color(0xFF48BB78),
        width: isTablet ? 2.0 : 1.5,
        dashArray: const [5, 5],
        markerSettings: MarkerSettings(
          isVisible: false,
        ),
        animationDuration: 1500,
        animationDelay: 700,
      ),
    ];
  }

  DateFormat _getDateFormat(List<ChartDataPoint> data) {
    if (data.isEmpty) return DateFormat('MMM dd');
    
    final firstDate = data.first.date;
    final lastDate = data.last.date;
    final difference = lastDate.difference(firstDate).inDays;
    
    if (difference <= 7) {
      return DateFormat('EEE dd/MM');
    } else if (difference <= 31) {
      return DateFormat('MMM dd');
    } else if (difference <= 365) {
      return DateFormat('MMM');
    } else {
      return DateFormat('yyyy');
    }
  }

  DateTimeIntervalType _getIntervalType(List<ChartDataPoint> data) {
    if (data.isEmpty) return DateTimeIntervalType.days;
    
    final firstDate = data.first.date;
    final lastDate = data.last.date;
    final difference = lastDate.difference(firstDate).inDays;
    
    if (difference <= 7) {
      return DateTimeIntervalType.days;
    } else if (difference <= 31) {
      return DateTimeIntervalType.days;
    } else if (difference <= 365) {
      return DateTimeIntervalType.months;
    } else {
      return DateTimeIntervalType.years;
    }
  }

  NumberFormat _getCurrencyFormat(double scalingFactor) {
    if (scalingFactor >= 1000000000) {
      return NumberFormat.compact(locale: 'en_US');
    } else if (scalingFactor >= 1000000) {
      return NumberFormat.compact(locale: 'en_US');
    } else if (scalingFactor >= 1000) {
      return NumberFormat.compact(locale: 'en_US');
    }
    
    return NumberFormat.currency(symbol: '\$', decimalDigits: 0);
  }

  Widget _buildEmptyState(bool isDark, bool isTablet) {
    return Column(
      children: [
        // Scaling notation placeholder
        const SizedBox(height: 8),
        
        // Empty state content
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1E293B).withValues(alpha: 0.1)
                  : const Color(0xFFF1F5F9).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.trending_up_outlined,
                    size: isTablet ? 48 : 40,
                    color: isDark ? Colors.white60 : Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Revenue Data Available',
                    style: TextStyle(
                      fontSize: isTablet ? 16 : 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white60 : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Revenue data will appear here once invoices are created',
                    style: TextStyle(
                      fontSize: isTablet ? 14 : 12,
                      color: isDark ? Colors.white.withValues(alpha: 0.4) : Colors.grey.shade500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
