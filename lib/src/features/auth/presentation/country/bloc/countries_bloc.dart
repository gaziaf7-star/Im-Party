import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/auth.dart';

part 'countries_event.dart';

part 'countries_state.dart';

class CountriesBloc extends Bloc<CountriesEvent, CountriesState> {
  final FetchCountriesUc _fetchCountriesUc;
  final FetchCountryCategoriesUc _fetchCountryCategoriesUc;
  final FetchCountriesByCategoryUc _fetchCountriesByCategoryUc;

  CountriesBloc(
    this._fetchCountriesUc,
    this._fetchCountryCategoriesUc,
    this._fetchCountriesByCategoryUc,
  ) : super(
          CountriesState(
            controller: TextEditingController(),
            controllerEditInfo: TextEditingController(),
          ),
        ) {
    on<FetchCountriesEvent>(_fetchCountriesEvent);
    on<FetchCountryCategoriesEvent>(_fetchCountryCategoriesEvent);
    on<FetchHomeCountriesEvent>(_fetchHomeCountriesEvent);
    on<FetchCountriesByCategoryEvent>(_fetchCountriesByCategoryEvent);
    on<SelectedCountryEvent>(_selectCountryEvent);
    on<SelectedEditInfoCountryEvent>(_selectedEditInfoCountryEvent);

    on<SelectedCountryPopularEvent>(_selectedCountryPopular);
    on<SelectedCountryGlobalEvent>(_selectedCountryGlobal);
    on<SelectedCountryFollowingEvent>(_selectedCountryFollowing);

    on<UnSelectedCountryEvent>(_unSelectCountryEvent);

    on<UnSelectedCountryHotEvent>(_unselectedCountryPopular);
    on<UnSelectedCountryRelatedEvent>(_unselectedCountryGlobal);
    on<UnSelectedCountryNearbyEvent>(_unselectedCountryFollowing);
    on<ShowAllCountryEvent>(_showAllCountryEvent);
  }

  // Events
  Future<void> _fetchCountryCategoriesEvent(
    FetchCountryCategoriesEvent event,
    Emitter<CountriesState> emit,
  ) async {
    emit(state.copyWith(categoriesRequestState: RequestState.loading));
    final result = await _fetchCountryCategoriesUc();
    result.fold(
      (left) {
        emit(state.copyWith(categoriesRequestState: RequestState.error));
      },
      (right) {
        final categories = right.data ?? [];
        emit(
          state.copyWith(
            categoriesRequestState: RequestState.loaded,
            categories: categories,
          ),
        );
        if (categories.isNotEmpty) {
          add(FetchHomeCountriesEvent(categoryId: categories.first.id));
        }
      },
    );
  }

  Future<void> _fetchHomeCountriesEvent(
    FetchHomeCountriesEvent event,
    Emitter<CountriesState> emit,
  ) async {
    emit(state.copyWith(homeCountriesRequestState: RequestState.loading));
    final result = await _fetchCountriesByCategoryUc(event.categoryId);
    result.fold(
      (left) {
        emit(state.copyWith(homeCountriesRequestState: RequestState.error));
      },
      (right) {
        emit(
          state.copyWith(
            homeCountriesRequestState: RequestState.loaded,
            homeCountries: _arrangeForHomeRow(right.data),
          ),
        );
      },
    );
  }

  /// Country ids the home row must lead with, in this order.
  ///
  /// The backend returns all 243 countries in table order, which starts Saudi
  /// Arabia, Kuwait, UAE, Syria, Egypt -- an Arabic-first ordering inherited
  /// from the original product. Ids, not names: `e_name` is not stable across
  /// locales and `name` is Arabic.
  static const List<int> _leadingCountryIds = <int>[
    24, // Bangladesh
    25, // Pakistan
    22, // India
  ];

  /// Bangladesh, Pakistan, India first; everything else keeps backend order.
  ///
  /// Ordering only -- nothing is dropped, so the "More" dialog still sees the
  /// full list.
  static List<CountryEntity> _arrangeForHomeRow(List<CountryEntity>? all) {
    if (all == null || all.isEmpty) return const <CountryEntity>[];
    final byId = {for (final c in all) c.id: c};
    final leading = <CountryEntity>[
      for (final id in _leadingCountryIds)
        if (byId[id] != null) byId[id]!,
    ];
    final leadingIds = leading.map((c) => c.id).toSet();
    return [
      ...leading,
      ...all.where((c) => !leadingIds.contains(c.id)),
    ];
  }

