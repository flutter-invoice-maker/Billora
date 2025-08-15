// import 'package:dartz/dartz.dart';
// import '../../../../core/errors/failures.dart';
// import '../../../../core/usecases/usecase.dart';
// import '../entities/scanned_bill.dart';
// import '../repositories/bill_scanner_repository.dart';

// class ValidateBillDataUseCase implements UseCase<ScannedBill, ScannedBill> {
//   final BillScannerRepository repository;

//   ValidateBillDataUseCase(this.repository);

//   @override
//   Future<Either<Failure, ScannedBill>> call(ScannedBill bill) async {
//     return await repository.validateBillData(bill);
//   }
// } 