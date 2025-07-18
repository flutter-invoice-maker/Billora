import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:billora/src/features/customer/presentation/cubit/customer_cubit.dart';
import 'package:billora/src/features/customer/presentation/cubit/customer_state.dart';
import 'package:billora/src/features/customer/presentation/widgets/customer_card.dart';
import 'package:billora/src/core/widgets/loading_widget.dart';
import 'package:billora/src/core/widgets/error_widget.dart';
import 'package:billora/src/features/customer/presentation/pages/customer_form_page.dart';

class CustomerListPage extends StatefulWidget {
  const CustomerListPage({super.key});

  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  String _search = '';

  @override
  void initState() {
    super.initState();
    context.read<CustomerCubit>().fetchCustomers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Khách hàng'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Thêm khách hàng',
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<CustomerCubit>(),
                    child: const CustomerFormPage(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Tìm kiếm khách hàng',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => setState(() => _search = value),
            ),
          ),
          Expanded(
            child: BlocBuilder<CustomerCubit, CustomerState>(
              builder: (context, state) {
                return state.when(
                  initial: () => const SizedBox.shrink(),
                  loading: () => const LoadingWidget(),
                  loaded: (customers) {
                    final filtered = customers.where((c) =>
                      (c.name).toLowerCase().contains(_search.toLowerCase()) ||
                      ((c.email ?? '').toLowerCase().contains(_search.toLowerCase()))
                    ).toList();
                    if (filtered.isEmpty) {
                      return const Center(child: Text('Không có khách hàng nào.'));
                    }
                    return ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final customer = filtered[index];
                        return CustomerCard(
                          customer: customer,
                          onEdit: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => BlocProvider.value(
                                  value: context.read<CustomerCubit>(),
                                  child: CustomerFormPage(customer: customer),
                                ),
                              ),
                            );
                          },
                          onDelete: () {
                            context.read<CustomerCubit>().deleteCustomer(customer.id);
                          },
                        );
                      },
                    );
                  },
                  error: (message) => AppErrorWidget(message: message, onRetry: () => context.read<CustomerCubit>().fetchCustomers()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 
