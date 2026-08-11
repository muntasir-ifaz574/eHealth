import 'package:ehealth/core/router/route_names.dart';
import 'package:ehealth/features/home/presentation/screens/home_screen.dart';
import 'package:ehealth/features/hospital/presentation/screens/hospital_detail_screen.dart';
import 'package:ehealth/features/hospital/presentation/screens/hospital_list_screen.dart';
import 'package:ehealth/features/hospital/presentation/screens/hospital_map_screen.dart';
import 'package:ehealth/features/splash/presentation/screens/splash_screen.dart';
import 'package:ehealth/features/video_call/presentation/screens/doctor_list_screen.dart';
import 'package:ehealth/features/video_call/presentation/screens/video_call_screen.dart';
import 'package:ehealth/features/voice_assistant/presentation/screens/voice_assistant_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RoutePaths.splash,
    routes: [
      GoRoute(
        path: RoutePaths.splash,
        name: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RoutePaths.home,
        name: RouteNames.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: RoutePaths.hospitalList,
        name: RouteNames.hospitalList,
        builder: (context, state) => const HospitalListScreen(),
        routes: [
          GoRoute(
            path: 'map',
            name: RouteNames.hospitalMap,
            builder: (context, state) => const HospitalMapScreen(),
          ),
          GoRoute(
            path: ':placeId',
            name: RouteNames.hospitalDetail,
            builder: (context, state) => HospitalDetailScreen(
              placeId: state.pathParameters['placeId']!,
            ),
          ),
        ],
      ),
      GoRoute(
        path: RoutePaths.doctorList,
        name: RouteNames.doctorList,
        builder: (context, state) => const DoctorListScreen(),
      ),
      GoRoute(
        path: RoutePaths.videoCall,
        name: RouteNames.videoCall,
        builder: (context, state) => VideoCallScreen(
          doctorId: state.pathParameters['doctorId']!,
        ),
      ),
      GoRoute(
        path: RoutePaths.voiceAssistant,
        name: RouteNames.voiceAssistant,
        builder: (context, state) => const VoiceAssistantScreen(),
      ),
    ],
  );
});
