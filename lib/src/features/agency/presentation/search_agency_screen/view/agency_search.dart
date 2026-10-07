import 'package:flutter/cupertino.dart';
import 'package:general/src/features/agency/presentation/search_agency_screen/view/show_hosts_agency.dart';

import 'package:general/src/core/index.dart';
import '../../../agency.dart';

class AgencySearch extends StatefulWidget {
  const AgencySearch({super.key});

  @override
  State<AgencySearch> createState() => _AgencySearchState();
}

class _AgencySearchState extends State<AgencySearch> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    di<AgencySearchBloc>().add(ResetAgencyEvent());
    di<AgencySearchBloc>().add(const AgencySearchAddListenerEvent());
  }

  @override
  void dispose() {
    di<AgencySearchBloc>().add(const AgencySearchRemoveListenerEvent());
    super.dispose();
    _searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundImgWidget(
      resize: false,
      child: Scaffold(
        backgroundColor: ColorManager.transparent,
        appBar: AppBarWidget(
          height: 60.h,
          backgroundColor: ColorManager.transparent,
          title: Container(
            height: 35.h,
            margin: context.paddingSymmetric(horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: 30.radius,
              // color: ColorManager.white,
            ),
            child: TextInputWidget(
              onChanged: (str) {
                di<AgencySearchBloc>().add(
                  FetchRegularAgencyEvent(id: str ?? ''),
                );
              },
              controller: _searchController,
              StringManager.searchAgencyID.tr(),
              keyboardType: TextInputType.number,
              fillColor: ColorManager.white,
              textColor: ColorManager.secondaryText,
              border: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: ColorManager.white,
                  width: 1,
                ),
                borderRadius: 30.radius,
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: ColorManager.white,
                  width: 1,
                ),
                borderRadius: 30.radius,
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: ColorManager.white,
                  width: 1,
                ),
                borderRadius: 30.radius,
              ),
              errorBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: ColorManager.redAccount,
                  width: 1,
                ),
                borderRadius: 30.radius,
              ),
              suffixIcon: InkWell(
                onTap: () {},
                child: Icon(
                  CupertinoIcons.clear,
                  color: ColorManager.grey.withValues(alpha: (0.4)),
                  size: 15.r,
                ),
              ),
              prefixIcon: InkWell(
                onTap: () {
                  di<AgencySearchBloc>()
                      .add(FetchRegularAgencyEvent(id: _searchController.text));
                },
                child: Icon(
                  Icons.search,
                  color: ColorManager.grey.withValues(alpha: (0.4)),
                  size: 20.r,
                ),
              ),
              hintStyle: context.bodyMedium.colorExt(
                  ColorManager.secondaryText.withValues(alpha: (0.8))),
              // cursorColor: ColorManager.black,
              textStyle: context.bodyLarge.colorExt(ColorManager.textPrimary),
              contentPadding: context.paddingOnly(
                top: 0,
                end: 0,
                bottom: 0,
                start: 0,
              ),
            ),
          ),
          titleStyle: context.titleLarge.w600
              .copyWith(fontFamily: StringManager.fontFamily),
        ),
        body: BlocBuilder<AgencySearchBloc, AgencySearchState>(
          bloc: di<AgencySearchBloc>(),
          buildWhen: (prev, curr) => prev.agencyState != curr.agencyState || prev.agencyModel != curr.agencyModel,
          builder: (context, state) {
            return HandlingDataWidget(
              reqState: state.agencyState,
              title: StringManager.noAgencyDataNowTitle.tr(),
              subTitle: StringManager.noAgencyDataNowSubTitle.tr(),
              child: ListView.builder(
                controller: state.agencyScrollCtrl,
                itemCount: state.agencyModel?.agencies?.length ?? 0,
                padding: context.paddingSymmetric(horizontal: 5),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return SearchItemWidget(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return ShowHostsAgency(
                              isProfile: false,
                              agencyData: state.agencyModel?.agencies![index],
                            );
                          },
                        ),
                      );
                    },
                    isMaster: false,
                    ownerImage:
                        state.agencyModel?.agencies![index].owner?.image ?? "",
                    ownerId: state.agencyModel?.agencies![index].owner?.id
                            .toString() ??
                        "",
                    ownerName:
                        state.agencyModel?.agencies![index].owner?.name ?? "",
                    ownerFrame:
                        state.agencyModel?.agencies![index].owner?.frame ?? "",
                    ownerFrameType: state
                            .agencyModel?.agencies![index].owner?.frameType ??
                        "",
                    isSelected: false,
                    id: '${state.agencyModel?.agencies![index].id}',
                    name: '${state.agencyModel?.agencies![index].name}',
                    image: '${state.agencyModel?.agencies![index].image}',
                    usersNumber:
                        '${state.agencyModel?.agencies![index].totalMembers}',
                    bio: '${state.agencyModel?.agencies![index].bio}',
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
