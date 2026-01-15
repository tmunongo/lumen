import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LumenAboutDialog extends StatelessWidget {
  const LumenAboutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Icon(
                Icons.auto_stories,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Lumen Space',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'v1.0.0',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).hintColor,
                ),
              ),
              const SizedBox(height: 24),

              // Story
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'I created Lumen because, as both a writer and a developer, I know how easily inspiration gets scattered by disorganised ideas. This is a dedicated space to gather all your external resources - whether for a game, a blog post, or an app - and keep your creative process focused.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),

              // Actions
              SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    Text(
                      'The easiest way to support me is to spread the word about Lumen Space. You can also directly support the development of this app by buying me a coffee.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: () =>
                          _launchUrl('https://buymeacoffee.com/ta1da'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(
                          0xFFFFDD00,
                        ), // Coffee yellow
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 24,
                        ),
                      ),
                      icon: const Icon(Icons.coffee),
                      label: const Text(
                        'Buy Me a Coffee',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => showLicensePage(
                      context: context,
                      applicationName: 'Lumen Space',
                      applicationVersion: '1.0.0',
                      applicationIcon: const Icon(Icons.auto_stories),
                    ),
                    child: const Text('View Licenses'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Footer
              Text(
                '© 2026 Lumen Space',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).hintColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
