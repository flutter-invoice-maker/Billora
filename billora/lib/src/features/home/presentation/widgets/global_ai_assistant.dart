import 'package:flutter/material.dart';

class GlobalAIAssistant extends StatefulWidget {
  final int currentTabIndex;
  final Color primaryColor;

  const GlobalAIAssistant({
    super.key,
    required this.currentTabIndex,
    required this.primaryColor,
  });

  @override
  State<GlobalAIAssistant> createState() => _GlobalAIAssistantState();
}

class _GlobalAIAssistantState extends State<GlobalAIAssistant>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.repeat(reverse: true);
    _updateVisibility();
  }

  @override
  void didUpdateWidget(GlobalAIAssistant oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentTabIndex != widget.currentTabIndex) {
      _updateVisibility();
    }
  }

  void _updateVisibility() {
    setState(() {
      // Show AI assistant on main tabs (Dashboard, Customers, Products, Invoices)
      _isVisible = widget.currentTabIndex >= 0 && widget.currentTabIndex <= 4;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    return Positioned(
      bottom: 220, // Move up more to avoid overlapping with Add Invoice button
      right: 20,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: widget.primaryColor.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: FloatingActionButton(
                  onPressed: () => _showGlobalAIChatPanel(context),
                  backgroundColor: widget.primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  heroTag: "global_ai_assistant",
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(
                        Icons.auto_awesome,
                        size: 24,
                      ),
                      // Animated glow effect
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            gradient: RadialGradient(
                              colors: [
                                Colors.white.withValues(alpha: 0.2),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showGlobalAIChatPanel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final height = MediaQuery.of(context).size.height;
        return SizedBox(
          height: height,
          child: GlobalAIChatPanel(
            currentTabIndex: widget.currentTabIndex,
            primaryColor: widget.primaryColor,
            scrollController: ScrollController(),
          ),
        );
      },
    );
  }
}

class GlobalAIChatPanel extends StatefulWidget {
  final int currentTabIndex;
  final Color primaryColor;
  final ScrollController scrollController;

  const GlobalAIChatPanel({
    super.key,
    required this.currentTabIndex,
    required this.primaryColor,
    required this.scrollController,
  });

  @override
  State<GlobalAIChatPanel> createState() => _GlobalAIChatPanelState();
}

class _GlobalAIChatPanelState extends State<GlobalAIChatPanel> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _addSystemMessage();
  }

  void _addSystemMessage() {
    String contextMessage = _getContextualWelcomeMessage();
    _messages.add(ChatMessage(
      text: contextMessage,
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  String _getContextualWelcomeMessage() {
    switch (widget.currentTabIndex) {
      case 0:
        return 'Hello! I\'m your AI assistant. I can help you analyze your dashboard data, provide business insights, and answer questions about your invoices, customers, and products.';
      case 1:
        return 'Hi! I can help you with customer analysis, suggest customer segmentation strategies, and provide insights about your customer relationships.';
      case 2:
        return 'Hello! I can assist with product analysis, inventory insights, pricing strategies, and product performance metrics.';
      case 3:
        return 'Hi! I\'m here to help with invoice analysis, billing insights, payment tracking, and financial reporting.';
      default:
        return 'Hello! I\'m your AI assistant. I can help you with business analysis, data insights, and answer questions about your invoices, customers, and products.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(),
          
          // Quick Actions
          _buildContextualQuickActions(),
          
          // Messages
          Expanded(
            child: _buildMessagesList(),
          ),
          
          // Input
          _buildInputSection(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.primaryColor.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: widget.primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Business Assistant',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: widget.primaryColor,
                  ),
                ),
                Text(
                  _getContextualSubtitle(),
                  style: TextStyle(
                    fontSize: 12,
                    color: widget.primaryColor.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.close,
              color: widget.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  String _getContextualSubtitle() {
    switch (widget.currentTabIndex) {
      case 0:
        return 'Dashboard Analytics & Business Insights';
      case 1:
        return 'Customer Relationship Analysis';
      case 2:
        return 'Product & Inventory Intelligence';
      case 3:
        return 'Invoice & Financial Analysis';
      default:
        return 'Business Intelligence & Analytics';
    }
  }

  Widget _buildContextualQuickActions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _getContextualActions(),
      ),
    );
  }

  List<Widget> _getContextualActions() {
    switch (widget.currentTabIndex) {
      case 0: // Dashboard
        return [
          _buildQuickActionButton('Revenue Analysis', Icons.trending_up),
          _buildQuickActionButton('Customer Insights', Icons.people),
          _buildQuickActionButton('Product Performance', Icons.inventory),
          _buildQuickActionButton('Financial Summary', Icons.account_balance),
        ];
      case 1: // Customers
        return [
          _buildQuickActionButton('Customer Segmentation', Icons.group),
          _buildQuickActionButton('Payment Patterns', Icons.payment),
          _buildQuickActionButton('Customer Lifetime Value', Icons.star),
          _buildQuickActionButton('Retention Analysis', Icons.repeat),
        ];
      case 2: // Products
        return [
          _buildQuickActionButton('Top Selling Products', Icons.trending_up),
          _buildQuickActionButton('Inventory Optimization', Icons.inventory_2),
          _buildQuickActionButton('Pricing Strategy', Icons.attach_money),
          _buildQuickActionButton('Product Categories', Icons.category),
        ];
      case 3: // Invoices
        return [
          _buildQuickActionButton('Invoice Analysis', Icons.receipt_long),
          _buildQuickActionButton('Payment Status', Icons.payment),
          _buildQuickActionButton('Overdue Tracking', Icons.schedule),
          _buildQuickActionButton('Revenue Trends', Icons.show_chart),
        ];
      default:
        return [
          _buildQuickActionButton('Business Overview', Icons.business),
          _buildQuickActionButton('Data Analysis', Icons.analytics),
          _buildQuickActionButton('Performance Metrics', Icons.speed),
          _buildQuickActionButton('Growth Insights', Icons.trending_up),
        ];
    }
  }

  Widget _buildQuickActionButton(String text, IconData icon) {
    return InkWell(
      onTap: () => _sendQuickMessage(text),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: widget.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: widget.primaryColor.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: widget.primaryColor,
            ),
            const SizedBox(width: 4),
            Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: widget.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      controller: widget.scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: widget.primaryColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isUser 
                    ? widget.primaryColor 
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? Colors.white : Colors.black87,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Ask me anything about your business...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: widget.primaryColor, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: widget.primaryColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: IconButton(
              onPressed: _isLoading ? null : _sendMessage,
              icon: _isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendQuickMessage(String action) {
    String message = _getContextualMessage(action);
    _messageController.text = message;
    _sendMessage();
  }

  String _getContextualMessage(String action) {
    switch (action) {
      case 'Revenue Analysis':
        return 'Can you analyze my revenue trends and provide insights?';
      case 'Customer Insights':
        return 'What insights can you provide about my customers?';
      case 'Product Performance':
        return 'How are my products performing? Which ones are top sellers?';
      case 'Financial Summary':
        return 'Can you provide a financial summary of my business?';
      case 'Customer Segmentation':
        return 'How should I segment my customers for better targeting?';
      case 'Payment Patterns':
        return 'What patterns do you see in customer payments?';
      case 'Customer Lifetime Value':
        return 'Which customers have the highest lifetime value?';
      case 'Retention Analysis':
        return 'How can I improve customer retention?';
      case 'Top Selling Products':
        return 'What are my top selling products and why?';
      case 'Inventory Optimization':
        return 'How can I optimize my inventory management?';
      case 'Pricing Strategy':
        return 'What pricing strategies would you recommend?';
      case 'Product Categories':
        return 'How should I organize my product categories?';
      case 'Invoice Analysis':
        return 'Can you analyze my invoicing patterns and trends?';
      case 'Payment Status':
        return 'What\'s the status of my outstanding payments?';
      case 'Overdue Tracking':
        return 'Which invoices are overdue and need attention?';
      case 'Revenue Trends':
        return 'What trends do you see in my revenue data?';
      default:
        return 'Can you help me with $action?';
    }
  }

  void _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _isLoading) return;

    // Add user message
    _addMessage(message, true);
    _messageController.clear();

    // Show loading
    setState(() {
      _isLoading = true;
    });

    try {
      // Call AI API with contextual data
      final response = await _callGlobalAIApi(message);
      _addMessage(response, false);
    } catch (error) {
      _addMessage('Sorry, I encountered an error. Please try again.', false);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _addMessage(String text, bool isUser) {
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: isUser,
        timestamp: DateTime.now(),
      ));
    });

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.scrollController.hasClients) {
        widget.scrollController.animateTo(
          widget.scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<String> _callGlobalAIApi(String message) async {
    try {
      // For now, return a contextual response based on the current tab
      // In a real implementation, this would call the AI API with business data
      return _generateContextualResponse(message);
    } catch (error) {
      debugPrint('Global AI API error: $error');
      return 'I\'m having trouble connecting right now. Please try again later.';
    }
  }

  String _generateContextualResponse(String message) {
    final lowerMessage = message.toLowerCase();
    
    if (lowerMessage.contains('revenue') || lowerMessage.contains('financial')) {
      return 'Based on your business data, I can see trends in your revenue. Your invoicing patterns show consistent growth, with peak periods typically occurring at month-end. I recommend focusing on customer retention strategies to maintain this positive trajectory.';
    } else if (lowerMessage.contains('customer')) {
      return 'Your customer base shows healthy diversity. I notice that repeat customers generate 60% more revenue on average. Consider implementing a loyalty program to increase customer lifetime value and retention rates.';
    } else if (lowerMessage.contains('product') || lowerMessage.contains('inventory')) {
      return 'Your product performance data indicates strong sales in certain categories. I recommend analyzing your top-performing products to identify common characteristics and apply those insights to optimize your entire product portfolio.';
    } else if (lowerMessage.contains('invoice') || lowerMessage.contains('payment')) {
      return 'Your invoicing efficiency is good, with most invoices being processed within standard timeframes. To improve cash flow, consider implementing automated payment reminders for overdue invoices and offering early payment discounts.';
    } else {
      return 'I\'m here to help you analyze your business data and provide actionable insights. Feel free to ask me about your revenue trends, customer patterns, product performance, or invoicing processes. What specific aspect of your business would you like to explore?';
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
