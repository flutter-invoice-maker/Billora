import 'package:flutter/material.dart';
import 'package:billora/src/core/services/customer_ranking_service.dart';
import 'package:billora/src/core/services/data_refresh_service.dart';
import 'package:billora/src/core/services/avatar_service.dart';
//
// no-op

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
    
    // Load customer rankings specifically
    _rankingService.loadCustomerRankings();
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
    final rankings = _rankingService.rankings.take(10).toList();
    
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
        if (rankings.isEmpty)
          _buildEmptyState()
        else if (rankings.length < 3)
          _buildInsufficientDataState(rankings.length)
        else
          Column(
            children: [
              // Top 3 rankings with podium layout
              _buildTopThreeRankings(rankings.take(3).toList()),
              
              // Other rankings (4-10) as list items
              if (rankings.length > 3) ...[
                const SizedBox(height: 20),
                ...rankings.asMap().entries
                    .where((entry) => entry.key >= 3)
                    .take(7)
                    .map((entry) => _buildListRankingItem(entry.value, entry.key + 1)),
              ],
            ],
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
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
            'Customer rankings will appear here once you have at least 3 customers with invoices',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Need: 3 customers minimum',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsufficientDataState(int currentCount) {
    final remaining = 3 - currentCount;
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.blue[200]!,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.people_outline,
              size: 48,
              color: Colors.blue[600],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Almost there!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.blue[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You have $currentCount customer${currentCount == 1 ? '' : 's'}. Need $remaining more to see rankings.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.blue[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue[200],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Progress: $currentCount/3',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.blue[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopThreeRankings(List<CustomerRanking> topThree) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd place (left)
          if (topThree.length >= 2)
            Expanded(
              child: _buildPodiumItem(topThree[1], 2, height: 120),
            ),
          
          // 1st place (center) - highest
          if (topThree.isNotEmpty)
            Expanded(
              child: _buildPodiumItem(topThree[0], 1, height: 150),
            ),
          
          // 3rd place (right)
          if (topThree.length >= 3)
            Expanded(
              child: _buildPodiumItem(topThree[2], 3, height: 100),
            ),
        ],
      ),
    );
  }

  Widget _buildPodiumItem(CustomerRanking ranking, int position, {required double height}) {
    Color getCrownColor() {
      switch (position) {
        case 1: return const Color(0xFFFFD700); // Gold
        case 2: return const Color(0xFFC0C0C0); // Silver  
        case 3: return const Color(0xFFCD7F32); // Bronze
        default: return Colors.grey;
      }
    }


    Color getBorderColor() {
      switch (position) {
        case 1: return const Color(0xFFFFD700); // Gold border
        case 2: return const Color(0xFFC0C0C0); // Silver border
        case 3: return const Color(0xFFCD7F32); // Bronze border
        default: return Colors.grey;
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: getBorderColor(),
          width: position == 1 ? 3 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: getBorderColor().withValues(alpha: 0.2),
            blurRadius: position == 1 ? 15 : 10,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Crown icon
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: getCrownColor(),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: getCrownColor().withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.emoji_events,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(height: 8),
          
          // Avatar (prefer ranking.avatarUrl when available)
          Builder(
            builder: (context) {
              final String? avatarUrl = ranking.avatarUrl;
              final avatarSize = position == 1 ? 60.0 : 50.0;
              if (avatarUrl != null && avatarUrl.isNotEmpty) {
                return ClipOval(
                  child: Image.network(
                    avatarUrl,
                    width: avatarSize,
                    height: avatarSize,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) {
                      return AvatarService.buildAvatar(
                        name: ranking.customerName,
                        size: avatarSize,
                      );
                    },
                  ),
                );
              }
              return AvatarService.buildAvatar(
                name: ranking.customerName,
                size: avatarSize,
              );
            },
          ),
          const SizedBox(height: 12),
          
          // Customer name
          SizedBox(
            width: double.infinity,
            child: Text(
              ranking.customerName,
              style: TextStyle(
                fontSize: position == 1 ? 14 : 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4),
          
          // Level
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _rankingService.getLevelColor(ranking.level),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Lv${ranking.level}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          
          // Score
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  ranking.formattedScore,
                  style: TextStyle(
                    fontSize: position == 1 ? 14 : 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.orange[700],
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.local_fire_department,
                  color: Colors.orange[700],
                  size: position == 1 ? 14 : 12,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListRankingItem(CustomerRanking ranking, int position) {
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Avatar (prefer ranking.avatarUrl when available)
          Builder(
            builder: (context) {
              final String? avatarUrl = ranking.avatarUrl;
              const double avatarSize = 40.0;
              if (avatarUrl != null && avatarUrl.isNotEmpty) {
                return ClipOval(
                  child: Image.network(
                    avatarUrl,
                    width: avatarSize,
                    height: avatarSize,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) {
                      return AvatarService.buildAvatar(
                        name: ranking.customerName,
                        size: avatarSize,
                      );
                    },
                  ),
                );
              }
              return AvatarService.buildAvatar(
                name: ranking.customerName,
                size: avatarSize,
              );
            },
          ),
          const SizedBox(width: 12),
          
          // Customer info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ranking.customerName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _rankingService.getLevelColor(ranking.level),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Lv${ranking.level}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Top customer',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Score
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  ranking.formattedScore,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.orange[700],
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.local_fire_department,
                  color: Colors.orange[700],
                  size: 12,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Removed _safeCustomerCubit; avatars now resolve from ranking data directly