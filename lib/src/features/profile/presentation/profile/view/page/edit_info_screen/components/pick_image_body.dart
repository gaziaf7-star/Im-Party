part of '../edit_profile_screen.dart';

class PickImageBody extends StatelessWidget {
  const PickImageBody({super.key, required this.bloc, this.image});

  final EditInformationBloc bloc;
  final String? image;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditInformationBloc, EditInformationState>(
      bloc: di<EditInformationBloc>(),
      buildWhen: (prev, curr) => prev.image != curr.image,
      builder: (context, state) {
        if (state.image != null) {
          return Container(
            height: 60.h,
            width: 60.h,
            decoration: BoxDecoration(
              color: ColorManager.black,
              shape: BoxShape.circle,
              image: DecorationImage(
                fit: BoxFit.cover,
                image: FileImage(bloc.state.image!),
              ),
            ),
          );
        } else {
          return ImageViewWidget(
            url: image ?? "",
            boxFit: BoxFit.cover,
            height: 60.h,
            width: 60.h,
            shape: BoxShape.circle,
          );
        }
      },
    );
  }
}
