part of masamune.firebase;

class ChangeEmail extends UIPageChangeEmail {
  /// Default mail address.
  @protected
  @override
  String get email => FirestoreAuth.getEmail();

  /// What happens when a form is submitted.
  ///
  /// [context]: Build context.
  /// [form]: Form data.
  @override
  void onSubmit(BuildContext context, IDataDocument form) async {
    if (!this.validate(context)) return;
    final auth = await EmailAndPasswordAuth.changeEmail(email: form["email"])
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
