import 'package:flutter/material.dart';
import 'package:billora/src/features/customer/domain/entities/customer.dart';

class CustomerCard extends StatefulWidget {
  final Customer customer;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CustomerCard({
    super.key,
    required this.customer,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<CustomerCard> createState() => _CustomerCardState();
}

class _CustomerCardState extends State<CustomerCard>
    with SingleTickerProviderStateMixin {
  bool _showDeleteOptions = false;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-0.3, 0),
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF667eea).withAlpha((0.1 * 255).round()), // Fixed withOpacity
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.edit_outlined,
                  color: Color(0xFF667eea),
                ),
              ),
              title: const Text('Edit Customer'),
              subtitle: const Text('Modify customer information'),
              onTap: () {
                Navigator.pop(context);
                widget.onEdit?.call();
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withAlpha((0.1 * 255).round()), // Fixed withOpacity
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                ),
              ),
              title: const Text('Delete Customer'),
              subtitle: const Text('Remove customer permanently'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation();
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation() {
    setState(() {
      _showDeleteOptions = true;
    });
    _slideController.forward();
  }

  void _cancelDelete() {
    _slideController.reverse().then((_) {
      setState(() {
        _showDeleteOptions = false;
      });
    });
  }

  void _confirmDelete() {
    widget.onDelete?.call();
    _slideController.reverse().then((_) {
      setState(() {
        _showDeleteOptions = false;
      });
    });
  }

  String _getInitials(String name) {
    List<String> names = name.split(' ');
    String initials = '';
    for (int i = 0; i < names.length && i < 2; i++) {
      if (names[i].isNotEmpty) {
        initials += names[i][0].toUpperCase();
      }
    }
    return initials.isEmpty ? 'C' : initials;
  }

  Color _getAvatarColor(String name) {
    final colors = [
      const Color(0xFF667eea),
      const Color(0xFF764ba2),
      const Color(0xFFF093FB), // Fixed hex color
      const Color(0xFFF5576C), // Fixed hex color
      const Color(0xFF4facfe),
      const Color(0xFF00f2fe),
    ];
    return colors[name.hashCode % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Stack(
        children: [
          // Delete options background
          if (_showDeleteOptions)
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.red.withAlpha((0.1 * 255).round()), // Fixed withOpacity
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.withAlpha((0.3 * 255).round())), // Fixed withOpacity
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Row(
                      children: [
                        TextButton.icon(
                          onPressed: _cancelDelete,
                          icon: const Icon(Icons.close, color: Colors.grey),
                          label: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        TextButton.icon(
                          onPressed: _confirmDelete,
                          icon: const Icon(Icons.delete, color: Colors.white),
                          label: const Text('Delete', style: TextStyle(color: Colors.white)),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          
          // Main card
          SlideTransition(
            position: _slideAnimation,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha((0.08 * 255).round()), // Fixed withOpacity
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Customer Avatar
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getAvatarColor(widget.customer.name),
                            _getAvatarColor(widget.customer.name).withAlpha((0.7 * 255).round()), // Fixed withOpacity
                          ],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: _getAvatarColor(widget.customer.name).withAlpha((0.3 * 255).round()), // Fixed withOpacity
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _getInitials(widget.customer.name),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Customer Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.customer.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (widget.customer.email != null) ...[
                            Row(
                              children: [
                                Icon(
                                  Icons.email_outlined,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    widget.customer.email!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                          ],
                          if (widget.customer.phone != null) ...[
                            Row(
                              children: [
                                Icon(
                                  Icons.phone_outlined,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  widget.customer.phone!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                          ],
                          if (widget.customer.address != null) ...[
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    widget.customer.address!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    // Options Menu Button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        onPressed: _showOptionsMenu,
                        icon: const Icon(
                          Icons.more_vert,
                          color: Color(0xFF667eea),
                        ),
                        tooltip: 'Options',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
