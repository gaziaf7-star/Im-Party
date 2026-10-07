part of 'package:general/reels_viewer/src/reels_viewer.dart';

class _CountWidget extends StatelessWidget {
  final int? count;
  const _CountWidget({
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.paddingOnly(end: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            Methods.formatCompactNumber(count ?? 0),
            style: context.bodyMedium.colorExt(ColorManager.offWhite),
          ),
        ],
      ),
    );
  }
}
