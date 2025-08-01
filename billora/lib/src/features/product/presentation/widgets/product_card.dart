import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:billora/src/features/product/domain/entities/product.dart';
import 'package:billora/src/features/product/presentation/cubit/product_cubit.dart';
import 'package:billora/src/core/utils/localization_helper.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;

  const ProductCard({
    super.key,
    required this.product,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(product.name),
        subtitle: Text(product.category),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: onEdit,
              tooltip: 'Edit',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext dialogContext) {
                    return AlertDialog(
                      title: Text(LocalizationHelper.getLocalizedString(context, 'confirmDeletion')),
                      content: Text('Are you sure you want to delete ${product.name}?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(LocalizationHelper.getLocalizedString(context, 'invoiceCancel')),
                        ),
                        TextButton(
                          onPressed: () {
                            context.read<ProductCubit>().deleteProduct(product.id);
                            Navigator.of(context).pop();
                          },
                          child: Text(LocalizationHelper.getLocalizedString(context, 'delete')),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
} 