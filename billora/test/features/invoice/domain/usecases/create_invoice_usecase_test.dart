import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billora/src/features/invoice/domain/usecases/create_invoice_usecase.dart';
import 'package:billora/src/features/invoice/domain/repositories/invoice_repository.dart';
import 'package:billora/src/features/invoice/domain/entities/invoice.dart';
import 'package:billora/src/features/invoice/domain/entities/invoice_item.dart';
import 'package:dartz/dartz.dart';
import 'package:billora/src/core/errors/failures.dart';

class MockInvoiceRepository extends Mock implements InvoiceRepository {}

class FakeInvoice extends Fake implements Invoice {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeInvoice());
  });

  late CreateInvoiceUseCase usecase;
  late MockInvoiceRepository mockRepo;

  setUp(() {
    mockRepo = MockInvoiceRepository();
    usecase = CreateInvoiceUseCase(mockRepo);
  });

  test('should call repository and return Right when success', () async {
    final invoice = Invoice(
      id: '',
      customerId: 'c1',
      customerName: 'Test',
      items: [InvoiceItem(id: 'i1', name: 'Item', description: '', quantity: 1, unitPrice: 100, tax: 10, total: 110, productId: '')],
      subtotal: 100,
      tax: 10,
      total: 110,
      status: InvoiceStatus.draft,
      createdAt: DateTime.now(),
      dueDate: null,
      paidAt: null,
      note: null,
      templateId: null,
    );
    when(() => mockRepo.createInvoice(any())).thenAnswer((_) async => const Right(null));
    final result = await usecase(invoice);
    expect(result, equals(const Right(null)));
    verify(() => mockRepo.createInvoice(any())).called(1);
  });

  test('should return Left when repository fails', () async {
    final invoice = Invoice(
      id: '',
      customerId: 'c1',
      customerName: 'Test',
      items: [],
      subtotal: 0,
      tax: 0,
      total: 0,
      status: InvoiceStatus.draft,
      createdAt: DateTime.now(),
      dueDate: null,
      paidAt: null,
      note: null,
      templateId: null,
    );
    when(() => mockRepo.createInvoice(any())).thenAnswer((_) async => Left(AuthFailure('error')));
    final result = await usecase(invoice);
    expect(result, isA<Left>());
    verify(() => mockRepo.createInvoice(any())).called(1);
  });
} 