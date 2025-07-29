import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:time_ago_provider/time_ago_provider.dart' as TimeAgo;

void showCommentsBottomSheet(BuildContext context, String postId, String? currentUserId, String? userName, String? profileUrl) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return CommentsBottomSheet(
        postId: postId,
        currentUserId: currentUserId,
        userName: userName,
        profileUrl: profileUrl,
      );
    },
  );
}

class CommentsBottomSheet extends StatefulWidget {
  final String postId;
  final String? currentUserId;
  final String? userName;
  final String? profileUrl;

  const CommentsBottomSheet({
    super.key,
    required this.postId,
    this.currentUserId,
    this.userName,
    this.profileUrl,
  });

  @override
  State<CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Just now';
    return TimeAgo.format(timestamp.toDate(), locale: 'en');
  }


  void _addComment(String postId) async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final user = _auth.currentUser;
    if (user == null) return;

    final userSnapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: user.email)
        .get();

    if (userSnapshot.docs.isNotEmpty) {
      final userDoc = userSnapshot.docs.first;
      final username = userDoc['username'];
      final profileUrl = userDoc['profileUrl'];

      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('commentsList')
          .add({
        'userId': user.uid,
        'username': username,
        'profileUrl': profileUrl,
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('posts').doc(postId).update({
        'comments': FieldValue.increment(1),
      });

      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 1.0,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('posts')
                      .doc(widget.postId)
                      .collection('commentsList')
                      .orderBy('timestamp', descending: false)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No comments yet.'));
                    }

                    final comments = snapshot.data!.docs;

                    return ListView.builder(
                      controller: scrollController,
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        final isCurrentUser =
                            widget.currentUserId == comment['userId'];
                        return ListTile(
                          leading: CircleAvatar(
                            //radius: 16,
                            backgroundImage: CachedNetworkImageProvider(
                              comment['profileUrl'],
                            ),
                          ),
                          title: Row(
                            children: [
                              Text(comment['username'],style: const TextStyle(fontWeight: FontWeight.w500),),
                            ],
                          ),
                          subtitle: Text(comment['text']),
                          trailing: Text(formatTimestamp(comment['timestamp']),
                            textAlign: TextAlign.right,
                            style: TextStyle(fontSize: 12,color: Colors.grey),),
                        );
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding:  EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
                    ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[200],
                            border: const OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.all(Radius.circular(24)),
                            ),
                            hintText: 'Add a comment'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Card(
                      elevation: 0,
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      color: Colors.indigoAccent,
                      child: IconButton(
                        icon: const Icon(Icons.send,color: Colors.white,),
                        onPressed: () => _addComment(widget.postId),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}