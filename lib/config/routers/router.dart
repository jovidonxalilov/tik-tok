import 'package:go_router/go_router.dart';
import 'package:imtihon6/config/routers/routes.dart';
import 'package:imtihon6/features/camera_photo/presentation/pages/capture_page.dart';
import 'package:imtihon6/features/camera_photo/presentation/pages/upload_page.dart';
import 'package:imtihon6/features/user/presentation/pages/profil_page.dart';

import 'main_scaffold.dart';

final GoRouter router = GoRouter(
  initialLocation: Routes.profile,
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return MainScaffold(child: child);
      },
      routes: [
        GoRoute(path: Routes.profile, builder: (context, state) => ProfileScreen()),
        GoRoute(path: Routes.camera, builder: (context, state) => CameraScreen()),
      ],
    ),
    // GoRoute(path: Routes.camera, builder: (context, state) => CameraScreen()),
    GoRoute(
      path: Routes.upload,
      builder: (context, state) => YearReviewScreen(),
    ),
  ],
);
