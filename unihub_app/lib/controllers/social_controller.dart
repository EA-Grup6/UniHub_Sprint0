import '../networking/apibasehelper.dart';
import 'package:http/http.dart' as http;

ApiBaseHelper _helper = ApiBaseHelper();

class SocialController {
  Future<dynamic> follow(
      String usernameFollower, String usernameFollowed) async {
    var body = {'follower': usernameFollower, 'followed': usernameFollowed};
    print(body);
    final response = await _helper.post('/User/updateFollowers/follow', body);
    print('Code: ' +
        response.statusCode.toString() +
        'Body: ' +
        response.body.toString());
    return response;
  }

  Future<dynamic> unfollow(
      String usernameUnfollower, String usernameUnfollowed) async {
    var body = {'follower': usernameUnfollower, 'followed': usernameUnfollowed};
    print(body);
    final response = await _helper.post('/User/updateFollowers/unfollow', body);
    return response;
  }

  Future<dynamic> getProfiles() async {
    final http.Response response = await _helper.get('/User/getUsers');
    return response;
  }
}
