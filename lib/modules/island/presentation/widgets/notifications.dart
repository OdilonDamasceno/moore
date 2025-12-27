import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';

import 'package:moore/core/providers/notifications_manager_provider.dart';
import 'package:moore/core/ui/themes/app_colors.dart';
import 'package:moore/l10n/app_localizations.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class Notifications extends ConsumerWidget {
  const Notifications({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notiticationsHistory = ref.watch(notiticationsHistoryProvider);
    final l10n = AppLocalizations.of(context)!;

    return Material(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const .only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.notificationsTitle,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.grey.shade200,
                      ),
                      textAlign: .start,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      ref.read(notiticationsHistoryProvider.notifier).clearAll();
                    },
                    child: Text(l10n.clearAll),
                  ),
                ],
              ),
            ),
          ),
          if (notiticationsHistory.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(
                  l10n.noNotifications,
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.grey.shade500,
                  ),
                ),
              ),
            )
          else
            SliverList.builder(
              itemCount: notiticationsHistory.length,
              itemBuilder: (context, index) {
                final notification = notiticationsHistory[index];
                final border = RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: AppColors.grey.shade900.withAlpha(150),
                  ),
                );

                final backgroundColor = const Color.fromARGB(255, 15, 15, 15);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ExpansionTile(
                    backgroundColor: backgroundColor,
                    collapsedBackgroundColor: backgroundColor,
                    shape: border,
                    tilePadding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 4.0,
                    ),
                    collapsedShape: border,
                    leading: _buildNotificationIcon(notification.appIcon),
                    title: Text(
                      notification.appName,
                      style: const TextStyle(
                        fontSize: 8,
                        color: Colors.white54,
                      ),
                    ),
                    minTileHeight: 46,
                    subtitle: Text(
                      notification.summary,
                      maxLines: 1,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 10,
                      ),
                    ),
                    childrenPadding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 8.0,
                    ),
                    expandedAlignment: Alignment.centerLeft,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 40),
                        child: Align(
                          alignment: .centerLeft,
                          child: Text(
                            notification.body,
                            style: const TextStyle(
                              fontSize: 8,
                              color: Colors.white70,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: notification.actions.map((action) {
                            if (action.isEmpty) {
                              return const SizedBox.shrink();
                            }

                            if (action == 'default' || action == 'settings') {
                              return const SizedBox.shrink();
                            }

                            return Flexible(
                              child: TextButton(
                                onPressed: () {},
                                child: Text(action),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildNotificationIcon(String? appIcon) {
    const double size = 24;
    if (appIcon == null || appIcon.isEmpty) {
      return Icon(PhosphorIcons.bell(), size: size);
    }

    // If looks like a file path, try loading from filesystem first
    var path = appIcon;
    if (path.startsWith('file://')) {
      path = path.replaceFirst('file://', '');
    }

    try {
      if (path.contains('/') || path.startsWith('.')) {
        final file = File(path);
        if (file.existsSync()) {
          return Image.file(
            file,
            width: size,
            height: size,
            fit: BoxFit.cover,
            alignment: Alignment.center,
            errorBuilder: (_, _, _) => Icon(PhosphorIcons.bell(), size: size),
          );
        }
      }
    } catch (_) {
      // ignore filesystem errors and fallback to asset/icon
    }

    // Try as an asset path (apps might ship small icons as assets)
    return Image.asset(
      appIcon,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => Icon(PhosphorIcons.bell(), size: size),
    );
  }
}
