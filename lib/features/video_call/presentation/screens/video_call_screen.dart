import 'package:ehealth/core/config/env.dart';
import 'package:ehealth/core/di/core_providers.dart';
import 'package:ehealth/core/widgets/async_value_widget.dart';
import 'package:ehealth/features/video_call/presentation/providers/video_call_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

/// Full-screen live video call powered by the ZEGOCLOUD prebuilt call UI kit.
class VideoCallScreen extends ConsumerWidget {
  const VideoCallScreen({super.key, required this.doctorId});

  final String doctorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(callSessionProvider(doctorId));

    return Scaffold(
      body: AsyncValueWidget(
        value: sessionAsync,
        onRetry: () => ref.invalidate(callSessionProvider(doctorId)),
        data: (session) {
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
                    child: Text('Camera and microphone permissions are required for the call.'),
                  ),
                );
              }

              return ZegoUIKitPrebuiltCall(
                appID: Env.zegoAppId,
                appSign: Env.zegoAppSign,
                userID: session.callerUserId,
                userName: session.callerUserName,
                callID: session.callId,
                config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall(),
                events: ZegoUIKitPrebuiltCallEvents(
                  onCallEnd: (event, defaultAction) => Navigator.of(context).maybePop(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
