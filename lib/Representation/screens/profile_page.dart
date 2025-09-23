import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sonique/Data/models/user_model.dart';
import 'package:sonique/Representation/Bloc/auth_bloc/auth_bloc.dart';
import 'package:sonique/Representation/Bloc/auth_bloc/auth_event.dart';
import 'package:sonique/Representation/Bloc/auth_bloc/auth_state.dart';
import 'package:sonique/Representation/Bloc/like_song_bloc/like_song_bloc.dart';
import 'package:sonique/Representation/Bloc/like_song_bloc/like_song_event.dart';
import 'package:sonique/Representation/Bloc/music_player_bloc/music_player_bloc.dart';
import 'package:sonique/Representation/Bloc/music_player_bloc/music_player_event.dart';
import 'package:sonique/Representation/Bloc/playlist_bloc/playlist_bloc.dart';
import 'package:sonique/Representation/Bloc/playlist_bloc/playlist_event.dart';
import 'package:sonique/Representation/Bloc/user_data_bloc/user_data_bloc.dart';
import 'package:sonique/Representation/Bloc/user_data_bloc/user_data_event.dart';
import 'package:sonique/Representation/Bloc/user_data_bloc/user_data_state.dart';
import 'package:sonique/Representation/widgets/ImageUpdateModal.dart';
import 'package:sonique/Representation/widgets/MusicStats.dart';
import 'package:sonique/Representation/widgets/UserDetailCard.dart';
import 'package:sonique/Representation/widgets/UserDetailModal.dart';
import 'package:sonique/core/services/routes/routes.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserModel? user;

  @override
  void initState() {
    super.initState();
    context.read<UserDataBloc>().add(FetchUserDataEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Page'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(LogoutEvent());
              context.read<MusicPlayerBloc>().add(ResetPlayer());
              context.read<LikesBloc>().add(ResetBlocEvent());
              context.read<PlaylistBloc>().add(ResetLikeBlocEvent());
            },
          ),
        ],
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoadingState) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Logged out')));
            context.go(Routes.login);
          }
        },
        child: BlocBuilder<UserDataBloc, UserDataState>(
          builder: (context, state) {
            if (state is UserDataLoadingState) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is UserDataFetchedState) {
              user = state.user;
              return SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () => _showImageUpdateModal(context),
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundColor:
                                      Colors.grey[300], // fallback background
                                  child: ClipOval(
                                    child: CachedNetworkImage(
                                      imageUrl:
                                          user!.profile_image == ""
                                              ? 'https://i.imgur.com/BoN9kdC.png'
                                              : user!.profile_image!,
                                      width: 100, // 2 * radius
                                      height: 100,
                                      fit: BoxFit.cover,
                                      placeholder:
                                          (context, url) => const Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                      errorWidget:
                                          (context, url, error) => const Icon(
                                            Icons.person,
                                            size: 50,
                                            color: Colors.grey,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              GestureDetector(
                                onTap: () => _showUserDetailsModal(context),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${user!.firstName} ${user!.lastName}",
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.displayMedium!,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      "@${user!.username}",
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge!
                                          .copyWith(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: () => _showUserDetailsModal(context),
                            child: Text(
                              user!.bio == ""
                                  ? "'Add a bio'"
                                  : "'${user!.bio}'",
                              style: Theme.of(context).textTheme.labelLarge!
                                  .copyWith(color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ),
                    UserDetailCard(user: user!),
                    MusicStats(user: user!),
                  ],
                ),
              );
            } else if (state is UserDataErrorState) {
              return Center(child: Text(state.error));
            } else {
              return const Center(child: Text('Something went wrong!'));
            }
          },
        ),
      ),
    );
  }

  void _showUserDetailsModal(BuildContext context) {
    showModalBottomSheet(
      useRootNavigator: true,
      isScrollControlled: true,
      context: context,
      builder: (context) => UserDetailsModal(user: user!),
    );
  }

  void _showImageUpdateModal(BuildContext context) {
    showModalBottomSheet(
      useRootNavigator: true,
      context: context,
      builder: (context) => ImageUpdateModal(user: user!),
    );
  }
}
