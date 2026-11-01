import 'package:flutter_svga/flutter_svga.dart';
import 'package:general/src/core/cache/svga_movie_cache.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/domain/entities/user_entity.dart';
import 'package:general/src/features/profile/presentation/profile/view/page/user_profile/bloc/get_user_intro_bloc/get_user_intro_bloc.dart';
import 'package:general/src/features/profile/presentation/profile/view/page/user_profile/bloc/get_user_intro_bloc/get_user_intro_event.dart';
import 'package:general/src/features/profile/presentation/profile/view/page/user_profile/bloc/get_user_intro_bloc/get_user_intro_state.dart';

/// The visited user's ACTIVE entrance effect ("entry"), played once on their
/// profile the way it plays when they enter a room (im_Chat / Hello Party).
///
/// The profile response often leaves `intro` empty and only carries
/// `intro_id`; the file itself is then looked up in the user's intro list.
/// An .svga gets the user's picture and name written into its
/// `sender_avatar` / `sender_name` slots. Taps pass through.
class ProfileEntryEffect extends StatefulWidget {
  const ProfileEntryEffect({super.key, required this.user});

  final UserEntity? user;

  @override
  State<ProfileEntryEffect> createState() => _ProfileEntryEffectState();
}

class _ProfileEntryEffectState extends State<ProfileEntryEffect> {
  GetUserIntroBloc? _bloc;

  @override
  void initState() {
    super.initState();
    _maybeLookUp();
  }

  @override
  void didUpdateWidget(covariant ProfileEntryEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user?.id != widget.user?.id ||
        oldWidget.user?.introId != widget.user?.introId) {
      _maybeLookUp();
    }
  }

  void _maybeLookUp() {
    final u = widget.user;
    if (u == null || _bloc != null) return;
    if ((u.intro ?? '').isNotEmpty || (u.introId ?? 0) == 0) return;
    _bloc = di<GetUserIntroBloc>()..add(GetUserIntro(id: '${u.id ?? ''}'));
  }

  @override
  void dispose() {
    _bloc?.close();
    super.dispose();
  }

  String _resolve(List? intros) {
    final u = widget.user;
    var path = u?.intro ?? '';
    final activeId = u?.introId ?? 0;
    if (path.isEmpty && activeId != 0) {
      for (final i in intros ?? const []) {
        if (i.id == activeId) {
          path = i.image;
          break;
        }
      }
    }
    return path;
  }

  Widget _player(String path) {
    if (path.isEmpty) return const SizedBox.shrink();
    final url = EndPoints.getImage(path);
    // Keyed by file: plays ONCE per profile visit, a rebuild never replays.
    return IgnorePointer(
      child: _EntryPlayer(
        key: ValueKey(url),
        path: path,
        url: url,
        avatar: widget.user?.profile?.image ?? '',
        name: widget.user?.name ?? '',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bloc = _bloc;
    if (bloc == null) return _player(_resolve(null));
    return BlocBuilder<GetUserIntroBloc, GetUserIntroState>(
      bloc: bloc,
      buildWhen: (prev, curr) => prev.userIntroModel != curr.userIntroModel,
      builder: (context, state) => _player(_resolve(state.userIntroModel)),
    );
  }
}

class _EntryPlayer extends StatefulWidget {
  const _EntryPlayer({
    super.key,
    required this.path,
    required this.url,
    required this.avatar,
    required this.name,
  });

  final String path;
  final String url;
  final String avatar;
  final String name;

  @override
  State<_EntryPlayer> createState() => _EntryPlayerState();
}

class _EntryPlayerState extends State<_EntryPlayer>
    with SingleTickerProviderStateMixin {
  SVGAAnimationController? _svga;
  AnimationController? _image;
  bool _done = false;

  bool get _isSvga => Methods().isSvgaFile(widget.path);

  @override
  void initState() {
    super.initState();
    if (_isSvga) {
      _playSvga();
    } else {
      _image = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 4000),
      )..forward().whenComplete(_finish);
    }
  }

  Future<void> _playSvga() async {
    try {
      final movie = await SvgaMovieCache.instance.loadFromUrl(widget.url);
      if (!mounted) return;
      if (movie == null) {
        _finish();
        return;
      }
      // The user's own picture and name inside the entry, like in a room.
      if (widget.avatar.isNotEmpty) {
        await applySenderAvatar(movie, widget.avatar);
      }
      if (widget.name.trim().isNotEmpty) {
        applySenderName(movie, widget.name);
      }
      if (!mounted) return;
      final controller = SVGAAnimationController(vsync: this)
        ..videoItem = movie;
      setState(() => _svga = controller);
      controller.forward(from: 0).whenComplete(_finish);
    } catch (_) {
      _finish();
    }
  }

  void _finish() {
    if (mounted) setState(() => _done = true);
  }

  @override
  void dispose() {
    _svga?.dispose();
    _image?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_done) return const SizedBox.shrink();

    if (_isSvga) {
      final c = _svga;
      if (c == null) return const SizedBox.shrink();
      return SVGAImage(c, fit: BoxFit.cover, clearsAfterStop: true);
    }

    final ctrl = _image!;
    return AnimatedBuilder(
      animation: ctrl,
      builder: (context, child) {
        final t = ctrl.value;
        final inT = Curves.easeOutCubic.transform((t / 0.27).clamp(0.0, 1.0));
        final out = t > 0.8 ? (1 - (t - 0.8) / 0.2) : 1.0;
        return Opacity(
          opacity: (inT * out).clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset((1 - inT) * 90.w, 0),
            child: child,
          ),
        );
      },
      child: ImageViewWidget(url: widget.url, boxFit: BoxFit.contain),
    );
  }
}
