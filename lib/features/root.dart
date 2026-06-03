import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RootWidget extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;
  const RootWidget({super.key, required this.navigationShell});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _RootWidgetState();
}
class _RootWidgetState extends ConsumerState<RootWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: Container(),
    );
  }
}