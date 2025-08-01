import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:billora/src/features/bill_scanner/domain/usecases/scan_bill_usecase.dart';
import 'package:billora/src/features/bill_scanner/domain/entities/scan_result.dart';
import 'package:billora/src/features/bill_scanner/domain/repositories/bill_scanner_repository.dart';
import 'package:billora/src/core/errors/failures.dart';

import 'scan_bill_usecase_test.mocks.dart';

@GenerateMocks([BillScannerRepository])
void main() {
  late ScanBillUseCase useCase;
  late MockBillScannerRepository mockRepository;

  setUp(() {
    mockRepository = MockBillScannerRepository();
    useCase = ScanBillUseCase(mockRepository);
  });

  const testImagePath = 'test_image.jpg';
  final testScanResult = ScanResult(
    rawText: 'Test bill text',
    confidence: ScanConfidence.high,
    processedAt: DateTime.now(),
  );

  test('should return ScanResult when repository call is successful', () async {
    // arrange
    when(mockRepository.scanBill(testImagePath))
        .thenAnswer((_) async => Right(testScanResult));

    // act
    final result = await useCase(testImagePath);

    // assert
    expect(result, Right(testScanResult));
    verify(mockRepository.scanBill(testImagePath));
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return Failure when repository call is unsuccessful', () async {
    // arrange
    when(mockRepository.scanBill(testImagePath))
        .thenAnswer((_) async => const Left(ServerFailure('Error')));

    // act
    final result = await useCase(testImagePath);

    // assert
    expect(result, const Left(ServerFailure('Error')));
    verify(mockRepository.scanBill(testImagePath));
    verifyNoMoreInteractions(mockRepository);
  });
} 