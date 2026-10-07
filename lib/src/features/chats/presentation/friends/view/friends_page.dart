import 'package:flutter/cupertino.dart';
import 'package:general/src/features/chats/chats.dart';
import 'package:general/src/features/home/presentation/search_screen/bloc/search_manager/search_bloc.dart';
import 'package:general/src/features/home/presentation/search_screen/bloc/search_manager/search_events.dart';
import 'package:general/src/features/home/presentation/search_screen/bloc/search_manager/search_states.dart';
import 'package:general/src/features/profile/presentation/f_f_f_v/bloc/bloc_get_f_f_f/get_follower_or_following_bloc.dart';
import 'package:general/src/features/profile/presentation/f_f_f_v/bloc/bloc_get_f_f_f/get_follower_or_following_event.dart';
import 'package:general/src/features/profile/presentation/f_f_f_v/bloc/bloc_get_f_f_f/get_follower_or_following_state.dart';

import '../../../../auth/domain/entities/user_entity.dart';

part 'components/friends_user_info_row.dart';

part 'components/tab_bar_view_body.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FFFScreenState();
}

class _FFFScreenState extends State<FriendsPage> with TickerProviderStateMixin {
  //late TabController _controller;
  String text = StringManager.following.tr();
  final GetFollowerOrFollowingBloc _bloc = di<GetFollowerOrFollowingBloc>();

  late TextEditingController textController;

  @override
  void initState() {
    textController = TextEditingController();
    if (!_bloc.state.friendsRequestState.isLoaded) {
      _bloc.add(const GetFriendsEvent(loading: true));
    }
    di<SearchBloc>().add(const FriendsSearchAddListenerEvent());

    super.initState();
  }

  @override
  void dispose() {
    //_controller.dispose();
    di<SearchBloc>().add(const FriendsSearchRemoveListenerEvent());
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetFollowerOrFollowingBloc, GetFollowerOrFollowingState>(
      bloc: _bloc,
      buildWhen: (prev, curr) => prev.getFriendsRequest != curr.getFriendsRequest || prev.getFriends != curr.getFriends,
      builder: (context, state) {
        return HandlingDataWidget(
          title: StringManager.titleFriend.tr(),
          subTitle: StringManager.subtitleFriend.tr(),
          reqState: state.getFriendsRequest,
          onTap: () {
            di<GetFollowerOrFollowingBloc>()
                .add(const GetFriendsEvent(loading: true));
          },
          child: Column(
            children: [
              15.hBox,
              CustomSearchBar(
                  onChanged: (str) {
                    di<SearchBloc>()
                        .add(SearchFriendsEvent(keyWord: str ?? ''));
                  },
                  onSubmit: (str) {},
                  onPress: () {}),
              BlocBuilder<SearchBloc, SearchStates>(
                  bloc: di<SearchBloc>(),
                  buildWhen: (prev, curr) => prev.reqStateFriends != curr.reqStateFriends || prev.friendsList != curr.friendsList,
                  builder: (context, __) {
                    if (__.reqStateFriends.isLoaded) {
                      return HandlingDataWidget(
                        title: StringManager.titleFriend.tr(),
                        subTitle: StringManager.subtitleFriend.tr(),
                        reqState: __.reqStateFriends,
                        onTap: () {
                          di<GetFollowerOrFollowingBloc>()
                              .add(const GetFriendsEvent(loading: true));
                        },
                        child: Expanded(
                          child: TabViewBody(
                            entity: __.friendsList?.users ?? [],
                            fType_: RelationType.friends,
                            reqState: __.reqStateFriends,
                            controller: textController,
                            scrollControllerOverride: __.friendsScrollCtrl,
                          ),
                        ),
                      );
                    } else {
                      return Expanded(
                        child: TabViewBody(
                          entity: state.getFriends,
                          fType_: RelationType.friends,
                          reqState: state.getFriendsRequest,
                          controller: textController,
                        ),
                      );
                    }
                  }),
            ],
          ),
        );
      },
    );
  }
}

// Todo: sayed
class CustomSearchBar extends StatelessWidget {
  const CustomSearchBar({
    super.key,
    required this.onSubmit,
    required this.onChanged,
    required this.onPress,
    this.controller,
    this.onEditingComplete,
    // Both optional and default to this widget's original Friends/ID-search
    // behaviour, so the existing call sites (Friends page, the gift "send
    // to" pickers) are unaffected. The Home page's general user/room Search
    // screen passes its own hint + a text keyboard instead.
    this.hintText,
    this.keyboardType,
    // Owner request (Home Search screen only): typed text a bit bigger.
    // Optional, defaults to null so TextInputWidget falls back to its own
    // default size (14) everywhere else this is used.
    this.fontSize,
    // this.focusNode
  });

  final void Function(String)? onSubmit;
  final void Function(String?)? onChanged;
  final void Function()? onEditingComplete;
  final VoidCallback onPress;
  final TextEditingController? controller;
  final String? hintText;
  final TextInputType? keyboardType;
  final double? fontSize;

  // final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35.h,
      margin: context.paddingSymmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: 30.radius,
        // color: ColorManager.white,
      ),
      child: TextInputWidget(
        onEditingComplete: onEditingComplete,
        hintText ?? StringManager.pleaseEnterIdFriends.tr(),
        controller: controller,
        keyboardType: keyboardType ?? TextInputType.number,
        fillColor: ColorManager.white,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        onSubmitted: onSubmit,
        // Was ColorManager.secondaryText at 30% alpha — a mutable,
        // panel-driven grey rendered almost fully transparent, so whatever
        // the user actually typed was nearly invisible. Fixed, solid, and
        // readable now.
        textColor: ColorManager.momentPostTextColor,
        textSize: fontSize,
        border: OutlineInputBorder(
          borderSide: const BorderSide(
            color: ColorManager.white,
            width: 1,
          ),
          borderRadius: 30.radius,
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: ColorManager.white,
            width: 1,
          ),
          borderRadius: 30.radius,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: ColorManager.white,
            width: 1,
          ),
          borderRadius: 30.radius,
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: ColorManager.redAccount,
            width: 1,
          ),
          borderRadius: 30.radius,
        ),
        suffixIcon: InkWell(
          onTap: () {
            controller?.clear();
            onChanged?.call('');
            di<SearchBloc>().add(const SearchFriendsEvent(keyWord: ''));
          },
          child: Icon(
            CupertinoIcons.clear_circled_solid,
            color: ColorManager.grey.withValues(alpha: (0.4)),
            size: 15.r,
          ),
        ),
        prefixIcon: Icon(
          Icons.search,
          color: ColorManager.grey.withValues(alpha: (0.4)),
        ),
        // Was ColorManager.greyTextColor (mutable/panel-driven) — fixed now.
        hintStyle: context.bodyMedium.colorExt(
          ColorManager.momentPostTextColor.withValues(alpha: (0.5)),
        ),
        // Was commented out, falling back to TextInputWidget's own mutable
        // ColorManager.textPrimary default — the app's brand colour now,
        // matching the compose-field cursor convention used elsewhere.
        cursorColor: ColorManager.brandGradientColors.last,
        contentPadding: context.paddingOnly(
          top: 0,
          end: 0,
          bottom: 0,
          start: 0,
        ),
      ),
    );
  }
}