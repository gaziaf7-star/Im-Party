part of 'package:general/src/features/auth/presentation/add_information/view/add_information_page.dart';

class _PickImageBody extends StatelessWidget {
  const _PickImageBody({required this.state});

  final AddInformationState state;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.read<AddInformationBloc>().add(
            PickImageEvent(image: state.image),
          ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomRight,
        children: [
          Container(
            height: 55.h,
            width: 55.h,
            padding: const EdgeInsets.symmetric(),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: state.image != null
                    ?ColorManager.white:ColorManager.transparent,
                width: 2
              ),
              image: state.image != null
                  ? DecorationImage(
                      scale: 0.5,
                      fit: BoxFit.fill,
                      image: FileImage(
                        state.image ?? File(''),
                      ),
                    )
                  : DecorationImage(
                      fit: BoxFit.cover,
                      scale: 4,
                      image: AssetImage(AssetsManager.userAddInfo),
                    ),
            ),
          ),
          Positioned(
            bottom: -5.h,
            right: -5.w,
            child: CircleAvatar(
              radius: 12.r,
              backgroundColor: ColorManager.primary,
              child:Icon(Icons.camera_alt_rounded,size: 12.r,),
            ),
          )
        ],
      ),
    );
  }
}
