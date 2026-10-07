import 'dart:io';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/domain/entities/multi_images_entity.dart';
import 'package:general/src/features/auth/domain/entities/my_data_entity.dart';
import 'package:general/src/features/auth/presentation/country/bloc/countries_bloc.dart';
import 'package:general/src/features/profile/presentation/profile/view/page/edit_info_screen/bloc/edit_information/edit_information_bloc.dart';

part 'add_multi_picture.dart';

part 'components/edit_info_form.dart';

part 'components/edit_info_screen.dart';

part 'components/edit_profile_body.dart';

part 'components/pick_image_body.dart';

part 'widget/edit_birthday_row.dart';

part 'widget/edit_gender_row.dart';

part 'widget/row_edit_info.dart';

part 'widget/select_cover_image_dialog.dart';

part 'widget/select_image_dialog.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.data});

  final MyDataModel data;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final EditInformationBloc _bloc = di<EditInformationBloc>();

  @override
  void initState() {
    _bloc.add(AssignInformationEvent());

    if (!di<CountriesBloc>().state.requestState.isLoaded) {
      di<CountriesBloc>().add(const FetchCountriesEvent());
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.white,
      appBar: AppBarWidget(
        iconColor: Colors.black,
        title: StringManager.editProfile.tr(),
        backgroundColor: ColorManager.white,
        titleStyle: context.bodyLarge.bold.colorExt(ColorManager.black),
      ),
      body: BlocListener<EditInformationBloc, EditInformationState>(
        bloc: di<EditInformationBloc>(),
        listener: (context, state) {
          if (state.requestState.isLoaded) {
            di<FetchUserDataBloc>()
                .add(const FetchMyDataEvent(isLoading: false));
            Methods.showToast(context, message: state.message);
            di<EditInformationBloc>().add(const InitialStateEvent());
          }

          if (state.requestState.isError) {
            Methods.showToast(context, message: state.message, isError: true);
          }

          if (state.reqStateChangeCountry.isLoading) {
            Methods.showToast(context, isLoading: true);
            di<EditInformationBloc>().add(const InitialStateEvent());
          }

          if (state.reqStateChangeCountry.isLoaded) {
            Methods.showToast(context, message: state.message);
            di<EditInformationBloc>().add(const InitialStateEvent());
          }

          if (state.reqStateChangeCountry.isError) {
            Methods.showToast(context, message: state.message, isError: true);
          }
        },
        child: BlocBuilder<FetchUserDataBloc, FetchUserDataState>(
          bloc: di<FetchUserDataBloc>(),
          buildWhen: (prev, curr) => prev.reqState != curr.reqState || prev.userEntity != curr.userEntity,
          builder: (context, state) {
            if (state.reqState.isLoaded) {
              return _EditProfileBody(
                data: state.userEntity ?? const MyDataEntity(),
                blocInfo: _bloc,
              );
            } else {
              return _EditProfileBody(
                data: widget.data,
                blocInfo: _bloc,
              );
            }
          },
        ),
      ),
    );
  }
}