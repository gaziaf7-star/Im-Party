import 'package:general/src/core/index.dart';
import 'package:on_audio_query_forked/on_audio_query.dart';

/// Every audio file on the phone, listed so any number can be picked at once.
///
/// The party room used to open the system file browser, one file per trip. The
/// media store has already indexed every track, so they are simply listed —
/// with select-all — and the whole selection is added in one go.
///
/// Pops with the chosen songs, or null when dismissed.
class DeviceSongsSheet extends StatefulWidget {
  const DeviceSongsSheet({super.key});

  static Future<List<SongModel>?> show(BuildContext context) {
    return showModalBottomSheet<List<SongModel>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: ColorManager.transparent,
      builder: (_) => const DeviceSongsSheet(),
    );
  }

  @override
  State<DeviceSongsSheet> createState() => _DeviceSongsSheetState();
}

class _DeviceSongsSheetState extends State<DeviceSongsSheet> {
  /// The formats the media store reports vary by device; anything else here is
  /// not something the room's player can stream.
  static const _playable = {
    'mp3',
    'm4a',
    'aac',
    'wav',
    'flac',
    'ogg',
    'opus',
    'wma',
    'amr',
  };

  final OnAudioQuery _audioQuery = OnAudioQuery();

  /// Keyed by media-store id, so a re-query (or a search that hides a row)
  /// cannot lose a selection.
  final Set<int> _selected = <int>{};

