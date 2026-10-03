import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

class UpdateService {
  // Replace this URL with your actual GitHub Pages URL to version.json
  final String updateUrl = "https://raw.githubusercontent.com/Yashwant-Rangrej/Montra/main/version.json";
  
  Future<void> checkForUpdates(BuildContext context, {bool showNoUpdateMessage = false}) async {
    try {
      final dio = Dio();
      // Using a small timeout so it doesn't hang forever
      dio.options.connectTimeout = const Duration(seconds: 5);
      
      final response = await dio.get(updateUrl);
      
      if (response.statusCode == 200) {
        // Dio parses JSON automatically
        final data = response.data is String ? null : response.data;
        // In case github raw returns raw string, we might need to parse it, 
        // but raw github usually has text/plain so we can let dio parse it or parse it manually if needed.
        // It's safer to just handle it if it's a map.
        if (data is Map<String, dynamic>) {
          final latestVersion = data['latest_version'] as String?;
          final downloadUrl = data['download_url'] as String?;
          final releaseNotes = data['release_notes'] as String?;
          
          if (latestVersion != null && downloadUrl != null) {
            final packageInfo = await PackageInfo.fromPlatform();
            final currentVersion = packageInfo.version;
            
            if (!context.mounted) return;
            if (_isNewerVersion(latestVersion, currentVersion)) {
              _showUpdateDialog(context, latestVersion, releaseNotes, downloadUrl);
            } else if (showNoUpdateMessage) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('You are on the latest version!')),
              );
            }
          }
        }
      }
    } catch (e) {
      if (showNoUpdateMessage && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to check for updates. Check your connection.')),
        );
      }
    }
  }

  bool _isNewerVersion(String latest, String current) {
    final latestParts = latest.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final currentParts = current.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    
    for (int i = 0; i < latestParts.length && i < currentParts.length; i++) {
      if (latestParts[i] > currentParts[i]) return true;
      if (latestParts[i] < currentParts[i]) return false;
    }
    return latestParts.length > currentParts.length;
  }

  void _showUpdateDialog(BuildContext context, String version, String? notes, String url) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Update Available!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version $version is available.'),
            if (notes != null) ...[
              const SizedBox(height: 16),
              const Text('What\'s new:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(notes),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              final uri = Uri.parse(url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            child: const Text('Download'),
          ),
        ],
      ),
    );
  }
}
