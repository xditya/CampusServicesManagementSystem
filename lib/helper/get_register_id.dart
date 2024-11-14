String getRegisterIdFromEmail(String email) {
  List<String> emailParts = email.split('@');
  if (emailParts.length > 1) {
    List<String> idParts = emailParts[0].split('.');
    if (idParts.length > 1) {
      return idParts[1].toUpperCase();
    }
  }
  return '';
}
