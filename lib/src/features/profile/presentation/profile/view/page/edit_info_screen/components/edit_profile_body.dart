part of '../edit_profile_screen.dart';

// ignore: must_be_immutable
class _EditProfileBody extends StatelessWidget {
  EditInformationBloc blocInfo = di<EditInformationBloc>();
  final MyDataEntity data;

  _EditProfileBody({required this.data, required this.blocInfo});

  @override
  Widget build(BuildContext context) {
    return EditInfoForm(data: data);
  }
}
