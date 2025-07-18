import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:time_ago_provider/time_ago_provider.dart' as TimeAgo;
import 'package:video_player/video_player.dart';
import 'CommentsScreen.dart';
import 'LikesScreen.dart';
import 'create_post.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  bool isLiked = false;

  // Initialize Firebase Services
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // User data variables
  String? userName = '';
  String? profileUrl = '';
  String? currentUserId = '';

  String formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Just now';
    return TimeAgo.format(timestamp.toDate());
  }

  @override
  void initState() {
    super.initState();
    loadCurrentUser();
  }

/* --------------------------- Like Method --------------------------- */

  void _toggleLike(String postId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final DocumentReference postRef =
        _firestore.collection('posts').doc(postId);
    final CollectionReference likesRef = postRef.collection('likesList');

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final DocumentSnapshot snapshot = await transaction.get(postRef);
      final data = snapshot.data() as Map<String, dynamic>;
      final likesMap =
          data['likes'] is Map ? Map<String, dynamic>.from(data['likes']) : {};

      if (likesMap.containsKey(user.uid)) {
        likesMap.remove(user.uid);
        transaction.delete(likesRef.doc(user.uid));
      } else {
        likesMap[user.uid] = true;

        transaction.set(
          likesRef.doc(user.uid),
          {
            'userId': user.uid,
            'username': userName,
            'profileUrl': profileUrl,
            'timestamp': FieldValue.serverTimestamp(),
          },
        );
      }

      transaction.update(postRef, {
        'likes': likesMap,
        'likesCount': likesMap.length,
      });
    });
  }

/* --------------------------- User Data Loading Method --------------------------- */

  Future<void> loadCurrentUser() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        QuerySnapshot querySnapshot = await _firestore
            .collection('users')
            .where('email', isEqualTo: user.email)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          DocumentSnapshot userDoc = querySnapshot.docs.first;
          setState(() {
            userName = userDoc['username'];
            profileUrl = userDoc['profileUrl'];
            currentUserId = userDoc['uid'];
          });
        }
      } catch (e) {
        return;
      }
    }
  }

