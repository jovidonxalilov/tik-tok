import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:imtihon6/config/routers/routes.dart';
import 'package:imtihon6/config/service/firebase_service.dart';
import 'package:imtihon6/core/dp/dp_injection.dart';
import 'package:imtihon6/features/camera_photo/presentation/pages/upload_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';

import '../../../../core/constants/app_status.dart';
import '../bloc/bloc.dart';
import '../bloc/event.dart';
import '../bloc/state.dart';


class CameraScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CameraBloc(firebaseService: getIt<FirebaseService>(), userId: 'jovidon')..add(CameraInitialize()),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: BlocConsumer<CameraBloc, CameraState>(
          listener: (context, state) {
            if (state.status == CameraStatus.error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'Camera error'),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state.status == CameraStatus.uploaded) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Media uploaded successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state.status == CameraStatus.initial) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Initializing camera...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              );
            }
            if (state.controller == null || !state.controller!.value.isInitialized) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt, size: 64, color: Colors.white54),
                    SizedBox(height: 16),
                    Text(
                      'Camera not available',
                      style: TextStyle(color: Colors.white),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        context.read<CameraBloc>().add(CameraInitialize());
                      },
                      child: Text('Retry'),
                    ),
                  ],
                ),
              );
            }
      
            return Stack(
              children: [
                // Camera Preview
                Positioned.fill(
                  child: CameraPreview(state.controller!),
                ),
      
                // Upload Status Overlay
                if (state.status == CameraStatus.uploading)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.7),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: Colors.white),
                            SizedBox(height: 16),
                            Text(
                              'Uploading to Firebase...',
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
      
                // Right side controls
                Positioned(
                  right: 15,
                  top: 100,
                  child: Column(
                    children: [
                      _buildControlIcon(
                        Icons.cameraswitch,
                        onTap: () => context.read<CameraBloc>().add(CameraSwitchCamera()),
                      ),
                      SizedBox(height: 20),
                      _buildControlIcon(
                        state.isFlashOn ? Icons.flash_on : Icons.flash_off,
                        onTap: () => context.read<CameraBloc>().add(CameraToggleFlash()),
                        isActive: state.isFlashOn,
                      ),
                      SizedBox(height: 20),
                      _buildControlIcon(Icons.timer),
                      SizedBox(height: 20),
                      _buildControlIcon(Icons.color_lens),
                      SizedBox(height: 20),
                      _buildControlIcon(Icons.music_note),
                    ],
                  ),
                ),
      
                // Bottom controls
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: MediaQuery.of(context).size.height * 0.25,
                  child: Container(
                    color: Colors.black,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Gallery preview (last captured)
                            GestureDetector(
                              onTap: () {
                                context.push(Routes.upload);
                              },
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.photo_library, color: Colors.white),
                              ),
                            ),
      
                            // Record/Capture button
                            GestureDetector(
                              onTap: () {
                                if (state.isRecording) {
                                  context.read<CameraBloc>().add(CameraStopRecording());
                                } else {
                                  context.read<CameraBloc>().add(CameraTakePicture());
                                }
                              },
                              onLongPress: () {
                                if (!state.isRecording) {
                                  context.read<CameraBloc>().add(CameraStartRecording());
                                }
                              },
                              child: Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 3),
                                ),
                                child: Center(
                                  child: Container(
                                    width: state.isRecording ? 30 : 50,
                                    height: state.isRecording ? 30 : 50,
                                    decoration: BoxDecoration(
                                      shape: state.isRecording ? BoxShape.rectangle : BoxShape.circle,
                                      color: Colors.red,
                                      borderRadius: state.isRecording ? BorderRadius.circular(5) : null,
                                    ),
                                  ),
                                ),
                              ),
                            ),
      
                            // Switch to front camera shortcut
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.flip_camera_ios, color: Colors.white),
                            ),
                          ],
                        ),
      
                        SizedBox(height: 20),
      
                        // Bottom options
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildBottomOption('Effects'),
                            _buildBottomOption('60s'),
                            _buildBottomOption('15s'),
                            _buildBottomOption('Templates'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
      
                // Recording indicator
                if (state.isRecording)
                  Positioned(
                    top: 60,
                    left: 20,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'REC',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildControlIcon(IconData icon, {VoidCallback? onTap, bool isActive = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? Colors.yellow.withOpacity(0.8) : Colors.white.withOpacity(0.3),
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.black : Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildBottomOption(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white,
        fontSize: 12,
      ),
    );
  }
}

