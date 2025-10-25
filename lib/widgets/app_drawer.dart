import 'package:flutter/material.dart';
import '../pages/content_library_page.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color(0xFF0F0E12), // dark background matching app
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: const [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Color(0xFFD32F2F), // red circle
                      child: Icon(Icons.account_balance, color: Colors.white, size: 20),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'ALL PEOPLES CHURCH',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(color: Colors.white12, height: 1),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    _buildTile(context, Icons.library_books, 'Content Library', onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ContentLibraryPage()));
                    }),
                    _buildTile(context, Icons.location_on, 'Church Locations', onTap: () {
                      Navigator.pop(context);
                      // implement navigation
                    }),
                    _buildTile(context, Icons.book, 'Bible (NET 2016)', onTap: () {
                      Navigator.pop(context);
                    }),
                    _buildTile(context, Icons.live_tv, 'Live Stream', onTap: () {
                      Navigator.pop(context);
                    }),
                    const SizedBox(height: 8),
                    const Divider(color: Colors.white12),
                    _buildTile(context, Icons.settings, 'Settings', onTap: () {
                      Navigator.pop(context);
                    }),
                    _buildTile(context, Icons.info, 'About', onTap: () {
                      Navigator.pop(context);
                    }),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Version: v2-20240326', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    SizedBox(height: 6),
                    Text(' All Peoples Church', style: TextStyle(color: Colors.white38, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTile(BuildContext context, IconData icon, String title, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
      dense: true,
    );
  }
}

