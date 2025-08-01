import 'package:equatable/equatable.dart';
import 'package:camera/camera.dart';
import '../../../../core/constants/app_status.dart';

class CameraState extends Equatable {
  final CameraStatus status;
  final CameraController? controller;
  final bool isFlashOn;
  final bool isRecording;
  final String? errorMessage;
  final String? lastCapturedPath;
  final String? uploadedUrl;

  const CameraState({
    this.status = CameraStatus.initial,
    this.controller,
    this.isFlashOn = false,
    this.isRecording = false,
    this.errorMessage,
    this.lastCapturedPath,
    this.uploadedUrl,
  });

  CameraState copyWith({
    CameraStatus? status,
    CameraController? controller,
    bool? isFlashOn,
    bool? isRecording,
    String? errorMessage,
    String? lastCapturedPath,
    String? uploadedUrl,
  }) {
    return CameraState(
      status: status ?? this.status,
      controller: controller ?? this.controller,
      isFlashOn: isFlashOn ?? this.isFlashOn,
      isRecording: isRecording ?? this.isRecording,
      errorMessage: errorMessage ?? this.errorMessage,
      lastCapturedPath: lastCapturedPath ?? this.lastCapturedPath,
      uploadedUrl: uploadedUrl ?? this.uploadedUrl,
    );
  }

  @override
  List<Object?> get props => [
    status,
    controller,
    isFlashOn,
    isRecording,
    errorMessage,
    lastCapturedPath,
    uploadedUrl,
  ];
}