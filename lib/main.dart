import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.red),
      home: const DefaultTabController(
        length: 4,
        child: _TabsNonScrollableDemo(),
      ),
    );
  }
}

class _TabsNonScrollableDemo extends StatefulWidget {
  const _TabsNonScrollableDemo({super.key});

  @override
  State<_TabsNonScrollableDemo> createState() => __TabsNonScrollableDemoState();
}

class __TabsNonScrollableDemoState extends State<_TabsNonScrollableDemo>
    with SingleTickerProviderStateMixin, RestorationMixin {
  late TabController _tabController;
  final RestorableInt tabIndex = RestorableInt(0);

  // Tab 2 (image/caption) controllers from your base
  final TextEditingController _imgUrlController = TextEditingController(
    text: 'https://upload.wikimedia.org/wikipedia/commons/1/17/Google-flutter-logo.png',
  );
  final TextEditingController _captionController = TextEditingController(text: 'Sample caption');
  String _imageUrl = 'https://upload.wikimedia.org/wikipedia/commons/1/17/Google-flutter-logo.png';
  String _caption = 'Sample caption';

  // Today (Tab 1) state
  final TextEditingController _cityController = TextEditingController();
  String? _cityEntered;
  int? _todayTempC;
  String? _todayCond;
  final List<String> _conds = ['Sunny', 'Cloudy', 'Rainy'];

  // 7-day (Tab 2) state
  final List<String> _weekday = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  List<Map<String, dynamic>> _forecast = [];

  @override
  String get restorationId => 'tab_non_scrollable_demo';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(tabIndex, 'tab_index');
    _tabController.index = tabIndex.value;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(initialIndex: 0, length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        tabIndex.value = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    tabIndex.dispose();
    _imgUrlController.dispose();
    _captionController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _onFetchWeather() {
    final r = Random();
    final c = _cityController.text.trim().isEmpty
        ? 'Atlanta'
        : _cityController.text.trim();
    setState(() {
      _cityEntered = c;
      _todayTempC = 15 + r.nextInt(16); // 15–30 °C
      _todayCond = _conds[r.nextInt(_conds.length)];
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Fetched weather for $c')),
    );
  }

  void _gen7DayForecast() {
    final r = Random();
    final now = DateTime.now();
    final city = (_cityEntered ?? _cityController.text.trim()).isEmpty
        ? 'Atlanta'
        : (_cityEntered ?? _cityController.text.trim());
    final List<Map<String, dynamic>> data = [];

    for (int i = 0; i < 7; i++) {
      final d = now.add(Duration(days: i));
      final idx = (d.weekday - 1) % 7;
      data.add({
        'day': _weekday[idx],
        'temp': 15 + r.nextInt(16),        // 15–30
        'cond': _conds[r.nextInt(_conds.length)],
        'city': city,
      });
    }

    setState(() => _forecast = data);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Generated 7-day forecast for $city')),
    );
  }

  IconData _iconFor(String cond) {
    switch (cond) {
      case 'Sunny':
        return Icons.wb_sunny_outlined;
      case 'Cloudy':
        return Icons.cloud_outlined;
      default:
        return Icons.umbrella_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabs = ['Tab 1', 'Tab 2', 'Tab 3', 'Tab 4'];
    final bg = [
      Colors.blue[50]!,
      Colors.green[50]!,
      Colors.amber[50]!,
      Colors.purple[50]!
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Tabs Demo'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: false,
          tabs: [for (final tab in tabs) Tab(text: tab)],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1 — Today (with input + simulated weather)
          Container(
            color: bg[0],
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Weather — Today',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _cityController,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        labelText: 'City',
                        hintText: 'Enter a city (e.g., Atlanta)',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _onFetchWeather(),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _onFetchWeather,
                        child: const Text('Fetch Weather'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_cityEntered != null && _todayTempC != null && _todayCond != null)
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(_iconFor(_todayCond!), size: 36),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_cityEntered!, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 4),
                                    Text('$_todayTempC°C • $_todayCond', style: const TextStyle(fontSize: 16)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // TAB 2 — 7-Day Forecast (button + list)
          Container(
            color: bg[1],
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _gen7DayForecast,
                    child: const Text('Get 7-Day Forecast'),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: _forecast.isEmpty
                      ? const Center(child: Text('No forecast yet'))
                      : ListView.builder(
                          itemCount: _forecast.length,
                          itemBuilder: (context, i) {
                            final f = _forecast[i];
                            return Card(
                              elevation: 1,
                              child: ListTile(
                                leading: Icon(_iconFor(f['cond'] as String)),
                                title: Text('${f['day']} — ${f['city']}'),
                                subtitle: Text('${f['temp']}°C • ${f['cond']}'),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),

          // TAB 3 — same as base
          Container(
            color: bg[2],
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Button pressed in Tab 3 tab!'),
                  ),
                );
              },
              child: const Text('Click me'),
            ),
          ),

          // TAB 4 — same as base (image/caption area preserved on Tab 2)
          Container(
            color: bg[3],
            padding: const EdgeInsets.all(12),
            child: ListView.builder(
              itemCount: 8,
              itemBuilder: (context, i) {
                final n = i + 1;
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(child: Text('$n')),
                    title: Text('Item $n'),
                    subtitle: const Text('Details inside a Card widget'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        height: 64,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              tooltip: 'Tab 1',
              isSelected: _tabController.index == 0,
              onPressed: () => _tabController.animateTo(0),
              icon: const Icon(Icons.text_fields),
            ),
            IconButton(
              tooltip: 'Tab 2',
              isSelected: _tabController.index == 1,
              onPressed: () => _tabController.animateTo(1),
              icon: const Icon(Icons.image),
            ),
            IconButton(
              tooltip: 'Tab 3',
              isSelected: _tabController.index == 2,
              onPressed: () => _tabController.animateTo(2),
              icon: const Icon(Icons.touch_app),
            ),
            IconButton(
              tooltip: 'Tab 4',
              isSelected: _tabController.index == 3,
              onPressed: () => _tabController.animateTo(3),
              icon: const Icon(Icons.list),
            ),
          ],
        ),
      ),
    );
  }
}
