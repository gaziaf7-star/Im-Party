part of 'delete_song_bloc.dart';

 class BaseDeleteSongEvent extends Equatable{
  @override
  List<Object?> get props => [];
}
 class DeleteSongEvent extends BaseDeleteSongEvent{
   final int songId;
   DeleteSongEvent({required this.songId});
 }
