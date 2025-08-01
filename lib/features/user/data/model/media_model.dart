import 'package:equatable/equatable.dart';

enum MediaType {
  image,
  video,
}

class MediaItem extends Equatable {
  final String id;
  final String url;
  final String thumbnailUrl;
  final MediaType type;
  final DateTime createdAt;
  final String userId;

  const MediaItem({
    required this.id,
    required this.url,
    required this.thumbnailUrl,
    required this.type,
    required this.createdAt,
    required this.userId,
  });

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    return MediaItem(
      id: json['id'],
      url: json['url'],
      thumbnailUrl: json['thumbnailUrl'],
      type: MediaType.values.firstWhere((e) => e.name == json['type']),
      createdAt: DateTime.parse(json['createdAt']),
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'thumbnailUrl': thumbnailUrl,
      'type': type.name,
      'createdAt': createdAt.toIso8601String(),
      'userId': userId,
    };
  }

  @override
  List<Object> get props => [id, url, thumbnailUrl, type, createdAt, userId];
}
