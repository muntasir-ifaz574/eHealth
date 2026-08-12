import 'package:equatable/equatable.dart';

/// The doc leaves `POST users/appointments`'s response shape unspecified
/// ("Consultation creation details") — only `consultationId` is relied on,
/// since that's all the payment step needs.
class BookingConfirmation extends Equatable {
  const BookingConfirmation({required this.consultationId});

  final int consultationId;

  @override
  List<Object?> get props => [consultationId];
}
