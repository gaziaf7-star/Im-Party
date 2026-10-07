import 'package:general/src/core/index.dart';
import 'package:general/src/features/groups/domain/entities/group_params.dart';
import 'package:general/src/features/groups/presentation/groups_list/bloc/groups_list_bloc.dart';
import 'package:general/src/features/groups/presentation/join_group/bloc/join_group_bloc.dart';

class JoinGroupArgs {
  final int? groupId;
  final String? inviteToken;

  const JoinGroupArgs({this.groupId, this.inviteToken});
}

class JoinGroupScreen extends StatefulWidget {
  final JoinGroupArgs args;

  const JoinGroupScreen({super.key, required this.args});

  @override
  State<JoinGroupScreen> createState() => _JoinGroupScreenState();
}

class _JoinGroupScreenState extends State<JoinGroupScreen> {
  final _tokenController = TextEditingController();

  @override
  void initState() {
    super.initState();
    di<JoinGroupBloc>().add(const ResetJoinGroupEvent());
    if (widget.args.inviteToken != null) {
      _tokenController.text = widget.args.inviteToken!;
    }
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  void _submit() {
    final token = _tokenController.text.trim();
    di<JoinGroupBloc>().add(
      SubmitJoinGroupEvent(
        JoinGroupParams(
          groupId: widget.args.groupId,
          inviteToken: token.isEmpty ? null : token,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.scaffoldBg,
      appBar: AppBarWidget(
        title: StringManager.joinGroup.tr(),
        backgroundColor: ColorManager.scaffoldBg,
      ),
      body: BlocConsumer<JoinGroupBloc, JoinGroupState>(
        bloc: di<JoinGroupBloc>(),
        listener: (context, state) {
          if (state.reqState.isError) {
            Methods.showToast(context, isError: true, message: state.message);
          } else if (state.reqState.isLoaded && state.joinedGroup != null) {
            di<GroupsListBloc>().add(UpsertGroupLocallyEvent(state.joinedGroup!));
            Methods.showToast(context, message: state.message);
            Navigator.pop(context, state.joinedGroup);
          }
        },
        builder: (context, state) {
          return Padding(
            padding: context.paddingAll(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                  StringManager.inviteLink.tr(),
                  style: context.bodyMedium.w600
                      .colorExt(ColorManager.textPrimary),
                ),
                8.hBox,
                Container(
                  decoration: BoxDecoration(
                    color: ColorManager.white,
                    borderRadius: 12.radius,
                    border: Border.all(color: ColorManager.divider),
                  ),
                  child: TextInputWidget(
                    StringManager.inviteLink,
                    controller: _tokenController,
                    textColor: ColorManager.textPrimary,
                    cursorColor: ColorManager.primary,
                  ),
                ),
                32.hBox,
                MainButton(
                  title: StringManager.joinGroup.tr(),
                  height: 50,
                  isLoading: state.reqState.isLoading,
                  onTap: _submit,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
