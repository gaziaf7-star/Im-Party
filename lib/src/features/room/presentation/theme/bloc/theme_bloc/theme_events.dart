part of 'theme_bloc.dart';

abstract class ThemeEvents extends Equatable {
  const ThemeEvents();
}

// pick image
class GetThemesEvent extends ThemeEvents {
  const GetThemesEvent(); 

  @override
  List<Object> get props => [];
}

class SelectThemeEvent extends ThemeEvents {
  final String imageId;
  const SelectThemeEvent({required this.imageId}); 

  @override
  List<Object> get props => [ imageId ];
}

