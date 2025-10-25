import 'package:flutter/material.dart';
import 'home_page.dart';
import '../widgets/app_drawer.dart';
import 'toolkit_page.dart';
import 'resources_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({Key? key}) : super(key: key);

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selected = 0;

  final List<Widget> _pages = [const HomePage(), const ToolkitPage(), const ResourcesPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(children: [
          const CircleAvatar(backgroundColor: Colors.red, child: Icon(Icons.account_balance, color: Colors.white, size: 18)),
          const SizedBox(width: 12),
          const Text('ALL PEOPLES CHURCH', style: TextStyle(fontWeight: FontWeight.bold)),
        ]),
        actions: [Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.menu), onPressed: () => Scaffold.of(ctx).openEndDrawer()))],
      ),
  endDrawer: const AppDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _navButton(0, 'Home'),
                const SizedBox(width: 8),
                _navButton(1, 'Toolkit'),
                const SizedBox(width: 8),
                _navButton(2, 'Resources'),
              ],
            ),
          ),
          Expanded(child: _pages[_selected]),
        ],
      ),
    );
  }

  Widget _navButton(int idx, String label) {
    final selected = _selected == idx;
    return GestureDetector(
      onTap: () => setState(() => _selected = idx),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.red[700] : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? Colors.red[700]! : Colors.white24),
        ),
        child: Text(label, style: TextStyle(color: selected ? Colors.white : Colors.white70, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
