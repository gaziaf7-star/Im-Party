import 'package:general/src/core/widgets/user_info_row.dart';
import 'package:general/src/features/chats/presentation/friends/view/friends_page.dart';
import 'package:general/src/features/home/presentation/search_screen/bloc/search_manager/search_bloc.dart';
import 'package:general/src/features/home/presentation/search_screen/bloc/search_manager/search_events.dart';
import 'package:general/src/features/home/presentation/search_screen/bloc/search_manager/search_states.dart';

import '../../../vip.dart';

class SendVipBottomSheet extends StatelessWidget {
  final String vipId;
  SendVipBottomSheet({super.key,req,required this.vipId});

  final textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.paddingSymmetric(
        vertical: 30,
      ),
      decoration: BoxDecoration(

        image: DecorationImage(
          fit: BoxFit.cover,
            image: AssetImage(AssetsManager.background_))
      ),
      child: Scaffold(

        backgroundColor: ColorManager.transparent,
        appBar: AppBarWidget(
            backgroundColor: ColorManager.transparent,
            title: CustomSearchBar(
                controller:textController ,
                onSubmit: (str) {
                  di<SearchBloc>().add(
                      SearchEvent(keyWord: textController.text));                  },
                onChanged: (str) {},
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
              onTap: () {
                //      di<SearchBloc>().add(SearchEvent(keyWord: value ?? ""));
              },
              child: ListView.separated(
                padding: context.paddingOnly(top: 20, bottom: 20),
                shrinkWrap: true,
                itemCount: state.data?.users.length ?? 0,
                itemBuilder: (context, index) {

                    if (state.data?.users.isNotEmpty == true) {
                      return UserInfoRow(
                        user: state.data!.users[index],
                        margin: context.paddingZero(),
                        select: (){},
                        endIcon:  MainButton(
                          onTap: (){

                            di<VipCenterBloc>().add(
                              SendVipEvent(
                                context: context,
                                userId: state.data!.users[index].uuid.toString(),
                                targetId: vipId,
                              ),
                            );
                          },
                          title: StringManager.send.tr(),
                          height: 30.h,
                          width: 90.w,
                          isLoading: false,
                          buttonColor: ColorManager.transparent,
                          borderColor: ColorManager.primary,
                          style: context.bodyMedium.w600.colorExt(ColorManager.primary),
                        ),
                      );
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
