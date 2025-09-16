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
  final TextEditingController _imgUrlController = TextEditingController(text: 'https://upload.wikimedia.org/wikipedia/commons/1/17/Google-flutter-logo.png');
  final TextEditingController _captionController = TextEditingController(text: 'Sample caption');
  String _imageUrl = 'https://upload.wikimedia.org/wikipedia/commons/1/17/Google-flutter-logo.png';
  String _caption = 'Sample caption';

  final TextEditingController _cityController = TextEditingController();
  String? _cityEntered;

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
    final c = _cityController.text.trim().isEmpty ? 'Atlanta' : _cityController.text.trim();
    setState(() => _cityEntered = c);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fetching weather for $c...')));
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
                    if (_cityEntered != null)
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              const Icon(Icons.place_outlined, size: 28),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _cityEntered!,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                ),
                              ),
                              const Text('— ready'),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            color: bg[1],
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _captionController,
                  decoration: const InputDecoration(labelText: 'Caption / Name'),
                  onChanged: (v) => setState(() => _caption = v),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _imgUrlController,
                  decoration: const InputDecoration(labelText: 'Image URL (network)'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _imageUrl = _imgUrlController.text.trim().isEmpty
                              ? _imageUrl
                              : _imgUrlController.text.trim();
                        });
                      },
                      child: const Text('Load Image'),
                    ),
                    const SizedBox(width: 12),
                    Text('Caption: $_caption'),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Center(
                    child: Image.network(
                      _imageUrl,
                      width: 150,
                      height: 150,
                      errorBuilder: (_, __, ___) => const Text('Failed to load image'),
                    ),
                  ),
                ),
              ],
            ),
          ),
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