  Future<void> _fetchCountriesByCategoryEvent(
    FetchCountriesByCategoryEvent event,
    Emitter<CountriesState> emit,
  ) async {
    emit(state.copyWith(
      countriesByCategoryRequestState: RequestState.loading,
      selectedCategoryId: event.categoryId,
    ));
    final result = await _fetchCountriesByCategoryUc(event.categoryId);
    result.fold(
      (left) {
        emit(state.copyWith(
            countriesByCategoryRequestState: RequestState.error));
      },
      (right) {
        emit(
          state.copyWith(
            countriesByCategoryRequestState: RequestState.loaded,
            countriesByCategory: right.data,
          ),
        );
      },
    );
  }

  Future<void> _showAllCountryEvent(
    ShowAllCountryEvent event,
    Emitter<CountriesState> emit,
  ) async {
    emit(state.copyWith(isShowMore: event.showAll));
  }

  Future<void> _fetchCountriesEvent(
    FetchCountriesEvent event,
    Emitter<CountriesState> emit,
  ) async {
    if (event.isLoading == true) {
      emit(state.copyWith(requestState: RequestState.loading));
    }

    final result = await _fetchCountriesUc();
    result.fold(
      (left) {
        emit(state.copyWith(requestState: RequestState.error));
      },
      (right) {
        emit(
          state.copyWith(
            requestState: RequestState.loaded,
            countries: right.data,
            countries2: right.data,
          ),
        );
        add(const UnSelectedCountryEvent());
      },
    );
  }

  void _selectCountryEvent(
    SelectedCountryEvent event,
    Emitter<CountriesState> emit,
  ) {
    Methods.printLog("country-entity -----> ${event.countryEntity}");
    emit(
      state.copyWith(
        countryEntity: event.countryEntity,
        countryId: event.countryId,
        controller: event.countryEntity?.name,
        isNullCountry: event.isNullCountry ?? false,
        countryEntityNearby: event.countryEntityNearby,
      ),
    );
  }

  void _selectedCountryFollowing(
    SelectedCountryFollowingEvent event,
    Emitter<CountriesState> emit,
  ) =>
      emit(
        state.copyWith(
          countryEntityNearby: event.countryEntityNearby,
        ),
      );

  void _selectedCountryPopular(
    SelectedCountryPopularEvent event,
    Emitter<CountriesState> emit,
  ) {
    Methods.printLog(event.countryEntityHot.toString());
    emit(
      state.copyWith(
        countryEntityHot: event.countryEntityHot,
      ),
    );
  }

  void _selectedCountryGlobal(
    SelectedCountryGlobalEvent event,
    Emitter<CountriesState> emit,
  ) {
    emit(
      state.copyWith(
        countryEntityRelated: event.countryEntityRelated,
      ),
    );
  }

  void _selectedEditInfoCountryEvent(
    SelectedEditInfoCountryEvent event,
    Emitter<CountriesState> emit,
  ) {
    emit(
      state.copyWith(
        countryEntityEditInfo: event.countryEntityEditInfo,
        controllerEditInfo: event.countryEntityEditInfo?.name,
      ),
    );
  }

  void _unSelectCountryEvent(
    UnSelectedCountryEvent event,
    Emitter<CountriesState> emit,
  ) =>
      emit(state.copyWith(isNullCountry: true));

  void _unselectedCountryPopular(
    UnSelectedCountryHotEvent event,
    Emitter<CountriesState> emit,
  ) =>
      emit(state.copyWith(isNullCountryPopular: true));

  void _unselectedCountryFollowing(
    UnSelectedCountryNearbyEvent event,
    Emitter<CountriesState> emit,
  ) =>
      emit(state.copyWith(isNullCountryFollowing: true));

  void _unselectedCountryGlobal(
    UnSelectedCountryRelatedEvent event,
    Emitter<CountriesState> emit,
  ) =>
      emit(state.copyWith(isNullCountryGlobal: true));
}
