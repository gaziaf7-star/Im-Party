part of '../family_requests_page.dart';

class _RequestsBody extends StatelessWidget {
  const _RequestsBody({required this.data,
    required this.bloc,
    required this.familyId,
  });

  final List<FamilyRequestEntity>? data;
  final TakeActionBloc bloc;
  final String familyId;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: data?.length??0,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: context.paddingAll(5),
      itemBuilder: (context, index) {
        return _UserInfoRowBody(
          userEntity: data![index].user,
          // underNameWidth: MediaQuery.of(context).size.width - 180,
          endIcon: Row(
            children: [
              InkWell(
                onTap: () => bloc.add(
                  FamilyTakeActionEvent(
                      status: '1',
                      reqId: '${data![index].id}',
                      userId: '${data![index].user.id}',
                      familyId: familyId),
                ),
                child: Image.asset(
                  AssetsManager.acceptIcon,
                  scale: 4,
                ),
              ),
              10.wBox,
              InkWell(
                onTap: () => bloc.add(
                  FamilyTakeActionEvent(
                    status: '2',
                    reqId: '${data![index].id}',
                    userId: '${data![index].user.id}',
                    familyId: familyId
                  ),
                ),
                child: Image.asset(
                  AssetsManager.declineIcon,
                  scale: 4,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
