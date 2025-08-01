

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:imtihon6/config/service/firebase_service.dart';
import 'package:imtihon6/core/dp/dp_injection.dart';

import '../../../user/data/model/media_model.dart';
import '../../../user/presentation/bloc/profile_bloc.dart';
import '../../../user/presentation/bloc/profile_state.dart';

class YearReviewScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc(firebaseService: getIt<FirebaseService>(), userId: 'jovidon'),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Column(
              children: [
                SizedBox(height: 60),
      
                // Title
                Text(
                  'My 2024',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w300,
                  ),
                ),
      
                SizedBox(height: 5),
      
                Text(
                  'Memories to is a choice',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                  ),
                ),
      
                SizedBox(height: 40),
      
                // Main content
                Expanded(
                  child: BlocBuilder<ProfileBloc, ProfileState>(
                    builder: (context, state) {
                      if (state.mediaItems.isEmpty) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.8,
                              height: 250,
                              decoration: BoxDecoration(
                                color: Colors.grey[800],
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.photo_library,
                                      size: 64,
                                      color: Colors.grey[600],
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'No memories yet',
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      'Create some memories first!',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      }
      
                      // Show latest media item as featured
                      final latestMedia = state.mediaItems.first;
      
                      return Column(
                        children: [
                          // Featured media
                          Container(
                            width: MediaQuery.of(context).size.width * 0.8,
                            height: 250,
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Stack(
                                children: [
                                  Image.network(
                                    latestMedia.thumbnailUrl,
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[800],
                                        child: Center(
                                          child: Icon(
                                            Icons.error,
                                            color: Colors.grey[600],
                                            size: 48,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  if (latestMedia.type == MediaType.video)
                                    Center(
                                      child: Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.black.withOpacity(0.7),
                                        ),
                                        child: Icon(
                                          Icons.play_arrow,
                                          color: Colors.white,
                                          size: 32,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
      
                          SizedBox(height: 20),
      
                          Text(
                            '1/${state.mediaItems.length}',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 16,
                            ),
                          ),
      
                          SizedBox(height: 40),
      
                          // Media grid preview
                          Container(
                            height: 100,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              itemCount: state.mediaItems.length > 5 ? 5 : state.mediaItems.length,
                              itemBuilder: (context, index) {
                                final mediaItem = state.mediaItems[index];
                                return Container(
                                  width: 80,
                                  height: 80,
                                  margin: EdgeInsets.only(right: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Stack(
                                      children: [
                                        Image.network(
                                          mediaItem.thumbnailUrl,
                                          width: double.infinity,
                                          height: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              color: Colors.grey[700],
                                              child: Icon(
                                                Icons.error,
                                                color: Colors.grey[500],
                                                size: 24,
                                              ),
                                            );
                                          },
                                        ),
                                        if (mediaItem.type == MediaType.video)
                                          Positioned(
                                            top: 4,
                                            right: 4,
                                            child: Container(
                                              padding: EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(0.7),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Icon(
                                                Icons.videocam,
                                                color: Colors.white,
                                                size: 12,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
      
                // Select photos button
                Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 50,
                  margin: EdgeInsets.only(bottom: 30),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(25),
                      onTap: () {
                        // Navigate to photo selection or gallery
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Photo selection feature coming soon!'),
                            backgroundColor: Colors.blue,
                          ),
                        );
                      },
                      child: Center(
                        child: Text(
                          'Select photos',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
      
                // Bottom options
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildBottomOption('60s'),
                    _buildBottomOption('15s'),
                    _buildBottomOption('Templates'),
                  ],
                ),
      
                SizedBox(height: 30),
              ],
            ),
      
            // Close button
            Positioned(
              top: 50,
              right: 20,
              child: GestureDetector(
                onTap: () {
                  // You can navigate back or show a dialog
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Close Year Review'),
                      content: Text('Are you sure you want to close the year review?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                           context.pop();
                          },
                          child: Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.5),
                  ),
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomOption(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white,
        fontSize: 12,
      ),
    );
  }
}