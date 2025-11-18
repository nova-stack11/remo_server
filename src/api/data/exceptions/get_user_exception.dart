abstract class GetUserException {}

class NotFoundUserException implements GetUserException {
  NotFoundUserException();
}

class WrongPasswordException implements GetUserException {
  WrongPasswordException();
}

