


import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

abstract interface class AuthRemoteDataSource {
  auth.User? get currentUser;
  Future<UserModel> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  });
  Future<UserModel> loginWithEmailPassword({
    required String email,
    required String password,
  });
  Future<UserModel?> getCurrentUserData();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final auth.FirebaseAuth firebaseAuth;
  final FirebaseFirestore firebaseFirestore;
  AuthRemoteDataSourceImpl(this.firebaseAuth, this.firebaseFirestore);

  @override
  auth.User? get currentUser => firebaseAuth.currentUser;

  @override
  Future<UserModel> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await firebaseAuth.signInWithEmailAndPassword(
        password: password,
        email: email,
      );
      if (response.user == null) {
        throw const ServerException('User is null!');
      }
      final data = await firebaseFirestore.collection(FireStoreCollections.userCollection).doc(response.user!.uid).get();

      if(data.data() == null){
        throw const ServerException('User does\'nt exists in DB!');
      }

      return UserModel.fromJson(data.data()!);
    } on auth.FirebaseAuthException catch (e) {
      throw ServerException(e.message!);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await firebaseAuth.createUserWithEmailAndPassword(
        password: password,
        email: email,
      );

      if (response.user == null) {
        throw const ServerException('User is null!');
      }
      await firebaseFirestore.collection(FireStoreCollections.userCollection).doc(response.user!.uid).set({
        "name":name,
        "email":response.user!.email!,
        "id":response.user!.uid,
      });

      return UserModel(
        id:response.user!.uid,
        email: response.user!.email!,
        name: name,
      );
    } on auth.FirebaseAuthException catch (e) {
      throw ServerException(e.message!);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel?> getCurrentUserData() async {
    try {
      if (currentUser != null) {
        final userData = await firebaseFirestore.collection(FireStoreCollections.userCollection).doc(currentUser!.uid).get();
        return UserModel.fromJson(userData.data()!).copyWith(
          email: currentUser!.email,
        );
      }

      return null;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }


}
