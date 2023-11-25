import 'package:flutter/material.dart';

class ExampleDynamicIslandBrandLogo extends StatelessWidget {
  const ExampleDynamicIslandBrandLogo({
    required this.width,
    required this.height,
    super.key,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: const BoxDecoration(color: Colors.red),
      child: Center(
        child: Text(
          'BRAND LOGO',
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
        ),
      ),
    );
  }
}
