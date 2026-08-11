abstract final class RouteNames {
  static const splash = 'splash';
  static const home = 'home';
  static const hospitalList = 'hospitalList';
  static const hospitalMap = 'hospitalMap';
  static const hospitalDetail = 'hospitalDetail';
  static const doctorList = 'doctorList';
  static const videoCall = 'videoCall';
  static const voiceAssistant = 'voiceAssistant';
}

abstract final class RoutePaths {
  static const splash = '/splash';
  static const home = '/home';
  static const hospitalList = '/hospitals';
  static const hospitalMap = '/hospitals/map';
  static const hospitalDetail = '/hospitals/:placeId';
  static const doctorList = '/doctors';
  static const videoCall = '/call/:doctorId';
  static const voiceAssistant = '/voice';

  static String hospitalDetailOf(String placeId) => '/hospitals/$placeId';

  static String videoCallOf(String doctorId) => '/call/$doctorId';
}
