import 'package:flutter/material.dart';

class ChangeLogModal extends StatelessWidget {
  final String version;
  final List<String> majorUpdates;
  final List<String> bugFixes;

  const ChangeLogModal({
    Key? key,
    required this.version,
    required this.majorUpdates,
    required this.bugFixes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Version: $version'),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Major Update:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...majorUpdates.map((update) => ListTile(
                  leading: const Icon(Icons.check, color: Colors.green),
                  title: Text(update),
                )),
            const SizedBox(height: 16),
            const Text(
              'Bug Fixes:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...bugFixes.map((bug) => ListTile(
                  leading: const Icon(Icons.bug_report, color: Colors.red),
                  title: Text(bug),
                )),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
