import 'package:flutter/material.dart';

class MyTextIconButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final void Function() onPressed;
  const MyTextIconButton({super.key, required this.icon, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          //textBaseline: TextBaseline.alphabetic,
          children: [
            Icon(icon),
            const SizedBox(width: 5),
            Text(text, style: Theme.of(context).textTheme.displayMedium,),
          ],
        ));
  }
}
