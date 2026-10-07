import 'dart:io';

import 'package:general/src/core/index.dart';
import 'package:general/src/features/groups/domain/entities/group_enums.dart';

class GroupAvatarPicker extends StatelessWidget {
  final File? avatarFile;
  final String? avatarUrl;
  final VoidCallback onTap;

  const GroupAvatarPicker({
    super.key,
    this.avatarFile,
    this.avatarUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: AlignmentDirectional.bottomEnd,
        children: [
          ClipRRect(
            borderRadius: 50.radius,
            child: avatarFile != null
                ? Image.file(
              avatarFile!,
              width: 100.w,
              height: 100.w,
              fit: BoxFit.cover,
            )
                : UserImage(
              image: (avatarUrl == null || avatarUrl!.isEmpty)
                  ? ''
                  : EndPoints.getImage(avatarUrl!),
              imageSize: 100.w,
            ),
          ),
          Container(
            padding: context.paddingAll(6),
            decoration: BoxDecoration(
              // Brand gradient (was the flat panel-driven primary).
              gradient: ColorManager.brandGradient,
              shape: BoxShape.circle,
              border: Border.all(color: ColorManager.white, width: 2),
            ),
            child: Icon(Icons.camera_alt,
                color: ColorManager.onBrandGradient, size: 16.h),
          ),
        ],
      ),
    );
  }
}

class GroupNameField extends StatelessWidget {
  final TextEditingController controller;

  const GroupNameField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget(
          StringManager.groupName.tr(),
          style: context.bodyMedium.w600
              .colorExt(ColorManager.momentPostTextColor),
        ),
        8.hBox,
        Container(
          decoration: BoxDecoration(
            color: ColorManager.white,
            borderRadius: 12.radius,
            border: Border.all(color: ColorManager.divider),
          ),
          child: TextInputWidget(
            StringManager.groupNameHint,
            controller: controller,
            maxLength: 50,
            // Field background is white, so the text must be dark (textPrimary is
            // white in the dark theme -> invisible).
            textColor: ColorManager.momentPostTextColor,
            hintStyle: context.bodyMedium
                .colorExt(ColorManager.greyTextColor.withValues(alpha: 0.8)),
            cursorColor: ColorManager.brandGradientColors.last,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return StringManager.groupNameRequired.tr();
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
}

class GroupPrivacySelector extends StatelessWidget {
  final GroupPrivacy privacy;
  final ValueChanged<GroupPrivacy> onChanged;

  const GroupPrivacySelector({
    super.key,
    required this.privacy,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _OptionGroup<GroupPrivacy>(
      title: StringManager.groupPrivacy.tr(),
      value: privacy,
      onChanged: onChanged,
      options: {
        GroupPrivacy.public: StringManager.groupPublic.tr(),
        GroupPrivacy.private: StringManager.groupPrivate.tr(),
      },
    );
  }
}

class GroupJoinPolicySelector extends StatelessWidget {
  final GroupJoinPolicy joinPolicy;
  final ValueChanged<GroupJoinPolicy> onChanged;

  const GroupJoinPolicySelector({
    super.key,
    required this.joinPolicy,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _OptionGroup<GroupJoinPolicy>(
      title: StringManager.joinPolicy.tr(),
      value: joinPolicy,
      onChanged: onChanged,
      options: {
        GroupJoinPolicy.open: StringManager.joinOpen.tr(),
        GroupJoinPolicy.approval: StringManager.joinByRequest.tr(),
        GroupJoinPolicy.inviteOnly: StringManager.joinInviteOnly.tr(),
      },
    );
  }
}

class _OptionGroup<T> extends StatelessWidget {
  final String title;
  final T value;
  final Map<T, String> options;
  final ValueChanged<T> onChanged;

  const _OptionGroup({
    required this.title,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget(
          title,
          isTranslate: false,
          style: context.bodyMedium.w600
              .colorExt(ColorManager.momentPostTextColor),
        ),
        8.hBox,
        Wrap(
          spacing: 8.w,
          children: options.entries.map((entry) {
            final selected = entry.key == value;
            return ChoiceChip(
              label: TextWidget(
                entry.value,
                isTranslate: false,
                // The chip background is white, so the unselected label must be a
                // dark color (textPrimary is white in the dark theme -> invisible).
                style: context.bodyMedium.colorExt(
                  selected
                      ? ColorManager.onBrandGradient
                      : ColorManager.momentPostTextColor,
                ),
              ),
              selected: selected,
              showCheckmark: false,
              backgroundColor: ColorManager.white,
              // Brand gradient accent colour (was the flat panel-driven primary).
              selectedColor: ColorManager.brandGradientColors.last,
              shape: RoundedRectangleBorder(
                borderRadius: 20.radius,
                side: const BorderSide(color: ColorManager.divider),
              ),
              onSelected: (_) => onChanged(entry.key),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class GroupSwitchTile extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const GroupSwitchTile({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextWidget(
            title,
            isTranslate: false,
            style: context.bodyMedium.w600
                .colorExt(ColorManager.momentPostTextColor),
          ),
        ),
        Switch.adaptive(
          value: value,
          activeThumbColor: ColorManager.brandGradientColors.last,
          onChanged: onChanged,
        ),
      ],
    );
  }
}