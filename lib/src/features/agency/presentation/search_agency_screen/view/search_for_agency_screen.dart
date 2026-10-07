import 'package:flutter/cupertino.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/agency/presentation/search_agency_screen/view/show_hosts_agency.dart';
import 'package:general/src/features/chats/presentation/chats/bloc/manager_get_users_chat/get_users_chat_bloc.dart';
import '../../../../../core/widgets/id_with_copy.dart';
import '../../../agency.dart';

part 'component/agencies_body.dart';
part 'widgets/search_item_widget.dart';

class SearchForAgencyScreen extends StatefulWidget {
  const SearchForAgencyScreen({super.key});

  @override
  State<SearchForAgencyScreen> createState() => _SearchForAgencyScreenState();
}

class _SearchForAgencyScreenState extends State<SearchForAgencyScreen>
    with TickerProviderStateMixin {
  late final TextEditingController _searchController;
  late TabController _controller;
  late final ValueNotifier<String> _selectedIdNotifier;

  @override
  void initState() {
    super.initState();
    // Load the full, activity-sorted agency list (most active first) with
    // infinite scroll. Uses the regular (paginated) flow + scroll listener.
    di<AgencySearchBloc>().add(ResetAgencyEvent());
    di<AgencySearchBloc>().add(const FetchRegularAgencyEvent(id: ""));
    di<AgencySearchBloc>().add(const AgencySearchAddListenerEvent());

    _controller = TabController(length: 2, vsync: this);
    _searchController = TextEditingController();
    _selectedIdNotifier = ValueNotifier<String>("");
  }

  @override
  void dispose() {
    di<AgencySearchBloc>().add(const AgencySearchRemoveListenerEvent());
    super.dispose();
    _controller.dispose();
    _searchController.dispose();
    _selectedIdNotifier.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final normalPage = BackgroundImgWidget(
      child: Scaffold(
        backgroundColor: ColorManager.transparent,
        floatingActionButton: FloatingActionButton.extended(
          elevation: 2.0,
          backgroundColor: ColorManager.primary,
          shape: RoundedRectangleBorder(borderRadius: 30.radius),
          onPressed: () =>
              di<AgencySearchBloc>().add(FetchFormListEvent(context: context)),
          label: Text(StringManager.createAgency.tr()),
          icon: const Icon(CupertinoIcons.add),
        ),
        appBar: AppBarWidget(
          backgroundColor: ColorManager.transparent,
          title: StringManager.agencies.tr(),
          titleStyle: context.bodyLarge.bold,
          actions: [
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, Routes.agencySearch);
              },
              icon: const Icon(
                CupertinoIcons.search,
                size: 20,
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              10.hBox,
              Expanded(
                child: _AgenciesBody(
                  selectedIdNotifier: _selectedIdNotifier,
                  isMaster: true,
                ),
              ),
              ValueListenableBuilder(
                valueListenable: _selectedIdNotifier,
                builder: (context, _, child) =>
                    _selectedIdNotifier.value.isEmpty
                        ? const SizedBox.shrink()
                        : Padding(
                            padding: context.paddingSymmetric(
                                vertical: 15, horizontal: 90),
                            child: ButtonWidget(
                              height: 40.h,
                              isLoading: di<JoinToAgenciesBloc>()
                                  .state
                                  .state
                                  .isLoading,
                              onPressed: () {
                                di<JoinToAgenciesBloc>().add(
                                  JoinToAgencyEvent(
                                    agencyId: _selectedIdNotifier.value,
                                    context: context,
                                  ),
                                );
                              },
                              title: StringManager.join.tr(),
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );

    return normalPage;
  }
}
