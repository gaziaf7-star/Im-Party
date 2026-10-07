import 'dart:io';

import 'package:general/src/core/index.dart';
import 'package:general/src/features/groups/domain/entities/group_enums.dart';
import 'package:general/src/features/groups/domain/entities/group_params.dart';
import 'package:general/src/features/groups/presentation/create_group/bloc/create_group_bloc.dart';
import 'package:general/src/features/groups/presentation/groups_list/bloc/groups_list_bloc.dart';
import 'package:general/src/features/groups/presentation/widgets/group_form_fields.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  File? _avatar;
  GroupPrivacy _privacy = GroupPrivacy.public;
  GroupJoinPolicy _joinPolicy = GroupJoinPolicy.open;
  bool _onlyAdminsPost = false;

  @override
  void initState() {
    super.initState();
    di<CreateGroupBloc>().add(const ResetCreateGroupEvent());
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picked =
    await Methods.pickImageSafely(ImagePicker(), source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _avatar = File(picked.path));
    }
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    di<CreateGroupBloc>().add(
      SubmitCreateGroupEvent(
        CreateGroupParams(
          name: _nameController.text.trim(),
          avatar: _avatar,
          privacy: _privacy,
          joinPolicy: _joinPolicy,
          onlyAdminsPost: _onlyAdminsPost,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fixed white + brand-gradient app bar (was the panel-driven
      // scaffoldBg/flat app bar) — matches the professional look used
      // across the app.
      backgroundColor: ColorManager.white,
      appBar: AppBarWidget(
        title: StringManager.createGroup.tr(),
        backgroundGradient: ColorManager.brandGradient,
        titleStyle: context.titleLarge.w600
            .size(16)
            .colorExt(ColorManager.onBrandGradient),
        iconColor: ColorManager.onBrandGradient,
      ),
      body: BlocConsumer<CreateGroupBloc, CreateGroupState>(
        bloc: di<CreateGroupBloc>(),
        listener: (context, state) {
          if (state.reqState.isError) {
            Methods.showToast(context, isError: true, message: state.message);
          } else if (state.reqState.isLoaded && state.createdGroup != null) {
            Methods.showToast(context, message: StringManager.groupCreated.tr());
            // Add the new group to the in-memory groups tab IN-PLACE (dedup by id)
            // so it appears the moment we return — regardless of which entry point
            // opened this screen (the chats-tab FAB ignored the pop result, so the
            // group otherwise stayed hidden until a cold-start refetch).
            di<GroupsListBloc>()
                .add(UpsertGroupLocallyEvent(state.createdGroup!));
            Navigator.pop(context, true);
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: context.paddingAll(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: GroupAvatarPicker(
                      avatarFile: _avatar,
                      onTap: _pickAvatar,
                    ),
                  ),
                  24.hBox,
                  GroupNameField(
                    controller: _nameController,
                  ),
                  20.hBox,
                  GroupPrivacySelector(
                    privacy: _privacy,
                    onChanged: (value) => setState(() => _privacy = value),
                  ),
                  16.hBox,
                  GroupJoinPolicySelector(
                    joinPolicy: _joinPolicy,
                    onChanged: (value) => setState(() => _joinPolicy = value),
                  ),
                  16.hBox,
                  GroupSwitchTile(
                    title: StringManager.onlyAdminsPost.tr(),
                    value: _onlyAdminsPost,
                    onChanged: (value) =>
                        setState(() => _onlyAdminsPost = value),
                  ),
                  32.hBox,
                  MainButton(
                    title: StringManager.createGroup.tr(),
                    height: 50,
                    titleSize: 16,
                    // Brand gradient (was the flat panel-driven primary).
                    buttonColorList: ColorManager.brandGradientColors,
                    titleColor: ColorManager.onBrandGradient,
                    isLoading: state.reqState.isLoading,
                    onTap: _submit,
                  ),
                  20.hBox,
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}