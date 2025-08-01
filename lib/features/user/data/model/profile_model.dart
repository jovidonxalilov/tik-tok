import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String id;
  final String username;
  final String profileImageUrl;
  final int followingCount;
  final int followersCount;
  final int likesCount;

  const UserProfile({
    required this.id,
    required this.username,
    required this.profileImageUrl,
    this.followingCount = 0,
    this.followersCount = 0,
    this.likesCount = 0,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      username: json['username'],
      profileImageUrl: json['profileImageUrl'],
      followingCount: json['followingCount'] ?? 0,
      followersCount: json['followersCount'] ?? 0,
      likesCount: json['likesCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'profileImageUrl': profileImageUrl,
      'followingCount': followingCount,
      'followersCount': followersCount,
      'likesCount': likesCount,
    };
  }

  UserProfile copyWith({
    String? id,
    String? username,
    String? profileImageUrl,
    int? followingCount,
    int? followersCount,
    int? likesCount,
  }) {
    return UserProfile(
      id: id ?? this.id,
      username: username ?? this.username,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      followingCount: followingCount ?? this.followingCount,
      followersCount: followersCount ?? this.followersCount,
      likesCount: likesCount ?? this.likesCount,
    );
  }

  @override
  List<Object> get props => [id, username, profileImageUrl, followingCount, followersCount, likesCount];
}