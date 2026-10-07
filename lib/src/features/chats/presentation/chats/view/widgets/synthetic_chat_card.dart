import 'package:general/src/features/chats/chats.dart';

/// WhatsApp-style row for the synthetic conversations (Technical Support and the
/// app-wide World chat). Visually aligned with [ChatRoomCard] so they blend into
/// the unified "All" list while keeping their own asset avatar.
class SyntheticChatCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String timeLabel;
  final String image;

  /// When true the avatar is wrapped in a colored circle (used for the World
  /// chat group icon, matching the old fixed-row styling).
  final bool circledIcon;
  final VoidCallback onTap;

  const SyntheticChatCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.timeLabel,
    required this.image,
    required this.onTap,
    this.circledIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.paddingSymmetric(horizontal: 5, vertical: 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: 6.radius,
        child: SizedBox(
          height: 70.h,
          child: Row(
            children: [
              if (circledIcon)
                Container(
                  height: 60.h,
                  width: 60.h,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    gradient: ColorManager.brandGradient,
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    image,
                    color: ColorManager.onBrandGradient,
                    height: 32.h,
                    width: 32.h,
                  ),
                )
              else
                Image.asset(
                  image,
                  height: 60.h,
                  width: 60.h,
                ),
              10.wBox,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextWidget(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.bodyLarge
                          .colorExt(ColorManager.momentPostTextColor)
                          .w500,
                    ),
                    5.hBox,
                    TextWidget(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.bodyMedium
                          .colorExt(ColorManager.momentPostTextColor),
                    ),
                  ],
                ),
              ),
              if (timeLabel.isNotEmpty)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextWidget(
                      timeLabel,
                      style: context.bodyMedium
                          .colorExt(ColorManager.momentPostTextColor),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}