import 'package:dartz/dartz.dart';
import 'package:ehealth/core/error/exceptions.dart';
import 'package:ehealth/core/error/failures.dart';
import 'package:ehealth/core/result/result.dart';
import 'package:ehealth/features/voice_assistant/data/datasources/speech_recognition_data_source.dart';
import 'package:ehealth/features/voice_assistant/data/datasources/text_to_speech_data_source.dart';
import 'package:ehealth/features/voice_assistant/domain/entities/voice_recognition_result.dart';
import 'package:ehealth/features/voice_assistant/domain/repositories/voice_repository.dart';

class VoiceRepositoryImpl implements VoiceRepository {
  VoiceRepositoryImpl({
    required SpeechRecognitionDataSource speechDataSource,
    required TextToSpeechDataSource ttsDataSource,
  })  : _speech = speechDataSource,
        _tts = ttsDataSource;

  final SpeechRecognitionDataSource _speech;
  final TextToSpeechDataSource _tts;

  @override
  bool get isListening => _speech.isListening;

  @override
  Future<Result<bool>> initialize() async {
    try {
      final available = await _speech.initialize();
      return Right(available);
    } catch (_) {
      return const Left(VoiceFailure('Speech recognition is not available on this device.'));
    }
  }

  @override
  Future<Result<void>> startListening({
    required void Function(VoiceRecognitionResult result) onResult,
  }) async {
    try {
      await _speech.startListening(onResult: onResult);
      return const Right(null);
    } on PermissionException catch (e) {
      return Left(PermissionFailure(e.message));
    } catch (_) {
      return const Left(VoiceFailure());
    }
  }

  @override
  Future<Result<void>> stopListening() async {
    try {
      await _speech.stopListening();
      return const Right(null);
    } catch (_) {
      return const Left(VoiceFailure('Unable to stop listening.'));
    }
  }

  @override
  void setEngineListeners({
    void Function()? onListeningStopped,
    void Function(String message, bool permanent)? onError,
  }) {
    _speech.onListeningStopped = onListeningStopped;
    _speech.onErrorOccurred = onError;
  }

  @override
  Future<Result<void>> speak(String message) async {
    try {
      await _tts.speak(message);
      return const Right(null);
    } catch (_) {
      return const Left(VoiceFailure('Unable to speak the response.'));
    }
  }
}
