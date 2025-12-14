import 'package:shared_preferences/shared_preferences.dart';
import 'package:trawallet_final_version/services/auth_service.dart';
import 'dart:convert';

class FavoritesService {
  static const String _favoritesPrefix = 'favorite_destinations_';
  static final FavoritesService _instance = FavoritesService._internal();
  factory FavoritesService() => _instance;
  FavoritesService._internal();

  final Map<String, Set<String>> _favoritesCache = {};
  String? _currentUserId;
  bool _isInitialized = false;

  String _getFavoritesKey(String userId) {
    return '$_favoritesPrefix$userId';
  }

  String? _getCurrentUserId() {
    final authService = AuthService();
    final user = authService.currentUser;

    if (user?.uid != null) {
      return user!.uid;
    } else if (user?.email != null) {
      return user!.email!;
    }

    return null;
  }

  Future<void> initialize() async {
    final userId = _getCurrentUserId();

    if (userId == null) {
      print('Warning: No user logged in. Favorites will not be saved.');
      _currentUserId = null;
      _isInitialized = true;
      return;
    }

    if (_isInitialized && _currentUserId == userId) return;

    _currentUserId = userId;

    if (!_favoritesCache.containsKey(userId)) {
      final prefs = await SharedPreferences.getInstance();
      final favoritesKey = _getFavoritesKey(userId);
      final favoritesJson = prefs.getString(favoritesKey);

      if (favoritesJson != null) {
        try {
          final List<dynamic> favoritesList = json.decode(favoritesJson);
          _favoritesCache[userId] = favoritesList
              .map((id) => id.toString())
              .toSet();
        } catch (e) {
          print('Error loading favorites: $e');
          _favoritesCache[userId] = {};
        }
      } else {
        _favoritesCache[userId] = {};
      }
    }

    _isInitialized = true;
  }

  Future<void> reset() async {
    _isInitialized = false;
    _currentUserId = null;
  }

  Set<String> _getCurrentUserFavorites() {
    final userId = _currentUserId;
    if (userId == null) return {};
    return _favoritesCache[userId] ?? {};
  }

  Future<Set<String>> getFavorites() async {
    await initialize();
    return Set.from(_getCurrentUserFavorites());
  }

  Future<bool> isFavorite(String destinationId) async {
    await initialize();
    return _getCurrentUserFavorites().contains(destinationId);
  }

  Future<bool> addFavorite(String destinationId) async {
    await initialize();

    final userId = _currentUserId;
    if (userId == null) {
      print('Cannot add favorite: No user logged in');
      return false;
    }

    _favoritesCache[userId] = _favoritesCache[userId] ?? {};
    _favoritesCache[userId]!.add(destinationId);

    return await _saveFavorites(userId);
  }

  Future<bool> removeFavorite(String destinationId) async {
    await initialize();

    final userId = _currentUserId;
    if (userId == null) {
      print('Cannot remove favorite: No user logged in');
      return false;
    }

    _favoritesCache[userId]?.remove(destinationId);

    return await _saveFavorites(userId);
  }

  Future<bool> toggleFavorite(String destinationId) async {
    await initialize();

    final userId = _currentUserId;
    if (userId == null) {
      print('Cannot toggle favorite: No user logged in');
      return false;
    }

    if (_getCurrentUserFavorites().contains(destinationId)) {
      return await removeFavorite(destinationId);
    } else {
      return await addFavorite(destinationId);
    }
  }

  Future<bool> _saveFavorites(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesKey = _getFavoritesKey(userId);
      final favorites = _favoritesCache[userId] ?? {};
      final favoritesJson = json.encode(favorites.toList());

      await prefs.setString(favoritesKey, favoritesJson);
      return true;
    } catch (e) {
      print('Error saving favorites: $e');
      return false;
    }
  }

  Future<bool> clearFavorites() async {
    await initialize();

    final userId = _currentUserId;
    if (userId == null) {
      print('Cannot clear favorites: No user logged in');
      return false;
    }

    _favoritesCache[userId] = {};
    return await _saveFavorites(userId);
  }

  Future<int> getFavoritesCount() async {
    await initialize();
    return _getCurrentUserFavorites().length;
  }

  Future<bool> deleteUserFavorites(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesKey = _getFavoritesKey(userId);
      await prefs.remove(favoritesKey);

      _favoritesCache.remove(userId);

      return true;
    } catch (e) {
      print('Error deleting user favorites: $e');
      return false;
    }
  }

  Future<Set<String>> getFavoritesForUser(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesKey = _getFavoritesKey(userId);
    final favoritesJson = prefs.getString(favoritesKey);

    if (favoritesJson != null) {
      try {
        final List<dynamic> favoritesList = json.decode(favoritesJson);
        return favoritesList.map((id) => id.toString()).toSet();
      } catch (e) {
        print('Error loading favorites for user $userId: $e');
        return {};
      }
    }

    return {};
  }
}
