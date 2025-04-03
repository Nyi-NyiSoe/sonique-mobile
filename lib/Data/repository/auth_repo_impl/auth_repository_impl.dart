import 'package:sonique/Data/models/user_model.dart';
import 'package:sonique/Data/source/auth_repo/auth_local_data_source.dart';
import 'package:sonique/Data/source/auth_repo/auth_remote_data_source.dart';
import 'package:sonique/Domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final user = await remoteDataSource.login(email, password);
      await localDataSource.saveUser(user);
      return user;
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await localDataSource.deleteUser();
    } catch (e) {
      throw Exception('Failed to logout: $e');
    }
  }
}
