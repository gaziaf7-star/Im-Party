import 'dart:developer';
import 'package:general/src/features/room/presentation/room_controller.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube_api/youtube_api.dart';
import 'get_youtube_videos_event.dart';
import 'get_youtube_videos_state.dart';

class GetYoutubeVideosBloc extends Bloc<GetYoutubeEvent, GetYoutubeState> {
  List<YouTubeVideo> results = [];

  GetYoutubeVideosBloc() : super(GetYoutubeStateInitial()) {
    on<GetYoutubeVideoEvent>((event, emit) async {
      emit(GetYoutubeStateLoading());

      // Validate API key
      if (youtubeApiKey.trim().isEmpty) {
        log('YouTube API key is empty');
        emit(const GetYoutubeStateError('Missing YouTube API key'));
        return;
      }

      try {
        if (event.search == '') {
          final api = YoutubeAPI(youtubeApiKey, maxResults: 50, type: 'video');
          results = await api.getTrends(
            regionCode: event.regionCode,
          );
        } else {
          final api = YoutubeAPI(youtubeApiKey, maxResults: 50, type: 'video');
          results = await api.search(event.search);
        }
        emit(GetVideosYoutubeSuccessState(results));
      } catch (e, st) {
        log('Error fetching youtube videos: $e\n$st');
        emit(GetYoutubeStateError(e.toString()));
      }
    });
  }
}
