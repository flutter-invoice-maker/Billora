import 'package:flutter/material.dart';
import 'package:billora/src/core/services/ai_chat_service.dart';
import 'package:billora/src/core/di/injection_container.dart';

class EnhancedAIChatWidget extends StatefulWidget {
  final int currentTabIndex;
  final Color primaryColor;
  final ScrollController scrollController;

  const EnhancedAIChatWidget({
    super.key,
    required this.currentTabIndex,
    required this.primaryColor,
    required this.scrollController,
  });

  @override
  State<EnhancedAIChatWidget> createState() => _EnhancedAIChatWidgetState();
}

class _EnhancedAIChatWidgetState extends State<EnhancedAIChatWidget>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _showQuickActions = true;
  late AIChatService _aiChatService;
  late AnimationController _quickActionsController;
  late Animation<double> _quickActionsAnimation;

  @override
  void initState() {
    super.initState();
    _aiChatService = sl<AIChatService>();
    _quickActionsController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _quickActionsAnimation = CurvedAnimation(
      parent: _quickActionsController,
      curve: Curves.easeInOut,
    );
    _addSystemMessage();
  }

  void _addSystemMessage() {
    _messages.add(ChatMessage(
      text: _getContextualWelcomeMessage(),
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  String _getContextualWelcomeMessage() {
    switch (widget.currentTabIndex) {
      case 0:
        return 'Hello! I\'m your AI business analyst. I can analyze your dashboard data, provide business insights, and answer questions about your invoices, customers, and products. What would you like to know?';
      case 1:
        return 'Hi! I can help you with customer analysis, suggest customer segmentation strategies, and provide insights about your customer relationships. What would you like to explore?';
      case 2:
        return 'Hello! I can assist with product analysis, inventory insights, pricing strategies, and product performance metrics. How can I help you today?';
      case 3:
        return 'Hi! I\'m here to help with invoice analysis, billing insights, payment tracking, and financial reporting. What would you like to know about your invoices?';
      default:
        return 'Hello! I\'m your AI business assistant. I can help you with business analysis, data insights, and answer questions about your invoices, customers, and products. What would you like to explore?';
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
          _buildHeader(),
          if (_showQuickActions) _buildQuickActions(),
          Expanded(
            child: _buildMessagesList(),
          ),
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
                  _getTabDescription(),
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

  String _getTabDescription() {
    switch (widget.currentTabIndex) {
      case 0:
        return 'Dashboard Analytics';
      case 1:
        return 'Customer Insights';
      case 2:
        return 'Product Analysis';
      case 3:
        return 'Invoice Management';
      default:
        return 'Business Intelligence';
    }
  }

  Widget _buildQuickActions() {
    final quickActions = _aiChatService.getQuickActions(widget.currentTabIndex);
    
    return SizeTransition(
      sizeFactor: _quickActionsAnimation,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: quickActions.map((action) => _buildQuickActionChip(action)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionChip(QuickAction action) {
    return GestureDetector(
      onTap: () => _handleQuickAction(action),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: widget.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: widget.primaryColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              action.icon,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 6),
            Text(
              action.title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: widget.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _buildMessageBubble(message.text, message.isUser, suggestions: message.suggestions);
      },
    );
  }

  Widget _buildMessageBubble(String message, bool isUser, {List<QuickAction> suggestions = const []}) {
    final isError = message.contains('quota exceeded') || 
                   message.contains('billing') || 
                   message.contains('payment') ||
                   message.contains('API key') ||
                   message.contains('model not found');
    
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isError ? Colors.red.shade100 : Colors.blue.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                isError ? Icons.error : Icons.smart_toy,
                size: 20,
                color: isError ? Colors.red.shade600 : Colors.blue.shade600,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isUser 
                      ? Theme.of(context).primaryColor 
                      : (isError ? Colors.red.shade50 : Colors.grey.shade100),
                    borderRadius: BorderRadius.circular(16),
                    border: isError ? Border.all(color: Colors.red.shade200) : null,
                  ),
                  child: Text(
                    message,
                    style: TextStyle(
                      color: isUser ? Colors.white : (isError ? Colors.red.shade800 : Colors.black87),
                      fontSize: 16,
                    ),
                  ),
                ),
                if (suggestions.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: suggestions.map((suggestion) => _buildSuggestionChip(suggestion)).toList(),
                  ),
                ],
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 12),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.person,
                size: 20,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(QuickAction suggestion) {
    return ActionChip(
      avatar: Text(suggestion.icon),
      label: Text(suggestion.title),
      onPressed: () => _handleQuickAction(suggestion),
      backgroundColor: Colors.blue.shade50,
      labelStyle: TextStyle(color: Colors.blue.shade700),
    );
  }

  Widget _buildInputSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Ask me anything about your business...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
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

  void _handleQuickAction(QuickAction action) {
    _messageController.text = action.prompt;
    _sendMessage();
  }

  void _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _isLoading) return;

    // Add user message
    _addMessage(message, true);
    _messageController.clear();

    // Hide quick actions when user starts typing
    if (_showQuickActions) {
      setState(() {
        _showQuickActions = false;
      });
      _quickActionsController.reverse();
    }

    // Show loading
    setState(() {
      _isLoading = true;
    });

    try {
      // Call AI service with actual business data
      final response = await _aiChatService.sendMessage(message, widget.currentTabIndex);
      
      if (response.isError) {
        _addMessage(response.message, false, suggestions: []);
      } else {
        _addMessage(response.message, false, suggestions: response.suggestions);
      }
    } catch (error) {
      _addMessage('Sorry, I encountered an error. Please try again.', false, suggestions: []);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _addMessage(String text, bool isUser, {List<QuickAction> suggestions = const []}) {
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: isUser,
        timestamp: DateTime.now(),
        suggestions: suggestions,
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

  @override
  void dispose() {
    _messageController.dispose();
    _quickActionsController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<QuickAction> suggestions;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.suggestions = const [],
  });
} 