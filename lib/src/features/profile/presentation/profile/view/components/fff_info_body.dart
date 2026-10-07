import 'package:general/src/core/index.dart';

class FFLFInfoBody extends StatelessWidget {
  const FFLFInfoBody({
    super.key,
    required this.onTap,
    required this.count,
    required this.title,
    required this.isMyProfile,
    this.textColor,
    this.countFontSize,
    this.labelFontSize,
  });
  final VoidCallback onTap;
  final bool isMyProfile;
  final String count, title;
  final Color? textColor;

  /// Optional overrides for this row's two text sizes. Null (every existing
  /// caller) keeps the current isTheme1-based defaults below — only Mine's
  /// own stats row passes smaller explicit sizes, to match the reference
  /// image's more compact "1 / 0 / 0 / 0.0" proportions.
  final double? countFontSize;
  final double? labelFontSize;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isMyProfile ? onTap : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          BlocBuilder<FetchUserDataBloc, FetchUserDataState>(
            bloc: di<FetchUserDataBloc>(),
            buildWhen: (prev, curr) =>
            prev.userEntity?.unreadCounterEntity !=
                curr.userEntity?.unreadCounterEntity,
            builder: (context, state) {
              return CounterWidget(
                topPadding: -10.h,
                rightPadding: -17.w,
                padding: 4,
                fontSize: 10.sp,
                isMyProfile: isMyProfile,
                count: title == StringManager.add.tr()
                    ? (state.userEntity?.unreadCounterEntity?.followeds
                    .toString() ??
                    '0')
                    : title == StringManager.followers.tr()
                    ? (state.userEntity?.unreadCounterEntity?.followers
                    .toString() ??
                    '0')
                    : title == StringManager.friends.tr()
                    ? (state.userEntity?.unreadCounterEntity?.friend
                    .toString() ??
                    '0')
                    : (state.userEntity?.unreadCounterEntity?.visitor
                    .toString() ??
                    '0'),
                child: TextWidget(
                  count,
                  style: context.bodyMedium
                      .size(countFontSize ??
                      (ConstantsManager.isTheme1 == true ? 18.0 : 14.0))
                      .w600
                      .colorExt(textColor ?? ColorManager.momentPostTextColor),
                ),
              );
            },
          ),
          TextWidget(
            title,
            style: context.bodyMedium
                .size(labelFontSize ??
                (ConstantsManager.isTheme1 ? 12.0 : 14.0))
                .copyWith(
              fontWeight: ConstantsManager.isTheme1
                  ? FontWeight.w400
                  : FontWeight.w600,
              color: textColor ??
                  ColorManager.momentPostTextColor.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}