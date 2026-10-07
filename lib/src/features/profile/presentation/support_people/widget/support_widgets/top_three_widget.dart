import 'package:general/src/core/index.dart';
import 'package:general/src/features/profile/data/model/top.dart';

import 'item_support_body.dart';

class SupportTopThreeWidget extends StatelessWidget {
  final List<Top> usersEntity;

  const SupportTopThreeWidget({
    super.key,
    this.usersEntity = const [],
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 210.h,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: 0,
            child: ItemSupportCardWidget(
              userTopEntity: usersEntity.isNotEmpty ? usersEntity[0] : null,
              frameImage: AssetsManager.topOneFrame,
              isUpper: true,
            ),
          ),
          Positioned(
            top: 65.h,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ItemSupportCardWidget(
                  userTopEntity: usersEntity.length > 1 ? usersEntity[1] : null,
                  frameImage: AssetsManager.topTwoFrame,
                  isUpper: false,
                ),
                ItemSupportCardWidget(
                  userTopEntity: usersEntity.length > 2 ? usersEntity[2] : null,
                  frameImage: AssetsManager.topThreeFrame,
                  isUpper: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
