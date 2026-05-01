import 'package:coworkhub/database/db_helper.dart';

class WorkspaceService {
  final DBHelper _dbHelper = DBHelper();

  Future<List<Map<String, dynamic>>> getWorkspaces() async {
    return await _dbHelper.getWorkspaces();
  }

  Future<List<Map<String, dynamic>>> getAmenities() async {
    return await _dbHelper.getAmenities();
  }
}