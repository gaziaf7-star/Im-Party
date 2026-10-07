import 'package:general/src/core/index.dart';
import 'package:general/src/features/home/presentation/home/bloc/home_manager/home_bloc.dart';
import 'package:general/src/features/theme2_app/home/presentation/view/widgets/theme2_lives_body.dart';

/// Standalone "Live" list screen — the same content as the home page's Live
/// tab ([Theme2LivesBody]), reachable from outside the home (e.g. the Reels
/// top bar). Refreshes the live-rooms slice on open.
class Theme2LivesPage extends StatefulWidget {
  const Theme2LivesPage({super.key});

  @override
  State<Theme2LivesPage> createState() => _Theme2LivesPageState();
}

class _Theme2LivesPageState extends State<Theme2LivesPage> {
  final HomeBloc _bloc = di<HomeBloc>();

  @override
  void initState() {
    super.initState();
    _bloc.add(const FetchLiveRoomsEvent());
  }

  @override
  Widget build(BuildContext context) {
    // Same admin-driven background as the home page, so this standalone route
    // looks IDENTICAL to the home's Live tab (it was a flat dark scaffold).
    return BackgroundImgWidget(
      child: Scaffold(
        backgroundColor: ColorManager.transparent,
        appBar: AppBar(
          backgroundColor: ColorManager.transparent,
          elevation: 0,
          title: TextWidget(
            StringManager.live.tr(),
            style:
                context.bodyLarge.w600.colorExt(ColorManager.theme2TextPrimary),
          ),
          iconTheme: IconThemeData(color: ColorManager.theme2TextPrimary),
          centerTitle: true,
        ),
        body: Theme2LivesBody(bloc: _bloc),
      ),
    );
  }
}
