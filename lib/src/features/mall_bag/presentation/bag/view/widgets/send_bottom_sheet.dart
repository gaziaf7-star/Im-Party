import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/user_info_row.dart';
import 'package:general/src/features/auth/domain/entities/user_entity.dart';
import 'package:general/src/features/chats/presentation/friends/view/friends_page.dart';
import 'package:general/src/features/home/presentation/search_screen/bloc/search_manager/search_bloc.dart';
import 'package:general/src/features/home/presentation/search_screen/bloc/search_manager/search_events.dart';
import 'package:general/src/features/home/presentation/search_screen/bloc/search_manager/search_states.dart';

import '../../../../mall_bag.dart';
import '../../../mall/bloc/mall_send_bloc/mall_send_bloc.dart';
import '../../bloc/bag_send_bloc/bag_send_bloc.dart';

class SendBottomSheet extends StatelessWidget {
  final bool isMall;
  final MyBagEntity? selectedItem;
  final MallEntity? selectedItemMall;


  SendBottomSheet({super.key, req, required this.isMall, this.selectedItem, this.selectedItemMall});

  final textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.paddingSymmetric(
        vertical: 30,
      ),
      decoration: BoxDecoration(
          image: DecorationImage(
              fit: BoxFit.cover, image: AssetImage(AssetsManager.background_))),
      child: Scaffold(
        backgroundColor: ColorManager.transparent,
        appBar: AppBarWidget(
            backgroundColor: ColorManager.transparent,
            title: CustomSearchBar(
                controller: textController,
                onSubmit: (str) {
                  di<SearchBloc>()
                      .add(SearchEvent(keyWord: textController.text));
                },
                onChanged: (str) {
                  di<SearchBloc>()
                      .add(SearchEvent(keyWord: textController.text));
                },
                onPress: () {}),
            titleStyle: context.titleLarge.w600
                .copyWith(fontFamily: StringManager.fontFamily)),
        body: BlocBuilder<SearchBloc, SearchStates>(
          bloc: di<SearchBloc>(),
          buildWhen: (prev, curr) => prev.reqState != curr.reqState || prev.data != curr.data,
          builder: (context, state) {
            return HandlingDataWidget(
              reqState: state.reqState,
              title: StringManager.noOne.tr(),
              subTitle: StringManager.noOneEmptySubTitle.tr(),
              onTap: () {},
              child: ListView.separated(
                padding: context.paddingOnly(top: 20, bottom: 20),
                shrinkWrap: true,
                itemCount: state.data?.users.length ?? 0,
                itemBuilder: (context, index) {
                  if (state.data?.users != null) {
                    if (state.data?.users.isNotEmpty == true) {
                      return UserInfoRow(
                        user: state.data?.users[index] ?? const UserEntity(),
                        margin: context.paddingZero(),
                        select: () {},
                        endIcon: MainButton(
                          onTap: () {
                            if (isMall) {
                              di<MallSendBloc>().add(
                                SendItemEvent(
                                  param: SendMallParam(
                                    itemId: selectedItemMall?.id.toString() ?? '0',
                                    userId: '${state.data?.users[index].id}',
                                  ),
                                  context: context,
                                ),
                              );
                            } else {
                              di<BagSendBloc>().add(
                                SendBagItemEvent(
                                  param: SendBagParam(
                                    itemId: '${selectedItem?.id}',
                                    userId: '${state.data?.users[index].uuid}',
                                    targetId: '${selectedItem?.targetId}',
                                  ),
                                  context: context,
                                ),
                              );
                            }
                          },
                          title: StringManager.send.tr(),
                          height: 30.h,
                          width: 90.w,
                          isLoading: false,
                          buttonColor: ColorManager.transparent,
                          borderColor: ColorManager.primary,
                          style: context.bodyMedium.w600
                              .colorExt(ColorManager.primary),
                        ),
                      );
                    }
                  }
                  return null;
                },
                separatorBuilder: (BuildContext context, int index) {
                  return 10.hBox;
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
