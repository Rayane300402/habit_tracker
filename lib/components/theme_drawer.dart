import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/themeProvider.dart';

class ThemeDrawer extends StatelessWidget {
  const ThemeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Center(
        child: CupertinoSwitch(
          value: Provider.of<ThemeProvider>(context).isDarkMode,
          onChanged: (value) => Provider.of<ThemeProvider>(context, listen: false).toggleTheme() ,
        ),
      ),
    );
  }
}
