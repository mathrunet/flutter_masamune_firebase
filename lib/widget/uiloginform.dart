part of masamune.firebase;

/// Display the login form.
class UILoginForm extends StatelessWidget with UIFormMixin {
  /// Dialog title.
  final String title;

  /// Default submit button text.
  final String defaultSubmitText;

  /// Default submit button action.
  final void Function(String email, String password) defaultSubmitAction;

  /// Display the login form.
  ///
  /// [title]: Dialog title.
  /// [defaultSubmitText]: Default submit button text.
  /// [defaultSubmitAction]: Default submit button action.
  UILoginForm(
      {this.title = "Email & Password SignIn",
      this.defaultSubmitText = "Login",
      this.defaultSubmitAction});

  /// Build method.
  ///
  /// [BuildContext]: Build Context.
  @override
  Widget build(BuildContext context) {
    return Form(
      key: this.formKey,
      autovalidate: true,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TextFormField(
                maxLength: 200,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: "Please enter a email address".localize(),
                  labelText: "Email".localize(),
                ),
                autovalidate: false,
                validator: (value) {
                  if (isEmpty(value))
                    return "Please enter some text".localize();
                  return null;
                },
                onSaved: (value) {
                  if (isEmpty(value)) return;
                  context.form["email"] = value;
                })),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TextFormField(
                obscureText: true,
                maxLength: 50,
                keyboardType: TextInputType.visiblePassword,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: "Please enter a password".localize(),
                  labelText: "Password".localize(),
                ),
                autovalidate: false,
                validator: (value) {
                  if (isEmpty(value))
                    return "Please enter some text".localize();
                  if (value.length < 8) {
                    return Texts.format(
                        "Please enter at least %s characters.".localize(),
                        [8]);
                  }
                  return null;
                },
                onSaved: (value) {
                  if (isEmpty(value)) return;
                  context.form["password"] = value;
                }))
      ]));
  }
}
