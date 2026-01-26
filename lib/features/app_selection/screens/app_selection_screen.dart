import 'package:flutter/material.dart';
import '../../../core/services/app_list_service.dart';
import '../../../core/services/app_monitor_service.dart';
import '../../../core/models/app_info.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../data/local/storage_service.dart';
import '../widgets/app_item_widget.dart';

/// Screen for selecting apps to lock
class AppSelectionScreen extends StatefulWidget {
  const AppSelectionScreen({super.key});

  @override
  State<AppSelectionScreen> createState() => _AppSelectionScreenState();
}

class _AppSelectionScreenState extends State<AppSelectionScreen> {
  final AppListService _appListService = AppListService();
  StorageService? _storageService;
  List<AppInfo> _apps = [];
  List<AppInfo> _filteredApps = [];
  Set<String> _selectedApps = {};
  bool _isLoading = true;
  String _errorMessage = '';
  bool _isLockActive = false;
  final TextEditingController _searchController = TextEditingController();
  AppMonitorService? _monitorService;

  @override
  void initState() {
    super.initState();
    _initializeStorage();
    _initializeMonitor();
    _loadApps();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _initializeMonitor() async {
    try {
      _monitorService = await AppMonitorService.getInstance();
      _isLockActive = _monitorService?.isMonitoring ?? false;
      setState(() {});
    } catch (e) {
      debugPrint('Failed to initialize monitor: $e');
    }
  }

  Future<void> _initializeStorage() async {
    try {
      _storageService = await StorageService.getInstance();
      await _loadSavedSelections();
    } catch (e) {
      // Storage initialization failed, continue without saved selections
      debugPrint('Failed to initialize storage: $e');
    }
  }

  Future<void> _loadSavedSelections() async {
    try {
      if (_storageService != null) {
        final savedApps = await _storageService!.loadLockedApps();
        setState(() {
          _selectedApps = savedApps;
        });
      }
    } catch (e) {
      debugPrint('Failed to load saved selections: $e');
    }
  }

  Future<void> _saveSelections() async {
    try {
      if (_storageService != null) {
        await _storageService!.saveLockedApps(_selectedApps);
        
        // Sync to Accessibility Service if monitoring is active
        if (_monitorService != null && _monitorService!.isMonitoring) {
          await _monitorService!.syncLockedAppsToAccessibility(_selectedApps);
        }
      }
    } catch (e) {
      debugPrint('Failed to save selections: $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadApps() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final apps = await _appListService.getInstalledApps(
        includeSystemApps: false,
      );
      setState(() {
        _apps = apps;
        _filteredApps = apps;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    if (query.isEmpty) {
      setState(() {
        _filteredApps = _apps;
      });
    } else {
      _searchApps(query);
    }
  }

  Future<void> _searchApps(String query) async {
    try {
      final filtered = await _appListService.searchApps(query);
      setState(() {
        _filteredApps = filtered;
      });
    } catch (e) {
      // If search fails, show all apps
      setState(() {
        _filteredApps = _apps;
      });
    }
  }

  void _toggleAppSelection(String packageName) {
    setState(() {
      if (_selectedApps.contains(packageName)) {
        _selectedApps.remove(packageName);
      } else {
        _selectedApps.add(packageName);
      }
    });
    _saveSelections(); // Save after each toggle
  }

  void _selectAll() {
    setState(() {
      _selectedApps = _filteredApps.map((app) => app.packageName).toSet();
    });
    _saveSelections(); // Save after select all
  }

  void _deselectAll() {
    setState(() {
      _selectedApps.clear();
    });
    _saveSelections(); // Save after deselect all
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.selectApps),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        actions: [
          IconButton(
            icon: Icon(_isLockActive ? Icons.lock : Icons.lock_open),
            tooltip: _isLockActive ? AppStrings.appLockActive : AppStrings.appLockInactive,
            onPressed: _toggleAppLock,
          ),
        ],
      ),
      floatingActionButton: _selectedApps.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _toggleAppLock,
              backgroundColor: _isLockActive ? AppColors.error : AppColors.primary,
              icon: Icon(_isLockActive ? Icons.stop : Icons.play_arrow),
              label: Text(_isLockActive ? AppStrings.stopAppLock : AppStrings.startAppLock),
            )
          : null,
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: AppStrings.searchApps,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
              ),
            ),
          ),
          // Selection Actions
          if (_filteredApps.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingMd,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedApps.isEmpty
                        ? AppStrings.noAppsSelected
                        : '${_selectedApps.length} ${AppStrings.appsSelected}',
                    style: TextStyle(
                      fontSize: AppFonts.sizeBase,
                      color: AppColors.textSecondary,
                      fontFamily: AppFonts.primary,
                    ),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: _selectAll,
                        child: Text(AppStrings.selectAll),
                      ),
                      TextButton(
                        onPressed: _deselectAll,
                        child: Text(AppStrings.deselectAll),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          // Content
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: AppConstants.spacingMd),
            Text(
              AppStrings.loadingApps,
              style: TextStyle(
                fontSize: AppFonts.sizeBase,
                color: AppColors.textSecondary,
                fontFamily: AppFonts.primary,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: AppConstants.iconSizeXl,
              color: AppColors.error,
            ),
            const SizedBox(height: AppConstants.spacingMd),
            Text(
              AppStrings.failedToLoadApps,
              style: TextStyle(
                fontSize: AppFonts.sizeBase,
                color: AppColors.textPrimary,
                fontFamily: AppFonts.primary,
              ),
            ),
            const SizedBox(height: AppConstants.spacingSm),
            Text(
              _errorMessage,
              style: TextStyle(
                fontSize: AppFonts.sizeSm,
                color: AppColors.textSecondary,
                fontFamily: AppFonts.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingLg),
            ElevatedButton(
              onPressed: _loadApps,
              child: Text(AppStrings.retry),
            ),
          ],
        ),
      );
    }

    if (_filteredApps.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.apps_outlined,
              size: AppConstants.iconSizeXl,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppConstants.spacingMd),
            Text(
              AppStrings.emptyStateTitle,
              style: TextStyle(
                fontSize: AppFonts.sizeLg,
                color: AppColors.textPrimary,
                fontFamily: AppFonts.primary,
              ),
            ),
            const SizedBox(height: AppConstants.spacingSm),
            Text(
              AppStrings.emptyStateMessage,
              style: TextStyle(
                fontSize: AppFonts.sizeBase,
                color: AppColors.textSecondary,
                fontFamily: AppFonts.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _filteredApps.length,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingMd,
        vertical: AppConstants.spacingSm,
      ),
      itemBuilder: (context, index) {
        final app = _filteredApps[index];
        return AppItemWidget(
          app: app,
          isSelected: _selectedApps.contains(app.packageName),
          onTap: () => _toggleAppSelection(app.packageName),
        );
      },
    );
  }

  Future<void> _toggleAppLock() async {
    if (_monitorService == null) {
      await _initializeMonitor();
    }

    if (_monitorService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to initialize app lock service'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    try {
      if (_isLockActive) {
        await _monitorService!.stopMonitoring();
        setState(() {
          _isLockActive = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('App Lock stopped'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        if (_selectedApps.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please select at least one app to lock'),
              backgroundColor: AppColors.warning,
            ),
          );
          return;
        }

        // Check Accessibility Service permission first
        final hasAccessibilityPermission = await _monitorService!.isAccessibilityServiceEnabled();
        if (!hasAccessibilityPermission) {
          _showAccessibilityPermissionDialog();
          return;
        }

        final started = await _monitorService!.startMonitoring();
        if (started) {
          setState(() {
            _isLockActive = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('App Lock started! Locked apps will be protected.'),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 3),
            ),
          );
        } else {
          // Show detailed error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Permission Required',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Grant "Usage Access" permission in Settings, then restart the app.',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 6),
              action: SnackBarAction(
                label: 'Open Settings',
                textColor: AppColors.textOnPrimary,
                onPressed: () async {
                  await _monitorService?.requestUsageStatsPermission();
                },
              ),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showAccessibilityPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Accessibility Permission Required',
            style: TextStyle(
              fontSize: AppFonts.sizeLg,
              fontWeight: FontWeight.bold,
              fontFamily: AppFonts.primary,
            ),
          ),
          content: Text(
            'To lock apps instantly, please enable Accessibility Service. This allows the app to detect when locked apps are opened.',
            style: TextStyle(
              fontSize: AppFonts.sizeBase,
              fontFamily: AppFonts.primary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontFamily: AppFonts.primary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _monitorService?.requestAccessibilityServicePermission();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please enable "App Lock: Islam360" in Accessibility Settings'),
                    backgroundColor: AppColors.primary,
                    duration: const Duration(seconds: 4),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: Text(
                'Open Settings',
                style: TextStyle(
                  color: AppColors.textOnPrimary,
                  fontFamily: AppFonts.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
