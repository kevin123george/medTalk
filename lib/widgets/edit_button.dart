
import 'package:flutter/material.dart';

class EditButton extends StatefulWidget {
  const EditButton({super.key});

  @override
  State<EditButton> createState() => _EditButtonState();
}

class _EditButtonState extends State<EditButton> {
  bool state = false;
  late final ColorScheme _colorScheme = Theme.of(context).colorScheme;

  Icon get icon {
    final IconData iconData = state ? Icons.edit : Icons.edit_document;

    return Icon(
      iconData,
      color: Colors.grey,
      size: 20,
    );
  }

  void _toggle() {
    setState(() {
      state = !state;
    });
  }

  double get turns => state ? 1 : 0;

  @override
  Widget build(BuildContext context) {
    return AnimatedRotation(
      turns: turns,
      curve: Curves.decelerate,
      duration: const Duration(milliseconds: 300),
      child: FloatingActionButton(
        elevation: 5,
        shape: const CircleBorder(),
        backgroundColor: _colorScheme.surface,
        onPressed: () => _toggle(),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: icon,
        ),
      ),
    );
  }
}
