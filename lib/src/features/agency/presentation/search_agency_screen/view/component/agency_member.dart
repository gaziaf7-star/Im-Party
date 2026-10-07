part of '../show_hosts_agency.dart';

class AgencyMember extends StatelessWidget {
  final List<MemberEntity>? members;

  const AgencyMember({super.key, required this.members});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AgencySearchBloc, AgencySearchState>(
        bloc: di<AgencySearchBloc>(),
        buildWhen: (prev, curr) => prev.state != curr.state,
        builder: (context, state) {
          return HandlingDataWidget(
            title: StringManager.noAgencyDataNowTitle.tr(),
            subTitle: StringManager.noAgencyDataNowSubTitle.tr(),
            reqState: di<AgencySearchBloc>().state.state,
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              removeLeft: true,
              removeBottom: true,
              removeRight: true,
              child: ListView.builder(
                padding: context.paddingZero(),
                itemCount: members?.length ?? 0,
                itemBuilder: (context, index) {
                  return Container(
                    // margin: context.paddingSymmetric(horizontal: 10),
                    padding: context.paddingSymmetric(vertical: 5),
                    // decoration: BoxDecoration(
                    //   color: ColorManager.white,
                    //   borderRadius: 5.radius,
                    // ),
                    child: Row(
                      children: [
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: ImageViewWidget(
                            url: members?[index].image ?? "",
                            displayName: members?[index].name ?? '',
                            boxFit: BoxFit.cover,
                            width: 50.w,
                            height: 50.h,
                            radius: 50.r,
                          ),
                        ),
                        10.wBox,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              TextWidget(
                                members?[index].name ?? "",
                                style: context.bodyLarge.w500,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              10.wBox,
                              TextWidget(
                                "ID: ${members?[index].uuid ?? ""}",
                                style: TextStyle(
                                    color: ColorManager.textPrimary
                                        .withValues(alpha: (0.7)),
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w400),
                              ),

                              //15.hBox,
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
                // separatorBuilder: (context, index) => Divider(
                //   color: Colors.black.withValues(alpha: 0.1),
                //   thickness: 2,
                //   indent: 50,
                //   endIndent: 50,
                // ),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
              ),
            ),
          );
        });
  }
}
