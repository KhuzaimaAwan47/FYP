
//Validators

class Validators{


  static String? validateUsername (String? value) {
    if (value!.isEmpty) {
      return 'Please enter a username';
    }
    if (value.length < 6) {
      return 'Username must be at least 6 characters long';
    }
    return null;

  }

 static String? validateEmail (String? value) {
   final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
   if (!emailRegex.hasMatch(value!)) {
     return 'Please enter a valid email address';
   }
   return null;
}

static String? validatePassword (String? value){
   if (value!.isEmpty) {
     return 'Please enter a password';
   }
   if (value.length < 6) {
     return 'Password must be at least 6 characters long';
   }
   if (!RegExp(r'[a-zA-Z]').hasMatch(value)) {
     return 'Password must contain at least one letter';
   }
   if (!RegExp(r'\d').hasMatch(value)) {
     return 'Password must contain at least one number';
   }
   return null;
 }

 static String? validateConfirmPassword(String? value, String? password) {
   if (value != password) {
     return 'Passwords do not match';
   }

   if (value == null || value.isEmpty) {
     return 'Please confirm your password';  // Ensures the confirm password field is not empty.
   }

   return null;
 }



}