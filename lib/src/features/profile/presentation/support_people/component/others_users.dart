import 'package:general/src/core/index.dart';

import '../../../data/model/top.dart';

class OthersUsers extends StatelessWidget {
  final List<Top> usersData;

  const OthersUsers({required this.usersData, super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: context.paddingSymmetric(horizontal: 15).copyWith(bottom: 15),
        padding: context.paddingSymmetric(horizontal: 10,vertical: 10),
        decoration:  BoxDecoration(
          color: ColorManager.transparent,
          borderRadius: 15.radius,
          border: Border.all(
            color: ColorManager.white
          )
        ),
        child: usersData.isEmpty
            ? Center(
                child: TextWidget(
                StringManager.noDataYet.tr(),
                style: context.bodyLarge,
              ))
            : ListView.separated(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: usersData.length,
                padding: context.paddingSymmetric(vertical: 0),
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      Methods().userProfileNavigator(
                        context: context,
                        userId: '${usersData[index].id}',
                      );
                    },
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          TextWidget(
                            "${index + 4}",
                            style: context.bodyMedium.colorExt( ColorManager.textPrimary),
                          ),
                          index>=6?8.wBox:15.wBox,
                          Container(
                            constraints: BoxConstraints(
                              maxWidth: 50.w,
                              maxHeight: 50.h,
                            ),
                            child: UserImage(
                              image: usersData[index].image!,
                              displayName: usersData[index].name ?? '',
                              imageSize: 50.w,
                            ),
                          ),
                          10.wBox,
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GradientTextVip(
                                text: usersData[index].name!,
                                textStyle: context.bodyMedium.colorExt(ColorManager.textPrimary),
                                isVip: false,
                                width: 150.w,
                                textOverflow: TextOverflow.ellipsis,
                              ),
                              Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                children: [
                                  5.wBox,
                                  TextWidget(
                                    usersData[index].id!.toString(),
                                    style: context.bodySmall.colorExt(
                                        ColorManager.greySubtitle),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Spacer(
                            flex: 10,
                          ),
                          Row(
                            children: [
                              TextWidget(
                                usersData[index].total.toString(),
                                style: context.bodyMedium.colorExt(ColorManager.textPrimary)
                              ),
                              Image.asset(
                                AssetsManager.supporterCoin,
                                scale: 2,
                              ),
                            ],
                          ),
                        ]),
                  );
                },
                separatorBuilder: (BuildContext context, index) {
                  return 10.hBox;
                },
              ),
      ),
    );
  }
}
