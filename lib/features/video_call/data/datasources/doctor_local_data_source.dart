import 'package:ehealth/features/video_call/data/models/doctor_model.dart';

/// Placeholder for a real backend endpoint (e.g. `GET /doctors`). Swap this
/// for a Dio-backed `DoctorRemoteDataSource` once the doctor directory API
/// exists — the repository and everything above it stays unchanged.
class DoctorLocalDataSource {
  const DoctorLocalDataSource();

  Future<List<DoctorModel>> fetchAvailableDoctors() async {
    return const [
      DoctorModel(id: 'doc_1', name: 'Dr. Amelia Chen', specialty: 'General Physician', isOnline: true),
      DoctorModel(id: 'doc_2', name: 'Dr. Rahim Islam', specialty: 'Cardiologist', isOnline: true),
      DoctorModel(id: 'doc_3', name: 'Dr. Sarah Ahmed', specialty: 'Pediatrician', isOnline: false),
      DoctorModel(id: 'doc_4', name: 'Dr. Farhan Kabir', specialty: 'Dermatologist', isOnline: true),
    ];
  }

  Future<DoctorModel?> fetchDoctorById(String doctorId) async {
    final doctors = await fetchAvailableDoctors();
    for (final doctor in doctors) {
      if (doctor.id == doctorId) return doctor;
    }
    return null;
  }
}
