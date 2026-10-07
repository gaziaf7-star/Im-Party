part of '../coin_seller_screen.dart';

class CoinSellerHistoryItem extends StatelessWidget {
  const CoinSellerHistoryItem({
    super.key,
    required this.item,
  });

  final CoinSellerHistoryItemModel item;

  String _formatCoins(dynamic rawAmount) {
    final value = rawAmount is num
        ? rawAmount
        : num.tryParse(rawAmount?.toString() ?? '') ?? 0;

    if (value % 1 == 0) {
      return NumberFormat('#,##0').format(value);
    }

    return NumberFormat('#,##0.##').format(value);
  }

  String _timeAgo(String? rawDate) {
    final value = rawDate?.trim() ?? '';

    if (value.isEmpty) return '';

    final parsed = DateTime.tryParse(value);

    if (parsed == null) {
      return value;
    }

    final localDate = parsed.toLocal();
    var difference = DateTime.now().difference(localDate);

    // Protect the UI from tiny device/server clock differences.
    if (difference.isNegative) {
      difference = Duration.zero;
    }

    if (difference.inSeconds < 45) {
      return 'Just now';
    }

    if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes min ago';
    }

    if (difference.inHours < 24) {
      final hours = difference.inHours;
      return hours == 1
          ? '1 hour ago'
          : '$hours hours ago';
    }

    if (difference.inDays == 1) {
      return 'Yesterday';
    }

    if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    }

    return DateFormat(
      'dd MMM yyyy • hh:mm a',
    ).format(localDate);
  }

  @override
  Widget build(BuildContext context) {
    final name = (item.recipientName ?? '').trim();
    final publicId = (item.recipientId ?? '').trim();
    final avatar = (item.recipientAvatar ?? '').trim();
    final note = (item.note ?? '').trim();
    final timeAgo = _timeAgo(item.createdAt);
    final coins = _formatCoins(item.amount);

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.fromLTRB(
        12.w,
        12.h,
        12.w,
        12.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: _coinSellerBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile image with the same purple/cyan Coin Seller style.
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _coinSellerGradient,
              ),
            ),
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: UserImage(
                image: EndPoints.getImage(avatar),
                displayName: name,
                boxFit: BoxFit.cover,
                borderRadius: 50.radius,
                imageSize: 48.r,
              ),
            ),
          ),

          11.wBox,

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextWidget(
                        name.isEmpty ? 'User' : name,
                        isTranslate: false,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.bodyMedium
                            .size(14)
                            .bold
                            .colorExt(
                          Colors.black,
                        ),
                      ),
                    ),

                    if (timeAgo.isNotEmpty) ...[
                      8.wBox,
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 7.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F1F7),
                          borderRadius:
                          BorderRadius.circular(10.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              size: 11.h,
                              color: _coinSellerSubText,
                            ),
                            4.wBox,
                            TextWidget(
                              timeAgo,
                              isTranslate: false,
                              maxLines: 1,
                              style: context.bodySmall
                                  .size(9.5)
                                  .w600
                                  .colorExt(
                                _coinSellerSubText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),

                5.hBox,

                Row(
                  children: [
                    Icon(
                      Icons.badge_outlined,
                      size: 14.h,
                      color: _coinSellerPurple,
                    ),
                    5.wBox,
                    Expanded(
                      child: TextWidget(
                        publicId.isEmpty
                            ? 'ID: --'
                            : 'ID: $publicId',
                        isTranslate: false,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.bodySmall
                            .size(11.5)
                            .w600
                            .colorExt(
                          const Color(0xFF5E5868),
                        ),
                      ),
                    ),
                  ],
                ),

                if (note.isNotEmpty) ...[
                  6.hBox,
                  TextWidget(
                    note,
                    isTranslate: false,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.bodySmall
                        .size(10.5)
                        .colorExt(
                      _coinSellerSubText,
                    ),
                  ),
                ],

                9.hBox,

                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 7.h,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        _coinSellerPurple.withValues(alpha: 0.10),
                        _coinSellerCyan.withValues(alpha: 0.10),
                      ],
                    ),
                    borderRadius:
                    BorderRadius.circular(13.r),
                    border: Border.all(
                      color: _coinSellerPurple.withValues(
                        alpha: 0.18,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        AssetsManager.coin,
                        height: 17.h,
                        width: 17.h,
                      ),
                      5.wBox,
                      TextWidget(
                        '$coins Coins',
                        isTranslate: false,
                        maxLines: 1,
                        style: context.bodyMedium
                            .size(12.5)
                            .bold
                            .colorExt(
                          _coinSellerPurple,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
