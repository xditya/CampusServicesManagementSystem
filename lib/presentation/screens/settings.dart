import 'package:flutter/material.dart';
import 'package:csms/presentation/providers/theme_provider.dart';
import 'package:csms/helper/config.dart';
import 'package:csms/presentation/router/router.dart';
import 'package:fluro/fluro.dart';

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

  Future<void> _handleLogout(BuildContext context) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      await account.deleteSession(sessionId: 'current');

      if (context.mounted) {
        Navigator.of(context).pop();

        AppRouter.router.navigateTo(
          context,
          '/login',
          transition: TransitionType.fadeIn,
          replace: true,
        );
      }
    } catch (e) {
      if (context.mounted) {
        // Pop the loading dialog
        Navigator.of(context).pop();

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final themeProvider = ThemeProvider.of(context);
    _selectedOption = themeProvider?.themeMode == ThemeMode.dark
        ? _themeValues[2]
        : themeProvider?.themeMode == ThemeMode.light
            ? _themeValues[1]
            : _themeValues[0];
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
            // Appearance Section
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

            // Theme Options
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

            const SizedBox(height: 24),

            // Account Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Account',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Manage your account settings',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                  ),
                ],
              ),
            ),

            // Logout Button
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Material(
                borderRadius: BorderRadius.circular(16),
                color: colorScheme.errorContainer,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _handleLogout(context),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colorScheme.error,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.logout_rounded,
                            color: colorScheme.onError,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Logout',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.error,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Sign out of your account',
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
                        Icon(
                          Icons.chevron_right_rounded,
                          color: colorScheme.error,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
