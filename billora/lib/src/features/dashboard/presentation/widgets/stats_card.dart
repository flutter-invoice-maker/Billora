import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StatsCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const StatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  State<StatsCard> createState() => _StatsCardState();
}

class _StatsCardState extends State<StatsCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                                  colors: [
                  widget.color,
                  Color.fromARGB(
                    (widget.color.a * 0.85).round(),
                    widget.color.r.round(),
                    widget.color.g.round(),
                    widget.color.b.round(),
                  ),
                ],
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withAlpha(76),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withAlpha(25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withAlpha(51),
                  width: 1.5,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _controller.reverse().then((_) {
                      if (mounted) _controller.forward();
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8), // Giảm padding từ 14 xuống 8
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Header row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                widget.title,
                                style: const TextStyle(
                                  fontSize: 11, // Giảm từ 14 xuống 11
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  letterSpacing: 0.3,
                                  height: 1.2,
                                ),
                                maxLines: 1, // Giảm từ 2 xuống 1
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4), // Giảm từ 8 xuống 4
                            Container(
                              padding: const EdgeInsets.all(4), // Giảm từ 8 xuống 4
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(51),
                                borderRadius: BorderRadius.circular(8), // Giảm từ 12 xuống 8
                              ),
                              child: Icon(
                                widget.icon,
                                color: Colors.white,
                                size: 16, // Giảm từ 22 xuống 16
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 4), // Giảm từ 12 xuống 4
                        
                        // Value text
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            widget.value,
                            style: const TextStyle(
                              fontSize: 18, // Giảm từ 26 xuống 18
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.5,
                              height: 1.0,
                            ),
                          ),
                        ),
                        
                        // Accent line
                        Container(
                          margin: const EdgeInsets.only(top: 2), // Giảm từ 6 xuống 2
                          height: 2, // Giảm từ 3 xuống 2
                          width: 25, // Giảm từ 40 xuống 25
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(76),
                            borderRadius: BorderRadius.circular(1), // Giảm từ 2 xuống 1
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
}