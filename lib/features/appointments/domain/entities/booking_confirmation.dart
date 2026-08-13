import 'package:equatable/equatable.dart';

class BookingConfirmation extends Equatable {
  const BookingConfirmation({required this.consultationId});

  final int consultationId;

  @override
  List<Object?> get props => [consultationId];
}
