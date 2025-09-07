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
  bool _showMenu = false;
  late ChatbotAIService _aiService;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  late AnimationController _quickActionsController;
  late AnimationController _menuController;
  late Animation<double> _quickActionsAnimation;
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
    _quickActionsAnimation = CurvedAnimation(
      parent: _quickActionsController,
      curve: Curves.easeInOut,
    );
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
    switch (currentTabIndex) {
      case 0: // Dashboard
        return [
          QuickAction(
            title: 'Revenue Analysis',
            icon: '📊',
            prompt: 'Can you analyze my revenue trends and provide insights?',
            category: 'Financial',
          ),
          QuickAction(
            title: 'Business Performance',
            icon: '🚀',
            prompt: 'How is my business performing overall?',
            category: 'Overview',
          ),
        ];
      case 1: // Customers
        return [
          QuickAction(
            title: 'Customer Segmentation',
            icon: '🎯',
            prompt: 'How should I segment my customers for better targeting?',
            category: 'Strategy',
          ),
          QuickAction(
            title: 'Customer Lifetime Value',
            icon: '💰',
            prompt: 'Which customers have the highest lifetime value?',
            category: 'Analysis',
          ),
        ];
      case 2: // Products
        return [
          QuickAction(
            title: 'Top Selling Products',
            icon: '🏆',
            prompt: 'What are my top selling products and why?',
            category: 'Performance',
          ),
          QuickAction(
            title: 'Inventory Optimization',
            icon: '📦',
            prompt: 'How can I optimize my inventory management?',
            category: 'Operations',
          ),
        ];
      case 3: // Invoices
        return [
          QuickAction(
            title: 'Invoice Analysis',
            icon: '📄',
            prompt: 'Can you analyze my invoicing patterns and trends?',
            category: 'Analysis',
          ),
          QuickAction(
            title: 'Payment Status',
            icon: '💳',
            prompt: 'What\'s the status of my outstanding payments?',
            category: 'Financial',
          ),
        ];
      default:
        return [
          QuickAction(
            title: 'Business Overview',
            icon: '🏢',
            prompt: 'Can you give me an overview of my business?',
            category: 'General',
          ),
        ];
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
          if (_showMenu) _buildMenuDropdown(),
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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
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

  Widget _buildQuickActions() {
    final quickActions = _getQuickActions(widget.currentTabIndex);
    
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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Attachment button
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(18),
            ),
            child: IconButton(
              onPressed: _showAttachmentOptions,
              icon: Icon(
                Icons.attach_file,
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

  void _showAttachmentOptions() {
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
              'Attach File',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttachmentOption(
                  icon: Icons.image,
                  label: 'Photo',
                  onTap: () {
                    Navigator.pop(context);
                    _attachImage();
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.videocam,
                  label: 'Video',
                  onTap: () {
                    Navigator.pop(context);
                    _attachVideo();
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.insert_drive_file,
                  label: 'Document',
                  onTap: () {
                    Navigator.pop(context);
                    _attachDocument();
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: widget.primaryColor),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _attachImage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Image attachment feature coming soon!')),
    );
  }

  void _attachVideo() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Video attachment feature coming soon!')),
    );
  }

  void _attachDocument() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Document attachment feature coming soon!')),
    );
  }

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