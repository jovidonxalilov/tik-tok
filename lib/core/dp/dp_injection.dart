import 'dart:developer';

import 'package:get_it/get_it.dart';

import 'register_blocs.dart';
import 'register_services.dart';

final GetIt getIt = GetIt.instance;
Future<void> setupDependencies() async {
  await registerServices(getIt);
  await registerBlocs(getIt);

  log("All Register Complate For GetIT");
}
