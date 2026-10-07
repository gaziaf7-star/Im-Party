
part of 'package:general/src/features/agency/presentation/charge_agency/view/component/info_charge_agency/view/info_charge_agency_screen.dart';

class _PickImageBody extends StatelessWidget {
  const _PickImageBody({
    required this.bloc,
    required this.state,
  });

  final UpdateChargeAgencyBloc bloc;
  final GetChargeAgencyStates state;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: ScreenUtil().screenWidth * 0.37,
      height: ScreenUtil().screenWidth * 0.27,
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          BlocBuilder<UpdateChargeAgencyBloc, UpdateChargeAgencyState>(
            bloc: bloc,
            buildWhen: (prev, curr) => prev.pathImg != curr.pathImg,
            builder: (context, chargeState) {
              return chargeState.pathImg.isNotEmpty
                  ? Container(
                      height: 80.h,
                      width: 80.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: ColorManager.white.withValues(alpha: (0.4 ))),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: FileImage(
                            File(chargeState.pathImg),
                          ),
                        ),
                      ),
                    )
                  : UserImage(
                      image: state.myChargeAgencyData?.img??'',
                      displayName: state.myChargeAgencyData?.name ?? '',
                      imageSize: 80.w,
                      border: Border.all(
                          color: ColorManager.white.withValues(alpha: (0.4 ))),
                      borderRadius: 40.radius,
                    );
            },
          ),
          // Image.asset(
          //   AssetsManager.frameCharge,
          //   scale: 3.5,
          // ),
          Positioned(
            left: 85.w,
            top: 70.w,
            child: InkWell(
              onTap: () {
                bloc.add(
                  PickImageEvent(
                    source: ImageSource.gallery,
                    phone: state.myChargeAgencyData?.phone??'',
                    id: '${state.myChargeAgencyData?.id??''}',
                  ),
                );
              },
              child: Container(
                padding: context.paddingAll(5),
                margin: EdgeInsets.only(
                  right: 18.w,
                  bottom: 10.w,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: (0.2 )),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: ColorManager.white.withValues(alpha: (0.4 )),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  CupertinoIcons.camera,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
