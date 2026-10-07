import 'package:general/src/core/index.dart';
import 'package:general/src/features/moment/presentation/bloc/moment_gift_bloc/moment_gift_bloc.dart';
import 'package:general/src/features/moment/presentation/bloc/moment_gift_bloc/moment_gift_state.dart';

class GiftListView extends StatelessWidget {
  const GiftListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MomentGiftBloc, MomentGiftState>(
      bloc: di<MomentGiftBloc>(),
      buildWhen: (prev, curr) => prev.momentGiftList != curr.momentGiftList,
      builder: (context, state) {
        final momentGiftList = state.momentGiftList;
        int topIndex = -1;
        if (momentGiftList.isNotEmpty) {
          int maxGifts = momentGiftList
              .map((e) => e.totalNumGift)
              .reduce((a, b) => a > b ? a : b);
          topIndex =
              momentGiftList.indexWhere((e) => e.totalNumGift == maxGifts);
        }
        return InkWell(
          onTap: () {
            Navigator.pushNamed(
              context,
              Routes.giftRankScreen,
              arguments: GiftRankArguments(
                momentGiftList: momentGiftList,
                topIndexes: topIndex,
              ),
            );
          },
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const TextWidget(
                      "Gift list",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16,color: Colors.black54),
                    ),
                    TextWidget(
                      "${state.momentGiftList.length} people send gifts",
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              SizedBox(
                  height: 80.h,
                  width: double.infinity,
                  child: state.momentGiftList.isNotEmpty
                      ? ListView.builder(
                          shrinkWrap: true,
                          padding: context.paddingZero(),
                          scrollDirection: Axis.horizontal,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: state.momentGiftList.length,
                          itemBuilder: (context, index) {
                            final isTopUser = index == topIndex;

                            return Padding(
                              padding: context.paddingOnly(start: 10),
                              child: Column(
                                children: [
                                  Stack(
                                    children: [
                                      ImageViewWidget(
                                        url: EndPoints.getImage(
                                            state.momentGiftList[index].image),
                                        height: 50.h,
                                        width: 50.h,
                                        shape: BoxShape.circle,
                                      ),
                                      if (isTopUser)
                                        const Positioned(
                                          top: -2,
                                          left: -2,
                                          child: Icon(Icons.star,
                                              color: Colors.orange, size: 16),
                                        ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.favorite,
                                          size: 14,
                                          color: Colors.grey.shade300),
                                      const SizedBox(width: 4),
                                      ConstrainedBox(
                                        constraints: BoxConstraints(
                                            maxWidth: 50.w, minWidth: 10.w),
                                        child: TextWidget(
                                          state.momentGiftList[index]
                                              .totalNumGift
                                              .toString(),
                                          style: context.bodyMedium.copyWith(
                                              color: Colors.grey.shade400),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        )
                      : Padding(
                          padding: context.paddingSymmetric(horizontal: 10),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor:
                                      ColorManager.grey.withAlpha(70),
                                  child: Image.asset(
                                    AssetsManager.seat,
                                    width: 30,
                                    height: 30,
                                  ),
                                ),
                                3.hBox,
                                Text(
                                  StringManager.giftList,
                                  style: context.bodyMedium
                                      .copyWith(color: Colors.grey.shade400),
                                ),
                              ],
                            ),
                          ),
                        )),
            ],
          ),
        );
      },
    );
  }
}
