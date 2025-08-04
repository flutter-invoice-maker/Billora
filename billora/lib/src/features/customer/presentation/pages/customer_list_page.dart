import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/customer_cubit.dart';
import '../cubit/customer_state.dart';
import 'package:billora/src/features/customer/presentation/widgets/customer_card.dart';
import 'package:billora/src/core/widgets/loading_widget.dart';
import 'package:billora/src/core/widgets/error_widget.dart';
import 'customer_form_page.dart';
import 'package:billora/src/core/utils/app_strings.dart';

class CustomerListPage extends StatefulWidget {
  const CustomerListPage({super.key});

  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    context.read<CustomerCubit>().fetchCustomers();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh data when returning to this page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<CustomerCubit>().fetchCustomers();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.customerListTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _openForm(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                                    hintText: AppStrings.customerSearchHint,
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchTerm = value;
                });
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<CustomerCubit, CustomerState>(
              builder: (context, state) {
                return state.when(
                  initial: () => const LoadingWidget(),
                  loading: () => const LoadingWidget(),
                  loaded: (customers) {
                    var filteredCustomers = customers;
                    if (_searchTerm.isNotEmpty) {
                      final searchWords = _searchTerm
                          .toLowerCase()
                          .split(' ')
                          .where((s) => s.isNotEmpty)
                          .toList();

                      filteredCustomers = customers.where((customer) {
                        final customerText =
                            '${customer.name.toLowerCase()} ${customer.email?.toLowerCase() ?? ''} ${customer.phone?.toLowerCase() ?? ''}';
                        
                        return searchWords.every((word) => customerText.contains(word));
                      }).toList();
                    }

                    return ListView.builder(
                      itemCount: filteredCustomers.length,
                      itemBuilder: (context, index) {
                        final customer = filteredCustomers[index];
                        return CustomerCard(
                          customer: customer,
                          onEdit: () {
                            _openForm(customer);
                          },
                          onDelete: () {
                            context.read<CustomerCubit>().deleteCustomer(customer.id);
                          },
                        );
                      },
                    );
                  },
                  error: (msg) => AppErrorWidget(
                      message: msg,
                      onRetry: () =>
                          context.read<CustomerCubit>().fetchCustomers()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _openForm([customer]) {
    final cubit = BlocProvider.of<CustomerCubit>(context, listen: false);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider<CustomerCubit>.value(
          value: cubit,
          child: CustomerFormPage(customer: customer),
        ),
      ),
    );
    if (!mounted) return;
    cubit.fetchCustomers();
  }
} 
