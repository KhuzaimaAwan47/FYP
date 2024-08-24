Future signUpUser() async {
  if (passwordConfirmed()) {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      //add user details
      addUserDetails(
        usernameController.text.trim(),
        emailController.text.trim(),
        isClientChecked ? 'client' : 'freelancer',
        passwordController.text.trim(),
      );
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => LoginPage()));
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'email-already-in-use'){
        errorMessage = 'The email is already is in use. Please provide a different email.';
      }else if(e.code == 'invalid-email'){
        errorMessage = 'The email you provide is not valid. Please provide a valid email.';
      }else if(e.code == 'username-already-in-use'){
        errorMessage = 'This username alreay exits.';
      }else{
        errorMessage = 'An unexpected error occured. Please try again later.';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('errorMessage')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('An unexpected error occured. Please try again later.')),
      );
      print('Error $e');
    }
  }else{
    //print('Password do not match.');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Password do not match')),
    );
  }
}// SignUpUser
Future addUserDetails(String username, String email, String userType, String password) async {
  await FirebaseFirestore.instance.collection('users').add({
    'username' : username,
    'userType' : userType,
    'email'    : email,
    'passowrd' : password,
  });
}