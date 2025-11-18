abstract class Exception {}
abstract class CreateUserException {}

class SignUpErrorException implements CreateUserException {
  SignUpErrorException();
}

class UserAlreadyExistException implements CreateUserException {
  UserAlreadyExistException();
}

class TokenInvalidTypeException implements Exception {
  TokenInvalidTypeException();
}


class CommonException implements Exception {
  CommonException(this.error);

  final String error;
}

