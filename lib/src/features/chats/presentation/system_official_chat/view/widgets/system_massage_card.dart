part of '../system_messages_screen.dart';

class SystemMessageCard extends StatelessWidget {
  final String img;
  final String title;
  final String created;
  final int userId;
  final int index;

  const SystemMessageCard({
    super.key,
    required this.created,
    required this.title,
    required this.img,
    required this.index,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: context.paddingSymmetric(horizontal: 15, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                created.split(' ')[0],
                style: context.bodyMedium.w500.colorExt(ColorManager.timeColor),
                overflow: TextOverflow.clip,
              ),
            ],
          ),
          7.0.hBox,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ImageViewWidget(
                url: img,
                width: 45.h,
                height: 45.h,
                shape: BoxShape.circle,
                boxFit: BoxFit.cover,
                fallbackToLogo: true,
              ),
              5.wBox,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    20.hBox,
                    Stack(
                      children: [
                        Container(
                          padding: context
                              .paddingSymmetric(horizontal: 20, vertical: 10)
                              .copyWith(end: 10),
                          decoration: BoxDecoration(
                            color: ColorManager.myColorMessageChat,
                            borderRadius:
                                10.radius.copyWith(topLeft: 0.radiusCircular),
                          ),
                          child: Text(
                            title,
                            style: context.bodyMedium
                                .colorExt(ColorManager.textPrimary),
                            overflow: TextOverflow.clip,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
