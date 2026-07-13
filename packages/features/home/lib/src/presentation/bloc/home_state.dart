import '../../domain/home_data.dart';

/// State of the Home dashboard (SM-004).
class HomeState {
  const HomeState({
    this.data = HomeData.empty,
    this.isLoading = false,
    this.error,
  });

  final HomeData data;
  final bool isLoading;
  final String? error;
}
