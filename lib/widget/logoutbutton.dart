part of masamune.firebase;

/// Menu button to log out.
///
/// Please install it in the actions of AppBar.
class LogoutButton extends StatelessWidget {
  /// Button label.
  final String label;

  /// Confirmation screen title.
  final String confirmTitle;

  /// Confirmation screen text.
  final String confirmText;

  /// Submit button text.
  final String submitText;

  /// Cancel button text.
  final String cancelText;

  /// The title of the logout completion screen.
  final String completedTitle;

  /// Text of the logout completion screen.
  final String completedText;

  /// The root path of the page to return to after logging out.
  /// (usually the login screen)
  final String backRoutePath;

  /// Menu button to log out.
  ///
  /// Please install it in the actions of AppBar.
  LogoutButton(
      {this.label,
      this.confirmText,
      this.confirmTitle,
      this.submitText,
      this.cancelText,
      this.completedText,
      this.completedTitle,
      this.backRoutePath = "/login"});

  /// Build method.
  ///
  /// [BuildContext]: Build Context.
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      color: Colors.white,
      onSelected: (String s) {
        UIConfirm.show(context,
            title: this.confirmTitle,
            text: this.confirmText,
            submitText: this.submitText, onSubmit: () async {
          await FirestoreAuth.signOut().showIndicator(context);
          UIDialog.show(context,
              title: this.completedTitle,
              text: this.completedText, onSubmit: () async {
            context.navigator
                .pushNamedAndRemoveUntil(this.backRoutePath, (route) => false);
          });
        }, cacnelText: this.cancelText);
      },
      itemBuilder: (BuildContext context) {
        return [
          PopupMenuItem(
            child: Text(this.label),
            value: "logout",
          )
        ];
      },
    );
  }
}
