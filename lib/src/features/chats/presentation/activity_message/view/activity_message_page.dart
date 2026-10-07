import 'package:general/src/features/chats/chats.dart';
part 'widgets/activity_chat_card.dart';

class ActivityMessagePage extends StatefulWidget {
  const ActivityMessagePage({super.key});

  @override
  State<ActivityMessagePage> createState() => _ActivityMessagePageState();
}

class _ActivityMessagePageState extends State<ActivityMessagePage> {
  final GetSystemChatBloc bloc = di<GetSystemChatBloc>();
  @override
  void initState() {
    super.initState();
    // if (bloc.state.reqState != RequestState.loaded) {
    //   bloc.add(const GetSystemChatEvent());
    // }
  }

  @override
  Widget build(BuildContext context) {
  //  Brightness currentBrightness = Theme.of(context).brightness;
    //bool isDarkTheme = currentBrightness == Brightness.dark;
    return BlocBuilder<GetSystemChatBloc, GetSystemChatsStates>(
      bloc: bloc,
      buildWhen: (prev, curr) => prev != curr,
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                Container(
                  height: 40,
                  width: 40,
                  margin: context.paddingAll(5),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage(
                          AssetsManager.logo,
                        ),
                      )),
                ),
                 TextWidget(StringManager.officialMessage.tr()),
              ],
            ),
            actions: [
              Container(
                color: ColorManager.white,
                padding: context.paddingSymmetric(horizontal: 10),
                child: Row(
                  children: [
                    TextButtonWidget(
                      onTap: () {
                        context.pushNamedRoute(Routes.problemReportsScreen);
                      },
                      content: TextWidget(
                        StringManager.suggestion.tr(),
                        style: context.bodyMedium.w500
                            .colorExt(ColorManager.secondaryText)
                            .underline,
                      ),
                    ),
                    10.wBox,
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 18.5.h,
                        color: ColorManager.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // body: HandlingDataWidget(
          //   reqState: state.reqState,
          //   title: StringManager.noMessages,
          //   subTitle: StringManager.noMessagesMsg,
          //   onTap: (){
          //     bloc.add(const GetSystemChatEvent());
          //   },
          //   child: ListView.builder(
          //     padding: context.paddingOnly(
          //       top: 50,
          //       bottom: 20,
          //     ),
          //     itemCount: state.data?.officialEntity?.length??0,
          //     reverse: true,
          //     itemBuilder: (context, index) {
          //       return ActivityChatCard(
          //         img: state.data!.officialEntity![index].img,
          //         content: state.data!.officialEntity![index].content,
          //         title: state.data!.officialEntity![index].title,
          //         createdAt: state.data!.officialEntity![index].created,
          //       );
          //     },
          //   ),
          // ),
        );
      },
    );
  }
}
