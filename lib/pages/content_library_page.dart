import 'package:flutter/material.dart';
import '../models/content_item.dart';
import '../services/content_service.dart';
import '../widgets/content_tile.dart';

class ContentLibraryPage extends StatefulWidget {
  const ContentLibraryPage({Key? key}) : super(key: key);

  @override
  State<ContentLibraryPage> createState() => _ContentLibraryPageState();
}

class _ContentLibraryPageState extends State<ContentLibraryPage> {
  late Future<List<ContentItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = ContentService.fetchAll();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = ContentService.fetchAll();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Content Library')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<ContentItem>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ListView(children: [Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))]);
            }
            if (snapshot.hasError) {
              return ListView(children: [Padding(padding: EdgeInsets.all(24), child: Text('Error: ${snapshot.error}'))]);
            }
            final items = snapshot.data ?? [];
            if (items.isEmpty) {
              return ListView(children: [Padding(padding: EdgeInsets.all(24), child: Text('No content available'))]);
            }
            return ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => Divider(height: 1),
              itemBuilder: (context, i) => ContentTile(item: items[i]),
            );
          },
        ),
      ),
    );
  }
}
