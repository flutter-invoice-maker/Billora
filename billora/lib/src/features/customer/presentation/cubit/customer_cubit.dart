import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:billora/src/features/customer/domain/entities/customer.dart';
import 'package:billora/src/features/customer/domain/usecases/get_customers_usecase.dart';
import 'package:billora/src/features/customer/domain/usecases/create_customer_usecase.dart';
import 'package:billora/src/features/customer/domain/usecases/update_customer_usecase.dart';
import 'package:billora/src/features/customer/domain/usecases/delete_customer_usecase.dart';
import 'package:billora/src/features/customer/domain/usecases/search_customers_usecase.dart';
import 'customer_state.dart';

class CustomerCubit extends Cubit<CustomerState> {
  final GetCustomersUseCase getCustomersUseCase;
  final CreateCustomerUseCase createCustomerUseCase;
  final UpdateCustomerUseCase updateCustomerUseCase;
  final DeleteCustomerUseCase deleteCustomerUseCase;
  final SearchCustomersUseCase searchCustomersUseCase;

  CustomerCubit({
    required this.getCustomersUseCase,
    required this.createCustomerUseCase,
    required this.updateCustomerUseCase,
    required this.deleteCustomerUseCase,
    required this.searchCustomersUseCase,
  }) : super(const CustomerState.initial());

  Future<void> fetchCustomers() async {
    try {
      if (!isClosed) {
        emit(const CustomerState.loading());
        final result = await getCustomersUseCase();
        if (!isClosed) {
          result.fold(
            (failure) => emit(CustomerState.error(failure.message)),
            (customers) => emit(CustomerState.loaded(customers)),
          );
        }
      }
    } catch (e) {
      if (!isClosed) {
        emit(CustomerState.error('Failed to fetch customers: $e'));
      }
    }
  }

  Future<void> addCustomer(Customer customer) async {
    try {
      if (!isClosed) {
        emit(const CustomerState.loading());
        final result = await createCustomerUseCase(customer);
        if (!isClosed) {
          result.fold(
            (failure) => emit(CustomerState.error(failure.message)),
            (_) => fetchCustomers(),
          );
        }
      }
    } catch (e) {
      if (!isClosed) {
        emit(CustomerState.error('Failed to add customer: $e'));
      }
    }
  }

  Future<void> updateCustomer(Customer customer) async {
    try {
      if (!isClosed) {
        emit(const CustomerState.loading());
        final result = await updateCustomerUseCase(customer);
        if (!isClosed) {
          result.fold(
            (failure) => emit(CustomerState.error(failure.message)),
            (_) => fetchCustomers(),
          );
        }
      }
    } catch (e) {
      if (!isClosed) {
        emit(CustomerState.error('Failed to update customer: $e'));
      }
    }
  }

  Future<void> deleteCustomer(String id) async {
    try {
      if (!isClosed) {
        emit(const CustomerState.loading());
        final result = await deleteCustomerUseCase(id);
        if (!isClosed) {
          result.fold(
            (failure) => emit(CustomerState.error(failure.message)),
            (_) => fetchCustomers(),
          );
        }
      }
    } catch (e) {
      if (!isClosed) {
        emit(CustomerState.error('Failed to delete customer: $e'));
      }
    }
  }

  Future<void> searchCustomers(String query) async {
    try {
      if (!isClosed) {
        emit(const CustomerState.loading());
        final result = await searchCustomersUseCase(query);
        if (!isClosed) {
          result.fold(
            (failure) => emit(CustomerState.error(failure.message)),
            (customers) => emit(CustomerState.loaded(customers)),
          );
        }
      }
    } catch (e) {
      if (!isClosed) {
        emit(CustomerState.error('Failed to search customers: $e'));
      }
    }
  }
}
