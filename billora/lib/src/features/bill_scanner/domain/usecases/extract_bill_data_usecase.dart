// import 'package:dartz/dartz.dart';
// import '../../../../core/errors/failures.dart';
// import '../../../../core/usecases/usecase.dart';
// import '../entities/scanned_bill.dart';
// import '../repositories/bill_scanner_repository.dart';

// class ExtractBillDataUseCase implements UseCase<ScannedBill, String> {
//   final BillScannerRepository repository;

//   ExtractBillDataUseCase(this.repository);

//   @override
//   Future<Either<Failure, ScannedBill>> call(String imagePath) async {
//     return await repository.extractBillData(imagePath);
//   }
// } 