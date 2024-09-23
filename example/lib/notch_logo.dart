import 'package:flutter/material.dart';

const double _radius = 12.0;
const double _sideMargin = 8.0;
const double _topMargin = 8.0;
const double _bottomMargin = 2.0;

class ExampleNotchBrandLogo extends StatelessWidget {
  const ExampleNotchBrandLogo({
    required this.width,
    required this.height,
    super.key,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width - _sideMargin * 2,
      height: height - _topMargin - _bottomMargin,
      margin: const EdgeInsets.only(top: _topMargin, bottom: _bottomMargin),
      decoration: const BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.all(Radius.circular(_radius)),
      ),
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
