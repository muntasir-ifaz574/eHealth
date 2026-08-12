import 'package:ehealth/features/appointments/domain/entities/booking_confirmation.dart';

class BookingConfirmationModel extends BookingConfirmation {
  const BookingConfirmationModel({required super.consultationId});

  factory BookingConfirmationModel.fromJson(Map<String, dynamic> json) {
    return BookingConfirmationModel(consultationId: int.parse(json['consultationId'].toString()));
  }
}
