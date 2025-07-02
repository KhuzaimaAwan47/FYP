import 'package:flutter/material.dart';

// This page shows number of projects that are bidded by current user.
class NoOfBiddedProjects extends StatefulWidget {
  final List<Map<String, dynamic>> bids;

  const NoOfBiddedProjects({super.key, required this.bids});

  @override
  State<NoOfBiddedProjects> createState() => _NoOfBiddedProjectsState();
}

class _NoOfBiddedProjectsState extends State<NoOfBiddedProjects> {
  /* --------------------------- Show Bids Details Method Method --------------------------- */

  void _showBidDetails(BuildContext context, Map<String, dynamic> bid) {
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 10,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                    child: Text(
                      bid['project_name'] ?? 'No Title',
                      style: const TextStyle(
                          fontSize: 25, fontWeight: FontWeight.w500),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: Navigator.of(context).pop,
                  ),
                ]),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.person_outline,
                    color: Colors.indigoAccent,
                  ),
                  title: Text(bid['owner_name'] ?? 'N/A'),
                  subtitle: const Text('Owner'),
                ),
                if (bid['bid_amount'] != null)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.attach_money,
                      color: Colors.indigoAccent,
                    ),
                    title: Text('\$${bid['bid_amount']}'),
                    subtitle: const Text('Bid Amount'),
                  ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.info_outline,
                    color: Colors.indigoAccent,
                  ),
                  title: Text(bid['status'] ?? bid['status'] ?? 'N/A'),
                  subtitle: const Text('Status'),
                ),
                if (bid['description'] != null) ...[
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      bid['description'],
                      textAlign: TextAlign.justify,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Bidded Projects')),
      body: widget.bids.isEmpty
          ? const Center(child: Text('No bids found.'))
          : ListView.builder(
              itemCount: widget.bids.length,
              itemBuilder: (context, index) {
                final bids = widget.bids[index];
                return GestureDetector(
                  onTap: () {
                    _showBidDetails(context, bids);
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
                      title: Text(bids['project_name'] ?? 'Unknown Project'),
                      subtitle: Text('Status: ${bids['status'] ?? 'Unknown'}'),
                      trailing: Text('\$${bids['bid_amount']}'),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
