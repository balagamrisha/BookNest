import 'package:flutter/material.dart';

import 'discover.dart';
import 'home.dart';
import 'library.dart';
import 'my_books.dart';
import 'profile.dart';
import 'widgets.dart';

void main() {
  runApp(const BookNestApp());
}

class BookNestApp extends StatefulWidget {
  const BookNestApp({super.key});

  @override
  State<BookNestApp> createState() => _BookNestAppState();
}

class _BookNestAppState extends State<BookNestApp> {
  final library = Library();

  @override
  void initState() {
    super.initState();
    library.load();
  }

  @override
  void dispose() {
    library.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LibraryScope(
      library: library,
      // Rebuild the MaterialApp when the theme preference changes.
      child: ListenableBuilder(
        listenable: library,
        builder: (context, _) => MaterialApp(
          title: 'BookNest',
          debugShowCheckedModeBanner: false,
          theme: buildTheme(Brightness.light),
          darkTheme: buildTheme(Brightness.dark),
          themeMode: library.themeMode,
          home: const AppShell(),
        ),
      ),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _tab = 0;
  bool _warned = false;

  void _goTo(int index) => setState(() => _tab = index);

  @override
  Widget build(BuildContext context) {
    final lib = context.lib;
    if (lib.saveFailed && !_warned) {
      _warned = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          toast(
            context,
            'Could not save data on this device. Changes will last for this session only.',
          );
        }
      });
    }
    if (!lib.loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      // IndexedStack keeps each tab's scroll position and search results.
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _tab,
          children: [
            HomeScreen(onGoTo: _goTo),
            const DiscoverScreen(),
            MyBooksScreen(onGoTo: _goTo),
            const ProfileScreen(),
          ],
        ),
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _tab,
          onDestinationSelected: _goTo,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.explore_outlined),
              selectedIcon: Icon(Icons.explore),
              label: 'Discover',
            ),
            NavigationDestination(
              icon: Icon(Icons.collections_bookmark_outlined),
              selectedIcon: Icon(Icons.collections_bookmark),
              label: 'My Books',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
