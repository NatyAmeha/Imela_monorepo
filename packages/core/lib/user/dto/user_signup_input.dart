import 'package:imela_data/network/graphql/__generated__/schema.schema.gql.dart';

class UserEmailSignupInput {
  String email;
  String password;
  String firstName;
  String? lastName;
  String phoneNumber;
  String? profileImageUrl;

  UserEmailSignupInput({required this.email, required this.password, required this.firstName, required this.phoneNumber, this.lastName, this.profileImageUrl});

  GSignupInput toGraphQLInput() {

    return GSignupInput(
      (b) => b
        ..email = email
        ..password = password
        ..firstName = firstName
        ..lastName = lastName
        ..phoneNumber = phoneNumber
        ..profileImageUrl = profileImageUrl,
    );
  }

  static UserEmailSignupInput getEmailSignupInput(String firstName, String email , String password){
    return UserEmailSignupInput(
      email: email,
      password: password,
      firstName: firstName,
      phoneNumber: '',
    );
  }
}


