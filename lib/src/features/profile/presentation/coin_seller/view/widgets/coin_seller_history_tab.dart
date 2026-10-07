part of '../coin_seller_screen.dart';

class CoinSellerHistoryTab extends StatefulWidget {
  const CoinSellerHistoryTab({super.key});

  @override
  State<CoinSellerHistoryTab> createState() =>
      _CoinSellerHistoryTabState();
}

class _CoinSellerHistoryTabState
    extends State<CoinSellerHistoryTab> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  OutlineInputBorder _searchBorder(
      Color color, {
        double width = 1,
      }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16.r),
      borderSide: BorderSide(
        color: color,
        width: width,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      di<CoinSellerBloc>().add(
        const LoadMoreCoinSellerHistoryEvent(),
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({
    required bool isFrom,
  }) async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogTheme: const DialogThemeData(
              backgroundColor: Colors.white,
            ),
            colorScheme: const ColorScheme.light(
              primary: _coinSellerPurple,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: _coinSellerText,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: _coinSellerPurple,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) return;

    final formatted =
    DateFormat('yyyy-MM-dd').format(picked);

    di<CoinSellerBloc>().add(
      isFrom
          ? FilterCoinSellerHistoryEvent(
        fromDate: formatted,
      )
          : FilterCoinSellerHistoryEvent(
        toDate: formatted,
      ),
    );
  }

  void _search() {
    final value = _searchController.text.trim();

    di<CoinSellerBloc>().add(
      FilterCoinSellerHistoryEvent(
        searchKey: value.isEmpty ? null : value,
        clearSearchKey: value.isEmpty,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            16.w,
            2.h,
            16.w,
            0,
          ),
          child: Container(
            padding: EdgeInsets.fromLTRB(
              12.w,
              12.h,
              12.w,
              12.h,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: _coinSellerBorder,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.035),
                  blurRadius: 13.r,
                  offset: Offset(0, 4.h),
                ),
              ],
            ),
            child: Column(
              children: [
                TextInputWidget(
                  StringManager.searchRecipient.tr(),
                  controller: _searchController,
                  prefixIcon: Icons.search_rounded,
                  prefixColor: _coinSellerPurple,
                  suffixIcon: Icons.arrow_forward_rounded,
                  suffixColor: _coinSellerPurple,
                  onPressed: _search,
                  fillColor: const Color(0xFFF8F7FA),
                  textColor: Colors.black,
                  cursorColor: _coinSellerPurple,
                  textSize: 14,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _search(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 14.h,
                  ),
                  hintStyle: context.bodyMedium
                      .size(13)
                      .colorExt(
                    _coinSellerSubText.withValues(alpha: 0.72),
                  ),
                  border: _searchBorder(_coinSellerBorder),
                  enabledBorder:
                  _searchBorder(_coinSellerBorder),
                  focusedBorder: _searchBorder(
                    _coinSellerPurple,
                    width: 1.3,
                  ),
                ),
                10.hBox,
                BlocBuilder<CoinSellerBloc, CoinSellerState>(
                  bloc: di<CoinSellerBloc>(),
                  buildWhen: (prev, curr) =>
                  prev.fromDate != curr.fromDate ||
                      prev.toDate != curr.toDate,
                  builder: (context, state) {
                    return Row(
                      children: [
                        Expanded(
                          child: _DateFilterChip(
                            label: state.fromDate ??
                                StringManager.fromDate.tr(),
                            isActive:
                            state.fromDate != null,
                            onTap: () =>
                                _pickDate(isFrom: true),
                            onClear: state.fromDate == null
                                ? null
                                : () => di<CoinSellerBloc>().add(
                              const FilterCoinSellerHistoryEvent(
                                clearFromDate: true,
                              ),
                            ),
                          ),
                        ),
                        8.wBox,
                        Expanded(
                          child: _DateFilterChip(
                            label: state.toDate ??
                                StringManager.toDate.tr(),
                            isActive:
                            state.toDate != null,
                            onTap: () =>
                                _pickDate(isFrom: false),
                            onClear: state.toDate == null
                                ? null
                                : () => di<CoinSellerBloc>().add(
                              const FilterCoinSellerHistoryEvent(
                                clearToDate: true,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        10.hBox,
        Expanded(
          child: BlocBuilder<CoinSellerBloc, CoinSellerState>(
            bloc: di<CoinSellerBloc>(),
            buildWhen: (prev, curr) =>
            prev.history != curr.history ||
                prev.reqStateHistory != curr.reqStateHistory ||
                prev.isPaginating != curr.isPaginating,
            builder: (context, state) {
              return RefreshIndicatorWidget(
                onRefresh: () async {
                  di<CoinSellerBloc>().add(
                    const GetCoinSellerHistoryEvent(
                      isLoading: true,
                    ),
                  );
                },
                child: HandlingDataWidget(
                  reqState: state.reqStateHistory,
                  title: StringManager.noSellerHistoryTitle.tr(),
                  subTitle:
                  StringManager.noSellerHistorySubTitle.tr(),
                  titleStyle: context.bodyLarge
                      .w600
                      .colorExt(_coinSellerText),
                  subTitleStyle: context.bodyMedium.copyWith(
                    color: _coinSellerSubText,
                    height: 1.30,
                  ),
                  buttonBackgroundColors: _coinSellerGradient,
                  onTap: () => di<CoinSellerBloc>().add(
                    const GetCoinSellerHistoryEvent(
                      isLoading: true,
                    ),
                  ),
                  child: ListView.builder(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      16.w,
                      2.h,
                      16.w,
                      18.h,
                    ),
                    itemCount: state.history.length +
                        (state.isPaginating ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= state.history.length) {
                        return Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 16.h,
                          ),
                          child: Center(
                            child: GradientLoader(
                              size: 20.h,
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      }

                      return CoinSellerHistoryItem(
                        item: state.history[index],
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DateFilterChip extends StatelessWidget {
  const _DateFilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
    this.onClear,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 170),
          height: 42.h,
          padding: EdgeInsets.symmetric(
            horizontal: 10.w,
          ),
          decoration: BoxDecoration(
            color: isActive
                ? _coinSellerPurple.withValues(alpha: 0.08)
                : const Color(0xFFF8F7FA),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: isActive
                  ? _coinSellerPurple.withValues(alpha: 0.62)
                  : _coinSellerBorder,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_month_rounded,
                size: 16.h,
                color: isActive
                    ? _coinSellerPurple
                    : _coinSellerSubText,
              ),
              6.wBox,
              Flexible(
                child: TextWidget(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.bodySmall
                      .size(11.5)
                      .w600
                      .colorExt(
                    isActive
                        ? _coinSellerPurple
                        : _coinSellerSubText,
                  ),
                ),
              ),
              if (onClear != null) ...[
                5.wBox,
                GestureDetector(
                  onTap: onClear,
                  child: Icon(
                    Icons.close_rounded,
                    size: 15.h,
                    color: _coinSellerPurple,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
