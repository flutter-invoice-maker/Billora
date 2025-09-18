import 'package:flutter/material.dart';
import 'package:billora/src/core/services/vip_threshold_service.dart';
import 'package:billora/src/core/utils/currency_formatter.dart';

class VipThresholdSettings extends StatefulWidget {
  final Color primaryColor;
  final VoidCallback? onThresholdChanged;

  const VipThresholdSettings({
    super.key,
    required this.primaryColor,
    this.onThresholdChanged,
  });

  @override
  State<VipThresholdSettings> createState() => _VipThresholdSettingsState();
}

class _VipThresholdSettingsState extends State<VipThresholdSettings> {
  final VipThresholdService _vipService = VipThresholdService();
  final TextEditingController _thresholdController = TextEditingController();
  bool _isLoading = false;
  bool _isSaving = false;
  double _currentThreshold = 1000.0;
  Map<String, dynamic> _statistics = {};

  @override
  void initState() {
    super.initState();
    _loadThreshold();
    _loadStatistics();
  }

  @override
  void dispose() {
    _thresholdController.dispose();
    super.dispose();
  }

  Future<void> _loadThreshold() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final threshold = await _vipService.getVipThreshold();
      setState(() {
        _currentThreshold = threshold;
        _thresholdController.text = threshold.toStringAsFixed(0);
      });
    } catch (e) {
      _showErrorSnackBar('Failed to load VIP threshold: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadStatistics() async {
    try {
      final stats = await _vipService.getVipStatistics();
      setState(() {
        _statistics = stats;
      });
    } catch (e) {
      debugPrint('Error loading VIP statistics: $e');
    }
  }

  Future<void> _saveThreshold() async {
    final thresholdText = _thresholdController.text.trim();
    if (thresholdText.isEmpty) {
      _showErrorSnackBar('Please enter a valid threshold amount');
      return;
    }

    final threshold = double.tryParse(thresholdText);
    if (threshold == null || threshold <= 0) {
      _showErrorSnackBar('Please enter a valid positive number');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _vipService.setVipThreshold(threshold);
      await _vipService.updateAllCustomersVipStatus();
      
      setState(() {
        _currentThreshold = threshold;
      });

      await _loadStatistics();
      
      if (widget.onThresholdChanged != null) {
        widget.onThresholdChanged!();
      }

      _showSuccessSnackBar('VIP threshold updated successfully');
    } catch (e) {
      _showErrorSnackBar('Failed to save VIP threshold: $e');
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.primaryColor.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.primaryColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.star,
                color: widget.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'VIP Threshold Settings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: widget.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Set the minimum revenue amount for automatic VIP status',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),

          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            )
          else ...[
            // Current threshold display
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: widget.primaryColor.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.attach_money,
                    color: widget.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Current Threshold: ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: widget.primaryColor,
                    ),
                  ),
                  Text(
                    CurrencyFormatter.format(_currentThreshold),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: widget.primaryColor,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Threshold input
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'New VIP Threshold',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _thresholdController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Enter minimum revenue amount',
                    prefixText: '\$ ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: widget.primaryColor, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Statistics
            if (_statistics.isNotEmpty) ...[
              Text(
                'VIP Statistics',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 12),
              _buildStatisticsCard(),
              const SizedBox(height: 20),
            ],

            // Save button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveThreshold,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Update VIP Threshold',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatisticsCard() {
    final totalCustomers = _statistics['total_customers'] as int? ?? 0;
    final vipCustomers = _statistics['vip_customers'] as int? ?? 0;
    final vipPercentage = _statistics['vip_percentage'] as double? ?? 0.0;
    final totalVipRevenue = _statistics['total_vip_revenue'] as double? ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Total Customers',
                  totalCustomers.toString(),
                  Icons.people,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'VIP Customers',
                  vipCustomers.toString(),
                  Icons.star,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'VIP Percentage',
                  '${vipPercentage.toStringAsFixed(1)}%',
                  Icons.percent,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'VIP Revenue',
                  CurrencyFormatter.format(totalVipRevenue),
                  Icons.attach_money,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: widget.primaryColor,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: widget.primaryColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}


