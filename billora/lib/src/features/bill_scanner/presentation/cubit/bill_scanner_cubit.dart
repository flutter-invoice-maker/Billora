// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../domain/usecases/scan_bill_usecase.dart';
// import '../../domain/usecases/extract_bill_data_usecase.dart';
// import '../../domain/usecases/validate_bill_data_usecase.dart';
// import 'bill_scanner_state.dart';

// class BillScannerCubit extends Cubit<BillScannerState> {
//   final ScanBillUseCase scanBillUseCase;
//   final ExtractBillDataUseCase extractBillDataUseCase;
//   final ValidateBillDataUseCase validateBillDataUseCase;

//   BillScannerCubit({
//     required this.scanBillUseCase,
//     required this.extractBillDataUseCase,
//     required this.validateBillDataUseCase,
//   }) : super(const BillScannerState.initial());

//   Future<void> scanBill(String imagePath) async {
//     emit(const BillScannerState.scanning());
    
//     final result = await scanBillUseCase(imagePath);
    
//     result.fold(
//       (failure) => emit(BillScannerState.error(failure.message)),
//       (scanResult) => emit(BillScannerState.scanSuccess(scanResult)),
//     );
//   }

//   Future<void> extractBillData(String imagePath) async {
//     emit(const BillScannerState.processing());
    
//     final result = await extractBillDataUseCase(imagePath);
    
//     result.fold(
//       (failure) => emit(BillScannerState.error(failure.message)),
//       (scannedBill) => emit(BillScannerState.extractionSuccess(scannedBill)),
//     );
//   }

//   Future<void> validateBillData(dynamic bill) async {
//     emit(const BillScannerState.processing());
    
//     final result = await validateBillDataUseCase(bill);
    
//     result.fold(
//       (failure) => emit(BillScannerState.error(failure.message)),
//       (validatedBill) => emit(BillScannerState.extractionSuccess(validatedBill)),
//     );
//   }
// } 