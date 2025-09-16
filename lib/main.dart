import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.red),
      home: const DefaultTabController(
        length: 3,
        child: _TabsShell(),
      ),
    );
  }
}

class _TabsShell extends StatefulWidget {
  const _TabsShell({super.key});
  @override
  State<_TabsShell> createState() => _TabsShellState();
}

class _TabsShellState extends State<_TabsShell>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(initialIndex: 0, length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabs = const ['Today', 'Tab 2', 'Tab 3'];
    final bg = [
      Colors.blue[50]!,
      Colors.amber[50]!,
      Colors.purple[50]!,
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Info App'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [for (final t in tabs) Tab(text: t)],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Container(color: b
