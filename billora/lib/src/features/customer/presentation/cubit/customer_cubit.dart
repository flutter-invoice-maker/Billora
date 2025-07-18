import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:billora/src/features/customer/domain/entities/customer.dart';
import 'package:billora/src/features/customer/domain/usecases/get_customers_usecase.dart';
import 'package:billora/src/features/customer/domain/usecases/create_customer_usecase.dart';
import 'package:billora/src/features/customer/domain/usecases/update_customer_usecase.dart';
import 'package:billora/src/features/customer/domain/usecases/delete_customer_usecase.dart';
import 'customer_state.dart';

class CustomerCubit extends Cubit<CustomerState> {
  final GetCustomersUseCase getCustomersUseCase;
  final CreateCustomerUseCase createCustomerUseCase;
  final UpdateCustomerUseCase updateCustomerUseCase;
  final DeleteCustomerUseCase deleteCustomerUseCase;

  CustomerCubit({
    required this.getCustomersUseCase,
    required this.createCustomerUseCase,
    required this.updateCustomerUseCase,
    required this.deleteCustomerUseCase,
  }) : super(const CustomerState.initial());

  Future<void> fetchCustomers() async {
    emit(const CustomerState.loading());
    final result = await getCustomersUseCase();
    result.fold(
      (failure) => emit(CustomerState.error(failure.message)),
      (customers) => emit(CustomerState.loaded(customers)),
    );
  }

  Future<void> addCustomer(Customer customer) async {
    emit(const CustomerState.loading());
    final result = await createCustomerUseCase(customer);
    result.fold(
      (failure) => emit(CustomerState.error(failure.message)),
      (_) => fetchCustomers(),
    );
  }

  Future<void> updateCustomer(Customer customer) async {
    emit(const CustomerState.loading());
    final result = await updateCustomerUseCase(customer);
    result.fold(
      (failure) => emit(CustomerState.error(failure.message)),
      (_) => fetchCustomers(),
    );
  }

  Future<void> deleteCustomer(String id) async {
    emit(const CustomerState.loading());
    final result = await deleteCustomerUseCase(id);
    result.fold(
      (failure) => emit(CustomerState.error(failure.message)),
      (_) => fetchCustomers(),
    );
  }
}
