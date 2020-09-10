part of masamune.firebase;

class ChangeEmail extends UIPageChangeEmail {
  /// Initial definition of the controller.
  ///
  /// [context]: Build context.
  @override
  Map<String, String> define(BuildContext context) {
    return {"email": FirestoreAuth.getEmail()};
  }

  /// What happens when a form is submitted.
  @override
  void onSubmit(BuildContext context) async {
    if (!this.validate(context)) return;
    final auth = await FirestoreAuth.changeEmail(email: form["email"])
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
