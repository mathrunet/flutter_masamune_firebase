part of masamune.firebase;

class ReAuth extends UIPageReAuth {
  /// What happens when a form is submitted.
  ///
  /// [context]: Build context.
  /// [form]: Form data.
  @override
  void onSubmit(BuildContext context, IDataDocument form) async {
    if (!this.validate(context)) return;
    final auth = await EmailAndPasswordAuth.reauth(password: form["password"])
        .showIndicator(context);
    if (auth == null || auth.isError || auth.isAbort) {
      UIDialog.show(context,
          title: "Error".localize(),
          text: "Could not login. Please check your email address and password."
              .localize(),
          submitText: "OK",
          onSubmit: () {});
      return;
    }
    context.navigator.pushReplacementNamed(this.data.getString("redirect_to"));
  }
}
