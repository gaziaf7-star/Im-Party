import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/id_with_copy.dart';
import 'package:general/src/core/widgets/on_multiable_tab.dart';
import 'package:general/src/features/profile/presentation/f_f_f_v/bloc/bloc_get_f_f_f/get_follower_or_following_bloc.dart';
import 'package:general/src/features/profile/presentation/f_f_f_v/bloc/bloc_get_f_f_f/get_follower_or_following_event.dart';
import 'package:general/src/features/profile/presentation/f_f_f_v/bloc/bloc_get_f_f_f/get_follower_or_following_state.dart';
import '../../bloc/cp_request_bloc/cp_request_bloc.dart';

class AllFriendsView extends StatefulWidget {
  final String relationId;

  const AllFriendsView({super.key, required this.relationId});

  @override
  State<AllFriendsView> createState() => _AllFriendsViewState();
}

class _AllFriendsViewState extends State<AllFriendsView> {
  late final TextEditingController searchController;
  late final GetFollowerOrFollowingBloc friendsBloc;
  late final CpRequestBloc cpRequestBloc;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();

    friendsBloc = di<GetFollowerOrFollowingBloc>();
    cpRequestBloc = di<CpRequestBloc>();

    friendsBloc.add(AddListenerFriendsEvent());
    friendsBloc.add(const GetFriendsEvent(loading: false));
  }

  @override
  void dispose() {
    friendsBloc.add(RemoveListenerFriendsEvent());
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ScreenUtil().screenWidth,
      height: ScreenUtil().screenHeight * 0.7,
      decoration: BoxDecoration(
        color: ColorManager.offWhite,
        borderRadius: BorderRadius.only(
          topRight: 20.radiusCircular,
          topLeft: 20.radiusCircular,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: context.paddingSymmetric(vertical: 20, horizontal: 10),
            child: SizedBox(
              height: 40.h,
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  contentPadding: context.paddingAll(10),
                  border: OutlineInputBorder(
                    borderRadius: 8.radius,
                    borderSide: BorderSide.none,
                  ),
                  fillColor: ColorManager.babyBlue2,
                  filled: true,
                  hintText: StringManager.enterUserID.tr(),
                  suffixIcon:
                  Icon(Icons.search, color: Colors.grey, size: 20.w),
                ),
                onChanged: (value) {
                  friendsBloc.add(GetFriendsEvent(keyWord: value));
                },
                style: context.bodyMedium.size(16),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<GetFollowerOrFollowingBloc,
                GetFollowerOrFollowingState>(
              bloc: friendsBloc,
              buildWhen: (prev, curr) => prev.getFriendsMessage != curr.getFriendsMessage || prev.getFriendsRequest != curr.getFriendsRequest || prev.scrollControllerVisitor != curr.scrollControllerVisitor || prev.getFriends != curr.getFriends,
              builder: (context, state) {
                return HandlingDataWidget(
                  title: state.getFriendsMessage,
                  subTitle: state.getFriendsMessage,
                  reqState: state.getFriendsRequest,
                  child: ListView.builder(
                    controller: state.scrollControllerVisitor,
                    itemCount: state.getFriends.length,
                    itemBuilder: (context, index) {
                      final friend = state.getFriends[index];
                      return Padding(
                        padding: const EdgeInsets.all(10),
                        child: Container(
                          padding: context.paddingSymmetric(
                              horizontal: 10, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: 20.radius,
                          ),
                          child: Row(
                            children: [
                              UserImage(
                                image: friend.profile?.image ?? "",
                                displayName: friend.name ?? '',
                                imageSize: 53.w,
                              ),
                              10.wBox,
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 200.w,
                                    child: GradientName(child: Text(
                                      friend.name ?? "",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: context.bodyMedium
                                          .size(15)
                                          .colorExt(ColorManager.black),
                                    )),
                                  ),
                                  5.hBox,
                                  Row(
                                    children: [
                                      IdWithCopyIcon(
                                        userId: friend.uuid ?? '',
                                        idColor: ColorManager.black,
                                        idStyle: context.bodyMedium.w400
                                            .size(12)
                                            .colorExt(ColorManager.black),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const Spacer(),
                              BlocBuilder<CpRequestBloc, CpRequestStates>(
                                bloc: cpRequestBloc,
                                buildWhen: (prev, curr) => prev.userStates != curr.userStates || prev.loadingUserId != curr.loadingUserId,
                                builder: (context, cpState) {
                                  final isLoading =
                                      cpState.userStates.isLoading &&
                                          cpState.loadingUserId ==
                                              friend.id?.toString();
                                  return MultiTapCard(
                                    onTap: () {
                                      cpRequestBloc.add(
                                        CpRequestEvents(
                                          userId: friend.id?.toString() ?? "",
                                          relationId: widget.relationId,
                                          context: context,
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: 70.w,
                                      height: 30.h,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                        BorderRadius.circular(30.r),
                                        border: Border.all(
                                          color: ColorManager.primary,
                                        ),
                                      ),
                                      child: Center(
                                        child: isLoading
                                            ? LoadingWidget(
                                          color:
                                          ColorManager.primary,
                                        )
                                            : Text(
                                          StringManager.give.tr(),
                                          style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            color:
                                            ColorManager.primary,
                                            fontSize: 13.sp,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}