import 'dart:io';

import 'package:general/src/core/index.dart';
import 'package:general/src/features/family/family.dart';
import 'package:general/src/features/family/presentation/manger_family/bloc/manager_family_bloc.dart';

part 'components/form_input.dart';
part 'components/pick_image_body.dart';

class ManagerFamilyPage extends StatelessWidget {
  final ShowFamilyEntity? data;

  const ManagerFamilyPage({
    super.key,
    this.data,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<FetchUserDataBloc, FetchUserDataState>(
      bloc: di<FetchUserDataBloc>(),
      listener: (context, state) {
        if (state.reqState.isLoaded) {
          Navigator.pop(context);

          Navigator.pop(context);
          context.pushNamedRoute(Routes.familyScreen,
              arguments: state.userEntity?.familyId.toString() ?? '0');
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBarWidget(
          title: data == null ? StringManager.newFamily.tr() : StringManager.edit.tr(),
        ),
        body: Container(
          padding: context.paddingSymmetric(horizontal: 12),
          height: ScreenUtil().screenHeight,
          width: ScreenUtil().screenWidth,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                20.hBox,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextWidget(
                      StringManager.profilePicture.tr(),
                      textAlign: TextAlign.center,
                      style: context.bodySmall.w500
                          .colorExt(ColorManager.grey)
                          .size(14),
                    ),
                    _PickImageBody(
                        managerFamilyBloc:
                      di<ManagerFamilyBloc>(),
                        path: data?.img),
                  ],
                ),

                30.hBox,
                _FormWidget(
                  showFamilyEntity: data,
                ),
                140.hBox,
                Align(
                  alignment: Alignment.bottomCenter,
                  child: BlocBuilder<ManagerFamilyBloc, ManagerFamilyStates>(
                  bloc: di<ManagerFamilyBloc>(),
                    buildWhen: (prev, curr) => prev.reqState != curr.reqState,
                    builder: (context, state) {
                      return ButtonWidget(
                        onPressed: () {
                          di<ManagerFamilyBloc>().add(
                              ManagerFamilyEvent(
                                  familyId: data?.id.toString(),
                                  context: context));
                        },
                        isLoading: state.reqState.isLoading,
                        title: data != null
                            ? StringManager.confirm.tr()
                            : "${StringManager.create.tr()} (${MyDataModel.getInstance().familyPrice} ${StringManager.coins.tr()})",
                        height: 50.h,
                        radius: 25.r,
                        width: 280.w,
                        backgroundColor: ColorManager.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        titleColor: Colors.white,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
