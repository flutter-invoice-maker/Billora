import 'package:flutter/material.dart';
import 'package:billora/src/core/services/customer_ranking_service.dart';
import 'package:billora/src/core/services/data_refresh_service.dart';

class AIInsightRankingWidget extends StatefulWidget {
  const AIInsightRankingWidget({super.key});

  @override
  State<AIInsightRankingWidget> createState() => _AIInsightRankingWidgetState();
}

class _AIInsightRankingWidgetState extends State<AIInsightRankingWidget>
    with TickerProviderStateMixin {
  final CustomerRankingService _rankingService = CustomerRankingService();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _rankingService.addListener(_onRankingsChanged);
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    // Refresh all data from Firestore
    DataRefreshService().refreshAllData();
  }

  @override
  void dispose() {
    _rankingService.removeListener(_onRankingsChanged);
    _pulseController.dispose();
    super.dispose();
  }

  void _onRankingsChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final rankings = _rankingService.rankings.take(8).toList();
    
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
                      color: Colors.blue[600],
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
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
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
              _buildHeader(),
              const SizedBox(height: 20),
              if (rankings.isEmpty)
                _buildEmptyState()
              else
                _buildRankingsList(rankings),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[500]!, Colors.blue[700]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.emoji_events,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Customer Rankings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Top performing customers based on AI analysis',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No rankings yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Customer rankings will appear here once you have paid invoices',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRankingsList(List<CustomerRanking> rankings) {
    return Column(
      children: [
        // Top 3 rankings with special layout
        if (rankings.length >= 3) _buildTopThreeRankings(rankings.take(3).toList()),
        
        // Other rankings
        if (rankings.length > 3) ...[
          const SizedBox(height: 20),
          ...rankings.skip(3).map((ranking) => _buildRankingItem(ranking, rankings.indexOf(ranking) + 1)),
        ],
      ],
    );
  }

  Widget _buildTopThreeRankings(List<CustomerRanking> topThree) {
    return Row(
      children: [
        // 2nd place
        if (topThree.length >= 2)
          Expanded(
            child: _buildTopRankingItem(topThree[1], 2),
          ),
        
        // 1st place
        if (topThree.isNotEmpty)
          Expanded(
            child: _buildTopRankingItem(topThree[0], 1),
          ),
        
        // 3rd place
        if (topThree.length >= 3)
          Expanded(
            child: _buildTopRankingItem(topThree[2], 3),
          ),
      ],
    );
  }

  Widget _buildTopRankingItem(CustomerRanking ranking, int position) {
    final colors = [
      const Color(0xFF4A90E2), // Blue
      const Color(0xFF7ED321), // Green
      const Color(0xFFF5A623), // Orange
    ];
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _rankingService.getRankingColor(position).withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // Crown icon
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _rankingService.getRankingColor(position),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.emoji_events,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(height: 8),
          
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colors[position - 1],
              shape: BoxShape.circle,
              border: Border.all(
                color: _rankingService.getRankingColor(position),
                width: 3,
              ),
            ),
            child: Center(
              child: Text(
                ranking.customerName.isNotEmpty
                    ? ranking.customerName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          
          // Customer name
          Text(
            ranking.customerName,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          
          // Level badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: _rankingService.getLevelColor(ranking.level),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Lv.${ranking.level}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 4),
          
          // Score
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                ranking.formattedScore,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.local_fire_department,
                color: Colors.red[600],
                size: 12,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRankingItem(CustomerRanking ranking, int position) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          // Position number
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                position.toString(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue[100],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                ranking.customerName.isNotEmpty
                    ? ranking.customerName[0].toUpperCase()
                    : '?',
                style: TextStyle(
                  color: Colors.blue[700],
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Customer info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ranking.customerName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _rankingService.getLevelColor(ranking.level),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Lv.${ranking.level}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Alone raho useme khusi he ahoa...',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Score
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Text(
                    ranking.formattedScore,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.local_fire_department,
                    color: Colors.red[600],
                    size: 14,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Icon(
                Icons.diamond,
                color: Colors.grey[400],
                size: 12,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