  List<SongModel> _songs = const [];
  bool _hasPermission = false;
  bool _loading = true;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool retry = false}) async {
    final granted = await _audioQuery.checkAndRequest(retryRequest: retry);
    if (!mounted) return;

    if (!granted) {
      setState(() {
        _hasPermission = false;
        _loading = false;
      });

      return;
    }

    final songs = await _audioQuery.querySongs(
      sortType: SongSortType.DATE_ADDED,
      orderType: OrderType.DESC_OR_GREATER,
      uriType: UriType.EXTERNAL,
      ignoreCase: true,
    );
    if (!mounted) return;

    setState(() {
      _hasPermission = true;
      _songs = _playableOnly(songs);
      _loading = false;
    });
  }

  /// Drops entries the player cannot open, and anything the media store lists
  /// without a real path — ringtones and notification sounds show up on some
  /// devices with an empty `data`.
  List<SongModel> _playableOnly(List<SongModel> songs) {
    return songs.where((song) {
      final path = song.data;
      if (path.isEmpty) return false;

      final dot = path.lastIndexOf('.');

      return dot >= 0 && _playable.contains(path.substring(dot + 1).toLowerCase());
    }).toList();
  }

  List<SongModel> get _visible {
    if (_query.isEmpty) return _songs;

    final needle = _query.toLowerCase();

    return _songs
        .where((song) =>
            song.title.toLowerCase().contains(needle) ||
            (song.artist ?? '').toLowerCase().contains(needle))
        .toList();
  }

  /// Select-all applies to what is VISIBLE, so it behaves as expected while a
  /// search is active instead of quietly selecting hidden rows too.
  bool get _allVisibleSelected {
    final visible = _visible;

    return visible.isNotEmpty &&
        visible.every((song) => _selected.contains(song.id));
  }

  void _toggleAll() {
    final visible = _visible;
    setState(() {
      if (_allVisibleSelected) {
        _selected.removeAll(visible.map((s) => s.id));
      } else {
        _selected.addAll(visible.map((s) => s.id));
      }
    });
  }

  void _submit() {
    final chosen = _songs.where((song) => _selected.contains(song.id)).toList();
    Navigator.of(context).pop(chosen.isEmpty ? null : chosen);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ScreenUtil().screenHeight * 0.8,
      decoration: BoxDecoration(
        color: ColorManager.scaffoldBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        children: [
          _header(context),
          Expanded(child: _body()),
          if (_hasPermission && _songs.isNotEmpty) _footer(context),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Padding(
      padding: context.paddingSymmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextWidget(
                  StringManager.localMusic.tr(),
                  style: context.bodyLarge.w600
                      .colorExt(ColorManager.textPrimary),
                ),
              ),
              if (_hasPermission && _songs.isNotEmpty)
                TextButton(
                  onPressed: _toggleAll,
                  child: TextWidget(
                    _allVisibleSelected
                        ? StringManager.clearAll.tr()
                        : StringManager.selectAll.tr(),
                    style: context.bodyMedium.w600
                        .colorExt(ColorManager.primary),
                  ),
                ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.close, color: ColorManager.textPrimary),
              ),
            ],
          ),
          if (_hasPermission && _songs.isNotEmpty)
            TextInputWidget(
              StringManager.search.tr(),
              prefixIcon: Icons.search,
              onChanged: (value) =>
                  setState(() => _query = (value ?? '').trim()),
            ),
        ],
      ),
    );
  }

  Widget _body() {
    if (_loading) return const LoadingView();

    if (!_hasPermission) {
      return ErrorOrEmptyWidget(
        image: '',
        title: StringManager.musicPermissionTitle.tr(),
        message: StringManager.musicPermissionMessage.tr(),
        buttonTitle: StringManager.allow.tr(),
        onTap: () {
          setState(() => _loading = true);
          _load(retry: true);
        },
      );
    }

    final visible = _visible;

    if (visible.isEmpty) {
      return const EmptyStateWidget(
        title: StringManager.noSongsFound,
        message: StringManager.noSongsFoundMessage,
      );
    }

    return ListView.separated(
      padding: context.paddingSymmetric(horizontal: 8),
      itemCount: visible.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final song = visible[index];

        return _SongRow(
          song: song,
          selected: _selected.contains(song.id),
          onTap: () => setState(() {
            _selected.contains(song.id)
                ? _selected.remove(song.id)
                : _selected.add(song.id);
          }),
        );
      },
    );
  }

  Widget _footer(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: context.paddingSymmetric(horizontal: 16, vertical: 10),
        child: ButtonWidget(
          title: _selected.isEmpty
              ? StringManager.addMusic.tr()
              : '${StringManager.addMusic.tr()} (${_selected.length})',
          height: 46.h,
          radius: 23.r,
          backgroundColor: _selected.isEmpty
              ? ColorManager.divider
              : ColorManager.primary,
          titleColor: _selected.isEmpty
              ? ColorManager.secondaryText
              : ColorManager.buttonTextColor,
          onPressed: _selected.isEmpty ? null : _submit,
        ),
      ),
    );
  }
}

class _SongRow extends StatelessWidget {
  const _SongRow({
    required this.song,
    required this.selected,
    required this.onTap,
  });

  final SongModel song;
  final bool selected;
  final VoidCallback onTap;

  String get _duration {
    final ms = song.duration ?? 0;
    if (ms <= 0) return '';
    final total = Duration(milliseconds: ms);
    final seconds = total.inSeconds.remainder(60).toString().padLeft(2, '0');

    return '${total.inMinutes}:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: context.paddingSymmetric(horizontal: 8),
      leading: Icon(
        selected ? Icons.check_circle : Icons.circle_outlined,
        color: selected ? ColorManager.primary : ColorManager.secondaryText,
        size: 24.sp,
      ),
      title: TextWidget(
        song.title,
        maxLines: 1,
        isTranslate: false,
        overflow: TextOverflow.ellipsis,
        style: context.bodyMedium.w600.colorExt(ColorManager.textPrimary),
      ),
      subtitle: TextWidget(
        [song.artist, _duration]
            .where((part) => part != null && part.isNotEmpty)
            .join(' · '),
        maxLines: 1,
        isTranslate: false,
        overflow: TextOverflow.ellipsis,
        style: context.bodySmall.colorExt(ColorManager.secondaryText),
      ),
    );
  }
}
