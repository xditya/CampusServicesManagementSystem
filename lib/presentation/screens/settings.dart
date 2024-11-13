import 'package:flutter/material.dart';
import 'package:csms/presentation/providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  final List<String> _themeValues = ['Follow System', 'Light', 'Dark'];

  List<Map<String, dynamic>> get _themeOptions => [
        {
          'title': 'Follow System',
          'subtitle': 'Matches your device theme',
          'icon': Icons.brightness_auto,
          'value': _themeValues[0]
        },
        {
          'title': 'Light Mode',
          'subtitle': 'Classic bright theme',
          'icon': Icons.light_mode,
          'value': _themeValues[1]
        },
        {
          'title': 'Dark Mode',
          'subtitle': 'Easier on the eyes',
          'icon': Icons.dark_mode,
          'value': _themeValues[2]
        },
      ];

  late String _selectedOption;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final themeProvider = ThemeProvider.of(context);
    _selectedOption = themeProvider?.themeMode == ThemeMode.dark
        ? _themeValues[2] // Dark
        : themeProvider?.themeMode == ThemeMode.light
            ? _themeValues[1] // Light
            : _themeValues[0]; // Follow System
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = ThemeProvider.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Appearance',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Customize your display',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 2),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _themeOptions.length,
              itemBuilder: (context, index) {
                final option = _themeOptions[index];
                final isSelected = _selectedOption == option['value'];

                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 4.0),
                  child: Material(
                    borderRadius: BorderRadius.circular(16),
                    color: isSelected
                        ? colorScheme.primaryContainer
                        : colorScheme.surface,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        ThemeMode newThemeMode;
                        switch (option['value']) {
                          case 'Light':
                            newThemeMode = ThemeMode.light;
                            break;
                          case 'Dark':
                            newThemeMode = ThemeMode.dark;
                            break;
                          case 'Follow System':
                          default:
                            newThemeMode = ThemeMode.system;
                            break;
                        }
                        themeProvider?.updateTheme(newThemeMode);
                        setState(() {
                          _selectedOption = option['value'];
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? colorScheme.primary
                                    : colorScheme.primaryContainer
                                        .withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                option['icon'],
                                color: isSelected
                                    ? colorScheme.onPrimary
                                    : colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    option['title'],
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: isSelected
                                              ? colorScheme.primary
                                              : colorScheme.onSurface,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    option['subtitle'],
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: colorScheme.onSurface
                                              .withOpacity(0.7),
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle,
                                color: colorScheme.primary,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
