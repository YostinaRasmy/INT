import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    required this.color,
    required this.text,
    this.onTap,
    this.padding = const EdgeInsets.all(8.0),
  });

  final Color color;
  final String text;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(24.0),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 100.0,
            child: Center(
              child: Text(
                text,
                style: const TextStyle(fontSize: 18.0, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
