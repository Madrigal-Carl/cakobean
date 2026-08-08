import 'package:flutter/material.dart';

import 'package:cakobean/app/theme/app_theme.dart';

/// Fades and slides its [child] in once, on first build. Pass an [index] to
/// stagger siblings — each one waits `index * interval` before starting, so
/// lists "cascade" into view instead of popping in all at once.
///
/// Used for entrance animations on list/grid items and page sections.
/// Items that are built lazily by a scroll view animate the first time they
/// enter the viewport, which reads as a pleasant scroll-reveal.
class StaggerIn extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration interval;

  const StaggerIn({
    super.key,
    required this.child,
    this.index = 0,
    this.interval = const Duration(milliseconds: 45),
  });

  @override
  State<StaggerIn> createState() => _StaggerInState();
}

class _StaggerInState extends State<StaggerIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: AppMotion.base);
    final curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _opacity = curve;
    _offset = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(curve);
    _run();
  }

  Future<void> _run() async {
    final delayMs = widget.interval.inMilliseconds * widget.index;
    if (delayMs > 0) {
      await Future<void>.delayed(Duration(milliseconds: delayMs.clamp(0, 300)));
      if (!mounted) return;
    }
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _offset, child: widget.child),
    );
  }
}
