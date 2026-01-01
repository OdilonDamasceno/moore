import 'package:flutter/material.dart';
import 'package:moore/core/ui/themes/app_colors.dart';

class ToggleFilledButton extends StatelessWidget {
  final Widget icon;
  final Widget label;
  final Widget? subtitle;
  final void Function(bool) onPressed;
  final bool enabled;

  const ToggleFilledButton({
    super.key,
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onPressed,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return MaterialButton(
      padding: const .all(12),
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: AppColors.grey[800]!,
          width: 0.1,
        ),
        borderRadius: BorderRadius.circular(
          enabled ? 12.0 : 20,
        ),
      ),
      color: AppColors.black10,
      child: Row(
        crossAxisAlignment: .stretch,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: enabled ? AppColors.primary : AppColors.grey[900],
              borderRadius: enabled
                  ? BorderRadius.circular(
                      10.0,
                    )
                  : null,
              shape: enabled ? BoxShape.rectangle : BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: icon,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              mainAxisAlignment: .center,
              children: [
                DefaultTextStyle(
                  style: textTheme.bodyMedium!.copyWith(
                    color: AppColors.white,
                    fontSize: 12,
                  ),
                  overflow: .ellipsis,
                  child: label,
                ),
                if (subtitle != null)
                  DefaultTextStyle(
                    style: textTheme.bodySmall!.copyWith(
                      color: theme.disabledColor,
                      fontSize: 8,
                    ),
                    overflow: .ellipsis,
                    child: subtitle!,
                  ),
              ],
            ),
          ),
        ],
      ),
      onPressed: () {},
    );
  }
}
