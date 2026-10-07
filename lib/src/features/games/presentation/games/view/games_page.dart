import 'dart:async';
import 'dart:math';
import 'package:general/src/features/games/games.dart';
import 'package:general/src/features/profile/presentation/coins/bloc/my_store_bloc/my_store_bloc.dart';
import 'package:general/src/features/room/room.dart';
import 'widgets/games_grid_widget.dart';

part 'components/games_tab_view_body.dart';

class GamesPage extends StatefulWidget {
  const GamesPage({super.key});

  @override
  State<GamesPage> createState() => _GamesPageState();
}

class _GamesPageState extends State<GamesPage> {
  final ExploreBloc bloc = di<ExploreBloc>();

  @override
  void initState() {
    _fetchGames();
    super.initState();
  }

  void _fetchGames({bool isLoading = true}) {
    if (isLoading == false) {
      bloc
        ..add(const FetchGamesEvent(isGamesLoading: false,type: 'outer'))
        ..add(const FetchGamesRoomEvent(isGamesRoomLoading: false))
        ..add(const FetchGamersEvent());
    } else {
      if (!bloc.state.outerReqStateGames.isLoaded) {
        bloc.add(const FetchGamesEvent(type: 'outer'));
      }
      if (!bloc.state.reqStateGamesRoom.isLoaded) {
        bloc.add(const FetchGamesRoomEvent());
      }
      if (!bloc.state.reqStateGamers.isLoaded) {
        bloc.add(const FetchGamersEvent());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ExploreBloc, ExploreState>(
        bloc: bloc,
        buildWhen: (prev, curr) => prev != curr,
        builder: (context, state) {
          return _GamesTabViewBody(
            bloc: bloc,
            onRefresh: () async => _fetchGames(isLoading: false),
          );
        },
      ),
    );
  }
}
