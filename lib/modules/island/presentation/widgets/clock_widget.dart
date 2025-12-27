import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:moore/core/ui/themes/app_colors.dart';
import 'package:moore/l10n/app_localizations.dart';

final _clockProvider = StreamProvider<DateTime>((ref) {
  return Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());
});

class ClockWidget extends ConsumerWidget {
  const ClockWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;
    final formatter = DateFormat(localizations.clockFormatter);
    final textTheme = Theme.of(context).textTheme;
    final state = ref.watch(_clockProvider);

    return state.when(
      data: (date) => Text(
        formatter.format(date),
        style: textTheme.bodyMedium?.copyWith(color: AppColors.white),
      ),
      error: (_, _) => const SizedBox.shrink(),
      loading: () => const SizedBox.shrink(),
    );
  }
}
