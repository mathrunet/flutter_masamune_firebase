part of masamune.firebase;

/// Menu button to account management.
///
/// Please install it in the actions of AppBar.
class AccountButton extends StatelessWidget {
  /// Logout button label.
  final String logoutLabel;

  /// User delete button label.
  final String deleteLabel;

  /// Change email button label.
  final String changeEmailLabel;

  /// Change password button label.
  final String changePasswordLabel;

  /// Setting button label.
  final String settingLabel;

  /// Confirmation screen title.
  final String logoutConfirmTitle;

  /// Confirmation screen text.
  final String logoutConfirmText;

  /// Submit button text.
  final String logoutSubmitText;

  /// Cancel button text.
  final String logoutCancelText;

  /// The title of the logout completion screen.
  final String logoutCompletedTitle;

  /// Text of the logout completion screen.
  final String logoutCompletedText;

  /// Confirmation screen title.
  final String deleteConfirmTitle;

  /// Confirmation screen text.
  final String deleteConfirmText;

  /// Submit button text.
  final String deleteSubmitText;

  /// Cancel button text.
  final String deleteCancelText;

  /// The title of the logout completion screen.
  final String deleteCompletedTitle;

  /// Text of the logout completion screen.
  final String deleteCompletedText;

  /// Displays the deleting user account menu.
  final bool enableDeleteAccount;

  /// The root path of the page to return to after logging out.
  /// (usually the login screen)
  final String backRoutePath;

  /// The path to the password change screen.
  final String changePasswordRoutePath;

  /// The path to the email change screen.
  final String changeEmailRoutePath;

  /// Recertification screen path.
  final String reauthRoutePath;

  /// Displays the email address change menu.
  final bool enableChangeEmail;

  /// Displays the password change menu.
  final bool enableChangePassword;

  /// Callback for a successful logout.
  final Function onLogout;

  /// Callback for a successful account deletion.
  final Function onDeleted;

  /// The route path of the setting.
  final String settingRoutePath;

  /// True if the setting is enabled.
  final bool enableSetting;

  /// Menu button to account management.
  ///
  /// Please install it in the actions of AppBar.
  AccountButton(
      {this.logoutLabel = "Logout",
      this.logoutConfirmText = "You're logging out. Are you sure?",
      this.logoutConfirmTitle = "Confirmation",
      this.logoutSubmitText = "Yes",
      this.logoutCancelText = "No",
      this.logoutCompletedText = "Logout is complete.",
      this.logoutCompletedTitle = "Success",
      this.deleteLabel = "Account deletion",
      this.deleteConfirmText =
          "The account is deleted. After deleting the account, it cannot be restored. Are you sure?",
      this.deleteConfirmTitle = "Confirmation",
      this.deleteSubmitText = "Yes",
      this.deleteCancelText = "No",
      this.deleteCompletedText = "Account deletion is complete.",
      this.deleteCompletedTitle = "Success",
      this.changeEmailLabel = "Change Email",
      this.changePasswordLabel = "Change Password",
      this.settingLabel = "Setting",
      this.backRoutePath = "/login",
      this.reauthRoutePath = "/account/reauth",
      this.changeEmailRoutePath = "/account/email/edit",
      this.changePasswordRoutePath = "/account/password/edit",
      this.settingRoutePath = "/setting",
      this.enableDeleteAccount = false,
      this.enableSetting = false,
      this.enableChangeEmail = false,
      this.onLogout,
      this.onDeleted,
      this.enableChangePassword = false});

  /// Build method.
  ///
  /// [BuildContext]: Build Context.
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      color: Colors.white,
      onSelected: (String s) {
        switch (s) {
          case "setting":
            context.rootNavigator.pushNamed(this.settingRoutePath);
            break;
          case "delete":
            UIConfirm.show(context,
                title: this.deleteConfirmTitle.localize(),
                text: this.deleteConfirmText.localize(),
                submitText: this.deleteSubmitText.localize(),
                onSubmit: () async {
              FirestoreAuth auth =
                  await FirestoreAuth.delete().showIndicator(context);
              if (auth == null || auth.isError || auth.isAbort) {
                UIDialog.show(context,
                    title: "Error".localize(), text: auth?.message);
                return;
              }
              if (this.onDeleted != null) this.onDeleted();
              UIDialog.show(context,
                  title: this.deleteCompletedTitle.localize(),
                  text: this.deleteCompletedText.localize(),
                  onSubmit: () async {
                context.navigator.pushNamedAndRemoveUntil(
                    this.backRoutePath, (route) => false);
              });
            }, cacnelText: this.deleteCancelText.localize());
            break;
          case "logout":
            UIConfirm.show(context,
                title: this.logoutConfirmTitle.localize(),
                text: this.logoutConfirmText.localize(),
                submitText: this.logoutSubmitText.localize(),
                onSubmit: () async {
              FirestoreAuth auth =
                  await FirestoreAuth.signOut().showIndicator(context);
              if (auth == null || auth.isError || auth.isAbort) {
                UIDialog.show(context,
                    title: "Error".localize(), text: auth?.message);
                return;
              }
              if (this.onLogout != null) this.onLogout();
              UIDialog.show(context,
                  title: this.logoutCompletedTitle.localize(),
                  text: this.logoutCompletedText.localize(),
                  onSubmit: () async {
                context.navigator.pushNamedAndRemoveUntil(
                    this.backRoutePath, (route) => false);
              });
            }, cacnelText: this.logoutCancelText.localize());
            break;
          case "changeEmail":
            context.rootNavigator.pushNamed(
                "${this.reauthRoutePath}?redirect_to=${this.changeEmailRoutePath}");
            break;
          case "changePassword":
            context.rootNavigator.pushNamed(
                "${this.reauthRoutePath}?redirect_to=${this.changePasswordRoutePath}");
            break;
        }
      },
      itemBuilder: (BuildContext context) {
        return [
          if (this.enableSetting)
            PopupMenuItem(
              child: Text(this.settingLabel.localize()),
              value: "setting",
            ),
          if (this.enableChangeEmail)
            PopupMenuItem(
              child: Text(this.changeEmailLabel.localize()),
              value: "changeEmail",
            ),
          if (this.enableChangePassword)
            PopupMenuItem(
              child: Text(this.changePasswordLabel.localize()),
              value: "changePassword",
            ),
          PopupMenuItem(
            child: Text(this.logoutLabel.localize()),
            value: "logout",
          ),
          if (this.enableDeleteAccount)
            PopupMenuItem(
              child: Text(this.deleteLabel.localize()),
              value: "delete",
            ),
        ];
      },
    );
  }
}
