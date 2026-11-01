import 'package:general/src/core/index.dart';

/// One card of the profile's gift / entry / medal walls: a soft peach card
/// with the item in the middle, an orange "x87" count tab in the top-right
/// corner and the item's name along the bottom.
class Theme2HonorCard extends StatelessWidget {
  const Theme2HonorCard({
    super.key,
    required this.image,
    this.count = '',
    this.label = '',
    this.leadingIcon,
  });

  /// Item image path (relative or full; .svga plays).
  final String image;

  /// Owned/received count; the tab is hidden when empty or "0".
  final String count;

  /// Name along the bottom; hidden when empty.
  final String label;

  /// Small glyph before the label.
  final IconData? leadingIcon;

  static const _peachTop = Color(0xFFFFF3EC);
  static const _peachBottom = Color(0xFFFFE3D8);
  static const _text = Color(0xFF4A3B36);

  @override
  Widget build(BuildContext context) {
    final url = EndPoints.getImage(image);
    final showCount = count.isNotEmpty && count != '0';
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.r),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_peachTop, _peachBottom],
        ),
        border: Border.all(color: Colors.white, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE8A48A).withValues(alpha: .18),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(10.w, 14.h, 10.w, 4.h),
                  child: Center(
                    child: url.isEmpty
                        ? Icon(Icons.card_giftcard_rounded,
                            color: const Color(0xFFE8A48A), size: 34.sp)
                        : Methods().isSvgaFile(url)
                            ? CacheSvgaWidget(url: url, boxFit: BoxFit.contain)
                            : ImageViewWidget(
                                url: url,
                                boxFit: BoxFit.contain,
                              ),
                  ),
                ),
              ),
              if (label.isNotEmpty)
                Padding(
                  padding: EdgeInsets.fromLTRB(6.w, 0, 6.w, 8.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (leadingIcon != null) ...[
                        Icon(leadingIcon,
                            size: 12.sp, color: const Color(0xFFB07AE0)),
                        3.wBox,
                      ],
                      Flexible(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _text,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          if (showCount)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(7.w, 2.h, 7.w, 3.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(13.r),
                    bottomLeft: Radius.circular(12.r),
                  ),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFFFB347), Color(0xFFFF5A2E)],
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.local_fire_department_rounded,
                        size: 11.sp, color: const Color(0xFFFFF1B8)),
                    1.wBox,
                    Text(
                      'x$count',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w800,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Grid used by every honor wall: 3 cards per row.
SliverGridDelegate theme2HonorGridDelegate() =>
    SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
      crossAxisSpacing: 10.w,
      mainAxisSpacing: 10.h,
      childAspectRatio: 0.82,
    );
