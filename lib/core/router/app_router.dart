import 'package:ehealth/core/router/route_names.dart';
import 'package:ehealth/core/widgets/app_shell.dart';
import 'package:ehealth/features/appointments/presentation/screens/appointment_booking_screen.dart';
import 'package:ehealth/features/appointments/presentation/screens/my_appointments_screen.dart';
import 'package:ehealth/features/auth/presentation/providers/auth_providers.dart';
import 'package:ehealth/features/auth/presentation/providers/auth_state.dart';
import 'package:ehealth/features/auth/presentation/screens/login_screen.dart';
import 'package:ehealth/features/auth/presentation/screens/profile_screen.dart';
import 'package:ehealth/features/auth/presentation/screens/register_screen.dart';
import 'package:ehealth/features/auth/presentation/screens/welcome_screen.dart';
import 'package:ehealth/features/home/presentation/screens/home_screen.dart';
import 'package:ehealth/features/hospital/presentation/screens/hospital_detail_screen.dart';
import 'package:ehealth/features/hospital/presentation/screens/hospital_list_screen.dart';
import 'package:ehealth/features/hospital/presentation/screens/hospital_map_screen.dart';
import 'package:ehealth/features/payments/presentation/screens/payment_result_screen.dart';
import 'package:ehealth/features/payments/presentation/screens/payment_review_screen.dart';
import 'package:ehealth/features/payments/presentation/screens/payment_webview_screen.dart';
import 'package:ehealth/features/prescriptions/presentation/screens/prescription_list_screen.dart';
import 'package:ehealth/features/prescriptions/presentation/screens/prescription_verify_screen.dart';
import 'package:ehealth/features/prompts/presentation/screens/health_progress_screen.dart';
import 'package:ehealth/features/prompts/presentation/screens/symptom_checker_screen.dart';
import 'package:ehealth/features/splash/presentation/screens/splash_screen.dart';
import 'package:ehealth/features/video_call/presentation/screens/doctor_list_screen.dart';
import 'package:ehealth/features/video_call/presentation/screens/video_call_screen.dart';
import 'package:ehealth/features/voice_assistant/presentation/screens/voice_assistant_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Notifies [GoRouter] to re-run `redirect` for the current location
/// whenever the auth session changes, without recreating the router itself.
/// `redirect` calls `bootstrap()`, which mutates `authControllerProvider` —
/// watching that provider directly from `goRouterProvider` would tear down
/// and rebuild the router mid-redirect, disposing the `ref` the in-flight
/// callback depends on.
class _GoRouterRefreshListenable extends ChangeNotifier {
  void refresh() => notifyListeners();
}

final _goRouterRefreshListenableProvider = Provider<_GoRouterRefreshListenable>((ref) {
  final listenable = _GoRouterRefreshListenable();
  ref.listen(authControllerProvider, (previous, next) => listenable.refresh());
  ref.onDispose(listenable.dispose);
  return listenable;
});

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RoutePaths.splash,
    refreshListenable: ref.watch(_goRouterRefreshListenableProvider),
    redirect: (context, state) async {
      if (state.matchedLocation == RoutePaths.splash) return null;

      if (ref.read(authControllerProvider).status == AuthStatus.unknown) {
        await ref.read(authControllerProvider.notifier).bootstrap();
      }

      final isAuthenticated = ref.read(authControllerProvider).isAuthenticated;
      final isAuthRoute =
          state.matchedLocation == RoutePaths.login || state.matchedLocation == RoutePaths.register;

      if (!isAuthenticated && !isAuthRoute) return RoutePaths.login;
      if (isAuthenticated && isAuthRoute) return RoutePaths.home;
      return null;
    },
    routes: [
      GoRoute(
        path: RoutePaths.splash,
        name: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RoutePaths.login,
        name: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RoutePaths.register,
        name: RouteNames.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: RoutePaths.welcome,
        name: RouteNames.welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      // The four bottom-nav tabs live in one persistent shell — built once by
      // AppShell and kept alive across tab switches, so the nav bar itself
      // never rebuilds when tapping between Home/Appointment/AI/Profile.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.home,
                name: RouteNames.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.appointmentList,
                name: RouteNames.appointmentList,
                builder: (context, state) => const MyAppointmentsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.symptomChecker,
                name: RouteNames.symptomChecker,
                builder: (context, state) => const SymptomCheckerScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.profile,
                name: RouteNames.profile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
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
          consultationId: state.pathParameters['consultationId']!,
        ),
      ),
      GoRoute(
        path: RoutePaths.voiceAssistant,
        name: RouteNames.voiceAssistant,
        builder: (context, state) => const VoiceAssistantScreen(),
      ),
      GoRoute(
        path: RoutePaths.appointmentBooking,
        name: RouteNames.appointmentBooking,
        builder: (context, state) => AppointmentBookingScreen(
          doctorId: int.parse(state.pathParameters['doctorId']!),
        ),
      ),
      GoRoute(
        path: RoutePaths.prescriptionList,
        name: RouteNames.prescriptionList,
        builder: (context, state) => PrescriptionListScreen(
          consultationId: state.pathParameters['consultationId']!,
        ),
      ),
      GoRoute(
        path: RoutePaths.prescriptionVerify,
        name: RouteNames.prescriptionVerify,
        builder: (context, state) => PrescriptionVerifyScreen(
          prescriptionId: state.pathParameters['prescriptionId']!,
        ),
      ),
      GoRoute(
        path: RoutePaths.healthProgress,
        name: RouteNames.healthProgress,
        builder: (context, state) => const HealthProgressScreen(),
      ),
      GoRoute(
        path: RoutePaths.paymentReview,
        name: RouteNames.paymentReview,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? const {};
          return PaymentReviewScreen(
            consultationId: int.parse(state.pathParameters['consultationId']!),
            amount: extra['amount'] as num,
            userId: extra['userId'] as int,
          );
        },
      ),
      GoRoute(
        path: RoutePaths.paymentCheckout,
        name: RouteNames.paymentCheckout,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? const {};
          return PaymentWebViewScreen(
            consultationId: int.parse(state.pathParameters['consultationId']!),
            amount: extra['amount'] as num,
            userId: extra['userId'] as int,
          );
        },
      ),
      GoRoute(
        path: RoutePaths.paymentResult,
        name: RouteNames.paymentResult,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? const {};
          return PaymentResultScreen(success: extra['success'] as bool? ?? false);
        },
      ),
    ],
  );
});
