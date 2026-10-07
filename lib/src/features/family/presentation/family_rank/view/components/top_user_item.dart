import 'package:general/src/core/widgets/show_svga.dart';
import 'package:general/src/features/family/domain/entities/family_rank_entity.dart';

import '../../../../../../core/index.dart';

class TopUserItem extends StatelessWidget {
  final FamilyRankEntity? familyRankEntity;
  final String frameImage;
  final bool isUpper;
final double? imageSize;

  const TopUserItem({
    this.familyRankEntity,
    this.imageSize,
    required this.frameImage,
    this.isUpper = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        GestureDetector(
          onTap: () {
            if (familyRankEntity != null && familyRankEntity!.id != 0) {
              Navigator.pushNamed(context, Routes.familyScreen,
                  arguments: familyRankEntity!.id.toString());
            }
          },
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: [
              UserImage(
                image: '${familyRankEntity?.img}',
                displayName: familyRankEntity?.name ?? '',
                imageSize: isUpper ? 75.h : 65.h,
                uniquId: '${familyRankEntity?.id}',
                frameSize: 110.w,
                isAsset: true,
                boxFit: BoxFit.cover,
              ),
              ShowSVGA(
                svgaAssetPath: frameImage,
                height: isUpper ? 220.h : 180,
                width: isUpper ? 380.w : 200.w,
                fit: BoxFit.fill,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
