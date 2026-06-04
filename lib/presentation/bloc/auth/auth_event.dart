part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthCheckStatus extends AuthEvent {}

class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;
  const AuthSignUpRequested({required this.email, required this.password, required this.name});
  @override
  List<Object?> get props => [email, password, name];
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  const AuthLoginRequested({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}

class AuthAnonymousLoginRequested extends AuthEvent {}

class AuthLogoutRequested extends AuthEvent {}