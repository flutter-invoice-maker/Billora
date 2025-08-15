import 'package:flutter/material.dart';
import 'package:billora/src/features/invoice/presentation/widgets/ai_chat_panel.dart';

class GlobalAIButton extends StatelessWidget {
  final String? invoiceId;
  final Color primaryColor;
  final bool isVisible;
  final VoidCallback? onPressed;

  const GlobalAIButton({
    super.key,
    this.invoiceId,
    required this.primaryColor,
    this.isVisible = true,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return Positioned(
      bottom: 200, // Move up more to avoid overlapping with Add Invoice button
      right: 20,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
              spreadRadius: 0,
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: onPressed ?? () => _showAIChatPanel(context),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 8,
          child: const Icon(
            Icons.auto_awesome,
            size: 24,
          ),
        ),
      ),
    );
  }

  void _showAIChatPanel(BuildContext context) {
    if (invoiceId == null) {
      // Show general AI assistant for main pages
      _showGeneralAIAssistant(context);
    } else {
      // Show invoice-specific AI chat
      _showInvoiceAIChat(context);
    }
  }

  void _showGeneralAIAssistant(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => GeneralAIAssistant(
          primaryColor: primaryColor,
          scrollController: scrollController,
        ),
      ),
    );
  }

  void _showInvoiceAIChat(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => AIChatPanel(
          invoiceId: invoiceId!,
          primaryColor: primaryColor,
          scrollController: scrollController,
        ),
      ),
    );
  }
}

class GeneralAIAssistant extends StatefulWidget {
  final Color primaryColor;
  final ScrollController scrollController;

  const GeneralAIAssistant({
    super.key,
    required this.primaryColor,
    required this.scrollController,
  });

  @override
  State<GeneralAIAssistant> createState() => _GeneralAIAssistantState();
}

class _GeneralAIAssistantState extends State<GeneralAIAssistant> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _addSystemMessage();
  }

  void _addSystemMessage() {
    _messages.add(ChatMessage(
      text: 'Hello! I\'m your AI business assistant. I can help you with:\n\n• Invoice analysis and insights\n• Business recommendations\n• Data analytics\n• Process optimization\n\nWhat would you like to know about your business?',
      isUser: false,
      timestamp: DateTime.now(),
    ));
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
          _buildQuickActions(),
          
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.primaryColor.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.auto_awesome,
            color: widget.primaryColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            'AI Business Assistant',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: widget.primaryColor,
            ),
          ),
          const Spacer(),
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

  Widget _buildQuickActions() {
    final quickActions = <Map<String, dynamic>>[
      {'icon': Icons.analytics, 'title': 'Business Insights', 'prompt': 'Show me business insights and analytics'},
      {'icon': Icons.trending_up, 'title': 'Growth Tips', 'prompt': 'Give me tips for business growth'},
      {'icon': Icons.assessment, 'title': 'Performance Review', 'prompt': 'Review my business performance'},
      {'icon': Icons.lightbulb, 'title': 'Innovation Ideas', 'prompt': 'Suggest innovative business ideas'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: quickActions.map((action) => _buildQuickActionCard(action)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(Map<String, dynamic> action) {
    return GestureDetector(
      onTap: () => _handleQuickAction(action['prompt']!),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.primaryColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              action['icon'] as IconData,
              color: widget.primaryColor,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              action['title']!,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: widget.primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      controller: widget.scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: widget.primaryColor,
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: message.isUser 
                    ? widget.primaryColor 
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? Colors.white : Colors.grey.shade800,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey.shade300,
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
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
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: widget.primaryColor),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: widget.primaryColor,
              shape: BoxShape.circle,
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

  void _handleQuickAction(String prompt) {
    _messageController.text = prompt;
    _sendMessage();
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
      // Call AI API for general business assistance
      final response = await _callGeneralAI(message);
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

  Future<String> _callGeneralAI(String message) async {
    try {
      // For now, return a mock response
      // In the future, this can be connected to a general AI service
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      
      if (message.toLowerCase().contains('insight') || message.toLowerCase().contains('analytics')) {
        return 'Based on your business data, I can see:\n\n• Revenue growth trend: +15% this quarter\n• Top performing products: Software licenses\n• Customer retention rate: 87%\n• Areas for improvement: Customer onboarding\n\nWould you like me to dive deeper into any specific area?';
      } else if (message.toLowerCase().contains('growth') || message.toLowerCase().contains('tip')) {
        return 'Here are some growth strategies for your business:\n\n• Expand to new markets with similar customer profiles\n• Implement customer loyalty programs\n• Optimize pricing strategies based on competitor analysis\n• Invest in digital marketing and automation\n\nWhich area interests you most?';
      } else if (message.toLowerCase().contains('performance') || message.toLowerCase().contains('review')) {
        return 'Your business performance overview:\n\n• Financial Health: Strong (A+)\n• Operational Efficiency: Good (B+)\n• Market Position: Excellent (A)\n• Innovation Score: Good (B)\n\nKey strengths: Customer satisfaction, product quality\nAreas to improve: Operational costs, market expansion';
      } else if (message.toLowerCase().contains('innovation') || message.toLowerCase().contains('idea')) {
        return 'Innovation opportunities for your business:\n\n• AI-powered customer service automation\n• Subscription-based service models\n• Mobile app for customer self-service\n• Data-driven decision making tools\n• Partnership with complementary businesses\n\nWould you like me to elaborate on any of these ideas?';
      } else {
        return 'I understand you\'re asking about "$message". As your AI business assistant, I can help you with:\n\n• Business strategy and planning\n• Performance analysis and insights\n• Growth opportunities and market trends\n• Operational efficiency improvements\n• Customer experience optimization\n\nWhat specific aspect would you like to explore?';
      }
    } catch (error) {
      debugPrint('General AI API error: $error');
      return 'I\'m having trouble connecting right now. Please try again later.';
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