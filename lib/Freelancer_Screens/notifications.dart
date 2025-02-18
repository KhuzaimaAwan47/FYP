import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? userName;
  List<QueryDocumentSnapshot> receivedNotifications = [];
  List<QueryDocumentSnapshot> sentNotifications = [];
  bool isLoadingUser = true;
  bool isLoadingNotifications = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    setState(() => isLoadingUser = true);
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        QuerySnapshot querySnapshot = await _firestore
            .collection('users')
            .where('email', isEqualTo: user.email)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          if (mounted) {
            setState(() {
              userName = querySnapshot.docs.first['username'];
              isLoadingUser = false;
            });
            await _loadAllBids();
          }
        } else {
          if (mounted) setState(() => isLoadingUser = false);
          _showErrorSnackbar('User name not found!');
        }
      } catch (e) {
        if (mounted) setState(() => isLoadingUser = false);
        _showErrorSnackbar('Error loading user: $e');
      }
    }
  }

  Future<void> _loadAllBids() async {
    if (userName == null) return;
    setState(() => isLoadingNotifications = true);
    try {
      await Future.wait([_loadReceivedBids(), _loadSentBids()]);
    } catch (e) {
      _showErrorSnackbar('Error loading bids: $e');
    } finally {
      if (mounted) setState(() => isLoadingNotifications = false);
    }
  }

  Future<void> _loadReceivedBids() async {
    QuerySnapshot snapshot = await _firestore
        .collection('notifications')
        .where('owner_name', isEqualTo: userName)
        .orderBy('created_at', descending: true)
        .get();
    if (mounted) setState(() => receivedNotifications = snapshot.docs);
  }

  Future<void> _loadSentBids() async {
    QuerySnapshot snapshot = await _firestore
        .collection('notifications')
        .where('bidder_name', isEqualTo: userName)
        .orderBy('created_at', descending: true)
        .get();
    if (mounted) setState(() => sentNotifications = snapshot.docs);
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // Future<void> _updateNotificationStatus(String notificationId, String status) async {
  //   try {
  //     await _firestore.collection('notifications').doc(notificationId).update({
  //       'status': status,
  //     });
  //     if (mounted) {
  //       _showSuccessSnackbar('Bid is $status');
  //       Navigator.of(context).pop();
  //       await _loadAllBids();
  //     }
  //   } catch (e) {
  //     _showErrorSnackbar('Error updating bid: $e');
  //   }
  // }


  Future<void> _updateNotificationStatus(String notificationId, String status) async {
    try {
      // Update the notification status
      await _firestore.collection('notifications').doc(notificationId).update({
        'status': status,
      });

      // If the bid is accepted, update the project's assigned_to field
      if (status == 'Accepted') {
        // Fetch the notification data
        DocumentSnapshot notificationSnapshot = await _firestore
            .collection('notifications')
            .doc(notificationId)
            .get();

        if (notificationSnapshot.exists) {
          String projectId = notificationSnapshot['project_id'];
          String bidderName = notificationSnapshot['bidder_name'];

          // Update the project document
          await _firestore
              .collection('projects')
              .doc(projectId)
              .update({'assigned_to': bidderName});
        }
      }

      if (mounted) {
        _showSuccessSnackbar('Bid is $status');
        Navigator.of(context).pop();
        await _loadAllBids();
      }
    } catch (e) {
      _showErrorSnackbar('Error updating bid: $e');
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 30, left: 16, right: 16),
      ),
    );
  }

  void _showNotificationPopup(BuildContext context, QueryDocumentSnapshot notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bid Details'),
        content: RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.black45),
            children: [
              TextSpan(
                text: '"${notification['project_name'] ?? 'Unknown Project'}"',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
              ),
              const TextSpan(text: '\n\nBidder: '),
              TextSpan(
                text: '${notification['bidder_name']}',
                style: const TextStyle(fontWeight:FontWeight.bold, color: Colors.blue),
              ),
              const TextSpan(text: '\nBid Amount: '),
              TextSpan(
                text: '\$${notification['bid_amount']}',
                style: const TextStyle(color: Colors.green),
              ),
              const TextSpan(text: '\nEstimated Time: '),
              TextSpan(
                text: '${notification['estimated_time']}',
                style: const TextStyle(color: Colors.orange),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Message', style: TextStyle(color: Colors.indigoAccent)),
          ),
          TextButton(
            onPressed: () => _updateNotificationStatus(notification.id, 'Rejected'),
            child: const Text('Reject', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => _updateNotificationStatus(notification.id, 'Accepted'),
            child: const Text('Accept', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.indigo,
        ),
      ),
    );
  }

  Widget _buildNotificationItem(QueryDocumentSnapshot notification, bool isReceived) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Card(
        elevation: 2,
        child: ListTile(
          title: Text(
            notification['project_name'] ?? 'Unknown Project',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                'Bid Amount: \$${notification['bid_amount']}',
                style: TextStyle(color: Colors.grey[700]),
              ),
              Text(
                'Estimated Time: ${notification['estimated_time']}',
                style: TextStyle(color: Colors.grey[700]),
              ),
            ],
          ),
          trailing: Text(
            notification['status'] ?? 'Pending',
            style: TextStyle(
              color: _getStatusColor(notification['status']),
              fontWeight: FontWeight.w500,
            ),
          ),
          onTap: isReceived ? () => _showNotificationPopup(context, notification) :
          notification['status'] == 'Accepted' ?() => _showStatusUpdatePopup(context, notification) :
          null,
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Accepted':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }


  void _showStatusUpdatePopup(BuildContext context, QueryDocumentSnapshot notification) async {
    try {
      final projectId = notification['project_id'];
      final projectSnapshot = await _firestore.collection('projects').doc(projectId).get();
      final currentStatus = projectSnapshot['project_status'] ?? 'Not Started';

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Update Project Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Current Status: $currentStatus'),
              //IconButton(onPressed: (){}, icon: Icon(Icons.message_outlined,color: Colors.indigo,)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => _updateProjectStatus(notification, 'Pending'),
              child: const Text('Pending', style: TextStyle(color: Colors.orangeAccent)),
            ),
            TextButton(
              onPressed: () => _updateProjectStatus(notification, 'Ongoing'),
              child: const Text('Ongoing', style: TextStyle(color: Colors.blue)),
            ),
            TextButton(
              onPressed: () => _updateProjectStatus(notification, 'Completed'),
              child: const Text('Completed', style: TextStyle(color: Colors.green)),
            ),
          ],
        ),
      );
    } catch (e) {
      _showErrorSnackbar('Error fetching project status: $e');
    }
  }

  Future<void> _updateProjectStatus(QueryDocumentSnapshot notification, String newStatus) async {
    try {
      final projectId = notification['project_id'];
      await _firestore.collection('projects').doc(projectId).update({
        'project_status': newStatus,
        'last_updated': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.of(context).pop();
        _showSuccessSnackbar('Status updated to $newStatus');
        await _loadAllBids(); // Refresh the list if needed
      }
    } catch (e) {
      _showErrorSnackbar('Error updating status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Bids'),
        centerTitle: true,
      ),
      body: isLoadingUser
          ? const Center(child: CircularProgressIndicator(color: Colors.indigo))
          : isLoadingNotifications
          ? const Center(child: CircularProgressIndicator(color: Colors.indigo))
          : receivedNotifications.isEmpty && sentNotifications.isEmpty
          ? const Center(child: Text('No bids available', style: TextStyle(fontSize: 16)))
          : ListView(
        children: [
          if (receivedNotifications.isNotEmpty) ...[
            _buildSectionHeader('Received Bids'),
            ...receivedNotifications.map((n) => _buildNotificationItem(n, true)),
          ],
          if (sentNotifications.isNotEmpty) ...[
            _buildSectionHeader('Sent Bids'),
            ...sentNotifications.map((n) => _buildNotificationItem(n, false)),
          ],
        ],
      ),
    );
  }
}
