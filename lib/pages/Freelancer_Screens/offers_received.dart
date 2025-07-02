import 'package:flutter/material.dart';

// This is offers received page that shows all offers that are sent by current user.
class OffersReceived extends StatefulWidget {
  final List<Map<String, dynamic>> offers;

  const OffersReceived({super.key, required this.offers});

  @override
  State<OffersReceived> createState() => _OffersReceivedState();
}

/* --------------------------- Show Offers Details Method --------------------------- */

void _showOfferDetails(BuildContext context, Map<String, dynamic> offer) {
  showDialog(
      context: context,
      builder: (_) {
        return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 10,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: Text(offer['project_name'] ?? 'No Title',
                                style: const TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.w500))),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: Navigator.of(context).pop,
                        ),
                      ],
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.person_outline,
                        color: Colors.indigoAccent,
                      ),
                      title: Text(offer['owner_name'] ?? 'N/A'),
                      subtitle: const Text('Owner'),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.person_outline,
                        color: Colors.indigoAccent,
                      ),
                      title: Text(offer['assigned_to'] ?? 'N/A'),
                      subtitle: const Text('Recipient'),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.attach_money,
                        color: Colors.indigoAccent,
                      ),
                      title: Text('\$${offer['budget']}'),
                      subtitle: const Text('Budget'),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.info_outline,
                        color: Colors.indigoAccent,
                      ),
                      title: Text(offer['project_status'] ??
                          offer['project_status'] ??
                          'N/A'),
                      subtitle: const Text('Status'),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.timer_outlined,
                        color: Colors.indigoAccent,
                      ),
                      title: Text(offer['estimated_time'] ??
                          offer['estimated_time'] ??
                          'N/A'),
                      subtitle: const Text('Estimated Time'),
                    ),
                  ]),
            ));
      });
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
                return GestureDetector(
                  onTap: () {
                    _showOfferDetails(context, offers);
                  },
                  child: Card(
                    margin: const EdgeInsets.all(8),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    color: Colors.grey[100],
                    child: ListTile(
                      leading: Icon(
                        Icons.assignment_outlined,
                        size: 30,
                        color: Colors.indigoAccent,
                      ),
                      title: Text(offers['project_name'] ?? 'Offer'),
                      subtitle: Text('Sender: ${offers['owner_name']}'),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
