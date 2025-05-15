import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class GroupChatScreen extends StatefulWidget {
  final String groupId;
  final String groupName;

  const GroupChatScreen({super.key, required this.groupId, required this.groupName});

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}
class _GroupChatScreenState extends State<GroupChatScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _markAsRead();
  }


  Future<Map<String, dynamic>> getCurrentUserDetails() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) return {};
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: currentUser.email)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.data() as Map<String, dynamic>;
      }
    } catch (e) {}
    return {};
  }

  void sendMessage() async {
    String messageText = _textController.text.trim();
    if (messageText.isEmpty) return;

    await _sendMessage(messageText, 'text');
    _textController.clear();
  }

  Future<void> _sendMessage(String content, String type) async {
    final currentUser = _auth.currentUser!;
    final currentUserData = await getCurrentUserDetails();

    try {
      // Send the message to the group
      final groupDocRef = _firestore.collection('groups').doc(widget.groupId);
      final messageRef = await groupDocRef
          .collection('messages')
          .add({
        'senderId': currentUser.uid,
        'senderName': currentUserData['username'] ?? 'User',
        'senderProfile': currentUserData['profileUrl'] ?? '',
        'content': content,
        'type': type,
        'timestamp': FieldValue.serverTimestamp(),
      });

      //  Update the group document with last message and timestamp
      await groupDocRef.set({
        'lastMessage': type == 'image' ? 'Sent an image' : content,
        'lastMessageTimestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Step 2: Get the group document to retrieve member emails
      final groupSnapshot = await groupDocRef.get();
      final List<dynamic>? memberEmails = groupSnapshot.get('members');

      if (memberEmails == null || memberEmails.isEmpty) {
        print("No members found in the group.");
        return;
      }

      // Fetch UIDs from the users collection based on emails
      final List<String> userEmails = memberEmails.cast<String>();
      final QuerySnapshot usersSnapshot = await _firestore
          .collection('users')
          .where('email', whereIn: userEmails)
          .get();

      final List<String> memberUids = usersSnapshot.docs
          .map((doc) => doc.get('uid') as String)
          .toList();

      if (memberUids.isEmpty) {
        return;
      }

      // Unread count updates
      final Map<String, dynamic> unreadCountsUpdate = {};

      for (final String memberId in memberUids) {
        if (memberId != currentUser.uid) {
          unreadCountsUpdate['unreadCounts.$memberId'] = FieldValue.increment(1);
        }
      }

      // Update the group document with unread counts
      if (unreadCountsUpdate.isNotEmpty) {
        await groupDocRef.update(unreadCountsUpdate);
      }

      // Scroll to the top
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } catch (e) {}
  }

  void _markAsRead() async {
    await _firestore
        .collection('groups')
        .doc(widget.groupId)
        .update({
      'unreadCounts.${_auth.currentUser!.uid}': 0,
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile == null) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      await _uploadImage(File(pickedFile.path));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send image')),
      );
    } finally {
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    try {
      // Upload to Firebase Storage
      final storagePath = 'group_images/${widget.groupId}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = _storage.ref().child(storagePath);
      await storageRef.putFile(imageFile);
      final downloadURL = await storageRef.getDownloadURL();

      // Send image message
      await _sendMessage(downloadURL, 'image');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(widget.groupName),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('groups')
                  .doc(widget.groupId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Process messages to add date separators
                List<DocumentSnapshot> messages = snapshot.data!.docs.reversed.toList();
                List<dynamic> items = [];
                DateTime? lastDate;

                for (var message in messages) {
                  Timestamp? timestamp = message['timestamp'];
                  DateTime messageTime = timestamp?.toDate() ?? DateTime.now();
                  DateTime dateOnly = DateTime(
                    messageTime.year,
                    messageTime.month,
                    messageTime.day,
                  );

                  if (lastDate == null || dateOnly.difference(lastDate).inDays != 0) {
                    items.add({'type': 'date', 'date': dateOnly});
                    lastDate = dateOnly;
                  }

                  items.add({'type': 'message', 'data': message});
                }

                return ListView.builder(
                  reverse: false,
                  controller: _scrollController,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];

                    if (item['type'] == 'date') {
                      return DateBubble(date: item['date']);
                    }

                    var message = item['data'] as DocumentSnapshot;
                    bool isMe = message['senderId'] == _auth.currentUser!.uid;
                    Timestamp? ts = message['timestamp'];
                    DateTime messageTime = ts?.toDate() ?? DateTime.now();



                    return GroupMessageBubble(
                      message: message['content'],
                      isMe: isMe,
                      senderName: message['senderName'],
                      profileUrl: message['senderProfile'],
                      timestamp: messageTime,
                      type: message['type'],
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    elevation: 2.0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _textController,
                            decoration: InputDecoration(
                              prefixIcon: IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.emoji_emotions, color: Colors.indigoAccent),
                              ),
                              hintText: "Type something...",
                              hintStyle: const TextStyle(color: Colors.indigoAccent),
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _pickImage(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt, color: Colors.indigoAccent),
                        ),
                        IconButton(
                          onPressed: () => _pickImage(ImageSource.gallery),
                          icon: const Icon(Icons.image, color: Colors.indigoAccent),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Material(
                  elevation: 0,
                  shape: const CircleBorder(),
                  color: Colors.indigoAccent,
                  child: InkWell(
                    onTap: sendMessage,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 45,
                      height: 45,
                      alignment: Alignment.center,
                      child: const Icon(Icons.send, size: 30, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GroupMessageBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final String senderName;
  final String profileUrl;
  final DateTime timestamp;
  final String type;

  const GroupMessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.senderName,
    required this.profileUrl,
    required this.timestamp,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isMe)
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(profileUrl),
                  radius: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  senderName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isMe ? Colors.indigoAccent : Colors.pinkAccent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (type == 'text')
                  Text(
                    message,
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.white,
                    ),
                  ),
                if (type == 'image')
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CachedNetworkImage(
                      imageUrl: message,
                      placeholder: (context, url) => SizedBox(
                          height: 200,
                          child: Center(
                              child: const CircularProgressIndicator())
                      ),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                      height: 200,
                      width: MediaQuery.of(context).size.width * 0.6,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('h:mm a').format(timestamp),
                  style: TextStyle(
                    fontSize: 12,
                    color: isMe ? Colors.white70 : Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DateBubble extends StatelessWidget {
  final DateTime date;

  const DateBubble({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    String formattedDate;
    final now = DateTime.now();

    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      formattedDate = 'Today';
    } else if (date.year == now.year && date.month == now.month && date.day == now.day - 1) {
      formattedDate = 'Yesterday';
    } else {
      formattedDate = DateFormat('MMMM d, y').format(date);
    }

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          formattedDate,
          style: TextStyle(color: Colors.grey.shade800),
        ),
      ),
    );
  }
}