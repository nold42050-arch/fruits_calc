import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/fruit.dart';
import 'screens/billing_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(FruitAdapter());
  await Hive.openBox<Fruit>('fruits');
  runApp(const FruitPriceApp());
}

class FruitPriceApp extends StatelessWidget {
  const FruitPriceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fruit Price Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF2E7D32),
        brightness: Brightness.light,
        textTheme: GoogleFonts.interTextTheme(),
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 1,
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1B5E20),
          titleTextStyle: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1B5E20),
          ),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAF8),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          elevation: 4,
          shape: StadiumBorder(),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    BillingScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _currentIndex == 0
                  ? Icons.point_of_sale_rounded
                  : Icons.settings_rounded,
              size: 24,
            ),
            const SizedBox(width: 10),
            Text(_currentIndex == 0 ? 'Billing' : 'Fruit Inventory'),
          ],
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        elevation: 3,
        backgroundColor: Colors.white,
        indicatorColor: Colors.green.shade100,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.point_of_sale_outlined),
            selectedIcon: Icon(Icons.point_of_sale_rounded),
            label: 'Billing',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
