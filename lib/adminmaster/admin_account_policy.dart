class AdminAccountPolicy {
  const AdminAccountPolicy._();

  static bool isSelfAccount(String currentEmail, String targetEmail) {
    return currentEmail.trim().toLowerCase() == targetEmail.trim().toLowerCase();
  }

  static bool canManageAccount({
    required String currentEmail,
    required String targetEmail,
  }) {
    return !isSelfAccount(currentEmail, targetEmail);
  }
}
