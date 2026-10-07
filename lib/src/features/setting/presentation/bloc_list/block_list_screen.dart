import 'dart:developer';

import 'package:general/src/features/profile/presentation/f_f_f_v/bloc/bloc_get_f_f_f/get_follower_or_following_bloc.dart';
import 'package:general/src/features/profile/presentation/f_f_f_v/bloc/bloc_get_f_f_f/get_follower_or_following_event.dart';
import 'package:general/src/features/profile/presentation/profile/view/page/user_profile/bloc/add_or_delete_block/add_or_delete_block_bloc.dart';
import 'package:general/src/features/profile/presentation/profile/view/page/user_profile/bloc/add_or_delete_block/add_or_delete_block_state.dart';
import 'package:general/src/features/setting/presentation/bloc_list/bloc/block_list_bloc.dart';
import 'package:general/src/features/setting/presentation/bloc_list/bloc/block_list_event.dart';
import 'package:general/src/features/setting/presentation/bloc_list/bloc/block_list_state.dart';
import 'package:general/src/features/setting/presentation/bloc_list/widget/list_user_widget.dart';

import '../../../../core/index.dart';


class BlockListScreen extends StatefulWidget {
  const BlockListScreen({super.key});

  @override
  State<BlockListScreen> createState() => _BlockListScreenState();
}

class _BlockListScreenState extends State<BlockListScreen> {
  final _getBlockListBloc = di<GetBlockListBloc>();
  final _addOrDeleteBLockListBloc = di<AddOrRemoveBlock>();
  @override
  void initState() {
    log('${_getBlockListBloc.state} QWERTY');
    super.initState();
    if (!_getBlockListBloc.state.requestStateBlockList.isLoaded) {
      log('QWERTY');
      _getBlockListBloc.add(const GetBlockListEvent());
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ColorManager.white,
        appBar:  AppBarWidget(
          backgroundColor: ColorManager.white,
          iconColor: ColorManager.black,
          titleStyle: context.bodyLarge.bold.colorExt(ColorManager.black),
          title: StringManager.blockList.tr(),
        ),
        body:  BlocListener<AddOrRemoveBlock, AddBlocOrRemoveState>(
          bloc: _addOrDeleteBLockListBloc,
          listener: (context, state) {
            if (state.requestStateRemoveBloc.isLoaded) {

              _getBlockListBloc.add(const GetBlockListEvent(isLoading: false));
              di<GetFollowerOrFollowingBloc>().add(const GetFriendsEvent(loading: false));
            }
            else if (state.requestStateRemoveBloc.isError) {
              Methods.showToast(
                  context,
                  isError:true,
                  message:  NetworkExceptions.getErrorMessage(state.errorMsgAddBloc!)
              );
            }
            else if (state.requestStateRemoveBloc.isLoading) {
              Methods.showToast(
                  context,
                  isLoading: true
              );
            }
          },
          child: BlocBuilder<GetBlockListBloc, GetBlockListState>(
            bloc: _getBlockListBloc,
            buildWhen: (prev, curr) => prev.requestStateBlockList != curr.requestStateBlockList || prev.blackListModel != curr.blackListModel,
            builder: (context, state) {

              return RefreshIndicatorWidget(
                onRefresh: ()async => _getBlockListBloc.add(const GetBlockListEvent()),
                child: HandlingDataWidget(

                    reqState: state.requestStateBlockList,
                    subTitle: StringManager.subTitleBlockList.tr(),
                    title:StringManager.titleBlockList.tr(),
                    titleStyle: context.bodyLarge.bold.colorExt(ColorManager.black),
                    subTitleStyle: context.bodyMedium.colorExt(ColorManager.black.withValues(alpha: 0.6)),
                    buttonBackgroundColors: [ColorManager.primary, ColorManager.primary],
                    onTap: (){
                      _getBlockListBloc.add(const GetBlockListEvent());

                    },
                    child: ListUserWidget(users: state.blackListModel!)),
              );

            },
          ),
        )
    );
  }
}