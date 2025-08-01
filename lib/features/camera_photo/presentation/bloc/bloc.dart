import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import 'package:imtihon6/features/camera_photo/presentation/bloc/state.dart';
import 'package:uuid/uuid.dart';
import '../../../../config/service/firebase_service.dart';
import '../../../../core/constants/app_status.dart';
// import '../../services/firebase_service.dart';
// import '../../models/media_item.dart';
// import '../../main.dart';
// import 'camera_event.dart';
import '../../../../main.dart';
import '../../../user/data/model/media_model.dart';
import 'state.dart';
// import '../../enums/app_status.dart';
import 'event.dart';

class CameraBloc extends Bloc<CameraEvent, CameraState> {
  final FirebaseService _firebaseService;
  final String userId; // 🔥 Auth o‘rniga tashqaridan kiritiladi
  final Uuid _uuid = const Uuid();
  int _currentCameraIndex = 0;

  CameraBloc({
    required FirebaseService firebaseService,
    required this.userId,
  })  : _firebaseService = firebaseService,
        super(const CameraState()) {
    on<CameraInitialize>(_onInitialize);
    on<CameraStartRecording>(_onStartRecording);
    on<CameraStopRecording>(_onStopRecording);
    on<CameraTakePicture>(_onTakePicture);
    on<CameraUploadMedia>(_onUploadMedia);
    on<CameraSwitchCamera>(_onSwitchCamera);
    on<CameraToggleFlash>(_onToggleFlash);
  }

  void _onInitialize(CameraInitialize event, Emitter<CameraState> emit) async {
    try {
      if (cameras.isEmpty) return;

      final controller = CameraController(
        cameras[_currentCameraIndex],
        ResolutionPreset.high,
        enableAudio: true,
      );

      await controller.initialize();

      emit(state.copyWith(
        status: CameraStatus.ready,
        controller: controller,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CameraStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onStartRecording(CameraStartRecording event, Emitter<CameraState> emit) async {
    if (state.controller == null || !state.controller!.value.isInitialized) return;

    try {
      await state.controller!.startVideoRecording();
      emit(state.copyWith(
        status: CameraStatus.recording,
        isRecording: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CameraStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onStopRecording(CameraStopRecording event, Emitter<CameraState> emit) async {
    if (state.controller == null || !state.isRecording) return;

    try {
      final videoFile = await state.controller!.stopVideoRecording();

      emit(state.copyWith(
        status: CameraStatus.captured,
        isRecording: false,
        lastCapturedPath: videoFile.path,
      ));

      // Auto upload
      add(CameraUploadMedia(file: File(videoFile.path), type: MediaType.video));
    } catch (e) {
      emit(state.copyWith(
        status: CameraStatus.error,
        errorMessage: e.toString(),
        isRecording: false,
      ));
    }
  }

  void _onTakePicture(CameraTakePicture event, Emitter<CameraState> emit) async {
    if (state.controller == null || !state.controller!.value.isInitialized) return;

    try {
      final imageFile = await state.controller!.takePicture();

      emit(state.copyWith(
        status: CameraStatus.captured,
        lastCapturedPath: imageFile.path,
      ));

      // Auto upload
      add(CameraUploadMedia(file: File(imageFile.path), type: MediaType.image));
    } catch (e) {
      emit(state.copyWith(
        status: CameraStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onUploadMedia(CameraUploadMedia event, Emitter<CameraState> emit) async {
    emit(state.copyWith(status: CameraStatus.uploading));

    try {
      final url = await _firebaseService.uploadMedia(event.file, event.type, userId);

      final mediaItem = MediaItem(
        id: _uuid.v4(),
        url: url,
        thumbnailUrl: url,
        type: event.type,
        createdAt: DateTime.now(),
        userId: userId,
      );

      await _firebaseService.saveMediaItem(mediaItem);

      emit(state.copyWith(
        status: CameraStatus.uploaded,
        uploadedUrl: url,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CameraStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }


  void _onSwitchCamera(CameraSwitchCamera event, Emitter<CameraState> emit) async {
    if (cameras.length <= 1) return;

    try {
      await state.controller?.dispose();

      _currentCameraIndex = (_currentCameraIndex + 1) % cameras.length;

      final controller = CameraController(
        cameras[_currentCameraIndex],
        ResolutionPreset.high,
        enableAudio: true,
      );

      await controller.initialize();

      emit(state.copyWith(
        controller: controller,
        status: CameraStatus.ready,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CameraStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onToggleFlash(CameraToggleFlash event, Emitter<CameraState> emit) async {
    if (state.controller == null) return;

    try {
      final newFlashMode = state.isFlashOn ? FlashMode.off : FlashMode.torch;
      await state.controller!.setFlashMode(newFlashMode);

      emit(state.copyWith(isFlashOn: !state.isFlashOn));
    } catch (e) {
      emit(state.copyWith(
        status: CameraStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  @override
  Future<void> close() {
    state.controller?.dispose();
    return super.close();
  }
}