import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:caretime/api_config.dart';
import 'package:caretime/api_client.dart';
import 'package:caretime/app_theme.dart';
import 'package:caretime/strings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _apiUrlController = TextEditingController();
  bool _isLoading = false;
  bool _debugMode = false;
  List<Map<String, dynamic>> _requestLogs = [];

  @override
  void initState() {
    super.initState();
    _loadCurrentApiUrl();
    _loadDebugSettings();
  }

  @override
  void dispose() {
    _apiUrlController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentApiUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final customApiUrl = prefs.getString('custom_api_url');
    _apiUrlController.text = customApiUrl ?? apiBaseUrl;
  }

  Future<void> _loadDebugSettings() async {
    final enabled = await ApiClient.isDebugModeEnabled();
    final logs = await ApiClient.getLogs();
    if (!mounted) return;
    setState(() {
      _debugMode = enabled;
      _requestLogs = logs;
    });
  }

  bool _isValidApiUrl(String url) {
    final trimmed = url.trim();
    final uri = Uri.tryParse(trimmed);
    if (uri == null) return false;
    if (!(uri.scheme == 'http' || uri.scheme == 'https')) return false;
    return uri.host.isNotEmpty;
  }

  List<Uri> _buildTestUris(String url) {
    final base = Uri.parse(url.trim());
    final root = base.replace(path: '/', query: null, fragment: null);
    final candidates = <Uri>[];
    void add(Uri uri) {
      if (!candidates.any((u) => u.toString() == uri.toString())) {
        candidates.add(uri);
      }
    }

    add(base);
    add(root);
    add(root.replace(path: '/health'));
    return candidates;
  }

  Future<bool> _validateAndTestApiUrl() async {
    final url = _apiUrlController.text.trim();
    if (!_isValidApiUrl(url)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.settingsApiInvalidUrl),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }

    int? lastStatus;
    Object? lastError;
    for (final uri in _buildTestUris(url)) {
      try {
        final response =
            await ApiClient.get(uri.toString()).timeout(
              const Duration(seconds: 5),
            );
        if (response.statusCode >= 200 && response.statusCode < 400) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${AppStrings.settingsApiTestOk} ${response.statusCode}',
                ),
                backgroundColor: Colors.green,
              ),
            );
          }
          if (_debugMode) {
            await _refreshLogs();
          }
          return true;
        }
        lastStatus = response.statusCode;
      } catch (e) {
        lastError = e;
      }
    }
    if (mounted) {
      final details =
          lastStatus != null
              ? 'Code: $lastStatus'
              : (lastError?.toString() ?? 'unknown error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppStrings.settingsApiTestFailed}$details'),
          backgroundColor: Colors.red,
        ),
      );
    }
    if (_debugMode) {
      await _refreshLogs();
    }
    return false;
  }

  Future<void> _saveApiUrl() async {
    setState(() => _isLoading = true);

    try {
      final ok = await _validateAndTestApiUrl();
      if (!ok) {
        if (mounted) {
          setState(() => _isLoading = false);
        }
        return;
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('custom_api_url', _apiUrlController.text.trim());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.settingsApiSaved),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppStrings.errorPrefix}$e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _resetToDefault() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('custom_api_url');
      _apiUrlController.text = apiBaseUrl;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.settingsApiReset),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppStrings.errorPrefix}$e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _toggleDebugMode(bool value) async {
    await ApiClient.setDebugModeEnabled(value);
    if (!mounted) return;
    setState(() => _debugMode = value);
    await _refreshLogs();
  }

  Future<void> _refreshLogs() async {
    final logs = await ApiClient.getLogs();
    if (!mounted) return;
    setState(() => _requestLogs = logs);
  }

  Future<void> _clearLogs() async {
    await ApiClient.clearLogs();
    if (!mounted) return;
    setState(() => _requestLogs = []);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(AppStrings.settingsDebugLogsCleared),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final logsToShow =
        _requestLogs.reversed.take(20).toList(growable: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.settingsTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              AppStrings.settingsConfigTitle,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              AppStrings.settingsConfigDescription,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _apiUrlController,
              decoration: const InputDecoration(
                labelText: AppStrings.settingsApiUrlLabel,
                hintText: AppStrings.settingsApiUrlHint,
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 16),
            const Text(
              AppStrings.settingsCurrentDefaultUrl,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                apiBaseUrl,
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveApiUrl,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child:
                        _isLoading
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : const Text(AppStrings.settingsSave),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _resetToDefault,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(AppStrings.settingsReset),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(AppStrings.settingsDebugMode),
              subtitle: const Text(AppStrings.settingsDebugModeDescription),
              value: _debugMode,
              onChanged: _isLoading ? null : _toggleDebugMode,
            ),
            if (_debugMode) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text(
                    AppStrings.settingsDebugLogsTitle,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _requestLogs.isEmpty ? null : _clearLogs,
                    child: const Text(AppStrings.settingsDebugClearLogs),
                  ),
                ],
              ),
              if (logsToShow.isEmpty)
                const Text(
                  AppStrings.settingsDebugLogsEmpty,
                  style: TextStyle(color: AppColors.textSecondary),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: logsToShow.length,
                  separatorBuilder: (_, __) => const Divider(height: 16),
                  itemBuilder: (context, index) {
                    final entry = logsToShow[index];
                    final method = entry['method']?.toString() ?? '-';
                    final url = entry['url']?.toString() ?? '-';
                    final status = entry['status']?.toString() ?? '-';
                    final ts = entry['ts']?.toString() ?? '';
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$method $url',
                          style: const TextStyle(
                            fontSize: 12,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${AppStrings.settingsDebugLogStatus} $status  $ts',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    );
                  },
                ),
            ],
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange, size: 20),
                      SizedBox(width: 8),
                      const Text(
                        AppStrings.settingsInfoTitle,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '- ${AppStrings.settingsInfoLine1}\n'
                    '- ${AppStrings.settingsInfoLine2}\n'
                    '- ${AppStrings.settingsInfoLine3}',
                    style: TextStyle(fontSize: 12, color: Colors.orange[700]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
