import 'package:fl_chart/fl_chart.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/id_with_copy.dart';
import 'package:general/src/features/agency/agency.dart';
import 'package:general/src/features/agency/domain/entity/agency_more_info_entity.dart';
import 'package:general/src/features/agency/presentation/host_agency/bloc/fetch_more_info_agency/fetch_more_info_agency_bloc.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class TabBarViewData extends StatefulWidget {
  const TabBarViewData({super.key, required this.year, required this.month});

  final String month;
  final String year;

  @override
  State<TabBarViewData> createState() => _TabBarViewDataState();
}

class _TabBarViewDataState extends State<TabBarViewData> {
  late AgencyDataGridSource _dataSource;
  final DataGridController _dataGridController = DataGridController();

  @override
  void initState() {
    super.initState();
    di<FetchMoreInfoAgencyBloc>().add(const AddUserTargetScrollListenerEvent());
  }

  @override
  void dispose() {
    di<FetchMoreInfoAgencyBloc>()
        .add(const RemoveUserTargetScrollListenerEvent());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<KickOutAgencyBloc, KickOutAgencyState>(
      bloc: di<KickOutAgencyBloc>(),
      listener: (context, state) {
        if (state.state.isLoading) {
          Methods.showToast(context, isLoading: true);
        } else if (state.state.isLoaded) {
          Methods.showToast(context,
              message: state.message ?? StringManager.success);
        } else if (state.state.isError) {
          Methods.showToast(context,
              message: state.message ?? StringManager.error, isError: true);
        }
      },
      child: BlocBuilder<FetchMoreInfoAgencyBloc, FetchMoreInfoAgencyState>(
        bloc: di<FetchMoreInfoAgencyBloc>(),
        buildWhen: (prev, curr) =>
            prev.entity != curr.entity ||
            prev.requestState != curr.requestState ||
            prev.userTargetScrollCtrl != curr.userTargetScrollCtrl ||
            prev.isPagination != curr.isPagination,
        builder: (context, state) {
          final users = state.entity?.usersTarget ?? <UserTargetEntity>[];

          _dataSource = AgencyDataGridSource(users, context,
              isPagination: state.isPagination);
          return HandlingDataWidget(
            reqState: state.requestState,
            title: StringManager.noHostsDataNowTitle.tr(),
            subTitle: StringManager.noHostsDataNowSubTitle.tr(),
            child: Column(
              children: [
                Row(
                  children: [
                    const Spacer(),
                    ButtonWidget(
                        height: 20.h,
                        width: 20.w,
                        title: Icon(
                          Icons.arrow_right_alt,
                          color: ColorManager.textPrimary,
                        ),
                        padding: EdgeInsets.zero,
                        paddingButton: EdgeInsets.zero,
                        backgroundColor: ColorManager.scaffoldBg,
                        borderColor: ColorManager.textPrimary,
                        onPressed: () {
                          _dataGridController.scrollToColumn(
                            6,
                            canAnimate:
                                true, // Optional: adds animation when scrolling
                          );
                        }),
                    10.wBox,
                  ],
                ),
                SizedBox(
                  height: ScreenUtil().screenHeight * 0.66,
                  child: SfDataGridTheme(
                    data: const SfDataGridThemeData(
                      gridLineColor: ColorManager.transparent,
                      frozenPaneLineColor: ColorManager.transparent,
                    ),
                    child: SfDataGrid(
                      verticalScrollController: state.userTargetScrollCtrl,
                      controller: _dataGridController,
                      source: _dataSource,
                      frozenColumnsCount: 1,
                      verticalScrollPhysics:
                          const AlwaysScrollableScrollPhysics(),
                      columnWidthMode: ColumnWidthMode.fill,
                      gridLinesVisibility: GridLinesVisibility.none,
                      headerGridLinesVisibility: GridLinesVisibility.none,
                      showVerticalScrollbar: false,
                      rowHeight: 60,
                      columns: <GridColumn>[
                        GridColumn(
                          columnName: 'user',
                          width: 150,
                          label: Container(
                            padding: const EdgeInsets.all(8.0),
                            alignment: Alignment.centerLeft,
                            child: const TextWidget(StringManager.userInfo),
                          ),
                        ),
                        GridColumn(
                          columnName: 'diamond',
                          width: 80,
                          label: const Center(
                              child: TextWidget(StringManager.diamond)),
                        ),
                        GridColumn(
                          columnName: 'salary',
                          width: 120,
                          label: const Center(
                              child: TextWidget(StringManager.guildSalary)),
                        ),
                        GridColumn(
                          columnName: 'days',
                          width: 42,
                          label: const Center(
                              child: TextWidget(StringManager.days)),
                        ),
                        GridColumn(
                          columnName: 'hours',
                          width: 60,
                          label: const Center(
                              child: TextWidget(StringManager.hours)),
                        ),
                        GridColumn(
                          columnName: 'chart',
                          width: 70,
                          label: const Center(
                              child: TextWidget(StringManager.chart)),
                        ),
                        GridColumn(
                          columnName: 'top3',
                          width: 130,
                          label: const Center(
                              child: TextWidget(StringManager.top3Supporters)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class AgencyDataGridSource extends DataGridSource {
  AgencyDataGridSource(this.users, this.context, {this.isPagination = false}) {
    _buildRows();
  }

  final List<UserTargetEntity> users;
  final BuildContext context;
  final bool isPagination;

  static const DataGridRow _loadingRow = DataGridRow(cells: [
    DataGridCell<dynamic>(columnName: 'user', value: null),
    DataGridCell<String>(columnName: 'diamond', value: ''),
    DataGridCell<String>(columnName: 'salary', value: ''),
    DataGridCell<String>(columnName: 'days', value: ''),
    DataGridCell<String>(columnName: 'hours', value: ''),
    DataGridCell<List<OldTargetEntity>>(columnName: 'chart', value: []),
    DataGridCell<List<String>>(columnName: 'top3', value: []),
  ]);

  late List<DataGridRow> dataGridRows;

  @override
  List<DataGridRow> get rows =>
      isPagination ? [...dataGridRows, _loadingRow] : dataGridRows;

  void _buildRows() {
    dataGridRows = users.map<DataGridRow>((data) {
      return DataGridRow(cells: [
        DataGridCell<dynamic>(columnName: 'user', value: data),
        DataGridCell<String>(
          columnName: 'diamond',
          value: Methods().convertToAbbreviatedString(data.userDiamonds ?? 0),
        ),
        DataGridCell<String>(
          columnName: 'salary',
          value: Methods().convertToAbbreviatedString(data.salary ?? 0),
        ),
        DataGridCell<String>(
          columnName: 'days',
          value: Methods().convertToAbbreviatedString(data.userDays ?? 0),
        ),
        DataGridCell<String>(
          columnName: 'hours',
          value: Methods().convertToAbbreviatedString(data.userHours ?? 0),
        ),
        DataGridCell<List<OldTargetEntity>>(
          columnName: 'chart',
          value: data.oldTargets ?? [],
        ),
        DataGridCell<List<String>>(
          columnName: 'top3',
          value: data.topUsers ?? [],
        ),
      ]);
    }).toList();
  }

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final userValue = row.getCells()[0].value;

    if (userValue == null) {
      return const DataGridRowAdapter(cells: [
        Center(child: CircularProgressIndicator(strokeWidth: 2)),
        SizedBox(),
        SizedBox(),
        SizedBox(),
        SizedBox(),
        SizedBox(),
        SizedBox(),
      ]);
    }

    final user = userValue as UserTargetEntity;
    final diamond = row.getCells()[1].value as String;
    final salary = row.getCells()[2].value as String;
    final days = row.getCells()[3].value as String;
    final hours = row.getCells()[4].value as String;
    final chartData = row.getCells()[5].value as List<OldTargetEntity>;
    final topUsers = row.getCells()[6].value as List<String>;

    return DataGridRowAdapter(cells: [
      GestureDetector(
        onTap: () => Methods()
            .userProfileNavigator(context: context, userId: user.id.toString()),
        onLongPress: () {
          if (user.id != MyDataModel.getInstance().id ||
              !(user.isAdmin ?? false)) {
            showDialog(
              context: context,
              builder: (context) => AnimatedDialog(
                title: StringManager.warning.tr(),
                description: StringManager.removeAnchor.tr(),
                onTap: () {
                  di<KickOutAgencyBloc>().add(
                    KickOutAgencyEvent(
                      context: context,
                      userId: user.id.toString(),
                    ),
                  );
                  Navigator.pop(context);
                },
              ),
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              UserImage(
                  image: user.image ?? '',
                  displayName: user.name ?? '',
                  imageSize: 35),
              const SizedBox(width: 5),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GradientTextVip(
                      text: user.name ?? "",
                      width: 90.w,
                      isVip: (user.coloredName ?? '') != '',
                      color: (user.coloredName ?? '') != ''
                          ? Color((int.parse(
                              user.coloredName!.replaceAll('#', '0xff'))))
                          : ColorManager.textPrimary,
                      mainAxisAlignment: MainAxisAlignment.center,
                      textAlign: TextAlign.center,
                      textStyle: context.bodyMedium.size(12).colorExt(
                            user.coloredName != ""
                                ? Color((int.parse(
                                    user.coloredName!.replaceAll('#', '0xff'))))
                                : ColorManager.textPrimary,
                          ),
                    ),
                    IdWithCopyIcon(
                      userId: user.uuid ?? "",
                      idStyle: context.bodyMedium.size(12).colorExt(
                            ColorManager.textPrimary.withValues(alpha: 0.5),
                          ),
                      idColor: ColorManager.textPrimary.withValues(alpha: 0.5),
                      isNeedCopyIcon: false,
                      isSpecial: ((user.idImage ?? '') != ''),
                      specialImg: user.idImage ?? '',
                      color: user.imageColorEntity?.color,
                      img: user.imageColorEntity?.image,
                      mainAxisAlignment: MainAxisAlignment.start,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      Center(child: TextWidget(diamond)),
      Center(child: TextWidget(salary)),
      Center(child: TextWidget(days)),
      Center(child: TextWidget(hours)),
      _ChartCell(data: chartData),
      _TopUsersCell(userUrls: topUsers),
    ]);
  }
}

class _ChartCell extends StatelessWidget {
  const _ChartCell({required this.data});

  final List<OldTargetEntity> data;

  @override
  Widget build(BuildContext context) {
    final filteredData = data
        .where((e) => e.month != null && e.userDiamonds != null)
        .toList()
      ..sort((a, b) => a.month!.compareTo(b.month!));

    if (filteredData.isEmpty) {
      return SizedBox(
        width: 70.w,
        height: 50.h,
        child: const Center(child: Text('No data')),
      );
    }

    final maxDiamonds = filteredData
        .map((e) => e.userDiamonds!)
        .fold<int>(0, (prev, curr) => curr > prev ? curr : prev);

    final chartData = filteredData
        .map((e) {
          final x = e.month!.toDouble();
          final y = maxDiamonds == 0 ? 0.0 : (e.userDiamonds! / maxDiamonds);
          return FlSpot(x, y);
        })
        .where((spot) => spot.x.isFinite && spot.y.isFinite)
        .toList();

    final minX = chartData.first.x;
    final maxX = chartData.last.x;

    return SizedBox(
      width: 70.w,
      height: 54.h,
      child: LineChart(
        LineChartData(
          minX: minX,
          maxX: maxX,
          minY: 0,
          maxY: 1,
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            show: true,
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 0.5,
                reservedSize: 20,
                getTitlesWidget: (value, _) => Text(
                  '${(value * 100).toInt()}%',
                  style: TextStyle(fontSize: 8, color: ColorManager.secondaryText),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, _) => Text(
                  value.toInt().toString(),
                  style: TextStyle(fontSize: 8, color: ColorManager.secondaryText),
                ),
              ),
            ),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey.shade300, width: 1),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: chartData,
              isCurved: true,
              color: Colors.blueAccent,
              barWidth: 2,
              isStrokeCapRound: true,
              belowBarData: BarAreaData(
                  show: true, color: Colors.blueAccent.withValues(alpha: 0.1)),
              dotData: const FlDotData(show: true),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopUsersCell extends StatelessWidget {
  const _TopUsersCell({required this.userUrls});

  final List<String> userUrls;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: SizedBox(
        width: 130,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: userUrls
              .map(
                (url) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: UserImage(
                    image: url,
                    borderRadius: 50.radius,
                    imageSize: 30.w,
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
