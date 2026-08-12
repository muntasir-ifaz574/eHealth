abstract final class RouteNames {
  static const splash = 'splash';
  static const home = 'home';
  static const login = 'login';
  static const register = 'register';
  static const welcome = 'welcome';
  static const profile = 'profile';
  static const hospitalList = 'hospitalList';
  static const hospitalMap = 'hospitalMap';
  static const hospitalDetail = 'hospitalDetail';
  static const doctorList = 'doctorList';
  static const videoCall = 'videoCall';
  static const voiceAssistant = 'voiceAssistant';
  static const voiceCommands = 'voiceCommands';
  static const appointmentList = 'appointmentList';
  static const appointmentBooking = 'appointmentBooking';
  static const prescriptionList = 'prescriptionList';
  static const prescriptionVerify = 'prescriptionVerify';
  static const symptomChecker = 'symptomChecker';
  static const healthProgress = 'healthProgress';
  static const paymentReview = 'paymentReview';
  static const paymentCheckout = 'paymentCheckout';
  static const paymentResult = 'paymentResult';
}

abstract final class RoutePaths {
  static const splash = '/splash';
  static const home = '/home';
  static const login = '/login';
  static const register = '/register';
  static const welcome = '/welcome';
  static const profile = '/profile';
  static const hospitalList = '/hospitals';
  static const hospitalMap = '/hospitals/map';
  static const hospitalDetail = '/hospitals/:placeId';
  static const doctorList = '/doctors';
  static const videoCall = '/call/:consultationId';
  static const voiceAssistant = '/voice';
  static const voiceCommands = '/voice-commands';
  static const appointmentList = '/appointments';
  static const appointmentBooking = '/appointments/book/:doctorId';
  static const prescriptionList = '/appointments/:consultationId/prescriptions';
  static const prescriptionVerify = '/prescriptions/:prescriptionId/verify';
  static const symptomChecker = '/symptom-checker';
  static const healthProgress = '/health-progress';
  static const paymentReview = '/payments/:consultationId/review';
  static const paymentCheckout = '/payments/:consultationId/checkout';
  static const paymentResult = '/payments/result';

  static String hospitalDetailOf(String placeId) => '/hospitals/$placeId';

  static String videoCallOf(String consultationId) => '/call/$consultationId';
}
