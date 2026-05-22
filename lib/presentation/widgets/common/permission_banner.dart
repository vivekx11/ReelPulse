import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/native/tracking_service.dart';

/// Shows a banner if required permissions are missing
class PermissionBanner extends ConsumerStatefulWidget {
  const PermissionBanner({super.key});

  @override
  ConsumerState<PermissionBanner> createState() => _PermissionBannerState();
}

class _PermissionBannerState extends ConsumerState<PermissionBanner> {
  bool _hasAccessibility = true;
  bool _hasUsageStats = true;
  bool _hasOverlay = true;
  bool _checked = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final svc = ref.read(trackingServiceProvider);
    final a = await svc.isAccessibilityEnabled();
    final u = await svc.isUsageStatsPermissionGranted();
    final o = await svc.isOverlayPermissionGranted();
    if (mounted) {
      setState(() {
        _hasAccessibility = a;
        _hasUsageStats = u;
        _hasOverlay = o;
        _checked = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_checked) return const SizedBox.shrink();
    if (_hasAccessibility && _hasUsageStats && _hasOverlay) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.neonOrange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.neonOrange.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: AppTheme.neonOrange, size: 18),
              const SizedBox(width: 8),
              Text(
                'Permissions Required',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.neonOrange,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (!_hasAccessibility)
            _PermissionRow(
              label: 'Accessibility Service',
              onGrant: () async {
                await ref
                    .read(trackingServiceProvider)
                    .openAccessibilitySettings();
                await _check();
              },
            ),
          if (!_hasUsageStats)
            _PermissionRow(
              label: 'Usage Stats',
              onGrant: () async {
                await ref
                    .read(trackingServiceProvider)
                    .openUsageStatsSettings();
                await _check();
              },
            ),
          if (!_hasOverlay)
            _PermissionRow(
              label: 'Display Over Other Apps',
              onGrant: () async {
                await ref
                    .read(trackingServiceProvider)
                    .openOverlaySettings();
                await _check();
              },
            ),
        ],
      ),
    );
  }
}

class _PermissionRow extends StatelessWidget {
  final String label;
  final VoidCallback onGrant;

  const _PermissionRow({required this.label, required this.onGrant});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          const Icon(Icons.close_rounded, color: AppTheme.neonRed, size: 14),
          const SizedBox(width: 6),
          Expanded(
            child: Text(label,
                style: Theme.of(context).textTheme.bodySmall),
          ),
          TextButton(
            onPressed: onGrant,
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.neonOrange,
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Grant', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
