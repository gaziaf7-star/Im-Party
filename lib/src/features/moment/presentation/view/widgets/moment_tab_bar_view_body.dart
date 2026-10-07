part of 'package:general/src/features/moment/presentation/view/moment_page.dart';

class MomentTabViewBody extends StatefulWidget {
  final List<MomentEntity> entity;
  final MomentType type;
  final RequestState reqState;
  final bool isPaginating;

  const MomentTabViewBody({
    super.key,
    required this.entity,
    required this.type,
    required this.reqState,
    this.isPaginating = false,
  });

  @override
  State<MomentTabViewBody> createState() => _MomentTabViewBodyState();
}

class _MomentTabViewBodyState extends State<MomentTabViewBody> {
  final _bloc = di<MomentBloc>();

  @override
  void initState() {
    super.initState();

    _bloc.add(const AddListenerFollowMomentEvent());

    _bloc.add(const AddListenerLatestMomentEvent());

    _bloc.add(const AddListenerMomentEvent());
  }

  @override
  void dispose() {
    _bloc.add(const RemoveListenerFollowMomentEvent());

    _bloc.add(const RemoveListenerLatestMomentEvent());

    _bloc.add(const RemoveListenerMomentEvent());

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicatorWidget(
      onRefresh: () async {
        if (widget.type == MomentType.follow) {
          di<MomentBloc>().add(const FetchFollowMomentData(isRefresh: true));
        } else if (widget.type == MomentType.recommend) {
          di<MomentBloc>().add(const FetchMomentData(isRefresh: true));
        } else if (widget.type == MomentType.latest) {
          di<MomentBloc>().add(const FetchLatestMomentData(isRefresh: true));
        }
      },
      child: CustomScrollView(
        controller: widget.type == MomentType.follow
            ? _bloc.state.scrollControllerFollowMoment
            : widget.type == MomentType.recommend
                ? _bloc.state.scrollControllerMoment
                : widget.type == MomentType.latest
                    ? _bloc.state.scrollControllerLatestMoment
                    : _bloc.state.scrollControllerMoment,
        slivers: [
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Padding(
                  padding:
                      context.paddingOnly(end: 10.w, top: 5.h, bottom: 5.h),
                  child: GestureDetector(
                    onTap: () {
                      di<MomentCommentBloc>().add(
                        FetchMomentComment(
                          momentId: widget.entity[index].momentId.toString(),
                          page: "1",
                        ),
                      );
                      di<GetMomentLikesBloc>().add(
                        GetMomentLikesEvent(
                          momentId: widget.entity[index].momentId.toString(),
                          page: "1",
                        ),
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MomentContentScreen(
                            momentBloc: _bloc,
                            type: widget.type,
                            currentMoment: widget.entity[index],
                            currentMomentIndex: index,
                            momentId: widget.entity[index].momentId,
                          ),
                        ),
                      );
                    },
                    child: MomentItem(
                      type: '4',
                      momentBloc: _bloc,
                      momentType: widget.type,
                      moment: widget.entity[index],
                      currentMomentIndex: index,
                      isProfile: false,
                    ),
                  ),
                );
              },
              childCount: widget.entity.length,
            ),
          ),
          if (widget.isPaginating)
            const SliverToBoxAdapter(
              child: CircleLoadingWidget(),
            ),
        ],
      ),
    );
  }
}
