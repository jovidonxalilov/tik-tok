import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/service/firebase_service.dart';
import '../../../../core/constants/app_status.dart';
import '../../data/model/media_model.dart';
import '../../data/model/profile_model.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final FirebaseService _firebaseService;
  final String userId;

  StreamSubscription<List<MediaItem>>? _mediaSubscription;

  ProfileBloc({
    required FirebaseService firebaseService,
    required this.userId,
  })  : _firebaseService = firebaseService,
        super(const ProfileState()) {
    on<ProfileLoad>(_onLoad);
    on<ProfileRefresh>(_onRefresh);
    on<ProfileUpdateStats>(_onUpdateStats);
    add(ProfileLoad());
  }

  void _onLoad(ProfileLoad event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      UserProfile? profile = await _firebaseService.getUserProfile(userId);

      if (profile == null) {
        profile = UserProfile(
          id: userId,
          username: '@user_${userId.substring(0, 8)}',
          profileImageUrl: '',
        );
        await _firebaseService.saveUserProfile(profile);
      }

      _mediaSubscription?.cancel();
      _mediaSubscription = _firebaseService.getUserMediaItems(userId).listen((mediaItems) {
        if (!isClosed) add(ProfileRefresh());
      });

      final mediaItems = await _firebaseService.getUserMediaItems(userId).first;

      emit(state.copyWith(
        status: ProfileStatus.loaded,
        profile: profile,
        mediaItems: mediaItems,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onRefresh(ProfileRefresh event, Emitter<ProfileState> emit) async {
    if (state.profile == null) return;

    try {
      final mediaItems = await _firebaseService.getUserMediaItems(state.profile!.id).first;
      emit(state.copyWith(
        mediaItems: mediaItems,
        status: ProfileStatus.loaded,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onUpdateStats(ProfileUpdateStats event, Emitter<ProfileState> emit) async {
    if (state.profile == null) return;

    try {
      await _firebaseService.updateProfileStats(
        state.profile!.id,
        followingCount: event.followingCount,
        followersCount: event.followersCount,
        likesCount: event.likesCount,
      );

      final updatedProfile = state.profile!.copyWith(
        followingCount: event.followingCount ?? state.profile!.followingCount,
        followersCount: event.followersCount ?? state.profile!.followersCount,
        likesCount: event.likesCount ?? state.profile!.likesCount,
      );

      emit(state.copyWith(profile: updatedProfile));
    } catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  @override
  Future<void> close() {
    _mediaSubscription?.cancel();
    return super.close();
  }
}
