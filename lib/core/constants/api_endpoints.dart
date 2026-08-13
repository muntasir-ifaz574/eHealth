abstract final class ApiEndpoints {
  static const String registration = 'users/registration';
  static const String login = 'users/login';
  static const String googleOAuth = 'users/google-oauth';
  static const String doctors = 'users/doctors';
  static const String appointments = 'users/appointments';

  static String consultationPrescriptions(String consultationId) =>
      'users/consultations/$consultationId/prescriptions';

  static String verifyPrescription(String prescriptionId) =>
      'users/prescriptions/$prescriptionId/verify';

  static String consultationConference(String consultationId) =>
      'users/consultations/$consultationId/conference';

  static const String getPrompts = 'prompt/get-prompts';
  static const String healthProgress = 'prompt/health-progress';
  static const String createPromptBackup = 'prompt/create-backup';

  static const String initiatePayment = 'doctor/payments/initiate';
  static const String paymentSuccess = 'doctor/payments/success';
}
