import 'package:flutter/material.dart';
import 'package:watashi/src/shared/constants/app_colors.dart';
import 'package:watashi/src/shared/constants/app_text_styles.dart';

class RadioOption<T> extends StatelessWidget {
  final String title;
  final String? subtitle;
  final T groupValue;
  final T value;
  final void Function(T?)? onChanged;
  final bool enabled;

  const RadioOption({
    super.key,
    required this.title,
    this.subtitle,
    required this.groupValue,
    required this.value,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final opacity = enabled ? 1.0 : 0.5;

    return Opacity(
      opacity: opacity,
      child: RadioListTile(
        contentPadding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        value: value,
        groupValue: groupValue,
        onChanged: enabled ? onChanged : null,
        title: Text.rich(
          TextSpan(
            text: title,
            style: AppTextStyles.radioOptionTitle.copyWith(
              color: isDarkMode
                  ? AppColors.darkTextPrimary
                  : AppColors.textPrimary,
            ),
            children: [
              if (subtitle != null)
                TextSpan(
                  text: " $subtitle",
                  style: AppTextStyles.radioOptionSubtitle.copyWith(
                    color: isDarkMode
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
            ],
          ),
        ),
        activeColor: AppColors.accent,
      ),
    );
  }
}