/* --------------------------- Main Build Widget --------------------------- */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Feed'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current User Post Input
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.grey[300],
                    backgroundImage:
                        profileUrl != null && profileUrl!.isNotEmpty
                            ? CachedNetworkImageProvider(profileUrl!)
                            : CachedNetworkImageProvider(
                                'https://t4.ftcdn.net/jpg/05/49/98/39/360_F_549983970_bRCkYfk0P6PP5fKbMhZMIb07mCJ6esXL.jpg',
                              ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const CreatePost()),
                        );
                      },
                      child: Container(
                        height: 50.0,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(24.0),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 12.0),
                        child: const Row(
                          children: [
                            Expanded(
                              child: Text(
                                "What's on your mind?",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),

              // Real-Time Posts
              StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('posts')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  final posts = snapshot.data!.docs;
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot post = posts[index];
                      return buildPostCard(post);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /* --------------------------- Post Card Widget --------------------------- */

  Widget buildPostCard(DocumentSnapshot post) {
    final String mediaType = post['mediaType'] ?? 'text';
    final String mediaUrl = post['mediaUrl'] ?? '';
    final String username = post['username'] ?? 'Unknown User';
    final String profileUrl = post['profileUrl'] ?? '';
    final Timestamp? timestamp = post['timestamp'];

    final likesMap =
        post['likes'] is Map ? Map<String, dynamic>.from(post['likes']) : {};
    final isLiked =
        currentUserId != null && likesMap.containsKey(currentUserId);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
        color: Colors.grey[100],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info Header
            Padding(
              padding: const EdgeInsets.only(
                  left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: profileUrl.isNotEmpty
                        ? CachedNetworkImageProvider(profileUrl)
                        : CachedNetworkImageProvider(
                            'https://t4.ftcdn.net/jpg/05/49/98/39/360_F_549983970_bRCkYfk0P6PP5fKbMhZMIb07mCJ6esXL',
                          ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(username,
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      Row(
                        children: [
                          Text('${formatTimestamp(timestamp)} • ',
                              style: TextStyle(color: Colors.grey)),
                          Icon(Icons.public, size: 12, color: Colors.grey),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Media Display
            if (mediaType == 'image' && mediaUrl.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(
                    left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
                child: SizedBox(
                  width: 400,
                  height: 500,
                  child: CachedNetworkImage(
                    imageUrl: mediaUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      period: const Duration(milliseconds: 1500),
                      child: Container(
                        color: Colors.grey[300],
                      ),
                    ),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error_outline),
                  ),
                ),
              )
            else if (mediaType == 'video' && mediaUrl.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(
                    left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
                child: SizedBox(
                    width: 400,
                    height: 500,
                    child: VideoPlayerItem(videoUrl: mediaUrl)),
              ),

            // Text Content
            if (post['textContent'].isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(
                    left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
                child: Text(
                  post['textContent'],
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),

            // Likes/Comments
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      showCommentsBottomSheet(context, post.id, currentUserId,
                          userName, profileUrl);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.mode_comment_rounded,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${post['comments']} comments',
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                          onTap: () {
                            showLikesBottomSheet(context, post.id);
                          },
                          child: Text('${post['likesCount']} likes')),
                      IconButton(
                        onPressed: () {
                          _toggleLike(post.id);
                        },
                        icon: Icon(
                          Icons.favorite,
                          color: isLiked ? Colors.red : Colors.grey,
                          size: 30,
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* --------------------------- Video Player Component with controls --------------------------- */

class VideoPlayerItem extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerItem({required this.videoUrl, super.key});

  @override
  State<VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    try {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
        ..addListener(_videoListener);

      await _controller.initialize();
      setState(() {
        _isInitialized = true;
        _isPlaying = false;
      });
      //_controller.play();
    } catch (e) {
      setState(() => _hasError = true);
    }
  }

  void _videoListener() {
    if (_controller.value.hasError) {
      setState(() => _hasError = true);
    }

    if (_controller.value.position == _controller.value.duration) {
      setState(() {
        _isPlaying = false;
      });
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _togglePlay() {
    setState(() => _isPlaying = !_isPlaying);
    _isPlaying ? _controller.play() : _controller.pause();
  }

  @override
  void dispose() {
    _controller.removeListener(_videoListener);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Video player or error/loading state
          if (_hasError)
            _buildErrorState()
          else if (_isInitialized)
            _buildVideoPlayer()
          else
            _buildLoadingState(),

          // Play/Pause controls
          if (_isInitialized && !_hasError)
            AnimatedOpacity(
              opacity: _isPlaying ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: GestureDetector(
                onTap: _togglePlay,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /* --------------------------- VideoPlayer Widget --------------------------- */

  Widget _buildVideoPlayer() {
    return Stack(
      fit: StackFit.expand,
      children: [
        GestureDetector(
          onTap: _togglePlay,
          child: AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
        ),
        if (_isInitialized && !_hasError)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildProgressBar(),
          ),
      ],
    );
  }

  /* --------------------------- Progress bar in video Widget --------------------------- */

  Widget _buildProgressBar() {
    final Duration duration = _controller.value.duration;
    final Duration position = _controller.value.position;

    return Slider(
      min: 0.0,
      max: duration.inMilliseconds.toDouble(),
      value: position.inMilliseconds.toDouble(),
      onChanged: (double value) {
        // Optional: Allow seeking
        _controller.seekTo(Duration(milliseconds: value.toInt()));
      },
      activeColor: Colors.red,
      inactiveColor: Colors.white,
    );
  }

  /* ---------------------------Loading State Widget --------------------------- */

  Widget _buildLoadingState() {
    return const SizedBox(
      height: 200,
      child: Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }

  /* --------------------------- Error Widget --------------------------- */

  Widget _buildErrorState() {
    return SizedBox(
      height: 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.white, size: 40),
          const SizedBox(height: 10),
          const Text('Failed to load video',
              style: TextStyle(color: Colors.white)),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _hasError = false;
                _isInitialized = false;
              });
              _initializeVideoPlayer();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
