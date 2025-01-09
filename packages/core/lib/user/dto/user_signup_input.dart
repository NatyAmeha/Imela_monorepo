import 'package:imela_data/network/graphql/__generated__/schema.schema.gql.dart';

class SignupInput {
  String? email;
  String? password;
  String? firstName;
  String? lastName;
  String? phoneNumber;
  String? googleId;
  String? profileImageUrl;

  SignupInput({
    this.email,
    this.password,
    required this.firstName,
    this.phoneNumber,
    this.lastName,
    this.profileImageUrl,
    this.googleId,
  });

  GSignupInput toGraphQLInput() {
    return GSignupInput(
      (b) => b
        ..email = email
        ..password = password
        ..firstName = firstName
        ..googleId = googleId
        ..lastName = lastName
        ..phoneNumber = phoneNumber
        ..profileImageUrl = profileImageUrl,
    );
  }

  static SignupInput getEmailSignupInput({String? firstName, String? email, String? password, String? phoneNumber, String? googleId}) {
    return SignupInput(
      email: email,
      password: password,
      firstName: firstName ?? '',
      phoneNumber: phoneNumber,
      googleId: googleId,
    );
  }

  static SignupInput getGoogleSignupInput({required String googleId, required String phoneNumber, String? username, String? email, String? profileImageUrl}) {
    return SignupInput(
      email: email,
      firstName: username,
      phoneNumber: phoneNumber,
      googleId: googleId,
      profileImageUrl: profileImageUrl,
      
    );
  }
}
