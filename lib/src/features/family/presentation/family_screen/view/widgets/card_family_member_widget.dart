import 'package:general/src/core/index.dart';

class CardFamilyMemberWidget extends StatelessWidget {
  final String name;
  final String? type;
  final String image;
  final String frame;
  final int? userId;
  final int? familyId;
  final int? ownerId;
  final int? familyStatus;
  final bool? isShowOptions;
  final bool amIOwner;
  final bool amIAdmin;

  const CardFamilyMemberWidget({
    required this.image,
    required this.name,
    this.type,
    super.key,
    required this.frame,
    this.familyStatus,
    this.isShowOptions = false,
    this.userId,
    this.ownerId,
    this.familyId,
    required this.amIOwner,
    required this.amIAdmin,
  });

  @override
  Widget build(BuildContext context) {
    final bool amITheOwner = (amIOwner);
    final bool amIAnAdmin = (amIAdmin);

    final bool isMyFamily = MyDataModel.getInstance().familyId == familyId;

    return GestureDetector(
      onLongPress: () {
        if (isMyFamily && !amITheOwner) {
          Methods.showCupertinoActionPicker(
              familyId: (familyId ?? 0).toString(),
              userId: (userId ?? 0).toString(),
              context: context,
              familyStatus: familyStatus ?? -1,
              amIAnAdmin: amIAnAdmin,
              amITheOwner: amITheOwner);
        }
      },
      child: Padding(
        padding: context.paddingSymmetric(horizontal: 5),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            SizedBox(
              child: UserImage(
                image: image,
                displayName: name,
                imageSize: 60.w,
                frameSize: 60.w,
                border: Border.all(color: ColorManager.primary, width: 2),
                isAsset: true,
                borderRadius: 50.radius,
              ),
            ),
            if (type != '')
              Positioned(
                bottom: -10,
                child: Container(
                  padding: context.paddingAll(2),
                  decoration: BoxDecoration(
                      color: ColorManager.primary, borderRadius: 4.radius),
                  child: Center(
                    child: TextWidget(
                      type!,
                      style: context.bodySmall.copyWith(
                          color: ColorManager.textPrimary, fontSize: 10),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
