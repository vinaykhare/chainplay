import 'package:flutter/material.dart';

class CatContainerHeader extends StatelessWidget {
  const CatContainerHeader({
    super.key,
    required this.catContainerTitle,
    this.onPressed,
    required this.catContainerIcon,
  });

  final String catContainerTitle;
  final VoidCallback? onPressed;
  final Widget catContainerIcon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(
          width: 30,
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(30),
            ),
          ),
          child: InkWell(
            onTap: onPressed,
            child: catContainerIcon,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: const BorderRadius.horizontal(
              right: Radius.circular(30),
            ),
          ),
          child: SizedBox(
            width: MediaQuery.of(context).size.width - 100,
            child: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                catContainerTitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
