import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:caretime/services/patient_api_service.dart';

class DoctorsState {
  final List<Map<String, dynamic>> doctors;
  final bool isLoading;
  final String? error;
  final String searchQuery;
  final String? selectedSpecialty;
  final String? selectedCountry;
  final String? selectedCity;

  const DoctorsState({
    this.doctors = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
    this.selectedSpecialty,
    this.selectedCountry,
    this.selectedCity,
  });

  DoctorsState copyWith({
    List<Map<String, dynamic>>? doctors,
    bool? isLoading,
    String? error,
    String? searchQuery,
    String? selectedSpecialty,
    String? selectedCountry,
    String? selectedCity,
  }) {
    return DoctorsState(
      doctors: doctors ?? this.doctors,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedSpecialty: selectedSpecialty ?? this.selectedSpecialty,
      selectedCountry: selectedCountry ?? this.selectedCountry,
      selectedCity: selectedCity ?? this.selectedCity,
    );
  }

  List<Map<String, dynamic>> get filteredDoctors {
    return doctors.where((doctor) {
      final searchLower = searchQuery.toLowerCase();
      final matchesSearch =
          searchLower.isEmpty ||
          (doctor['firstname'] ?? '').toString().toLowerCase().contains(
            searchLower,
          ) ||
          (doctor['lastname'] ?? '').toString().toLowerCase().contains(
            searchLower,
          ) ||
          ('${doctor['firstname'] ?? ''} ${doctor['lastname'] ?? ''}')
              .toLowerCase()
              .contains(searchLower) ||
          (doctor['specialty'] ?? '').toString().toLowerCase().contains(
            searchLower,
          ) ||
          (doctor['country'] ?? '').toString().toLowerCase().contains(
            searchLower,
          ) ||
          (doctor['city'] ?? '').toString().toLowerCase().contains(searchLower);

      final matchesSpecialty =
          selectedSpecialty == null ||
          selectedSpecialty == 'All specialties' ||
          doctor['specialty'] == selectedSpecialty;

      final matchesCountry =
          selectedCountry == null ||
          selectedCountry == 'All countries' ||
          doctor['country'] == selectedCountry;

      final matchesCity =
          selectedCity == null ||
          selectedCity == 'All cities' ||
          doctor['city'] == selectedCity;

      return matchesSearch && matchesSpecialty && matchesCountry && matchesCity;
    }).toList();
  }
}

class DoctorsNotifier extends StateNotifier<DoctorsState> {
  DoctorsNotifier() : super(const DoctorsState());

  Future<void> loadDoctors() async {
    if (state.isLoading) return;

    try {
      state = state.copyWith(isLoading: true, error: null);

      final doctors = await PatientApiService.getDoctorsListWithRetry(
        maxRetries: 2,
        retryDelay: const Duration(seconds: 1),
      );

      if (!state.isLoading) return;

      state = state.copyWith(doctors: doctors, isLoading: false);
    } catch (e) {
      print('❌ Error loading doctors: $e');

      if (!state.isLoading) return;

      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
        doctors: [],
      );
    }
  }

  Future<void> refreshDoctors() async {
    if (state.isLoading) return;

    try {
      state = state.copyWith(isLoading: true, error: null);

      final doctors = await PatientApiService.refreshDoctorsList();

      if (!state.isLoading) return;

      state = state.copyWith(doctors: doctors, isLoading: false);
    } catch (e) {
      print('❌ Error refreshing doctors: $e');

      if (!state.isLoading) return;

      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setSelectedSpecialty(String? specialty) {
    state = state.copyWith(selectedSpecialty: specialty);
  }

  void setSelectedCountry(String? country) {
    state = state.copyWith(selectedCountry: country, selectedCity: null);
  }

  void setSelectedCity(String? city) {
    state = state.copyWith(selectedCity: city);
  }

  void clearFilters() {
    state = state.copyWith(
      searchQuery: '',
      selectedSpecialty: null,
      selectedCountry: null,
      selectedCity: null,
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final doctorsProvider = StateNotifierProvider<DoctorsNotifier, DoctorsState>((
  ref,
) {
  return DoctorsNotifier();
});

// Providers dérivés
final filteredDoctorsProvider = Provider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(doctorsProvider).filteredDoctors;
});

final doctorsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(doctorsProvider).isLoading;
});

final doctorsErrorProvider = Provider<String?>((ref) {
  return ref.watch(doctorsProvider).error;
});

// Provider auto-initialisé pour les docteurs
final autoDoctorsProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  try {
    return await PatientApiService.getDoctorsListWithRetry(
      maxRetries: 2,
      retryDelay: const Duration(seconds: 1),
    );
  } catch (e) {
    print('❌ Error in autoDoctorsProvider: $e');
    rethrow;
  }
});

// Provider pour l'état des docteurs avec auto-initialisation
final doctorsStateProvider =
    StateNotifierProvider<DoctorsNotifier, DoctorsState>((ref) {
      final notifier = DoctorsNotifier();

      // Auto-initialiser les données
      ref.listen(autoDoctorsProvider, (previous, next) {
        next.when(
          data: (doctors) {
            notifier.state = notifier.state.copyWith(
              doctors: doctors,
              isLoading: false,
              error: null,
            );
          },
          loading: () {
            notifier.state = notifier.state.copyWith(
              isLoading: true,
              error: null,
            );
          },
          error: (error, stack) {
            notifier.state = notifier.state.copyWith(
              error: error.toString(),
              isLoading: false,
              doctors: [],
            );
          },
        );
      });

      return notifier;
    });
