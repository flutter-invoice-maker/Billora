import 'package:flutter/material.dart';
import 'package:billora/src/features/customer/domain/entities/customer.dart';
import 'package:billora/src/core/utils/localization_helper.dart';

class CustomerCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text(customer.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (customer.email != null) Text('${LocalizationHelper.getLocalizedString(context, 'email')}: ${customer.email}'),
            if (customer.phone != null) Text('${LocalizationHelper.getLocalizedString(context, 'phone')}: ${customer.phone}'),
            if (customer.address != null) Text('${LocalizationHelper.getLocalizedString(context, 'address')}: ${customer.address}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onEdit != null)
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: onEdit,
              ),
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: onDelete,
              ),
          ],
        ),
      ),
    );
  }
} 
