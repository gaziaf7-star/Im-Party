import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/bottom_dialog.dart';
import 'package:general/src/features/room/room.dart';
import '../../../gifts/bloc/gift_bloc/gift_bloc.dart';

class RankWidget extends StatelessWidget {
  final EnterRoomModel roomEntity;

  const RankWidget({
    super.key,
    required this.roomEntity,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        bottomDailog(
          context: context,
          height: MediaQuery.sizeOf(context).height / 1.25,
          widget: RankRoomPage(
            roomEntity: roomEntity,
          ),
        );
      },
      child: ConstantsManager.isVariantBuildA
          ? Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Image.asset(
                  AssetsManager.roomRankBadge,
                  fit: BoxFit.cover,
                  width: 75.w,
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 4.h),
                  child: BlocSelector<GiftBloc, GiftState, String?>(
                    bloc: di<GiftBloc>(),
                    selector: (state) => state.price,
                    builder: (context, price) {
                      String normalize(String? value) {
                        final v = (value ?? '').trim().toLowerCase();
                        return (v.isEmpty || v == 'null') ? '' : v;
                      }

                      final safePrice = normalize(price);
                      final safeGiftPrice = normalize(roomEntity.giftPrice);

                      final priceText = safePrice.isNotEmpty
                          ? safePrice
                          : safeGiftPrice.isNotEmpty
                              ? safeGiftPrice
                              : '0.0';

                      return Text(
                        ' $priceText',
                        style: context.bodyMedium
                            .size(8.5)
                            .colorExt(ColorManager.gold3),
                      );
                    },
                  ),
                ),
              ],
            )
          : Container(
              padding: context.paddingSymmetric(vertical: 4.0, horizontal: 8.0),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: (0.25)),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    AssetsManager.reward,
                    height: 16.h,
                    fit: BoxFit.contain,
                  ),
                  3.wBox,
                  BlocSelector<GiftBloc, GiftState, String?>(
                    bloc: di<GiftBloc>(),
                    selector: (state) => state.price,
                    builder: (context, price) {
                      String normalize(String? value) {
                        final v = (value ?? '').trim().toLowerCase();
                        return (v.isEmpty || v == 'null') ? '' : v;
                      }

                      final safePrice = normalize(price);
                      final safeGiftPrice = normalize(roomEntity.giftPrice);

                      final priceText = safePrice.isNotEmpty
                          ? safePrice
                          : safeGiftPrice.isNotEmpty
                              ? safeGiftPrice
                              : '0.0';

                      return Text(
                        ' $priceText',
                        style: context.bodyMedium
                            .size(12)
                            .colorExt(ColorManager.white),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
