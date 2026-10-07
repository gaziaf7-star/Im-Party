part of '../family_screen.dart';

class MoreIconBody extends StatelessWidget {
  final ShowFamilyEntity? familyEntity;
  final Color? iconColor;
  final bool isNewRequest;

  const MoreIconBody(
      {required this.familyEntity,
      required this.iconColor,
      super.key,
      required this.isNewRequest});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      iconColor: iconColor,
      color: ColorManager.black.withValues(alpha: (0.8 )),
      elevation: 0.0,
      style: TextButton.styleFrom(
          minimumSize: const Size(10, 10), padding: context.paddingZero()),
      padding: context.paddingZero(),
      icon: const Icon(Icons.more_vert),
      shape: RoundedRectangleBorder(borderRadius: 5.radius),
      itemBuilder: (_) => [
        if (familyEntity!.amIOwner == true && familyEntity!.id.toString()==
            '${MyDataModel.getInstance().familyId}') ...{
          popUpItemWidget(
            title: StringManager.edit.tr(),
            icon: Icons.edit_square,
            context: context,
            onTap: () {
              Navigator.pushNamed(context, Routes.createFamilyScreen,
                  arguments: CreateFamilyParam(
                    data: familyEntity!,
                  ));
            },
          ),
        },
        if (familyEntity!.amIOwner == true && familyEntity!.id.toString()==
            '${MyDataModel.getInstance().familyId}') ...{
          popUpItemWidget(
              title: StringManager.deleteFamily.tr(),
              icon: CupertinoIcons.delete_solid,
              context: context,
              onTap: () => {
                    showDialog(
                        context: context,
                        builder: (_) => AnimatedDialog(
                              title: StringManager.deleteFamily.tr(),
                              description:
                                  StringManager.areYouSureDeleteFamily.tr(),
                              conText: StringManager.done.tr(),
                              onTap: () {
                                di<DeleteFamilyBloc>().add(DeleteFamilyEvent(
                                    id: (familyEntity?.id ?? 0).toString()));
                              },
                            )
                        // Navigator.pushNamed(context, Routes.deleteScreen,
                        //     arguments: (familyEntity?.id ?? 0).toString()),
                        )
                  }),
        },
        if (familyEntity!.amIOwner == false && familyEntity!.id.toString()==
            '${MyDataModel.getInstance().familyId}') ...{
          popUpItemWidget(
            title: StringManager.exitFamily.tr(),
            context: context,
            icon: Icons.login,
            onTap: () => _showExitFamilyDialog(context),
          ),
        },
        if (familyEntity != null &&
            (familyEntity!.amIOwner! || familyEntity!.amIAdmin!) && familyEntity!.id.toString()==
            '${MyDataModel.getInstance().familyId}') ...{
          popUpItemWidget(
            title: StringManager.familyRequest.tr(),
            context: context,
            numOfRequests: familyEntity!.numOfRequests.toString(),
            showNotificationNum: true,
            icon: CupertinoIcons.bell_fill,
            onTap: () => Navigator.pushNamed(
              context,
              Routes.familyRequests,
              arguments: familyEntity!.id.toString(),
            ),
          ),

        },
      ],
    );
  }
}
