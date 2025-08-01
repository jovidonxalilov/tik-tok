import 'dart:developer';
import 'package:get_it/get_it.dart';
import 'package:imtihon6/config/service/firebase_service.dart';


Future<void> registerServices(GetIt getIt) async {
  getIt
    .registerLazySingleton<FirebaseService>(
      () =>  FirebaseService(),
    );

  log("Register Services Complete For GetIT");
}
