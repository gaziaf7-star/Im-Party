import 'package:general/src/core/index.dart';
import 'package:general/src/features/agency/domain/entity/agency_host_report.dart';
import 'package:general/src/features/agency/presentation/host_agency/bloc/agency_host_report/agency_host_report_bloc.dart';
import 'package:general/src/features/agency/presentation/host_agency/view/widgets/agency_ui.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class DailyData extends StatefulWidget {
  final bool isAdmin;
  final AgencyHostReportState state;

  const DailyData({super.key, required this.isAdmin, required this.state});

  @override
  State<DailyData> createState() => _DailyDataState();
}

class _DailyDataState extends State<DailyData> {
  @override
  Widget build(BuildContext context) {
    return widget.isAdmin
        ? _AdminBody(state: widget.state)
        : _UserBody(state: widget.state);
    // return BlocBuilder<AgencyHostReportBloc, AgencyHostReportState>(
    //   bloc: di<AgencyHostReportBloc>(),
    //   builder: (context, state) {
    //     return HandlingDataWidget(
    //         reqState: state.requestState,
    //         title: StringManager.noAgencyDataNowTitle.tr(),
    //         subTitle: StringManager.noAgencyDataNowSubTitle.tr(),
    //         onTap: () {
    //           di<AgencyHostReportBloc>().add(
    //             AgencyHostReportEvent(
    //                 isFirsLoading: true,
    //                 mounth: '${DateTime.now().month}',
    //                 year: '${DateTime.now().year}'),
    //           );
    //         },
    //         child: widget.isAdmin
    //             ? _AdminBody(state: state)
    //             : _UserBody(state: state));
    //   },
    // );
  }
}

class _AdminBody extends StatelessWidget {
  final AgencyHostReportState state;

  const _AdminBody({required this.state});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.paddingSymmetric(
        vertical: 10,
      ),
      child: _ReportDataTableBody(state: state),
    );
  }
}

class _UserBody extends StatelessWidget {
  final AgencyHostReportState state;

  const _UserBody({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Shifted down a bit from the very top, on request.
        10.hBox,
        Padding(
          padding: context.paddingSymmetric(
            horizontal: 15,
          ),
          // Dark now that the page is white (white text vanished on it).
          child: TextWidget(
            StringManager.dailyData.tr(),
            style: AgencyUI.title(context),
          ),
        ).agencyEntrance(5),
        12.hBox,
        Padding(
          padding: context.paddingOnly(
            start: 15,
            end: 15,
            bottom: 0,
          ),
          child: _ReportDataTableBody(state: state),
        ).agencyEntrance(6),
      ],
    );
  }
}

class _ReportDataTableBody extends StatelessWidget {
  final AgencyHostReportState state;

  const _ReportDataTableBody({required this.state});

  @override
  Widget build(BuildContext context) {
    final dataSource = ReportDataSource(state.data?.dalyReports ?? []);

    return Container(
      height: ScreenUtil().screenHeight * 0.42,
      margin: EdgeInsets.only(bottom: 50.h),
      decoration: AgencyUI.card(radius: 16.r),
      clipBehavior: Clip.antiAlias,
      child: SfDataGridTheme(
        data: SfDataGridThemeData(
          headerColor: ColorManager.primary,
          gridLineColor: AgencyUI.line,
          frozenPaneLineColor: AgencyUI.line,
        ),
        child: Padding(
          padding: EdgeInsets.zero,
          child: SfDataGrid(
            source: dataSource,
            frozenColumnsCount: 1,
            columnWidthMode: ColumnWidthMode.fill,
            showVerticalScrollbar: true,
            rowHeight: 54,
            headerRowHeight: 56,
            columns: [
              GridColumn(
                columnName: 'day',
                label: Center(
                  child: TextWidget(
                    StringManager.data.tr(),
                    style: context.bodyMedium.bold.colorExt(ColorManager.onDark),
                  ),
                ),
              ),
              GridColumn(
                columnName: 'minutes',
                label: Center(
                  child: TextWidget(
                    StringManager.onMicTime.tr(),
                    style: context.bodyMedium.bold.colorExt(ColorManager.onDark),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              GridColumn(
                columnName: 'diamonds',
                label: Center(
                  child: TextWidget(
                    StringManager.diamonds.tr(),
                    style: context.bodyMedium.bold.colorExt(ColorManager.onDark),
                  ),
                ),
              ),
              GridColumn(
                columnName: 'active',
                label: Center(
                  child: TextWidget(
                    StringManager.effectDays.tr(),
                    style: context.bodyMedium.bold.colorExt(ColorManager.onDark),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ReportDataSource extends DataGridSource {
  List<DataGridRow> _rows = [];

  ReportDataSource(List<DalyReportsEntity> reports) {
    _rows = reports.map((report) {
      return DataGridRow(cells: [
        DataGridCell<String>(columnName: 'day', value: report.day.toString()),
        DataGridCell<String>(
            columnName: 'minutes',
            value: report.liveMinutesFormatted.toString()),
        DataGridCell<String>(
            columnName: 'diamonds', value: report.diamonds.toString()),
        DataGridCell<Widget>(
          columnName: 'active',
          value: report.isActiveDay!
              ? Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 16),
                )
              : const TextWidget("-"),
        ),
      ]);
    }).toList();
  }

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((cell) {
        if (cell.value is Widget) {
          return Center(child: cell.value);
        } else {
          return Center(
            child: TextWidget(
              cell.value.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AgencyUI.ink,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }
      }).toList(),
    );
  }
}
