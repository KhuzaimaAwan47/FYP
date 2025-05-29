import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// This is offers received page that shows all offers that are sent by current user.
class OffersReceived extends StatefulWidget {
  final List<Map<String, dynamic>> offers;
  const OffersReceived({super.key, required this.offers});

  @override
  State<OffersReceived> createState() => _OffersReceivedState();
}

class _OffersReceivedState extends State<OffersReceived> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Offers Received')),
      body: widget.offers.isEmpty
          ? const Center(child: Text('No offers received.'))
          : ListView.builder(
        itemCount: widget.offers.length,
        itemBuilder: (context, index) {
          final offers = widget.offers[index];
          return Card(
            margin: const EdgeInsets.all(8),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            color: Colors.grey[100],
            child: ListTile(
              leading: Icon(Icons.assignment_outlined,size: 30,color: Colors.indigoAccent,),
              title: Text(offers['project_name'] ?? 'Offer'),
              subtitle: Text('Sender: ${offers['owner_name']}'),
            ),
          );
        },
      ),
    );
  }
}