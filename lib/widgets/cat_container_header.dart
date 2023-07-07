import 'package:chain_activities/helpers/constants.dart';
import 'package:flutter/material.dart';

class CatContainerHeader extends StatelessWidget {
  const CatContainerHeader({
    super.key,
    required this.containerTitle,
    this.onPressed,
  });

  final String containerTitle;
  final VoidCallback? onPressed;

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
            child: Image.asset(
              assetMap["logoImage"]!,
              height: 50,
            ),
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
                containerTitle,
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
