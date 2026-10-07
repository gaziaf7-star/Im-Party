import 'package:general/src/features/chats/chats.dart';

part 'widgets/system_massage_card.dart';

class SystemMessagesScreen extends StatefulWidget {
  const SystemMessagesScreen({super.key});

  @override
  State<SystemMessagesScreen> createState() => _SystemMessagesScreenState();
}

class _SystemMessagesScreenState extends State<SystemMessagesScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    if (!di<GetSystemChatBloc>().state.systemReqState.isLoaded) {
      di<GetSystemChatBloc>().add(const GetSystemChatEvent());
    }

    _scrollController.addListener(() {
      // لو عايز تزود لما يوصل لأول القائمة (بما إنها reversed)
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        di<GetSystemChatBloc>().add(LoadMoreSystemChatEvent());
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
      backgroundColor: ColorManager.scaffoldBg,
      appBar: AppBarWidget(
        backgroundColor: ColorManager.scaffoldBg,
        title: StringManager.systemMessage.tr(),
      ),
      body: SizedBox(
        height: ScreenUtil().screenHeight - 95,
        child: BlocBuilder<GetSystemChatBloc, GetSystemChatsStates>(
          bloc: di<GetSystemChatBloc>(),
          buildWhen: (prev, curr) => prev.systemReqState != curr.systemReqState || prev.systemEntity != curr.systemEntity,
          builder: (context, state) {
            return HandlingDataWidget(
              reqState: state.systemReqState,
              title: StringManager.noAlerts.tr(),
              subTitle: StringManager.emptyNotifications.tr(),
              onTap: () => di<GetSystemChatBloc>()
                  .add(const GetSystemChatEvent(isLoading: false)),
              child: ListView.builder(
                controller: _scrollController,
                reverse: true,
                itemCount: state.systemEntity.length,
                physics: const AlwaysScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  if (state.systemEntity[index].title != "") {
                    return SystemMessageCard(
                      index: index,
                      userId:
                          int.parse('${state.systemEntity[index].fromUserId}'),
                      img: state.systemEntity[index].img,
                      title: state.systemEntity[index].title,
                      created: state.systemEntity[index].created,
                    );
                  }
                  return null;
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
