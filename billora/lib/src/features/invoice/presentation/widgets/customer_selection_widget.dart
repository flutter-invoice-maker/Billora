import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:billora/src/features/customer/presentation/cubit/customer_cubit.dart';
import 'package:billora/src/features/customer/presentation/cubit/customer_state.dart';
import 'package:billora/src/features/customer/domain/entities/customer.dart';
import 'package:billora/src/core/services/avatar_service.dart';

class CustomerSelectionWidget extends StatefulWidget {
  final String? selectedCustomerId;
  final String? selectedCustomerName;
  final Function(Customer customer) onCustomerSelected;
  final Color primaryColor;

  const CustomerSelectionWidget({
    super.key,
    this.selectedCustomerId,
    this.selectedCustomerName,
    required this.onCustomerSelected,
    required this.primaryColor,
  });

  @override
  State<CustomerSelectionWidget> createState() => _CustomerSelectionWidgetState();
}

class _CustomerSelectionWidgetState extends State<CustomerSelectionWidget> {
  String _searchTerm = '';

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _showCustomerSelectionDialog,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: widget.primaryColor.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Customer',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: widget.primaryColor,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.person_outline, color: widget.primaryColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.selectedCustomerName ?? 'Select customer...',
                      style: TextStyle(
                        color: widget.selectedCustomerName != null 
                            ? Colors.black87 
                            : Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_drop_down, color: widget.primaryColor),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCustomerSelectionDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<CustomerCubit>(),
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Icon(
                        Icons.person_search,
                        color: widget.primaryColor,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Select Customer',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: widget.primaryColor,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(dialogContext),
                        child: Icon(
                          Icons.close,
                          color: Colors.grey.shade600,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Search bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search customers...',
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      prefixIcon: Icon(
                        Icons.search,
                        color: widget.primaryColor,
                        size: 20,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: widget.primaryColor, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchTerm = value;
                      });
                    },
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Customer list
                Container(
                  constraints: const BoxConstraints(maxHeight: 400),
                  child: BlocBuilder<CustomerCubit, CustomerState>(
                    builder: (context, state) {
                      return state.maybeWhen(
                        loaded: (customers) {
                          final filteredCustomers = customers.where((customer) {
                            if (_searchTerm.isEmpty) return true;
                            return customer.name.toLowerCase().contains(_searchTerm.toLowerCase()) ||
                                   (customer.email?.toLowerCase().contains(_searchTerm.toLowerCase()) ?? false);
                          }).toList();

                          if (filteredCustomers.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.person_off_outlined,
                                    size: 48,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _searchTerm.isEmpty 
                                        ? 'No customers found'
                                        : 'No customers match your search',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            itemCount: filteredCustomers.length,
                            itemBuilder: (context, index) {
                              final customer = filteredCustomers[index];
                              final isSelected = customer.id == widget.selectedCustomerId;
                              
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                elevation: isSelected ? 4 : 1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: isSelected ? widget.primaryColor : Colors.grey.shade200,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  leading: ClipOval(
                                    child: customer.avatarUrl != null
                                        ? Image.network(
                                            customer.avatarUrl!,
                                            width: 40,
                                            height: 40,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stack) {
                                              return AvatarService.buildAvatar(
                                                name: customer.name,
                                                size: 40.0,
                                                backgroundColor: widget.primaryColor.withValues(alpha: 0.2),
                                                textColor: widget.primaryColor,
                                              );
                                            },
                                          )
                                        : AvatarService.buildAvatar(
                                            name: customer.name,
                                            size: 40.0,
                                            backgroundColor: widget.primaryColor.withValues(alpha: 0.2),
                                            textColor: widget.primaryColor,
                                          ),
                                  ),
                                  title: Text(
                                    customer.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: isSelected ? widget.primaryColor : Colors.black87,
                                    ),
                                  ),
                                  subtitle: Text(
                                    customer.email ?? 'No email',
                                    style: TextStyle(
                                      color: isSelected 
                                          ? widget.primaryColor.withValues(alpha: 0.7)
                                          : Colors.grey.shade600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  trailing: isSelected 
                                      ? Icon(Icons.check_circle, color: widget.primaryColor, size: 24)
                                      : null,
                                  onTap: () {
                                    widget.onCustomerSelected(customer);
                                    Navigator.pop(context);
                                  },
                                ),
                              );
                            },
                          );
                        },
                        loading: () => const Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (message) => Padding(
                          padding: const EdgeInsets.all(32),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
                                const SizedBox(height: 16),
                                Text(
                                  'Error loading customers',
                                  style: TextStyle(
                                    color: Colors.red.shade600,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        orElse: () => const Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 