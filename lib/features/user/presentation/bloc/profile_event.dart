import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class ProfileLoad extends ProfileEvent {}

class ProfileRefresh extends ProfileEvent {}

class ProfileUpdateStats extends ProfileEvent {
  final int? followingCount;
  final int? followersCount;
  final int? likesCount;

  const ProfileUpdateStats({
    this.followingCount,
    this.followersCount,
    this.likesCount,
  });

  // @override
  // Future<List<Object?>> get props async => [followingCount, followersCount, likesCount];
}