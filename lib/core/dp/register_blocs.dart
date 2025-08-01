import 'dart:developer';
import 'package:get_it/get_it.dart';
import 'package:imtihon6/config/service/firebase_service.dart';
import 'package:imtihon6/features/camera_photo/presentation/bloc/bloc.dart';
import 'package:imtihon6/features/user/presentation/bloc/profile_bloc.dart';

Future<void> registerBlocs(GetIt getIt) async {
  getIt..registerFactory(
    () => ProfileBloc(firebaseService: getIt<FirebaseService>(),userId: 'jovidon'),
  )..registerFactory(() => CameraBloc(firebaseService: getIt<FirebaseService>(), userId: 'jovidon') );
  log("Register BLOC Complate For GetIT");
}
