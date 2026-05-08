import 'package:coworkhub/database/db_helper.dart';

class FavoriteService {

  final DBHelper _dbHelper = DBHelper();

  Future<bool> toggleFavorite(
      int userId,
      int resourceId,
      bool isFavorite,
      ) async {

    if (isFavorite) {
      await _dbHelper.removeFavorite(
        userId,
        resourceId,
      );

      return false;

    } else {

      await _dbHelper.addFavorite(
        userId,
        resourceId,
      );

      return true;
    }
  }

  Future<bool> isFavorite(
      int userId,
      int resourceId,
      ) async {

    return await _dbHelper.isFavorite(
      userId,
      resourceId,
    );
  }
}