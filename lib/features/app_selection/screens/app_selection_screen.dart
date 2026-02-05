import 'package:flutter/material.dart';
import '../../../core/services/app_list_service.dart';
import '../../../core/services/native_service.dart';
import '../../../core/models/app_info.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../data/local/storage_service.dart';
import '../widgets/app_item_widget.dart';

/// Screen for selecting apps to lock
/// Apps are automatically locked when selected (no Start/Stop button needed)
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
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeStorage();
    _loadApps();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _initializeStorage() async {
    try {
      _storageService = await StorageService.getInstance();
      await _loadSavedSelections();
    } catch (e) {
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

  /// Save selections and auto-enable/disable lock based on selection
  Future<void> _saveSelections() async {
    try {
      if (_storageService != null) {
        await _storageService!.saveLockedApps(_selectedApps);

        // Auto-enable/disable lock based on whether any apps are selected
        final hasApps = _selectedApps.isNotEmpty;

        // Sync to native layer (accessibility service)
        await NativeService.updateLockedAppsForAccessibility(
            _selectedApps.toList());
        await NativeService.updateLockEnabledForAccessibility(hasApps);

        debugPrint(hasApps
            ? 'App lock enabled with ${_selectedApps.length} apps'
            : 'App lock disabled (no apps selected)');
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
    _saveSelections();
  }

  void _selectAll() {
    setState(() {
      _selectedApps = _filteredApps.map((app) => app.packageName).toSet();
    });
    _saveSelections();
  }

  void _deselectAll() {
    setState(() {
      _selectedApps.clear();
    });
    _saveSelections();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.selectApps),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      body: Column(
        children: [
          // Info banner
          if (_selectedApps.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingMd,
                vertical: AppConstants.spacingSm,
              ),
              color: AppColors.primary.withValues(alpha: 0.1),
              child: Row(
                children: [
                  Icon(
                    Icons.shield_outlined,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppConstants.spacingSm),
                  Expanded(
                    child: Text(
                      'App lock is active for ${_selectedApps.length} app${_selectedApps.length > 1 ? 's' : ''}',
                      style: TextStyle(
                        fontSize: AppFonts.sizeSm,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
}
