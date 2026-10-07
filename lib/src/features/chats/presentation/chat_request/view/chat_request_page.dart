import 'package:general/src/features/chats/chats.dart';
import 'package:general/src/features/chats/presentation/chat_request/bloc/get_users_chat_request/chat_request_bloc.dart';

class ChatRequestPage extends StatefulWidget {
  const ChatRequestPage({super.key});

  @override
  State<ChatRequestPage> createState() => _ChatRequestPageState();
}

class _ChatRequestPageState extends State<ChatRequestPage>
    with TickerProviderStateMixin {
  @override
  void initState() {
    //if (!di<FetchChatRequestBloc>().state.reqState.isLoaded) {
    di<FetchChatRequestBloc>().add(const GetChatRequestUsersEvent());
    //}
    super.initState();
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
        title: StringManager.friendRequest.tr(),
        titleStyle: context.titleLarge.w600
            .size(16)
            .colorExt(ColorManager.onBrandGradient),
        iconColor: ColorManager.onBrandGradient,
      ),
      body: SafeArea(
        child: RefreshIndicatorWidget(
          onRefresh: () async =>
              di<FetchChatRequestBloc>().add(const GetChatRequestUsersEvent()),
          child: BlocBuilder<FetchChatRequestBloc, FetchChatRequestState>(
            bloc: di<FetchChatRequestBloc>(),
            buildWhen: (prev, curr) =>
            prev.reqState != curr.reqState || prev.data != curr.data,
            builder: (context, state) {
              return HandlingDataWidget(
                reqState: state.reqState,
                title: StringManager.noChats.tr(),
                subTitle: StringManager.noUsersMsg.tr(),
                titleStyle: context.bodyLarge
                    .colorExt(ColorManager.momentPostTextColor)
                    .w600,
                subTitleStyle: context.bodyMedium
                    .colorExt(ColorManager.momentPostTextColor),
                buttonBackgroundColors: ColorManager.brandGradientColors,
                buttonBorderColor: ColorManager.transparent,
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: state.data.length,
                  padding:
                  context.paddingSymmetric(vertical: 10, horizontal: 10),
                  itemBuilder: (__, index) {
                    return ChatRoomCard(
                      userChatEntity: state.data[index],
                      onLongPress: () => _deleteChat(context, state, index),
                      isMe: '${state.data[index].lastMessage.senderId}' ==
                          '${MyDataModel.getInstance().id}',
                      onTap: () {
                        di<FetchChatRequestBloc>().add(
                          UpdateTotalMessagesRequest(
                            userId: state.data[index].userId.toString(),
                            isIncreased: false,
                          ),
                        );
                        Navigator.pushNamed(
                          context,
                          Routes.messages,
                          arguments: MessagesParameter(
                            hasColorName: state.data[index].hasColorName,
                            name: state.data[index].name,
                            image: state.data[index].image,
                            userId: '${state.data[index].userId}',
                            isNotFriend: true,
                          ),
                        );
                      },
                    );
                  },
                  separatorBuilder: (context, index) => Container(
                    margin: context.paddingSymmetric(horizontal: 20),
                    height: 10,
                    color: ColorManager.transparent,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<dynamic> _deleteChat(
      BuildContext context,
      FetchChatRequestState state,
      int index,
      ) {
    return showDialog(
      context: context,
      builder: (_) => AnimatedDialog(
        title: StringManager.deleteChatTitle.tr(),
        description: StringManager.deleteChatSubTitle.tr(),
        conText: StringManager.done.tr(),
        dialogBackgroundColor: ColorManager.white,
        titleColor: ColorManager.momentPostTextColor,
        descriptionColor: ColorManager.momentPostTextColor,
        cancelTextColor: ColorManager.momentPostTextColor,
        confirmGradientColors: ColorManager.brandGradientColors,
        onTap: () {
          di<DeleteChatBloc>().add(
            DeleteChatEvent(userId: state.data[index].userId),
          );
          di<FetchChatRequestBloc>().add(
            RemoveLocalChatRequestUserEvent(
              chatId: state.data[index].chatId,
            ),
          );
          Navigator.pop(context);
        },
      ),
    );
  }
}