part of masamune.firebase;

class ChangeEmail extends UIPageForm {
  /// Page title.
  @protected
  String get title => "Change Email".localize();

  /// Set the form type.
  ///
  /// Available for login and password reset page.
  FormBuilderType get formType => FormBuilderType.center;

  /// Creating a app bar.
  ///
  /// [context]: Build context.
  @protected
  @override
  Widget appBar(BuildContext context) {
    return AppBar(title: Text(this.title));
  }

  /// Initial definition of the controller.
  ///
  /// [context]: Build context.
  @override
  Map<String, String> define(BuildContext context) {
    return {"email": FirestoreAuth.getEmail()};
  }

  /// Form body definition.
  ///
  /// [context]: Build context.
  @override
  List<Widget> formBody(BuildContext context,
      Map<String, TextEditingController> controller, IDataDocument form) {
    return [
      Text(
        "Please enter the information you want to change".localize(),
        textAlign: TextAlign.center,
      ),
      SizedBox(height: 20),
      FormItemTextField(
        controller: controller["email"],
        hintText: "Please enter a email address".localize(),
        labelText: "Email".localize(),
        keyboardType: TextInputType.emailAddress,
        onSaved: (value) {
          if (isEmpty(value)) return;
          form["email"] = value;
        },
      ),
    ];
  }

  /// Data load.
  ///
  /// [context]: Build context.
  @override
  FutureOr<IDataDocument<IDataField>> loader(BuildContext context) {
    return null;
  }

  /// What happens when a form is submitted.
  @override
  void onSubmit(BuildContext context) async {
    if (!this.validate()) return;
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
