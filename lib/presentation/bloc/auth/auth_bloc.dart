import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb
        ? '932446762055-ltf9rqlft49pbd3r7f3q9h03r5c3b1jg.apps.googleusercontent.com'
        : null,
  );

  AuthBloc() : super(AuthInitial()) {
    on<AuthCheckStatus>(_onCheckStatus);
    on<AuthSignUpRequested>(_onSignUp);
    on<AuthLoginRequested>(_onLogin);
    on<AuthAnonymousLoginRequested>(_onAnonymousLogin);
    on<AuthGoogleLoginRequested>(_onGoogleLogin);
    on<AuthLogoutRequested>(_onLogout);
  }

  void _onCheckStatus(AuthCheckStatus event, Emitter<AuthState> emit) {
    final user = _auth.currentUser;
    if (user != null) {
      emit(Authenticated(user));
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> _onSignUp(AuthSignUpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      await cred.user?.updateDisplayName(event.name);
      await _firestore.collection('users').doc(cred.user!.uid).set({
        'name': event.name,
        'email': event.email,
        'createdAt': FieldValue.serverTimestamp(),
      });
      emit(Authenticated(cred.user!));
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'Sign up failed'));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogin(AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      emit(Authenticated(cred.user!));
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'Login failed'));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onAnonymousLogin(AuthAnonymousLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final cred = await _auth.signInAnonymously();
      emit(Authenticated(cred.user!));
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'Anonymous login failed'));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogout(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    if (!kIsWeb) await _googleSignIn.signOut();
    await _auth.signOut();
    emit(Unauthenticated());
  }

  Future<void> _onGoogleLogin(
      AuthGoogleLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      UserCredential cred;

      if (kIsWeb) {
        // On web, use Firebase's built-in signInWithPopup — no deprecated signIn()
        final provider = GoogleAuthProvider();
        provider.addScope('email');
        cred = await _auth.signInWithPopup(provider);
      } else {
        // On mobile, use google_sign_in package
        final googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          emit(Unauthenticated());
          return;
        }
        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        cred = await _auth.signInWithCredential(credential);
      }

      final user = cred.user!;
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) {
        await _firestore.collection('users').doc(user.uid).set({
          'name': user.displayName ?? '',
          'email': user.email ?? '',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      emit(Authenticated(user));
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'Google sign-in failed'));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
