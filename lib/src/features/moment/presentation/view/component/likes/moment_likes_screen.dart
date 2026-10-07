import 'package:general/src/core/widgets/gradient_name.dart';
import 'package:general/src/core/index.dart';

import '../../../bloc/moment_likes_bloc/get_moment_likes_event.dart';
import '../../../bloc/moment_likes_bloc/moment_likes_bloc_bloc.dart';
import '../../../bloc/moment_likes_bloc/moment_likes_bloc_state.dart';

class MomentsLikesScreen extends StatefulWidget {
  final String momentId;

  const MomentsLikesScreen({
    required this.momentId,
    super.key,
  });

  @override
  State<MomentsLikesScreen> createState() => MomentsLikesScreenState();
}

class MomentsLikesScreenState extends State<MomentsLikesScreen> {

  @override
  void initState() {
    di<GetMomentLikesBloc>()
        .add(AddListenerLikeEvent(momentId: widget.momentId));

    super.initState();
  }

  @override
  void dispose() {
    di<GetMomentLikesBloc>()
        .add(RemoveListenerLikeEvent(momentId: widget.momentId));

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: ColorManager.lightGreyForBackground,
      body: SafeArea(
        top: true,
        bottom: false,
        child: SizedBox(
        height: ScreenUtil().screenHeight,
        child: Column(
          children: [
            Row(
              children: [
                const Spacer(flex: 1),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    // color: Colors.black,
                  ),
                ),
                const Spacer(flex: 5),
                Text(
                  StringManager.likes.tr(),
                  style:  context.bodyMedium.size(16).w600
                ),
                const Spacer(flex: 8),
              ],
            ),
            15.hBox,
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  BlocProvider.of<GetMomentLikesBloc>(context).add(
                      GetMomentLikesEvent(
                          momentId: widget.momentId, page: "1"));
                },
                child: BlocBuilder<GetMomentLikesBloc, GetMomentLikesState>(
                  buildWhen: (prev, curr) => prev.momentLikes != curr.momentLikes,
                  builder: (context, state) {
                    return ListView.builder(
                      controller:state.scrollControllerLikes,
                        itemCount: state.momentLikes.isNotEmpty
                            ? state.momentLikes.length
                            : 0,
                        itemBuilder: (context, index) {
                          return GradientName(child: Text(state.momentLikes[index].userName));
                        });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  // void _listener() {
  //   if (_scrollController.position.pixels ==
  //       _scrollController.position.maxScrollExtent) {
  //     BlocProvider.of<GetMomentLikesBloc>(context).add(
  //       GetMoreMomentLikesEvent(momentId: widget.momentId.toString()),
  //     );
  //   }
  // }
}
