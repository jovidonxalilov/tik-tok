import 'dart:io';

import 'package:equatable/equatable.dart';
import 'dart:io';

import '../../../user/data/model/media_model.dart';

abstract class CameraEvent extends Equatable {
  const CameraEvent();

  @override
  List<Object> get props => [];
}

class CameraInitialize extends CameraEvent {}

class CameraStartRecording extends CameraEvent {}

class CameraStopRecording extends CameraEvent {}

class CameraTakePicture extends CameraEvent {}

class CameraUploadMedia extends CameraEvent {
  final File file;
  final MediaType type;

  const CameraUploadMedia({required this.file, required this.type});

  @override
  List<Object> get props => [file, type];
}

class CameraSwitchCamera extends CameraEvent {}

class CameraToggleFlash extends CameraEvent {}