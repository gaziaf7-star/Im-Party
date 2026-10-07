part of 'package:general/src/features/agency/presentation/search_agency_screen/view/search_for_agency_screen.dart';

class _AgenciesBody extends StatelessWidget {
  const _AgenciesBody({required this.selectedIdNotifier, this.isMaster});

  final ValueNotifier<String> selectedIdNotifier;
  final bool? isMaster;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AgencySearchBloc, AgencySearchState>(
      bloc: di<AgencySearchBloc>(),
      buildWhen: (prev, curr) =>
          prev.agencyState != curr.agencyState ||
          prev.agencyModel != curr.agencyModel ||
          prev.isPaginatingAgency != curr.isPaginatingAgency,
      builder: (context, state) {
        final agencies = state.agencyModel?.agencies ?? const [];
        return HandlingDataWidget(
          reqState: state.agencyState,
          title: StringManager.noAgencyDataNowTitle.tr(),
          subTitle: StringManager.noAgencyDataNowSubTitle.tr(),
          child: ListView.builder(
            controller: state.agencyScrollCtrl,
            physics: const AlwaysScrollableScrollPhysics(),
            // +1 for the bottom load-more spinner while paginating.
            itemCount: agencies.length + (state.isPaginatingAgency ? 1 : 0),
            padding: context.paddingSymmetric(horizontal: 5),
            itemBuilder: (context, index) {
              if (index >= agencies.length) {
                return Padding(
                  padding: context.paddingSymmetric(vertical: 16),
                  child: const Center(child: CircularProgressIndicator()),
                );
              }
              final agency = agencies[index];
              return ValueListenableBuilder(
                valueListenable: selectedIdNotifier,
                builder: (context, value, child) => SearchItemWidget(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return ShowHostsAgency(
                            isProfile: false,
                            agencyData: agency,
                          );
                        },
                      ),
                    );
                  },
                  isMaster: isMaster,
                  ownerImage: agency.owner?.image ?? "",
                  ownerId: agency.owner?.id.toString() ?? "",
                  ownerName: agency.owner?.name ?? "",
                  ownerFrame: agency.owner?.frame ?? "",
                  ownerFrameType: agency.owner?.frameType ?? "",
                  isSelected: selectedIdNotifier.value == '${agency.id}',
                  id: '${agency.id}',
                  name: '${agency.name}',
                  image: '${agency.image}',
                  usersNumber: '${agency.totalMembers}',
                  bio: '${agency.bio}',
                ),
              );
            },
          ),
        );
      },
    );
  }
}