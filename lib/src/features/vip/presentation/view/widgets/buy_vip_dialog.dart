import 'package:general/src/features/home/presentation/search_screen/bloc/search_manager/search_bloc.dart';
import 'package:general/src/features/home/presentation/search_screen/bloc/search_manager/search_events.dart';
import 'package:general/src/features/home/presentation/search_screen/bloc/search_manager/search_states.dart';
import 'package:general/src/features/vip/presentation/bloc/buy_vip/buy_vip_bloc.dart';
import 'package:general/src/features/vip/presentation/bloc/buy_vip/buy_vip_event.dart';
import 'package:general/src/features/vip/presentation/view/components/bottom_sheet_vip.dart';

import '../../../../../core/index.dart';

class DialogBuyVIP extends StatelessWidget {
  final int idVip;

  // final String uuId;

  const DialogBuyVIP({
    super.key,
    required this.idVip,
    /*required this.uuId*/
  });

  @override
  Widget build(BuildContext context) {
    return  Container(
      padding: context.paddingOnly(top: 20, bottom: 20, start: 13, end: 13),
      decoration: BoxDecoration(
        color: ColorManager.vipDialogGray,
        borderRadius: 15.radius,
      ),
      child: BlocConsumer<SearchBloc, SearchStates>(
        bloc: di<SearchBloc>(),
        listener: (BuildContext context, SearchStates state) {
          if (state.selectedUserId != '') {
            // Update the TextInputWidget with the selected user's ID
           state.searchController.text = state.selectedUserId!;
          }
        },
        builder: (context, state) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextWidget(
                StringManager.sendVip.tr(),
                style: context.bodyMedium.copyWith(fontSize: 15.sp).colorExt(ColorManager.textPrimary),
              ),
              10.hBox,
              Row(
                children: [
                  Expanded(
                    child: TextInputWidget(
                      StringManager.enterId.tr(),
                      keyboardType: TextInputType.number,
                      controller: state.searchController,
                      validator: (value) {
                        if (value == null || value.isEmpty == true) {
                          return StringManager.requiredField.tr();
                        } else {
                          return null;
                        }
                      },
                      hintStyle: context.bodyMedium.w400.colorExt(
                        ColorManager.onDark.withValues(alpha: (0.3 )),
                      ),
                      fillColor: ColorManager.white.withValues(alpha: (0.2 )),
                    ),
                  ),
                  10.wBox,
                  ButtonWidget(
                    borderColor: ColorManager.white,
                    width: 80.h,
                    paddingButton: EdgeInsets.zero,
                    onPressed: () {
                      if (state.searchController.text != '') {
                        di<SearchBloc>().add(
                            SearchEvent(keyWord: state.searchController.text));


                        showModalBottomSheet(

                            isScrollControlled: true,
                            useSafeArea: true,
                            enableDrag: true,

                            context: context, builder: (context) {
                          return BottomSheetVip(
                            vipId: idVip,


                          );
                        });
                      }
                    },
                    backgroundColor: ColorManager.transparent,
                    height: 40.h,
                    title: StringManager.searchResult.tr(),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
              10.wBox,
              ButtonWidget(
                padding: context.paddingSymmetric(horizontal: 10),
                isLoading: di<BuyVipBloc>().state.requestState == RequestState.loading,
                onPressed: () {
                  if (state.selectedUserId != null &&
                      state.selectedUserId != '') {
                    di<BuyVipBloc>().add(BuyVipEvent(
                        type: '0',
                        toUid: state.selectedUserId,
                        vipId: idVip.toString(),
                        context: context));
                  } else {
                    Methods.showToast(context,
                        message: StringManager.pleseSelectUser.tr());
                  }
                },
                backgroundColor: ColorManager.primary,
                height: 40,
                titleColor: ColorManager.white,
                title: StringManager.send.tr(),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ],
          );
        },
      ),
    );
  }
}