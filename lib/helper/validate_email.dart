bool validateEmail(String email) {
  // #TODO: add checks for admin accounts
  if (email.endsWith('@mbcet.ac.in')) {
    return true;
  } else {
    return false;
  }
}
