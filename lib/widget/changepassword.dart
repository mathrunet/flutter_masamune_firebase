part of masamune.firebase;

class ChangePassword extends UIPageChangePassword {
  /// What happens when a form is submitted.
  @override
  void onSubmit(BuildContext context) async {
    if (!this.validate()) return;
    if (form["password"] != form["confirmation"]) {
      UIDialog.show(context,
          title: "Error".localize(),
          text: "Passwords do not match.".localize(),
          submitText: "OK".localize(),
          onSubmit: () {});
      return;
    }
    final auth = await FirestoreAuth.changePassword(password: form["password"])
        .showIndicator(context);
    if (auth == null || auth.isError || auth.isAbort) {
      UIDialog.show(context,
          title: "Error".localize(),
          text: "Editing is not completed.".localize(),
          submitText: "OK".localize(),
          onSubmit: () {});
      return;
    }
    UIDialog.show(context,
        title: "Success".localize(),
        text: "Editing is complete.".localize(),
        submitText: "OK".localize(), onSubmit: () {
      context.navigator.pop();
    });
  }
}
