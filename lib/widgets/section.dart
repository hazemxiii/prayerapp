import 'package:flutter/material.dart';
import 'package:prayerapp/main.dart';

class Section extends StatelessWidget {
  final List<Widget> content;
  final String title;
  final Widget? icon;
  const Section({
    super.key,
    required this.content,
    required this.title,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Palette.of(context).secColor,
          borderRadius: const BorderRadius.all(Radius.circular(5))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                    color: Palette.of(context).mainColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              icon ?? const SizedBox()
            ],
          ),
          ...content
        ],
      ),
    );
  }
}
