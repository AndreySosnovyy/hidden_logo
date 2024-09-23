import 'package:example/dynamic_island_logo.dart';
import 'package:example/notch_logo.dart';
import 'package:flutter/cupertino.dart';
import 'package:hidden_logo/hidden_logo.dart';

void main() async {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      title: 'Notch logo example',
      builder: (context, child) {
        return HiddenLogo(
          body: child!,
          notchBuilder: (context, constraints) {
            return ExampleNotchBrandLogo(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
            );
          },
          dynamicIslandBuilder: (context, constraints) {
            return ExampleDynamicIslandBrandLogo(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
            );
          },
        );
      },
      home: const CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(middle: Text('App Bar')),
        child: SizedBox(),
      ),
    );
  }
}
