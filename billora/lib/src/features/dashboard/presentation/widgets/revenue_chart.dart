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

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: _buildChartBackgroundGradient(isDark),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
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
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.06),
                      dashArray: const [3, 6],
                    ),
                    minorGridLines: MinorGridLines(
                      width: 0.4,
                      color: isDark 
                          ? Colors.white.withValues(alpha: 0.04)
                          : Colors.black.withValues(alpha: 0.03),
                      dashArray: const [2, 4],
                    ),
                    axisLine: AxisLine(
                      width: 1.5,
                      color: isDark 
                          ? Colors.white.withValues(alpha: 0.15)
                          : Colors.black.withValues(alpha: 0.12),
                    ),
                    labelStyle: TextStyle(
                      color: isDark ? Colors.white70 : const Color(0xFF64748B),
                      fontSize: labelFontSize,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                    title: AxisTitle(
                      text: 'Thời gian',
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
                    labelFormat: '{value}₫',
                    numberFormat: _getCurrencyFormat(),
                    majorGridLines: MajorGridLines(
                      width: 0.8,
                      color: isDark 
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.06),
                      dashArray: const [4, 8],
                    ),
                    minorGridLines: MinorGridLines(
                      width: 0.4,
                      color: isDark 
                          ? Colors.white.withValues(alpha: 0.04)
                          : Colors.black.withValues(alpha: 0.03),
                    ),
                    axisLine: AxisLine(
                      width: 1.5,
                      color: isDark 
                          ? Colors.white.withValues(alpha: 0.15)
                          : Colors.black.withValues(alpha: 0.12),
                    ),
                    labelStyle: TextStyle(
                      color: isDark ? Colors.white70 : const Color(0xFF64748B),
                      fontSize: labelFontSize,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                    title: AxisTitle(
                      text: 'Doanh thu (₫)',
                      textStyle: TextStyle(
                        color: isDark ? Colors.white60 : const Color(0xFF475569),
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                  // Modern Chart Series
                  series: _buildChartSeries(isDark, isTablet),

                  // Enhanced Tooltip
                  tooltipBehavior: TooltipBehavior(
                    enable: true,
                    animationDuration: 400,
                    canShowMarker: true,
                    header: '',
                    format: 'point.x: point.y₫',
                    shadowColor: Colors.black38,
                    elevation: 12,
                    borderWidth: 1,
                    borderColor: isDark 
                        ? Colors.white.withValues(alpha: 0.2)
                        : Colors.black.withValues(alpha: 0.1),
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
            ),
          ),
        );
      },
    );
  }

  LinearGradient _buildChartBackgroundGradient(bool isDark) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [
              const Color(0xFF1E293B).withValues(alpha: 0.8),
              const Color(0xFF334155).withValues(alpha: 0.6),
            ]
          : [
              Colors.white.withValues(alpha: 0.9),
              const Color(0xFFF8FAFC).withValues(alpha: 0.7),
            ],
      stops: const [0.0, 1.0],
    );
  }

  List<CartesianSeries> _buildChartSeries(bool isDark, bool isTablet) {
    final primaryGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF667EEA).withValues(alpha: 0.8),
        const Color(0xFF764BA2).withValues(alpha: 0.4),
        const Color(0xFF667EEA).withValues(alpha: 0.1),
      ],
      stops: const [0.0, 0.5, 1.0],
    );



    return [
      // Background Area Series
      AreaSeries<ChartDataPoint, DateTime>(
        dataSource: widget.chartData,
        xValueMapper: (ChartDataPoint data, _) => data.date,
        yValueMapper: (ChartDataPoint data, _) => data.value,
        name: 'Vùng doanh thu',
        gradient: primaryGradient,
        borderWidth: 0,
        animationDuration: 800,
        animationDelay: 100,
        enableTooltip: false,
      ),
      
      // Main Line Series with Gradient
      LineSeries<ChartDataPoint, DateTime>(
        dataSource: widget.chartData,
        xValueMapper: (ChartDataPoint data, _) => data.date,
        yValueMapper: (ChartDataPoint data, _) => data.value,
        name: 'Doanh thu',
        color: const Color(0xFF667EEA),
        width: isTablet ? 4.0 : 3.0,
        animationDuration: 1000,
        animationDelay: 200,
        dashArray: const [],
        
        // Enhanced Markers
        markerSettings: MarkerSettings(
          isVisible: true,
          height: isTablet ? 10.0 : 8.0,
          width: isTablet ? 10.0 : 8.0,
          shape: DataMarkerType.circle,
          color: Colors.white,
          borderColor: const Color(0xFF667EEA),
          borderWidth: isTablet ? 3.0 : 2.5,
        ),
        
        // Data Label Settings
        dataLabelSettings: DataLabelSettings(
          isVisible: false,
          labelAlignment: ChartDataLabelAlignment.top,
          textStyle: TextStyle(
            color: isDark ? Colors.white70 : const Color(0xFF475569),
            fontSize: isTablet ? 11.0 : 9.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Secondary Spline Series for smooth curves
      SplineSeries<ChartDataPoint, DateTime>(
        dataSource: widget.chartData,
        xValueMapper: (ChartDataPoint data, _) => data.date,
        yValueMapper: (ChartDataPoint data, _) => data.value,
        name: 'Xu hướng',
        color: const Color(0xFF10B981).withValues(alpha: 0.6),
        width: isTablet ? 2.0 : 1.5,
        animationDuration: 1200,
        animationDelay: 300,
        dashArray: const [8, 4],
        splineType: SplineType.cardinal,
        cardinalSplineTension: 0.4,
        enableTooltip: false,
        
        markerSettings: MarkerSettings(
          isVisible: false,
          height: isTablet ? 6.0 : 5.0,
          width: isTablet ? 6.0 : 5.0,
          shape: DataMarkerType.diamond,
          color: const Color(0xFF10B981),
          borderWidth: 1.5,
          borderColor: Colors.white,
        ),
      ),
    ];
  }

  Widget _buildEmptyState(bool isDark, bool isTablet) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: _buildChartBackgroundGradient(isDark),
        border: Border.all(
          color: isDark 
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(isTablet ? 24 : 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF667EEA).withValues(alpha: 0.1),
                    const Color(0xFF764BA2).withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: const Color(0xFF667EEA).withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.show_chart_rounded,
                size: isTablet ? 48 : 40,
                color: const Color(0xFF667EEA),
              ),
            ),
            SizedBox(height: isTablet ? 24 : 20),
            Text(
              'Không có dữ liệu biểu đồ',
              style: TextStyle(
                fontSize: isTablet ? 18 : 16,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
                letterSpacing: 0.3,
              ),
            ),
            SizedBox(height: isTablet ? 12 : 8),
            Text(
              'Dữ liệu sẽ hiển thị khi có giao dịch trong khoảng thời gian được chọn',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isTablet ? 14 : 12,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white60 : const Color(0xFF64748B),
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }



  DateFormat _getDateFormat(List<ChartDataPoint> data) {
    if (data.isEmpty) return DateFormat('dd/MM');
    
    final daysDifference = data.last.date.difference(data.first.date).inDays;
    
    if (daysDifference <= 7) {
      return DateFormat('E dd/MM');
    } else if (daysDifference <= 31) {
      return DateFormat('dd/MM');
    } else if (daysDifference <= 365) {
      return DateFormat('MM/yy');
    } else {
      return DateFormat('yyyy');
    }
  }

  DateTimeIntervalType _getIntervalType(List<ChartDataPoint> data) {
    if (data.isEmpty) return DateTimeIntervalType.days;
    
    final daysDifference = data.last.date.difference(data.first.date).inDays;
    
    if (daysDifference <= 7) {
      return DateTimeIntervalType.days;
    } else if (daysDifference <= 31) {
      return DateTimeIntervalType.days;
    } else if (daysDifference <= 365) {
      return DateTimeIntervalType.months;
    } else {
      return DateTimeIntervalType.years;
    }
  }

  NumberFormat _getCurrencyFormat() {
    return NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '',
      decimalDigits: 0,
    );
  }
}
