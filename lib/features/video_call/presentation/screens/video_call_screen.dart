import 'package:ehealth/core/config/env.dart';
import 'package:ehealth/core/di/core_providers.dart';
import 'package:ehealth/core/theme/app_colors.dart';
import 'package:ehealth/core/widgets/async_value_widget.dart';
import 'package:ehealth/features/video_call/presentation/providers/video_call_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

/// Full-screen live video call powered by the ZEGOCLOUD prebuilt call UI kit.
/// Session identity (consultationId/userId/userName) comes from the backend's
/// per-consultation conference response, but `appID`/`appSign` come from the
/// local `.env` instead of `credentials.appId`/`credentials.serverSecret` —
/// the backend's `serverSecret` is a 32-char ZEGO ServerSecret (meant to stay
/// server-side and mint short-lived tokens), not a valid 64-char AppSign, so
/// the SDK rejects it (`createEngine` error 1001001). Revert to the backend
/// values once it returns a real AppSign or a generated Kit Token instead.
class VideoCallScreen extends ConsumerWidget {
  const VideoCallScreen({super.key, required this.consultationId});

  final String consultationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final credentialsAsync = ref.watch(
      conferenceCredentialsProvider(consultationId),
    );

    return Scaffold(
      backgroundColor: AppColors.charcoalDeep,
      body: AsyncValueWidget(
        value: credentialsAsync,
        onRetry: () =>
            ref.invalidate(conferenceCredentialsProvider(consultationId)),
        data: (credentials) {
          return FutureBuilder<bool>(
            future: ref.read(permissionServiceProvider).requestCallEssentials(),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.data != true) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Camera and microphone permissions are required for the call.',
                    ),
                  ),
                );
              }

              final config = ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
                ..background = Container(color: AppColors.charcoalDeep)
                ..bottomMenuBar.backgroundColor = AppColors.charcoalDeep
                    .withValues(alpha: 0.55)
                // The Android activity doesn't declare PiP support
                // (android:supportsPictureInPicture), so backgrounding would
                // otherwise repeatedly throw setPictureInPictureParams errors.
                ..pip.enableWhenBackground = false;

              return ZegoUIKitPrebuiltCall(
                appID: Env.zegoAppId,
                appSign: Env.zegoAppSign,
                userID: credentials.userId.toString(),
                userName: credentials.userName,
                callID: credentials.consultationId,
                config: config,
                events: ZegoUIKitPrebuiltCallEvents(
                  onCallEnd: (event, defaultAction) {
                    if (context.canPop()) context.pop();
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
