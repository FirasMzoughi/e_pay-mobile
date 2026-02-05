import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static const _webClientId = '238649879933-tucpht63jji81m6a5lot6fjqngcbtioo.apps.googleusercontent.com';
  static const _androidClientId = '238649879933-l5eopc1qhlqjl9i2flgtl9oe720d2fem.apps.googleusercontent.com';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: _androidClientId, // Used on Android when json is missing (attempt)
    serverClientId: _webClientId, // Request this from the user's console for ID token
  );

  Future<AuthResponse> signInWithGoogle() async {
    try {
      // 1. Native Google Sign In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw 'Google Sign In aborted by user.';
      }

      // 2. Get the Auth Headers (ID Token / Access Token)
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw 'No ID Token found.';
      }

      // 3. Sign in to Supabase with the ID Token
      final AuthResponse response = await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      // 4. (Optional) Manual Profile Sync if trigger isn't used
      // It is best practice to use a Database Trigger, but we can do a quick check here too
      // _ensureProfileExists(response.user);

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await Supabase.instance.client.auth.signOut();
  }

  User? get currentUser => Supabase.instance.client.auth.currentUser;
  
  // Example of manual sync for fallback
  /*
  Future<void> _ensureProfileExists(User? user) async {
    if (user == null) return;
    final supabase = Supabase.instance.client;
    
    final data = await supabase.from('profiles').select().eq('id', user.id).maybeSingle();
    if (data == null) {
      await supabase.from('profiles').insert({
        'id': user.id,
        'email': user.email,
        'full_name': user.userMetadata?['full_name'],
        'avatar_url': user.userMetadata?['avatar_url'],
        'role': 'user',
      });
    }
  }
  */
}
