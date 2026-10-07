// import 'package:flutter/cupertino.dart';
// import 'package:flutter_card_swiper/flutter_card_swiper.dart';
// import 'package:general/src/features/games/games.dart';
// import 'package:general/src/features/games/presentation/games/bloc/action/action_bloc.dart';
// import 'package:general/src/features/games/presentation/games/bloc/explore/explore_bloc.dart';
// import 'package:general/src/features/moment/presentation/view/component/meet/action_user_widget.dart';
// import 'package:general/src/features/moment/presentation/view/component/meet/user_profile_card_widget.dart';
//
// class MeetTabViewBody extends StatefulWidget {
//   const MeetTabViewBody(
//       {super.key, required this.bloc, required this.controller});
//   final ExploreBloc bloc;
//   final CardSwiperController controller;
//
//   @override
//   State<MeetTabViewBody> createState() => _MeetTabViewBodyState();
// }
//
// class _MeetTabViewBodyState extends State<MeetTabViewBody> {
//   bool right = false;
//   bool left = false;
//   int currentCardIndex = 0;
//   @override
//   Widget build(BuildContext context) {
//     final bool isLoaded = widget.bloc.state.reqStateUsers.isLoaded;
//
//     return HandlingDataWidget(
//       reqState: widget.bloc.state.reqStateUsers,
//       title: StringManager.noUsers.tr(),
//       subTitle: StringManager.noUsersMsg.tr(),
//       onTap: () => widget.bloc.add(const FetchUsersEvent()),
//       child: isLoaded
//           ? Stack(
//               alignment: AlignmentDirectional.bottomCenter,
//               children: [
//                 CardSwiper(
//                   controller: widget.controller,
//                   duration: const Duration(milliseconds: 400),
//                   padding:
//                       context.paddingOnly(start: 0, top: 10, end: 0, bottom: 0),
//                   numberOfCardsDisplayed: 2,
//                   cardsCount: widget.bloc.state.users.length,
//                   cardBuilder: (_, index, x, y) {
//                     currentCardIndex = index;
//
//                     return UserProfileCardWidget(
//                       data: widget.bloc.state.users[index],
//                       controller: widget.controller,
//                     );
//                   },
//                   onSwipeDirectionChange: (direction1, direction2) {
//                     if (direction1 == CardSwiperDirection.right) {
//                       right = true;
//                       left = false;
//                     } else if (direction1 == CardSwiperDirection.left) {
//                       left = true;
//                       right = false;
//                     } else {
//                       right = false;
//                       left = false;
//                     }
//                     setState(() {});
//                   },
//                   onSwipe: (currentIndex, previousIndex, direction) async {
//                     if (currentIndex % 7 == 0) {
//                       di<ExploreBloc>().add(const FetchMoreUsersEvent());
//                     }
//                     if (direction == CardSwiperDirection.right) {
//                       di<ActionBloc>().add(LikeUserEvent(
//                           userId:
//                               '${widget.bloc.state.users[currentIndex].id}'));
//                       widget.controller.swipe(CardSwiperDirection.top);
//                     } else if (direction == CardSwiperDirection.left) {
//                       di<ActionBloc>().add(
//                         IgnoreUserEvent(
//                           userId: '${widget.bloc.state.users[currentIndex].id}',
//                         ),
//                       );
//                     }
//                     return true;
//                   },
//                 ),
//                 BlocProvider<ActionBloc>.value(
//                   value: di<ActionBloc>(),
//                   child: BlocConsumer<ActionBloc, ActionState>(
//                     listener: (context, state) {
//                       // if (state.reqStateIgnore.isLoaded) {
//                       //   controller.swipe(CardSwiperDirection.top);
//                       //   return;
//                       // }
//                       // if (state.reqStateLike.isLoaded) {
//                       //   controller.swipe(CardSwiperDirection.top);
//                       //   return;
//                       // }
//                     },
//                     builder: (context, state) {
//                       return Padding(
//                         padding: context.paddingSymmetric(vertical: 20),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                           children: [
//                             ActionUserWidget(
//                               icon: CupertinoIcons.clear,
//                               iconColor: right
//                                   ? ColorManager.transparent
//                                   : left
//                                       ? ColorManager.white
//                                       : ColorManager.purple90,
//                               width: ScreenUtil().screenWidth * 0.4,
//                               height: 47,
//                               borderColor: right
//                                   ? ColorManager.transparent
//                                   : left
//                                       ? ColorManager.purple90
//                                       : ColorManager.greyLight,
//                               bgColor: right
//                                   ? ColorManager.transparent
//                                   : left
//                                       ? ColorManager.purple90
//                                       : ColorManager.white,
//                               // reqState: state.reqStateIgnore,
//                               onTap: () {
//                                 di<ActionBloc>().add(IgnoreUserEvent(
//                                     userId:
//                                         '${widget.bloc.state.users[currentCardIndex].id}'));
//                                 widget.controller
//                                     .swipe(CardSwiperDirection.top);
//                               },
//                             ),
//                             ActionUserWidget(
//                               icon: widget.bloc.state.users[currentCardIndex]
//                                           .isLiked ==
//                                       true
//                                   ? CupertinoIcons.heart_fill
//                                   : CupertinoIcons.heart_fill,
//                               width: ScreenUtil().screenWidth * 0.4,
//                               height: 47,
//                               padding: 12.5,
//
//                               borderColor: left
//                                   ? ColorManager.transparent
//                                   : ColorManager.pink,
//                               iconColor: left
//                                   ? ColorManager.transparent
//                                   : ColorManager.white,
//
//                               bgColor: left
//                                   ? ColorManager.transparent
//                                   : ColorManager.pink,
//                               // reqState: state.reqStateLike,
//                               onTap: () {
//                                 di<ActionBloc>().add(LikeUserEvent(
//                                     userId:
//                                         '${widget.bloc.state.users[currentCardIndex].id}'));
//                                 widget.controller
//                                     .swipe(CardSwiperDirection.top);
//                               },
//                             ),
//
//                           ],
//                         ),
//                       );
//                     },
//                   ),
//                 )
//               ],
//             )
//           : const SizedBox.shrink(),
//     );
//   }
// }
