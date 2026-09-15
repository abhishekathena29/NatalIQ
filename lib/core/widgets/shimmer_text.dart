import 'package:flutter/material.dart';

import 'package:natal_iq/core/theme/app_theme.dart';

/// Port of `src/components/ai-elements/shimmer.tsx` — a text label with an
/// infinite linear gradient sweep across it, used for the "Aanya is
/// thinking…" state.
class ShimmerText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration duration;

  const ShimmerText(
    this.text, {
    super.key,
    this.style,
    this.duration = const Duration(seconds: 2),
  });

  @override
  State<ShimmerText> createState() => _ShimmerTextState();
}

class _ShimmerTextState extends State<ShimmerText> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = (widget.style ?? sansFont(color: AppColors.mutedForeground));
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        return ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(-1.0 - t * 2, 0),
              end: Alignment(1.0 - t * 2, 0),
              colors: [
                AppColors.mutedForeground.withValues(alpha: 0.35),
                AppColors.background,
                AppColors.mutedForeground.withValues(alpha: 0.35),
              ],
              stops: const [0.35, 0.5, 0.65],
            ).createShader(bounds);
          },
          child: Text(widget.text, style: style),
        );
      },
    );
  }
}
