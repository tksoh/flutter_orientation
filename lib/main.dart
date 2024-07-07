import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rotation_check/rotation_check.dart';

enum Orientation {
  portrait,
  landscape,
  free,
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Orientation',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Orientation Control Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  Orientation orientation = Orientation.free;
  final _orientation = ValueNotifier<bool>(false);
  late final AppLifecycleListener _listener;

  @override
  void initState() {
    super.initState();
    updateSystemRotationStatus();
    _listener = AppLifecycleListener(
      onResume: updateSystemRotationStatus,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _listener.dispose();
  }

  void updateSystemRotationStatus() async {
    _orientation.value = await getSystemRotation();
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 30),
            buildOrientationButtons(),
            const SizedBox(height: 30),
            buildSystemRotationStatus(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget buildOrientationButtons() {
    return SegmentedButton<Orientation>(
      segments: const <ButtonSegment<Orientation>>[
        ButtonSegment<Orientation>(
            value: Orientation.landscape,
            label: Text('Landscaoe'),
            icon: Icon(Icons.landscape)),
        ButtonSegment<Orientation>(
            value: Orientation.portrait,
            label: Text('Portrait'),
            icon: Icon(Icons.portrait)),
        ButtonSegment<Orientation>(
            value: Orientation.free,
            label: Text('System'),
            icon: Icon(Icons.screen_rotation_rounded)),
      ],
      selected: <Orientation>{orientation},
      onSelectionChanged: (Set<Orientation> newSelection) {
        setState(() {
          orientation = newSelection.first;
          switch (orientation) {
            case Orientation.free:
              unlockOrientation();
            case Orientation.landscape:
              lockLandscape();
            case Orientation.portrait:
              lockPortrait();
          }
        });
      },
    );
  }

  Widget buildSystemRotationStatus() {
    return ValueListenableBuilder(
      builder: (context, value, child) {
        final st = value ? 'UNLOCKED' : 'LOCKED';
        return Text(
          'System Auto Rotate: $st',
          style: TextStyle(
            color: value ? Colors.green : Colors.red,
          ),
        );
      },
      valueListenable: _orientation,
    );
  }

  Future<bool> getSystemRotation() async {
    final rotationCheck = RotationCheck();
    final isRotationEnabled = await rotationCheck.isRotationLocked();
    return isRotationEnabled ?? false;
  }

  void lockLandscape() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      // DeviceOrientation.portraitUp,
      // DeviceOrientation.portraitDown,
    ]);
  }

  void lockPortrait() {
    SystemChrome.setPreferredOrientations([
      // DeviceOrientation.landscapeRight,
      // DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  void unlockOrientation() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
}
