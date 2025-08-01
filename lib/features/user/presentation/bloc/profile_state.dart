import 'package:equatable/equatable.dart';

import '../../../../core/constants/app_status.dart';
import '../../data/model/media_model.dart';
import '../../data/model/profile_model.dart';


class ProfileState extends Equatable {
  final ProfileStatus status;
  final UserProfile? profile;
  final List<MediaItem> mediaItems;
  final String? errorMessage;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profile,
    this.mediaItems = const [],
    this.errorMessage,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    UserProfile? profile,
    List<MediaItem>? mediaItems,
    String? errorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      mediaItems: mediaItems ?? this.mediaItems,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, profile, mediaItems, errorMessage];
}