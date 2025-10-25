import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/content_item.dart';

class ContentTile extends StatelessWidget {
  final ContentItem item;

  const ContentTile({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: SizedBox(
        width: 56,
        height: 56,
        child: (item.thumbnailUrl != null && item.thumbnailUrl!.isNotEmpty && item.isImage)
            ? ClipRRect(borderRadius: BorderRadius.circular(4), child: Image.network(item.thumbnailUrl!, width: 56, height: 56, fit: BoxFit.cover))
            : (item.isImage && item.url != null)
                ? ClipRRect(borderRadius: BorderRadius.circular(4), child: Image.network(item.url!, width: 56, height: 56, fit: BoxFit.cover))
                : const Center(child: Icon(Icons.insert_drive_file, color: Colors.white70)),
      ),
      title: Text(item.title ?? 'Untitled'),
      subtitle: item.description != null ? Text(item.description!) : null,
      trailing: IconButton(
        icon: const Icon(Icons.open_in_new),
        onPressed: () async {
          final url = item.url ?? item.thumbnailUrl;
          if (url == null) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No URL available')));
            return;
          }
          final uri = Uri.tryParse(url);
          if (uri == null) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid URL')));
            return;
          }
          try {
            if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open URL')));
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error opening URL: $e')));
          }
        },
      ),
    );
  }
}
