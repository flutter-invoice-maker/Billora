import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/customer_cubit.dart';
import '../cubit/customer_state.dart';
import '../../domain/entities/customer.dart';
import 'customer_form_page.dart';
import 'package:billora/src/features/home/presentation/widgets/app_scaffold.dart';
import 'package:billora/src/core/widgets/delete_dialog.dart';

class CustomerListPage extends StatefulWidget {
  const CustomerListPage({super.key});

  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage>
    with TickerProviderStateMixin {
  String _searchTerm = '';
  late AnimationController _listAnimationController;
  late AnimationController _fadeController;
  bool _isSelectionMode = false;
  Set<String> _selectedCustomers = {};
  final ScrollController _scrollController = ScrollController();
  String _currentAlphabet = 'A';
  final Map<String, GlobalKey> _alphabetKeys = {};

  // Alphabet list for iOS-style scrolling
  final List<String> _alphabet = [
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
    'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '#'
  ];

  @override
  void initState() {
    super.initState();
    // Initialize keys for alphabet sections
    for (String letter in _alphabet) {
      _alphabetKeys[letter] = GlobalKey();
    }

    // Only fetch customers if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final customerState = context.read<CustomerCubit>().state;
        customerState.when(
          loaded: (_) => null, // Already loaded
          initial: () => context.read<CustomerCubit>().fetchCustomers(),
          loading: () => null, // Already loading
          error: (_) => context.read<CustomerCubit>().fetchCustomers(),
        );
      }
    });
    
    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _listAnimationController.forward();
    _fadeController.forward();

    // Listen to scroll changes to update current alphabet
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _listAnimationController.dispose();
    _fadeController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Find the current visible alphabet based on scroll position
    final customers = context.read<CustomerCubit>().state.maybeWhen(
      loaded: (customers) => customers.where((customer) {
        final searchLower = _searchTerm.toLowerCase();
        return searchLower.isEmpty ||
            customer.name.toLowerCase().contains(searchLower) ||
            (customer.email?.toLowerCase().contains(searchLower) ?? false) ||
            (customer.phone?.toLowerCase().contains(searchLower) ?? false);
      }).toList(),
      orElse: () => <Customer>[],
    );

    if (customers.isEmpty) return;

    final groupedCustomers = _groupCustomersByAlphabet(customers);
    final sortedKeys = groupedCustomers.keys.toList()
      ..sort((a, b) => a == '#' ? 1 : (b == '#' ? -1 : a.compareTo(b)));

    // Calculate which alphabet section is currently visible
    for (String letter in sortedKeys) {
      final key = _alphabetKeys[letter];
      if (key?.currentContext != null) {
        final RenderBox box = key!.currentContext!.findRenderObject() as RenderBox;
        final position = box.localToGlobal(Offset.zero);
        
        if (position.dy <= 200 && position.dy >= -100) {
          if (_currentAlphabet != letter) {
            setState(() {
              _currentAlphabet = letter;
            });
          }
          break;
        }
      }
    }
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedCustomers.clear();
      }
    });
  }

  void _selectAll(List<Customer> customers) {
    setState(() {
      if (_selectedCustomers.length == customers.length) {
        _selectedCustomers.clear();
      } else {
        _selectedCustomers = customers.map((c) => c.id).toSet();
      }
    });
  }

  void _deleteSelectedCustomers() {
    if (_selectedCustomers.isNotEmpty) {
      showDialog(
        context: context,
        builder: (dialogContext) => DeleteDialog(
          title: 'Delete Customers',
          message: 'Are you sure you want to delete ${_selectedCustomers.length} customer(s)? This action cannot be undone.',
          itemName: '${_selectedCustomers.length} customers',
          onDelete: () {
            for (String id in _selectedCustomers) {
              context.read<CustomerCubit>().deleteCustomer(id);
            }
            _selectedCustomers.clear();
            _toggleSelectionMode();
          },
        ),
      );
    }
  }

  // Group customers by first letter
  Map<String, List<Customer>> _groupCustomersByAlphabet(List<Customer> customers) {
    final Map<String, List<Customer>> grouped = {};
    
    for (final customer in customers) {
      final firstLetter = customer.name.isNotEmpty 
          ? customer.name[0].toUpperCase() 
          : '#';
      final key = RegExp(r'[A-Z]').hasMatch(firstLetter) ? firstLetter : '#';
      
      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(customer);
    }
    
    // Sort each group
    grouped.forEach((key, customers) {
      customers.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    });
    
    return grouped;
  }

  void _scrollToAlphabet(String letter) {
    final key = _alphabetKeys[letter];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentAlphabet = letter;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentTabIndex: 1, // Customers tab
      pageTitle: 'Customers',
      headerBottom: _CustomerHeaderSearch(
        onChanged: (value) {
          setState(() {
            _searchTerm = value;
          });
        },
      ),
      body: Container(
        color: const Color(0xFFFAFAFA),
        child: Column(
          children: [
            // Selection toolbar
            if (_isSelectionMode)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: _isSelectionMode ? 56 : 0,
                color: Colors.white,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Color(0xFFE5E5EA), width: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => _selectAll(context.read<CustomerCubit>().state.maybeWhen(
                          loaded: (customers) => customers.where((customer) {
                            final searchLower = _searchTerm.toLowerCase();
                            return searchLower.isEmpty ||
                                customer.name.toLowerCase().contains(searchLower) ||
                                (customer.email?.toLowerCase().contains(searchLower) ?? false) ||
                                (customer.phone?.toLowerCase().contains(searchLower) ?? false);
                          }).toList(),
                          orElse: () => <Customer>[],
                        )),
                        child: Text(
                          'Select All',
                          style: TextStyle(
                            color: const Color(0xFF007AFF),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${_selectedCustomers.length} selected',
                        style: const TextStyle(
                          color: Color(0xFF8E8E93),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(width: 16),
                      if (_selectedCustomers.isNotEmpty)
                        GestureDetector(
                          onTap: _deleteSelectedCustomers,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF3B30),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Text(
                              'Delete',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _toggleSelectionMode,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Color(0xFF8E8E93),
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 8),

            // Customer List with Alphabet Scroll
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  context.read<CustomerCubit>().fetchCustomers();
                },
                color: const Color(0xFF007AFF),
                backgroundColor: Colors.white,
                child: BlocBuilder<CustomerCubit, CustomerState>(
                  builder: (context, state) {
                    return state.when(
                      initial: () => const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.black, 
                          ),
                        ),
                      ),
                      loading: () => const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.black, // Đổi từ Color(0xFF007AFF) sang Colors.black
                          ),
                        ),
                      ),
                      loaded: (customers) {
                        final filteredCustomers = customers.where((customer) {
                          final searchLower = _searchTerm.toLowerCase();
                          return searchLower.isEmpty ||
                              customer.name.toLowerCase().contains(searchLower) ||
                              (customer.email?.toLowerCase().contains(searchLower) ?? false) ||
                              (customer.phone?.toLowerCase().contains(searchLower) ?? false);
                        }).toList();

                        if (filteredCustomers.isEmpty) {
                          return _buildEmptyState();
                        }

                        final groupedCustomers = _groupCustomersByAlphabet(filteredCustomers);
                        final sortedKeys = groupedCustomers.keys.toList()
                          ..sort((a, b) => a == '#' ? 1 : (b == '#' ? -1 : a.compareTo(b)));

                        return Stack(
                          children: [
                            // Main list - Hide scrollbar
                            ScrollConfiguration(
                              behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                              child: ListView.builder(
                                controller: _scrollController,
                                padding: const EdgeInsets.fromLTRB(20, 0, 40, 8),
                                itemCount: sortedKeys.length,
                                itemBuilder: (context, groupIndex) {
                                  final letter = sortedKeys[groupIndex];
                                  final customersInGroup = groupedCustomers[letter]!;
                                  
                                  return Column(
                                    key: _alphabetKeys[letter],
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Alphabet header
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                        child: Text(
                                          letter,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF8E8E93),
                                          ),
                                        ),
                                      ),
                                      // Customers in this group
                                      ...customersInGroup.asMap().entries.map((entry) {
                                        final customerIndex = entry.key;
                                        final customer = entry.value;
                                        return SlideTransition(
                                          position: Tween<Offset>(
                                            begin: const Offset(0, 0.3),
                                            end: Offset.zero,
                                          ).animate(CurvedAnimation(
                                            parent: _listAnimationController,
                                            curve: Interval(
                                              customerIndex * 0.05,
                                              1.0,
                                              curve: Curves.easeOutQuart,
                                            ),
                                          )),
                                          child: FadeTransition(
                                            opacity: Tween<double>(
                                              begin: 0.0,
                                              end: 1.0,
                                            ).animate(CurvedAnimation(
                                              parent: _listAnimationController,
                                              curve: Interval(
                                                customerIndex * 0.05,
                                                1.0,
                                                curve: Curves.easeOutQuart,
                                              ),
                                            )),
                                            child: _buildCustomerCard(customer, customerIndex),
                                          ),
                                        );
                                      }),
                                      const SizedBox(height: 8),
                                    ],
                                  );
                                },
                              ),
                            ),
                            
                            // Alphabet scroll bar (iOS style)
                            Positioned(
                              right: 4,
                              top: 50,
                              bottom: 50,
                              child: Container(
                                width: 24,
                                constraints: const BoxConstraints(
                                  minHeight: 200,
                                  maxHeight: double.infinity,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    final availableHeight = constraints.maxHeight;
                                    final itemHeight = availableHeight / _alphabet.length;
                                    
                                    return Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: _alphabet.map((letter) {
                                        final isActive = _currentAlphabet == letter;
                                        final hasCustomers = groupedCustomers.containsKey(letter);
                                        
                                        return GestureDetector(
                                          onTap: hasCustomers ? () => _scrollToAlphabet(letter) : null,
                                          child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 200),
                                            width: isActive ? 22 : 20,
                                            height: itemHeight.clamp(16, 24),
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: isActive 
                                                  ? const Color(0xFF007AFF).withValues(alpha: 0.1) 
                                                  : Colors.transparent,
                                              borderRadius: BorderRadius.circular(11),
                                            ),
                                            child: AnimatedDefaultTextStyle(
                                              duration: const Duration(milliseconds: 200),
                                              style: TextStyle(
                                                fontSize: isActive ? 14 : 11,
                                                fontWeight: isActive ? FontWeight.w900 : FontWeight.w600,
                                                color: hasCustomers 
                                                    ? (isActive ? const Color(0xFF007AFF) : const Color(0xFF8E8E93))
                                                    : const Color(0xFFE5E5EA),
                                              ),
                                              child: Text(
                                                letter,
                                                textAlign: TextAlign.center,
                                                overflow: TextOverflow.visible,
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                      error: (message) => _buildErrorState(message),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerCard(Customer customer, int index) {
    final isSelected = _selectedCustomers.contains(customer.id);
    
    return GestureDetector(
      onTap: () {
        if (_isSelectionMode) {
          setState(() {
            if (isSelected) {
              _selectedCustomers.remove(customer.id);
            } else {
              _selectedCustomers.add(customer.id);
            }
          });
        } else {
          _openForm(customer);
        }
      },
      onLongPress: () {
        if (!_isSelectionMode) {
          _toggleSelectionMode();
          setState(() {
            _selectedCustomers.add(customer.id);
          });
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE3F2FD) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isSelected 
              ? Border.all(color: const Color(0xFF007AFF), width: 1)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Selection checkbox (only visible in selection mode)
            if (_isSelectionMode) ...[
              AnimatedScale(
                duration: const Duration(milliseconds: 200),
                scale: _isSelectionMode ? 1.0 : 0.0,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF007AFF) : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? const Color(0xFF007AFF) : const Color(0xFFE5E5EA),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 12),
            ],
            
            // Avatar
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _getAvatarColor(customer.name),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Center(
                child: Text(
                  _getInitials(customer.name),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Customer Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF000000),
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (customer.email != null) ...[
                    Text(
                      customer.email!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF8E8E93),
                        fontWeight: FontWeight.w400,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1),
                  ],
                  if (customer.phone != null)
                    Text(
                      customer.phone!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF8E8E93),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                ],
              ),
            ),
            
            // Status and Actions
            if (!_isSelectionMode)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(index),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _getStatusText(index),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _getCustomerType(index),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF8E8E93),
                    ),
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () => _showOptionsMenu(customer),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.more_horiz,
                        color: Color(0xFF8E8E93),
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.people_outline,
              size: 40,
              color: Color(0xFF8E8E93),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No customers found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF000000),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try adjusting your search\nor add new customers',
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF8E8E93),
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.error_outline,
              size: 40,
              color: Color(0xFF8E8E93),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Error loading customers',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF000000),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF8E8E93),
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () {
              context.read<CustomerCubit>().fetchCustomers();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF007AFF),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(Customer customer) {
    final customerCubit = context.read<CustomerCubit>();
    showDialog(
      context: context,
      builder: (dialogContext) => DeleteDialog(
        title: 'Delete Customer',
        message: 'Are you sure you want to delete this customer? This action cannot be undone.',
        itemName: customer.name,
        onDelete: () {
          customerCubit.deleteCustomer(customer.id);
        },
      ),
    );
  }

  void _showOptionsMenu(Customer customer) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 5,
              margin: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFE5E5EA),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF007AFF).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.edit_outlined,
                  color: Color(0xFF007AFF),
                  size: 20,
                ),
              ),
              title: const Text(
                'Edit Customer',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF000000),
                ),
              ),
              subtitle: const Text(
                'Modify customer details',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF8E8E93),
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _openForm(customer);
              },
            ),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF3B30).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: Color(0xFFFF3B30),
                  size: 20,
                ),
              ),
              title: const Text(
                'Delete Customer',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFF3B30),
                ),
              ),
              subtitle: const Text(
                'Remove from database',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF8E8E93),
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _showDeleteDialog(customer);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _openForm([Customer? customer]) {
    final customerCubit = context.read<CustomerCubit>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider<CustomerCubit>.value(
          value: customerCubit,
          child: CustomerFormPage(customer: customer),
        ),
      ),
    );
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
      const Color(0xFF007AFF),
      const Color(0xFF34C759),
      const Color(0xFFFF9500),
      const Color(0xFFFF3B30),
      const Color(0xFF5856D6),
      const Color(0xFFAF52DE),
    ];
    return colors[name.hashCode % colors.length];
  }

  Color _getStatusColor(int index) {
    final colors = [
      const Color(0xFF34C759), // Green - Active
      const Color(0xFF34C759), // Green - Active  
      const Color(0xFF8E8E93), // Gray - Inactive
      const Color(0xFF34C759), // Green - Active
      const Color(0xFF34C759), // Green - Active
    ];
    return colors[index % colors.length];
  }

  String _getStatusText(int index) {
    final statuses = ['Active', 'Active', 'Inactive', 'Active', 'Active'];
    return statuses[index % statuses.length];
  }

  String _getCustomerType(int index) {
    final types = ['VIP', 'Key Account', 'Small Business', 'Prospect', 'Partnership'];
    return types[index % types.length];
  }
}

class _CustomerHeaderSearch extends StatelessWidget implements PreferredSizeWidget {
  final ValueChanged<String> onChanged;

  const _CustomerHeaderSearch({required this.onChanged});

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: TextField(
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: 'Search customers...',
            hintStyle: TextStyle(
              color: Colors.grey[600],
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: const Icon(Icons.search, color: Colors.black54, size: 20),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
    );
  }
}