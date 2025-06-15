import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_fyp/utlis/snack_bars.dart';
import 'package:video_player/video_player.dart';

class CreatePost extends StatefulWidget {
  const CreatePost({super.key});

  @override
  State<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {

  final TextEditingController _textController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = false;
  File? postMedia;
  String mediaType = 'text'; // can be 'image' , 'video' , 'text'
  String? userName = '';
  String? profileUrl = '';

  @override
  void initState() {
    super.initState();
    loadCurrentUser();
  }

  Future<void> loadCurrentUser() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      try {
        QuerySnapshot querySnapshot = await _firestore
            .collection('users')
            .where('email', isEqualTo: currentUser.email)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          DocumentSnapshot userDoc = querySnapshot.docs.first;
          setState(() {
            userName = userDoc['username'];
            profileUrl = userDoc['profileUrl'];
          });
        }
      } catch (e) {
       return;
      }
    }
  }

  // Fixed media picking function
  Future<void> pickMedia() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickMedia();

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      String? mimeType = pickedFile.mimeType;
      String detectedType = 'text';

      // Improved media type detection
      if (mimeType != null) {
        if (mimeType.startsWith('image/')) {
          detectedType = 'image';
        } else if (mimeType.startsWith('video/')) {
          detectedType = 'video';
        }
      } else {
        // Fallback to file extension check
        String extension = pickedFile.path.split('.').last.toLowerCase();
        if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension)) {
          detectedType = 'image';
        } else if (['mp4', 'mov', 'avi', 'mkv', 'webm'].contains(extension)) {
          detectedType = 'video';
        }
      }

      setState(() {
        postMedia = file;
        mediaType = detectedType; // Set to detected type, not text
      });
    }
  }

  Future<String?> uploadMedia(File media) async {
    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference reference = FirebaseStorage.instance
          .ref()
          .child("posts/$fileName");
      await reference.putFile(media);
      return await reference.getDownloadURL();
    } catch (e) {
      showErrorSnackbar(context, 'Upload failed: $e');
      return null;
    }
  }

  Future<void> createPost() async {
    if (_textController.text.isEmpty && postMedia == null) {
      showErrorSnackbar(context, 'Cannot post empty content.');
      return;
    }

    setState(() => isLoading = true);

    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) return;

      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: currentUser.email)
          .get();

      if (querySnapshot.docs.isEmpty) return;

      DocumentSnapshot userDoc = querySnapshot.docs.first;
      String? mediaUrl = '';

      if (postMedia != null && mediaType != 'text') {
        mediaUrl = await uploadMedia(postMedia!);
      }

      // Final check: prevent post if both text and media upload failed
      if (_textController.text.isEmpty && (mediaUrl == null || mediaUrl.isEmpty)) {
        showErrorSnackbar(context, 'Failed to upload media and text is empty.');
        return;
      }

      await _firestore.collection('posts').add({
        'userId': userDoc['uid'],
        'username': userDoc['username'],
        'profileUrl': userDoc['profileUrl'],
        'textContent': _textController.text,
        'mediaUrl': mediaUrl ?? '',
        'mediaType': mediaUrl != null && mediaUrl.isNotEmpty ? mediaType : 'text',
        'timestamp': FieldValue.serverTimestamp(),
        'likes': 0,
        'likesCount': 0,
        'comments': 0,
      });

      Navigator.pop(context);
    } catch (e) {
      showErrorSnackbar(context, 'Failed to create post: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Create Post'),
        actions: [
          IconButton(
            onPressed: isLoading ? null : createPost,
            icon: const Icon(Icons.post_add_outlined),
            color: isLoading ? Colors.grey : null,
          )
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: profileUrl != null && profileUrl!.isNotEmpty
                            ? CachedNetworkImageProvider(profileUrl!)
                            : CachedNetworkImageProvider(
                          'https://t4.ftcdn.net/jpg/05/49/98/39/360_F_549983970_bRCkYfk0P6PP5fKbMhZMIb07mCJ6esXL.jpg',
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(userName ?? 'Loading...', style: const TextStyle(fontWeight: FontWeight.w500)),
                          Row(
                            children: [
                              const Icon(Icons.public, size: 12, color: Colors.grey),
                              const SizedBox(width: 4.0),
                              const Text('Public', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  TextField(
                    controller: _textController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[200],
                      hintText: 'What\'s on your mind?',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: pickMedia,
                    child: Container(
                      height: 400,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Stack(
                        children: [
                          // Media preview
                          if (postMedia != null && mediaType == 'image')
                            Image.file(postMedia!, fit: BoxFit.cover)
                          else if (postMedia != null && mediaType == 'video')
                            VideoPlayerItem(postMedia!.path, videoUrl: '',)
                          else
                            const Center(
                              child: Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                            ),

                          // Close button for media
                          if (postMedia != null)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.close, color: Colors.white),
                                  onPressed: () {
                                    setState(() {
                                      postMedia = null;
                                      mediaType = 'text';
                                    });
                                  },
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (isLoading)
          Container(
            color: Colors.black54,
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          )
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isLoading ? null : createPost,
          style: ElevatedButton.styleFrom(
            backgroundColor: isLoading ? Colors.grey : Colors.indigoAccent,
            elevation: 2.0,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text('POST',
              style: TextStyle(color: Colors.white, fontSize: 18)),
        ),
      ),
    );
  }
}

class VideoPlayerItem extends StatefulWidget {
  final String videoPath;
  const VideoPlayerItem(this.videoPath, {super.key, required String videoUrl});

  @override
  State<VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: VideoPlayer(_controller),
    )
        : const Center(child: CircularProgressIndicator());
  }
}