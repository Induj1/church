import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/content_service.dart';
import '../models/content_item.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<ContentItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = ContentService.fetchAll();
  }

  @override
  Widget build(BuildContext context) {
    // MainShell provides the AppBar and Drawer. HomePage should only provide page content
    // so we avoid rendering a second AppBar when embedded inside MainShell.
    return SafeArea(
      child: FutureBuilder<List<ContentItem>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final items = snapshot.data ?? [];
          // group by type for simple sections
          final Map<String, List<ContentItem>> grouped = {};
          for (var it in items) {
            final k = (it.type ?? 'others').toLowerCase();
            grouped.putIfAbsent(k, () => []).add(it);
          }

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero carousel: take first 3 items
                if (items.isNotEmpty) _HeroCarousel(items: items.take(3).toList()),
                SizedBox(height: 12),
                Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('DAILY DEVOTION', style: TextStyle(fontWeight: FontWeight.bold))),
                SizedBox(height: 8),
                _HorizontalList(items: grouped['devotion'] ?? items.take(4).toList()),
                SizedBox(height: 12),
                Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('SERMON HIGHLIGHTS', style: TextStyle(fontWeight: FontWeight.bold))),
                SizedBox(height: 8),
                _HorizontalList(items: grouped['sermon'] ?? items.take(4).toList()),
                SizedBox(height: 12),
                Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('UPCOMING EVENTS', style: TextStyle(fontWeight: FontWeight.bold))),
                SizedBox(height: 8),
                _HorizontalList(items: grouped['event'] ?? items.take(3).toList()),
                SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HeroCarousel extends StatelessWidget {
  final List<ContentItem> items;
  const _HeroCarousel({Key? key, required this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: PageView.builder(
        itemCount: items.length,
        controller: PageController(viewportFraction: 0.92),
        itemBuilder: (context, i) {
          final it = items[i];
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: (it.isImage && (it.thumbnailUrl ?? it.url) != null)
                      ? Image.network(it.thumbnailUrl ?? it.url ?? '', fit: BoxFit.cover)
                      : Container(color: Colors.black26, child: Center(child: Icon(Icons.insert_drive_file, color: Colors.white70, size: 40))),
                ),
                Positioned(right: 12, bottom: 12, child: Icon(Icons.play_circle_fill, size: 44, color: Colors.white70)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HorizontalList extends StatelessWidget {
  final List<ContentItem> items;
  const _HorizontalList({Key? key, required this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 12),
        itemCount: items.length,
        itemBuilder: (context, i) {
          final it = items[i];
          return SizedBox(
            width: 220,
            child: Card(
              color: Colors.black54,
              child: Column(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
                      child: (it.isImage && (it.thumbnailUrl ?? it.url) != null)
                          ? Image.network(it.thumbnailUrl ?? it.url ?? '', fit: BoxFit.cover, width: double.infinity)
                          : Container(color: Colors.black26, child: Center(child: Icon(Icons.insert_drive_file, color: Colors.white70, size: 40))),
                    ),
                  ),
                  ListTile(
                    title: Text(it.title ?? 'Untitled', style: TextStyle(fontSize: 12)),
                    dense: true,
                    trailing: IconButton(
                      icon: Icon(Icons.open_in_new, size: 18),
                      onPressed: () async {
                        final url = it.url ?? it.thumbnailUrl;
                        if (url == null) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No URL available')));
                          return;
                        }
                        final uri = Uri.tryParse(url);
                        if (uri == null) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid URL')));
                          return;
                        }
                        try {
                          if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not open URL')));
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error opening URL: $e')));
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => SizedBox(width: 12),
      ),
    );
  }
}
