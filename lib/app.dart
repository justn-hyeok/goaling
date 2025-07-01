import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'features/goals/screens/home_screen.dart';
import 'features/vision_board/screens/vision_board_screen.dart';

class GoalingApp extends StatelessWidget {
  const GoalingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Goaling',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.notoSansTextTheme(),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const VisionBoardScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: '목표',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library),
            label: '비전보드',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
