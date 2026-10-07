import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/id_with_copy.dart';
import 'package:general/src/features/auth/auth.dart';
import 'package:general/src/features/family/family.dart';

part 'components/requests_body.dart';

part 'components/user_info_row_body.dart';

class FamilyRequestsPage extends StatefulWidget {
  final String id;

  const FamilyRequestsPage({required this.id, super.key});

  @override
  State<FamilyRequestsPage> createState() => _FamilyRequestsPageState();
}

class _FamilyRequestsPageState extends State<FamilyRequestsPage> {
  final FamilyRequestBloc _familyRequestBloc = di<FamilyRequestBloc>();
  final TakeActionBloc _takeActionBloc = di<TakeActionBloc>();
  List<FamilyRequestsModel>? data;

  @override
  void initState() {
    if (!_familyRequestBloc.state.reqState.isLoaded) {
      _familyRequestBloc.add(const GetFamilyRequestEvent());
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBarWidget(
        title: StringManager.joinRequests.tr(),
      ),
      body: BlocListener<TakeActionBloc, TakeActionState>(
        bloc: _takeActionBloc,
        listener: (context, state) {
          if (state.reqState.isLoaded) {

            Methods.showToast(
              context,
              message: state.message,
            );
          } else if (state.reqState.isError) {
            Methods.showToast(
              context,
              message: state.message,
            );
          }
        },
        child: BlocBuilder<FamilyRequestBloc, FamilyRequestState>(
          bloc: _familyRequestBloc,
          buildWhen: (prev, curr) => prev.reqState != curr.reqState || prev.data != curr.data,
          builder: (context, state) {
            return HandlingDataWidget(
              reqState: state.reqState,
              title: StringManager.titleEmptyFamily.tr(),
              subTitle: StringManager.subTitleEmptyFamily.tr(),
              onTap: () {
                _familyRequestBloc.add(const GetFamilyRequestEvent());

              },
              child: RefreshIndicatorWidget(
                onRefresh: () async {
                  _familyRequestBloc
                      .add(const GetFamilyRequestEvent(isLoading: false));
                },
                child: _RequestsBody(
                  bloc: _takeActionBloc,
                  data: state.data,
                  familyId: widget.id,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
