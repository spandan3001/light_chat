part of 'init_dependencies.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  _initAuth();
  //_initBlog();



  Hive.defaultDirectory = (await getApplicationDocumentsDirectory()).path;

  serviceLocator.registerLazySingleton(() => FirebaseAuth.instance);
  serviceLocator.registerLazySingleton(() => FirebaseFirestore.instance);

  serviceLocator.registerLazySingleton(
    () => Hive.box(name: 'chats'),
  );

  serviceLocator.registerFactory(() => InternetConnection());

  // core
  serviceLocator.registerLazySingleton(
    () => AppUserCubit(),
  );

  serviceLocator.registerFactory<ConnectionChecker>(
    () => ConnectionCheckerImpl(
      serviceLocator(),
    ),
  );
}

void _initAuth() {
  // Datasource
  serviceLocator
    ..registerFactory<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(
        serviceLocator(),
          serviceLocator()
      ),
    )
    // Repository
    ..registerFactory<AuthRepository>(
      () => AuthRepositoryImpl(
        serviceLocator(),
        serviceLocator(),
      ),
    )
    // Usecases
    ..registerFactory(
      () => UserSignUp(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => UserLogin(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => CurrentUser(
        serviceLocator(),
      ),
    )
    // Bloc
    ..registerLazySingleton(
      () => AuthBloc(
        userSignUp: serviceLocator(),
        userLogin: serviceLocator(),
        currentUser: serviceLocator(),
        appUserCubit: serviceLocator(),
      ),
    );
}

// void _initBlog() {
//   // Datasource
//   serviceLocator
//     ..registerFactory<BlogRemoteDataSource>(
//       () => BlogRemoteDataSourceImpl(
//         serviceLocator(),
//       ),
//     )
//     ..registerFactory<BlogLocalDataSource>(
//       () => BlogLocalDataSourceImpl(
//         serviceLocator(),
//       ),
//     )
//     // Repository
//     ..registerFactory<BlogRepository>(
//       () => BlogRepositoryImpl(
//         serviceLocator(),
//         serviceLocator(),
//         serviceLocator(),
//       ),
//     )
//     // Usecases
//     ..registerFactory(
//       () => UploadBlog(
//         serviceLocator(),
//       ),
//     )
//     ..registerFactory(
//       () => GetAllBlogs(
//         serviceLocator(),
//       ),
//     )
//     // Bloc
//     ..registerLazySingleton(
//       () => BlogBloc(
//         uploadBlog: serviceLocator(),
//         getAllBlogs: serviceLocator(),
//       ),
//     );
// }
