import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/bottom_dialog.dart';
import 'package:general/src/features/room/room.dart';

class VisitorAvatar extends StatelessWidget {
  final String image;
  final String userId;
  final String name;
  final double size;

  const VisitorAvatar({
    super.key,
    required this.image,
    required this.userId,
    required this.name,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return UserImage(
      key: ValueKey("cached_$userId}"),
      image: image,
      displayName: name,
      imageSize: size,
    );
  }
}

class NumberOfVisitor extends StatelessWidget {
  final MyDataModel myDataModel;
  final String ownerId;
  final List<UTDParticipant> vistors;
  final EnterRoomModel roomData;

  const NumberOfVisitor({
    required this.ownerId,
    required this.vistors,
    required this.myDataModel,
    required this.roomData,
    super.key,
  });

  String _resolveAvatar(UTDParticipant visitor) {
    final attr = visitor.attributes['avatar'];
    if (attr != null && attr.isNotEmpty) return attr;
    // visitor.id is a realtime participant identity and may be empty or
    // non-numeric; int.parse would throw FormatException and crash the header.
    final id = int.tryParse(visitor.id);
    if (id == null) return '';
    return UsersCache().getUser(id)?.image ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final visitorsCount = vistors.length;

    final maxVisitors = ConstantsManager.isVariantBuildA ? 4 : 6;
    final maxBeforeBadge = ConstantsManager.isVariantBuildA ? 3 : 5;

    final displayCount = visitorsCount == maxVisitors
        ? maxVisitors
        : visitorsCount > maxVisitors
            ? maxBeforeBadge
            : visitorsCount;

    final visitorWidgets = List.generate(
      displayCount,
      (index) {
        return Padding(
          padding: context.paddingSymmetric(horizontal: 3.0),
          child: VisitorAvatar(
            image: _resolveAvatar(vistors[index]),
            userId: vistors[index].id,
            name: vistors[index].attributes['name'] ?? '',
            size: visitorsCount == (ConstantsManager.isVariantBuildA ? 4 : 6)
                ? 29.0.h
                : 30.0.h,
          ),
        );
      },
    );

    return InkWell(
      onTap: () {
        bottomDailog(
          context: context,
          widget: VisitorsRoomScreen(
            roomData: roomData,
            vistors: vistors,
          ),
        );
      },
      child: Row(
        children: [
          if (visitorsCount > (ConstantsManager.isVariantBuildA ? 4 : 7))
            Container(
              padding: context.paddingSymmetric(vertical: 5.0, horizontal: 6.0),
              decoration: BoxDecoration(
                color: ColorManager.primary,
                borderRadius: 40.radius,
              ),
              child: Text(
                '+${visitorsCount - (ConstantsManager.isVariantBuildA ? 3 : 6)}',
                style: context.bodySmall.colorExt(ColorManager.white).size(12),
              ),
            ),
          SizedBox(
            height: 27.5.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: visitorWidgets,
            ),
          ),
          if (visitorsCount <= (ConstantsManager.isVariantBuildA ? 4 : 7))
            Text(
              visitorsCount.toString(),
              style: context.bodyLarge.colorExt(ColorManager.white),
            ),
        ],
      ),
    );
  }
}
