import 'package:flutter/cupertino.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/level_container.dart';
import 'package:general/src/core/widgets/on_multiable_tab.dart';
import 'package:general/src/features/family/family.dart';

import '../../widgets/pop_up_item_widget.dart';

part 'components/admins_and_members_body.dart';

part 'components/dialog_exit_family.dart';

part 'components/family_level_body.dart';

part 'components/header_body.dart';

part 'components/more_icon_body.dart';

part 'components/rooms_body.dart';

class FamilyScreen extends StatefulWidget {
  final String familyId;

  const FamilyScreen({super.key, required this.familyId});

  @override
  State<FamilyScreen> createState() => _FamilyScreenState();
}

class _FamilyScreenState extends State<FamilyScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showTitle = false;
  final ShowFamilyBloc _showFamilyBloc = di<ShowFamilyBloc>();
  final FamilyRoomBloc _familyRoomBloc = di<FamilyRoomBloc>();
  final ExitFamilyBloc _exitFamilyBloc = di<ExitFamilyBloc>();

  @override
  void initState() {
    _showFamilyBloc.add(ShowFamilyEvent(familyId: widget.familyId));

    di<JoinFamilyBloc>().add(const ResetJoinFamilyEvent());
    _familyRoomBloc.add(
        GetFamilyRoomEvent(familyId: widget.familyId, isFirstLoading: true));
    _scrollController.addListener(() {
      if (_scrollController.offset > 200 && !_showTitle) {
        setState(() {
          _showTitle = true;
        });
      } else if (_scrollController.offset <= 200 && _showTitle) {
        setState(() {
          _showTitle = false;
        });
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DeleteFamilyBloc, DeleteFamilyState>(
      bloc: di<DeleteFamilyBloc>(),
      listener: (context, state) {
        if (state.reqState.isLoaded) {
          Methods.showToast(
            context,
            message: state.message ?? "",
          );
          di<FetchUserDataBloc>().add(const FetchMyDataEvent(isLoading: false));
          Navigator.pushNamedAndRemoveUntil(
              context, Routes.layout, (route) => false);
        } else if (state.reqState.isError) {
          Methods.showToast(context,
              message: state.errorMsg ?? "", isError: true);
        }
      },
      child: BlocListener<JoinFamilyBloc, BaseJoinFamilyState>(
        bloc: di<JoinFamilyBloc>(),
        listener: (context, state) {
          if (state.reqState.isLoaded) {
            Methods.showToast(context, message: state.message ?? '');
          } else if (state.reqState.isError) {
            Methods.showToast(context, message: state.errorMsg ?? '');
          }
        },
        child: BlocListener<ExitFamilyBloc, ExitFamilyState>(
          bloc: _exitFamilyBloc,
          listener: (context, state) {
            if (state.reqState.isLoaded) {
              Methods.showToast(
                context,
                message: state.message ?? "",
              );
              di<FetchUserDataBloc>()
                  .add(const FetchMyDataEvent(isLoading: false));
              Navigator.pop(context);
            } else if (state.reqState.isError) {
              Methods.showToast(
                context,
                message: state.error ?? "",
                isError: true,
              );
            }
          },
          child: BlocBuilder<ShowFamilyBloc, ShowFamilyState>(
              bloc: _showFamilyBloc,
              buildWhen: (prev, curr) => prev.reqState != curr.reqState || prev.showFamilyEntity != curr.showFamilyEntity,
              builder: (context, state) {
                return Scaffold(
                  body: HandlingDataWidget(
                    reqState: state.reqState,
                    title: StringManager.someThingWentWrong.tr(),
                    subTitle: StringManager.noDataYet.tr(),
                    child: NestedScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      controller: _scrollController,
                      headerSliverBuilder: (context, innerBoxIsScrolled) => [
                        SliverAppBar(
                          pinned: true,
                          expandedHeight: ScreenUtil().screenHeight * 0.35,
                          automaticallyImplyLeading: false,
                          systemOverlayStyle: SystemUiOverlayStyle.dark,
                          backgroundColor: ColorManager.scaffoldBg,
                          title: TextWidget(
                            StringManager.family.tr(),
                            style: context.bodyLarge.w600.colorExt(
                                (_showTitle == true)
                                    ? ColorManager.textPrimary
                                    : ColorManager.onDark),
                          ),
                          leading: IconButton.filled(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: context.paddingZero(),
                              backgroundColor: ColorManager.transparent,
                            ),
                            icon: Icon(
                              Icons.arrow_back_ios,
                              size: 18.5.h,
                              color: ColorManager.textPrimary,
                            ),
                          ),
                          centerTitle: true,
                          actions: [
                            if (widget.familyId ==
                                MyDataModel.getInstance().familyId.toString())
                              MoreIconBody(
                                iconColor: (_showTitle == true)
                                    ? ColorManager.black
                                    : ColorManager.white,
                                familyEntity: state.showFamilyEntity,
                                isNewRequest:
                                    (state.showFamilyEntity!.numOfRequests !=
                                        0),
                              ),
                          ],
                          flexibleSpace: FlexibleSpaceBar(
                            background: SizedBox(
                              width: ScreenUtil().screenWidth,
                              height: ScreenUtil().screenHeight * 0.43,
                              child: ImageViewWidget(
                                url: EndPoints.getImage(
                                    state.showFamilyEntity?.img ?? ''),
                                width: ScreenUtil().screenWidth,
                                height: ScreenUtil().screenHeight * 0.43,
                                boxFit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ],
                      body: RefreshIndicatorWidget(
                        onRefresh: () async {
                          _showFamilyBloc
                              .add(ShowFamilyEvent(familyId: widget.familyId));
                          _familyRoomBloc.add(
                              GetFamilyRoomEvent(familyId: widget.familyId));
                        },
                        child: ListView(
                          padding: EdgeInsets.zero,
                          children: [
                            _HeaderBody(
                              familyEntity: state.showFamilyEntity,
                              exitFamilyBloc: _exitFamilyBloc,
                              showFamilyBloc: _showFamilyBloc,
                              familyId: widget.familyId,
                            ),
                            Container(
                              padding: context.paddingAll(15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  IndicatorRowWidget(
                                    title:
                                        '${StringManager.familyMember.tr()} (${((state.showFamilyEntity?.members?.length ?? 0) + 1)}/${state.showFamilyEntity?.maxNumOfMembers})',
                                    onTap: () => Navigator.pushNamed(
                                      context,
                                      Routes.familyMembers,
                                      arguments: MemberFamilyParam(
                                        owner: state.showFamilyEntity!
                                            .memberFamilyEntity!,
                                        familyId: state.showFamilyEntity!.id!,
                                      ),
                                    ),
                                  ),
                                  10.hBox,
                                  _AdminsAndMembersBody(
                                      showFamilyEntity: state.showFamilyEntity),
                                  35.hBox,
                                  BlocBuilder<FamilyRoomBloc, FamilyRoomState>(
                                    bloc: di<FamilyRoomBloc>(),
                                    buildWhen: (prev, curr) => prev.data != curr.data,
                                    builder: (context, roomState) {
                                      if ((di<FamilyRoomBloc>().state.data ??
                                              [])
                                          .isNotEmpty) {
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            IndicatorRowWidget(
                                                title: StringManager.familyRoom
                                                    .tr()),
                                            15.hBox,
                                            const _RoomsBody(),
                                          ],
                                        );
                                      } else {
                                        return const SizedBox();
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  bottomNavigationBar: (MyDataModel.getInstance().familyId ==
                              0 ||
                          MyDataModel.getInstance().familyId == null)
                      ? BlocBuilder<FamilyRoomBloc, FamilyRoomState>(
                          bloc: di<FamilyRoomBloc>(),
                          buildWhen: (prev, curr) => prev.reqState != curr.reqState,
                          builder: (context, roomState) {
                            return roomState.reqState.isLoading
                                ? const SizedBox()
                                : Padding(
                                    padding: context.paddingOnly(
                                        start: 25, end: 25, top: 10, bottom: 5),
                                    child: BlocBuilder<JoinFamilyBloc,
                                        BaseJoinFamilyState>(
                                      bloc: di<JoinFamilyBloc>(),
                                      buildWhen: (prev, curr) => prev.reqState != curr.reqState,
                                      builder: (context, joinState) {
                                        return ButtonWidget(
                                          isLoading:
                                              joinState.reqState.isLoading,
                                          onPressed: (joinState
                                                      .reqState.isLoaded ||
                                                  state.showFamilyEntity
                                                          ?.requested ==
                                                      true)
                                              ? () {}
                                              : () {
                                                  if (!di<JoinFamilyBloc>()
                                                      .state
                                                      .reqState
                                                      .isLoading) {
                                                    di<JoinFamilyBloc>().add(
                                                      JoinFamilyEvent(
                                                        familyId:
                                                            (di<ShowFamilyBloc>()
                                                                        .state
                                                                        .showFamilyEntity
                                                                        ?.id ??
                                                                    0)
                                                                .toString(),
                                                      ),
                                                    );
                                                  }
                                                },
                                          height: 50.h,
                                          radius: 30.r,
                                          backgroundColor:
                                              (joinState.reqState.isLoaded ||
                                                      state.showFamilyEntity
                                                              ?.requested ==
                                                          true)
                                                  ? ColorManager.grey
                                                      .withValues(alpha: 0.5)
                                                  : ColorManager.primary,
                                          title: (joinState.reqState.isLoaded ||
                                                  state.showFamilyEntity
                                                          ?.requested ==
                                                      true)
                                              ? StringManager
                                                  .yourRequestIsUnderReview
                                                  .tr()
                                              : StringManager.join.tr(),
                                        );
                                      },
                                    ),
                                  );
                          })
                      : const SizedBox(),
                );
              }),
        ),
      ),
    );
  }
}
