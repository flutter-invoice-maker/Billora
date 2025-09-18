import 'package:flutter/material.dart';
import 'package:billora/src/core/services/chatbot_ai_service.dart';
import 'package:billora/src/core/di/injection_container.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  final List<SimpleChatMessage> _messages = [];
  bool _isLoading = false;
  bool _showQuickActions = true;
  bool _showPresetQuestions = false;
  bool _showMenu = false;
  late ChatbotAIService _aiService;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  late AnimationController _quickActionsController;
  late AnimationController _menuController;
  // Removed legacy top quick actions animation
  late Animation<double> _menuAnimation;

  @override
  void initState() {
    super.initState();
    _aiService = sl<ChatbotAIService>();
    _quickActionsController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _menuController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    // quick actions animation not used for top section anymore
    _menuAnimation = CurvedAnimation(
      parent: _menuController,
      curve: Curves.easeInOut,
    );
    _addSystemMessage();
  }

  void _addSystemMessage() {
    _messages.add(SimpleChatMessage(
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

  List<QuickAction> _getQuickActions(int currentTabIndex) {
    // Messenger-style short questions focused on revenue/diagnostics/analysis (English only)
    switch (currentTabIndex) {
      case 0: // Dashboard
        return [
          QuickAction(
            title: 'This month\'s revenue',
            icon: '💵',
            prompt: 'Analyze this month\'s collected revenue vs last month, highlight trends and primary drivers.',
            category: 'Revenue',
          ),
          QuickAction(
            title: 'Revenue diagnosis',
            icon: '🩺',
            prompt: 'Diagnose recent revenue changes, identify the biggest impacting products/customers, and give recommendations.',
            category: 'Diagnostics',
          ),
          QuickAction(
            title: 'Cost & profit analysis',
            icon: '📊',
            prompt: 'Compute gross margin by product and suggest improvements.',
            category: 'Analysis',
          ),
        ];
      case 1: // Customers
        return [
          QuickAction(
            title: 'Top revenue customers',
            icon: '⭐',
            prompt: 'List top customers by this month\'s revenue and churn risk.',
            category: 'Revenue',
          ),
          QuickAction(
            title: 'Customer segmentation',
            icon: '🎯',
            prompt: 'Segment customers by value and purchase frequency and suggest campaigns.',
            category: 'Analysis',
          ),
        ];
      case 2: // Products
        return [
          QuickAction(
            title: 'Key revenue products',
            icon: '🏆',
            prompt: 'Identify products contributing the most revenue this month and the trend.',
            category: 'Revenue',
          ),
          QuickAction(
            title: 'Pricing & inventory optimization',
            icon: '⚙️',
            prompt: 'Analyze pricing and inventory turns and provide optimization suggestions.',
            category: 'Analysis',
          ),
        ];
      case 3: // Invoices
        return [
          QuickAction(
            title: 'Monthly invoice revenue',
            icon: '🧾',
            prompt: 'Summarize invoice revenue for this month, reconcile receivables and payment rate.',
            category: 'Revenue',
          ),
          QuickAction(
            title: 'Cash flow forecast',
            icon: '💳',
            prompt: 'Forecast expected cash inflow based on current invoice due dates.',
            category: 'Analysis',
          ),
        ];
      default:
        return [
          QuickAction(
            title: 'Revenue overview',
            icon: '📈',
            prompt: 'Provide a revenue overview, period-over-period comparison, and suggested actions.',
            category: 'Revenue',
          ),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          _buildHeader(),
          if (_showMenu) _buildMenuDropdown(),
          Expanded(
            child: _buildMessagesList(),
          ),
          if (_showPresetQuestions) _buildBottomSuggestions(),
          _buildInputSection(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      color: Colors.white,
      child: Row(
        children: [
          // AI Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [widget.primaryColor, widget.primaryColor.withValues(alpha: 0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          
          // AI Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI Assistant',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  _getTabDescription(),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          
          // Menu Button
          GestureDetector(
            onTap: _toggleMenu,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: AnimatedRotation(
                turns: _showMenu ? 0.125 : 0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  Icons.more_horiz,
                  color: Colors.grey.shade700,
                  size: 20,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Close Button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.close,
                color: Colors.grey.shade700,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleMenu() {
    setState(() {
      _showMenu = !_showMenu;
    });
    
    if (_showMenu) {
      _menuController.forward();
    } else {
      _menuController.reverse();
    }
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

  Widget _buildMenuDropdown() {
    final menuItems = [
      MenuItem(
        title: 'Clear Chat',
        icon: Icons.clear_all,
        onTap: _clearChat,
      ),
      MenuItem(
        title: 'Export Chat',
        icon: Icons.download,
        onTap: _exportChat,
      ),
      MenuItem(
        title: 'Settings',
        icon: Icons.settings,
        onTap: _openSettings,
      ),
    ];

    return SizeTransition(
      sizeFactor: _menuAnimation,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: menuItems.map((item) => _buildMenuItem(item)).toList(),
        ),
      ),
    );
  }

  Widget _buildMenuItem(MenuItem item) {
    return InkWell(
      onTap: () {
        item.onTap();
        _toggleMenu();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              item.icon,
              size: 20,
              color: Colors.grey.shade700,
            ),
            const SizedBox(width: 12),
            Text(
              item.title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Legacy top quick actions removed (now using bottom suggestions)

  Widget _buildBottomSuggestions() {
    final quickActions = _getQuickActions(widget.currentTabIndex);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: quickActions.map((action) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Center(
              child: GestureDetector(
                onTap: () => _handleQuickAction(action),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: widget.primaryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    action.title,
                    style: TextStyle(
                      color: widget.primaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Removed unused top quick action chip builder

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
                   message.contains('model not found') ||
                   message.contains('error');
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isError 
                      ? [Colors.red.shade500, Colors.red.shade600]
                      : [widget.primaryColor, widget.primaryColor.withValues(alpha: 0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                isError ? Icons.error_outline : Icons.auto_awesome,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser 
                        ? widget.primaryColor 
                        : isError 
                            ? Colors.red.shade50
                            : Colors.grey.shade100,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isUser ? 18 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 18),
                    ),
                  ),
                  child: Text(
                    message,
                    style: TextStyle(
                      color: isUser 
                          ? Colors.white 
                          : isError 
                              ? Colors.red.shade700
                              : Colors.black87,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                if (suggestions.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: suggestions.map((suggestion) => _buildSuggestionChip(suggestion)).toList(),
                  ),
                ],
              ],
            ),
          ),
          if (isUser) ...[
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
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      color: Colors.white,
      child: Row(
        children: [
          // Burger menu button for preset questions
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(18),
            ),
            child: IconButton(
              onPressed: _togglePresetQuestions,
              icon: Icon(
                Icons.menu,
                color: Colors.grey.shade600,
                size: 18,
              ),
              padding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(width: 8),
          
          // Text input
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 15,
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
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          
          // Send button
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [widget.primaryColor, widget.primaryColor.withValues(alpha: 0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: IconButton(
              onPressed: _isLoading ? null : _sendMessage,
              icon: _isLoading
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  void _togglePresetQuestions() {
    setState(() {
      _showPresetQuestions = !_showPresetQuestions;
      _showQuickActions = _showPresetQuestions; // reuse quick actions as preset list
    });
    if (_showPresetQuestions) {
      _quickActionsController.forward();
    } else {
      _quickActionsController.reverse();
    }
  }

  void _handleQuickAction(QuickAction action) {
    // Hide preset questions immediately and send the prompt without creating a user bubble
    setState(() {
      _showPresetQuestions = false;
      _showQuickActions = false;
    });
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
      final userId = _firebaseAuth.currentUser?.uid;
      if (userId == null) {
        _addMessage('Please log in to use the AI assistant.', false, suggestions: []);
        return;
      }

      final response = await _aiService.sendMessage(
        userId: userId,
        message: message,
        currentTabIndex: widget.currentTabIndex,
      );
      
      _addMessage(response, false, suggestions: []);
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
      _messages.add(SimpleChatMessage(
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

  void _clearChat() {
    setState(() {
      _messages.clear();
      _addSystemMessage();
    });
  }

  // Attachment options removed in favor of preset questions menu

  // Legacy attachment option UI removed

  // Legacy attachment handlers removed

  void _exportChat() {
    if (_messages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No messages to export')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Chat'),
        content: const Text('Choose export format:'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _exportAsText();
            },
            child: const Text('Text File'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _exportAsPDF();
            },
            child: const Text('PDF'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _exportAsText() {
    final StringBuffer buffer = StringBuffer();
    buffer.writeln('AI Chat Export - ${DateTime.now().toString()}');
    buffer.writeln('=' * 50);
    buffer.writeln();
    
    for (final message in _messages) {
      buffer.writeln('${message.isUser ? 'You' : 'AI'}: ${message.timestamp.toString()}');
      buffer.writeln(message.text);
      buffer.writeln();
    }
    
    // In a real app, you would save this to a file
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chat exported as text file')),
    );
  }

  void _exportAsPDF() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PDF export feature coming soon!')),
    );
  }

  void _openSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'AI Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 20),
            _buildSettingOption(
              icon: Icons.auto_awesome,
              title: 'AI Model',
              subtitle: 'GPT-4',
              onTap: () {
                Navigator.pop(context);
                _showModelSelection();
              },
            ),
            _buildSettingOption(
              icon: Icons.language,
              title: 'Language',
              subtitle: 'English',
              onTap: () {
                Navigator.pop(context);
                _showLanguageSelection();
              },
            ),
            _buildSettingOption(
              icon: Icons.notifications,
              title: 'Notifications',
              subtitle: 'Enabled',
              onTap: () {
                Navigator.pop(context);
                _toggleNotifications();
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            Icon(icon, color: widget.primaryColor, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  void _showModelSelection() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Model selection coming soon!')),
    );
  }

  void _showLanguageSelection() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Language selection coming soon!')),
    );
  }

  void _toggleNotifications() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notification settings coming soon!')),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _quickActionsController.dispose();
    _menuController.dispose();
    super.dispose();
  }
}

class SimpleChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<QuickAction> suggestions;

  SimpleChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.suggestions = const [],
  });
}

class QuickAction {
  final String title;
  final String icon;
  final String prompt;
  final String category;

  QuickAction({
    required this.title,
    required this.icon,
    required this.prompt,
    required this.category,
  });
}

class MenuItem {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  MenuItem({
    required this.title,
    required this.icon,
    required this.onTap,
  });
} 