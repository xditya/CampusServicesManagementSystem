bool validateEmail(String email) {
  // #TODO: add checks for admin accounts
  if (email.endsWith('@mbcet.ac.in') || email.endsWith("@xditya.me")) {
    return true;
  } else {
    return false;
  }
}
