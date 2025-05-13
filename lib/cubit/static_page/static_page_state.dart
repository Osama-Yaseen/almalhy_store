abstract class StaticPageState {}

class StaticPageInitial extends StaticPageState {}

class StaticPageLoading extends StaticPageState {}

class StaticPageLoaded extends StaticPageState {
  final String title;
  final dynamic content;
  StaticPageLoaded({required this.title, required this.content});
}

class StaticPageError extends StaticPageState {
  final String message;
  StaticPageError(this.message);
}
