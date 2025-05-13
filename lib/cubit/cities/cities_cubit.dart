import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:almalhy_store/errors/exception.dart';
import 'package:almalhy_store/errors/handler.dart';
import 'package:almalhy_store/services/city_service.dart';
import 'package:bloc/bloc.dart';
import 'cities_state.dart';
import 'package:almalhy_store/models/city_model.dart';

class CitiesCubit extends Cubit<CitiesState> {
  final CityService _cityService;
  static const _citiesKey = 'KEY_CITIES';

  CitiesCubit(this._cityService) : super(CitiesInitial());

  Future<void> fetchCities({String lang = 'en'}) async {
    emit(CitiesLoading());

    try {
      // 1️⃣ Try to load saved cities
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_citiesKey);
      if (stored != null) {
        final List<dynamic> jsonList = jsonDecode(stored);
        final cached =
            jsonList
                .map((e) => CityModel.fromJson(e as Map<String, dynamic>))
                .toList();
        emit(CitiesLoaded(cached));
        return;
      }

      // 2️⃣ If none saved yet, call the API
      final cities = await _cityService.getCities(lang: lang);

      // 3️⃣ Persist them for next time
      final encoded = jsonEncode(cities.map((c) => c.toJson()).toList());
      await prefs.setString(_citiesKey, encoded);

      emit(CitiesLoaded(cities));
    } on AppException catch (e) {
      emit(CitiesError(e.message));
    } catch (e) {
      final failure = handleException(e as Exception);
      emit(CitiesError(failure.message));
    }
  }
}
