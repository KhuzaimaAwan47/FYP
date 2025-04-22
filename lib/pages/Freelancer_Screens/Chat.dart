import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  late List<bool> isHoverList = [false, false, false, false, false];
  int _currentIndex =
  0; // 0: All, 1: Chat, 2: Group Chat
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Messages'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('users', arrayContains: FirebaseAuth.instance.currentUser!.uid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var chatDoc = snapshot.data!.docs[index];
              var users = List<String>.from(chatDoc['users']);
              var otherUserId = users.firstWhere(
                    (uid) => uid != FirebaseAuth.instance.currentUser!.uid,
              );
              var user1 = chatDoc['user1'] as Map<String, dynamic>? ?? {};
              var user2 = chatDoc['user2'] as Map<String, dynamic>? ?? {};
              var otherUser = user1['uid'] == otherUserId ? user1 : user2;
              var timestamp = chatDoc['timestamp'] != null
                  ? (chatDoc['timestamp'] as Timestamp).toDate()
                  : DateTime.now(); // Fallback to current time if null
              var unreadCount = chatDoc['unreadCounts'][FirebaseAuth.instance.currentUser!.uid] ?? 0;

              return Card(
                elevation: 0,
                color: Colors.grey.shade200,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 30,
                    child: CachedNetworkImage(imageUrl:otherUser['profileUrl'] ?? 'https://via.placeholder.com/150',
                    imageBuilder: (context, imageProvider)=> Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                      placeholder: (context,url)=> const CircularProgressIndicator(),
                      errorWidget: (context,url,error)=> const Icon(Icons.error),
                    ),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(otherUser['name'] ?? 'User'),
                      Text(
                        DateFormat('h:mm a').format(timestamp),
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          chatDoc['lastMessage'] ?? '',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                      if (unreadCount > 0)
                        Badge(
                          backgroundColor: Colors.indigoAccent,
                          label: Text(
                            unreadCount.toString(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MessagePage(
                          freelancerUid: otherUserId,
                          freelancerUsername: otherUser['name'] ?? 'User',
                          profileImageUrl: otherUser['profileUrl'] ?? 'https://via.placeholder.com/150',
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class MessagePage extends StatefulWidget {
  final String freelancerUid;
  final String freelancerUsername;
  final String profileImageUrl;

  const MessagePage({
    super.key,
    required this.freelancerUid,
    required this.freelancerUsername,
    required this.profileImageUrl,
  });

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final String chatId;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    String currentUserId = _auth.currentUser!.uid;
    List<String> userIds = [currentUserId, widget.freelancerUid];
    userIds.sort();
    chatId = userIds.join('_');
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

  void _markAsRead() async {
    await _firestore.collection('chats').doc(chatId).update({
      'unreadCounts.${_auth.currentUser!.uid}': 0,
    });
  }

  void sendMessage() async {
    String messageText = _textController.text.trim();
    if (messageText.isEmpty) return;

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
      'senderId': _auth.currentUser!.uid,
      'content': messageText,
      'type': 'text',
      'timestamp': FieldValue.serverTimestamp(),
    });

    final currentUserData = await getCurrentUserDetails();

    await _firestore.collection('chats').doc(chatId).set({
      'users': [_auth.currentUser!.uid, widget.freelancerUid],
      'lastMessage': messageText,
      'timestamp': FieldValue.serverTimestamp(),
      'user1': {
        'uid': _auth.currentUser!.uid,
        'name': currentUserData['username'] ?? 'User',
        'profileUrl': currentUserData['profileUrl'] ??
            'https://t4.ftcdn.net/jpg/05/49/98/39/360_F_549983970_bRCkYfk0P6PP5fKbMhZMIb07mCJ6esXL.jpg',
      },
      'user2': {
        'uid': widget.freelancerUid,
        'name': widget.freelancerUsername,
        'profileUrl': widget.profileImageUrl,
      },
      'unreadCounts': {
        widget.freelancerUid: FieldValue.increment(1),
      }
    }, SetOptions(merge: true));

    _textController.clear();
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      await _uploadImage(File(pickedFile.path));
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('chat_images/$chatId/${DateTime.now().millisecondsSinceEpoch}.jpg');

      await storageRef.putFile(imageFile);
      final downloadURL = await storageRef.getDownloadURL();

      await _firestore.collection('chats').doc(chatId).collection('messages').add({
        'senderId': _auth.currentUser!.uid,
        'content': downloadURL,
        'type': 'image',
        'timestamp': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('chats').doc(chatId).set({
        'lastMessage': 'Sent an image',
        'timestamp': FieldValue.serverTimestamp(),
        'unreadCounts': {
          widget.freelancerUid: FieldValue.increment(1),
        }
      }, SetOptions(merge: true));

      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send image')),
      );
    } finally {
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(backgroundImage: NetworkImage(widget.profileImageUrl)),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.freelancerUsername, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Text("Hey, I'm using Unity Gig", style: TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .doc(chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                List<DocumentSnapshot> messages = snapshot.data!.docs.reversed.toList();
                List<dynamic> items = [];
                DateTime? lastDate;

                for (var message in messages) {
                  final timestamp = message['timestamp'] as Timestamp?;
                  final messageDate = timestamp?.toDate() ?? DateTime.now();
                  final dateOnly = DateTime(messageDate.year, messageDate.month, messageDate.day);

                  if (lastDate == null || !dateOnly.isAtSameMomentAs(lastDate)) {
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
                    } else {
                      final message = item['data'] as DocumentSnapshot;
                      final isMe = message['senderId'] == _auth.currentUser!.uid;
                      return MessageBubble(
                        message: message['content'],
                        isMe: isMe,
                        timestamp: message['timestamp']?.toDate() ?? DateTime.now(),
                        type: message['type'] ?? 'text',
                      );
                    }
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

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final DateTime timestamp;
  final String type;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.timestamp,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: isMe ? Colors.indigoAccent : Colors.pinkAccent,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  blurRadius: 2,
                )
              ],
            ),
            child: Stack(
              children: [
                if (type == 'image')
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CachedNetworkImage(
                      imageUrl: message,
                      placeholder: (context, url) => SizedBox(
                        height: 200,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                      height: 200,
                      width: MediaQuery.of(context).size.width * 0.7,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(right: 60),
                    child: Text(
                      message,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Text(
                    DateFormat('h:mm a').format(timestamp),
                    style: const TextStyle(fontSize: 10, color: Colors.white),
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