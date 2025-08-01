import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:imtihon6/config/routers/routes.dart';
class MainScaffold extends StatefulWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  final List<String> _routes = [
    Routes.profile,
    Routes.camera,
  ];

  void _onTap(int index) {
    setState(() => _currentIndex = index);
    context.push(_routes[index]);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final location = GoRouterState.of(context).uri.toString();
    final matchedIndex = _routes.indexWhere((r) => location.startsWith(r));
    if (matchedIndex != -1 && matchedIndex != _currentIndex) {
      _currentIndex = matchedIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.profile_circled), label: 'Profil'),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.camera), label: "Camera"),
        ],
      ),
    );
  }
}
