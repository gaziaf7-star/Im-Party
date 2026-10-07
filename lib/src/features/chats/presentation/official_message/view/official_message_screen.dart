import 'package:general/src/features/chats/chats.dart';

import 'widgets/official_message_card.dart';

class OfficialMessageScreen extends StatefulWidget {
  const OfficialMessageScreen({super.key});

  @override
  State<OfficialMessageScreen> createState() => _OfficialMessageScreen();
}

class _OfficialMessageScreen extends State<OfficialMessageScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    if (!di<GetSystemChatBloc>().state.officialReqState.isLoaded) {
      di<GetSystemChatBloc>().add(const GetOfficialChatEvent());
    }

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        di<GetSystemChatBloc>().add(LoadMoreOfficialChatEvent());
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
    return Scaffold(
      // Fixed white + brand-gradient app bar (was the panel-driven
      // scaffoldBgAlt/flat app bar) — matches the professional look used
      // across the app.
      backgroundColor: ColorManager.white,
      appBar: AppBarWidget(
        backgroundGradient: ColorManager.brandGradient,
        title: StringManager.team.tr(),
        titleStyle: context.bodyLarge.bold
            .size(18)
            .colorExt(ColorManager.onBrandGradient),
        iconColor: ColorManager.onBrandGradient,
        height: 40,
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<GetSystemChatBloc, GetSystemChatsStates>(
              bloc: di<GetSystemChatBloc>(),
              buildWhen: (prev, curr) =>
              prev.officialReqState != curr.officialReqState ||
                  prev.officialEntity != curr.officialEntity,
              builder: (BuildContext context, GetSystemChatsStates state) {
                return HandlingDataWidget(
                  reqState: state.officialReqState,
                  title: StringManager.noAlerts.tr(),
                  subTitle: StringManager.emptyNotifications.tr(),
                  titleStyle: context.bodyLarge
                      .colorExt(ColorManager.momentPostTextColor)
                      .w600,
                  subTitleStyle: context.bodyMedium
                      .colorExt(ColorManager.momentPostTextColor),
                  buttonBackgroundColors: ColorManager.brandGradientColors,
                  buttonBorderColor: ColorManager.transparent,
                  onTap: () => di<GetSystemChatBloc>()
                      .add(const GetOfficialChatEvent(isLoading: false)),
                  child: ListView.builder(
                    controller: _scrollController,
                    itemBuilder: (context, index) {
                      if (state.officialEntity[index].title != "") {
                        return OfficialMessageCard(
                          title: state.officialEntity[index].title,
                          content: state.officialEntity[index].content,
                          created: state.officialEntity[index].created,
                          img: state.officialEntity[index].img,
                          url: state.officialEntity[index].url,
                        );
                      }
                      return const SizedBox();
                    },
                    shrinkWrap: true,
                    reverse: true,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: state.officialEntity.length,
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