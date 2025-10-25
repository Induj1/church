import 'package:flutter/material.dart';

class ToolkitPage extends StatelessWidget {
  const ToolkitPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // MainShell provides AppBar and Drawer; the page returns its content only.
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('TOOLKIT', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              physics: const NeverScrollableScrollPhysics(),
              children: List.generate(8, (i) => _toolTile('Category ${i+1}')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toolTile(String title) {
    return GestureDetector(
      onTap: () {},
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: Colors.black38),
            Center(child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700), textAlign: TextAlign.center)),
          ],
        ),
      ),
    );
  }
}
