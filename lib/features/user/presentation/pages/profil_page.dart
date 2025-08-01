import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:imtihon6/config/service/firebase_service.dart';
import 'package:imtihon6/core/dp/dp_injection.dart';
import '../../../../core/constants/app_status.dart';
import '../../../camera_photo/presentation/widgets/video_player_widget.dart';
import '../../data/model/media_model.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc(firebaseService: getIt<FirebaseService>(), userId: 'jovidon'),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: Icon(Icons.person_add, color: Colors.black),
          title: BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              return Text(
                state.profile?.username ?? 'Loading...',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              );
            },
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh, color: Colors.black),
              onPressed: () {
                context.read<ProfileBloc>().add(ProfileRefresh());
              },
            ),
            Icon(Icons.more_horiz, color: Colors.black),
            SizedBox(width: 16),
          ],
        ),
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state.status == ProfileStatus.loading) {
              return Center(child: CircularProgressIndicator());
            }

            if (state.status == ProfileStatus.error) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${state.errorMessage ?? 'Unknown error'}'),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ProfileBloc>().add(ProfileLoad());
                      },
                      child: Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                SizedBox(height: 20),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.orange, Colors.red],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: state.profile?.profileImageUrl != null &&
                      state.profile!.profileImageUrl.isNotEmpty
                      ? CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(state.profile!.profileImageUrl),
                  )
                      : Center(
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  state.profile?.username ?? '',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 20),

                // Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStat('${state.profile?.followingCount ?? 0}', 'Following'),
                    _buildStat('${state.profile?.followersCount ?? 0}', 'Followers'),
                    _buildStat('${state.profile?.likesCount ?? 0}', 'Likes'),
                  ],
                ),

                SizedBox(height: 20),

                // Buttons
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            context.read<ProfileBloc>().add(ProfileUpdateStats(
                              followersCount: (state.profile?.followersCount ?? 0) + 1,
                            ));
                          },
                          child: Text('Edit profile', style: TextStyle(color: Colors.black)),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey[300]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Container(
                        width: 40,
                        height: 35,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.bookmark_border, size: 20),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 30),

                // Safe GridView version
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Builder(
                      builder: (context) {
                        final mediaItems = state.mediaItems;

                        if (mediaItems == null || mediaItems.isEmpty) {
                          return _buildEmptyState();
                        }

                        return GridView.count(
                          crossAxisCount: 3,
                          crossAxisSpacing: 2,
                          mainAxisSpacing: 2,
                          children: List.generate(mediaItems.length, (index) {
                            try {
                              final mediaItem = mediaItems[index];
                              return GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => MediaPreviewDialog(
                                      url: mediaItem.thumbnailUrl ?? '',
                                      type: mediaItem.type,
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: Image.network(
                                          mediaItem.thumbnailUrl ?? '',
                                          width: double.infinity,
                                          height: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              color: Colors.grey[300],
                                              child: Icon(Icons.image, color: Colors.grey[600]),
                                            );
                                          },
                                        ),
                                      ),
                                      if (mediaItem.type == MediaType.video)
                                        Positioned(
                                          top: 4,
                                          right: 4,
                                          child: Container(
                                            padding: EdgeInsets.all(2),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(0.7),
                                              borderRadius: BorderRadius.circular(2),
                                            ),
                                            child: Icon(
                                              Icons.play_arrow,
                                              color: Colors.white,
                                              size: 12,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            } catch (e) {
                              return Container(
                                color: Colors.red[100],
                                child: Center(
                                  child: Icon(Icons.error, size: 20),
                                ),
                              );
                            }
                          }),
                        );
                      },
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

  Widget _buildStat(String number, String label) {
    return Column(
      children: [
        Text(
          number,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_library, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No media yet',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          Text(
            'Capture photos and videos to see them here',
            style: TextStyle(color: Colors.grey[400], fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMediaTile(dynamic mediaItem) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          child: Image.network(
            mediaItem.thumbnailUrl ?? '',
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: Colors.grey[300],
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[300],
                child: Icon(Icons.error, color: Colors.grey[600]),
              );
            },
          ),
        ),
        if (mediaItem.type == MediaType.video)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
      ],
    );
  }
}