import 'package:general/src/core/index.dart';

import '../../../../data/model/top_support.dart';
import 'user_info_support_widget.dart';

class SupportContainerWidget extends StatelessWidget {
  final TopSupportModel? topSupport;
  final bool? isSender;
  final Color? bgColor;

  const SupportContainerWidget({
    required this.topSupport,
    super.key,
    this.bgColor,
    this.isSender,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: context.paddingOnly(
          bottom: 10.h, top: 0,),
      itemBuilder: (context, index) {
        return UserInfoSupportWidget(
          index: index + 4,
          userTopEntity: topSupport?.otherUsers[index],
          isSender: isSender,
        );
      },
      itemCount:topSupport?.otherUsers.length ?? 0,
    );
  }
}
