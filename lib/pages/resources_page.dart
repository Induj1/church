import 'package:flutter/material.dart';

class ResourcesPage extends StatelessWidget {
  const ResourcesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // MainShell provides AppBar and Drawer; the page returns its content only.
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('RESOURCES', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: 6,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) => _resourceTile('Resource ${i + 1}', 'A short description for resource ${i + 1}.'),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _resourceTile(String title, String subtitle) {
    return Card(
      color: Colors.black54,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white70)),
        trailing: const Icon(Icons.open_in_new, color: Colors.white70),
      ),
    );
  }
}
