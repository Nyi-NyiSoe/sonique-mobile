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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is UnAuthenticatedState) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Logged out')));
            context.go(Routes.login);
          }
        },
        child: SafeArea(
          child: BlocBuilder<UserDataBloc, UserDataState>(
            builder: (context, state) {
              if (state is UserDataLoadingState) {
                return _ProfileStatusView(
                  child: const Center(child: CircularProgressIndicator()),
                  onLogout: () => _logout(context),
                );
              } else if (state is UserDataFetchedState) {
                user = state.user;
                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<UserDataBloc>().add(FetchUserDataEvent());
                  },
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                    children: [
                      _ProfileHeader(
                        user: state.user,
                        onEditProfile: () => _showUserDetailsModal(context),
                        onUpdateImage: () => _showImageUpdateModal(context),
                        onLogout: () => _logout(context),
                      ),
                      const SizedBox(height: 16),
                      _ArtistToggleCard(user: state.user),
                      const SizedBox(height: 12),
                      UserDetailCard(user: state.user),
                      const SizedBox(height: 12),
                      MusicStats(user: state.user),
                    ],
                  ),
                );
              } else if (state is UserDataErrorState) {
                return _ProfileStatusView(
                  onLogout: () => _logout(context),
                  child: _StateMessage(
                    icon: Icons.error_outline,
                    message: state.error,
                    action: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        TextButton.icon(
                          onPressed:
                              () => context.read<UserDataBloc>().add(
                                FetchUserDataEvent(),
                              ),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                        FilledButton.icon(
                          onPressed: () => _logout(context),
                          icon: const Icon(Icons.logout),
                          label: const Text('Logout'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return _ProfileStatusView(
                onLogout: () => _logout(context),
                child: const _StateMessage(
                  icon: Icons.person_off_outlined,
                  message: 'Something went wrong',
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _logout(BuildContext context) {
    context.read<AuthBloc>().add(LogoutEvent());
    context.read<MusicPlayerBloc>().add(ResetPlayer());
    context.read<LikesBloc>().add(ResetBlocEvent());
    context.read<PlaylistBloc>().add(ResetLikeBlocEvent());
  }

  void _showUserDetailsModal(BuildContext context) {
    final currentUser = user;
    if (currentUser == null) {
      return;
    }

    showModalBottomSheet(
      useRootNavigator: true,
      isScrollControlled: true,
      context: context,
      builder: (context) => UserDetailsModal(user: currentUser),
    );
  }

  void _showImageUpdateModal(BuildContext context) {
    final currentUser = user;
    if (currentUser == null) {
      return;
    }

    showModalBottomSheet(
      useRootNavigator: true,
      context: context,
      builder: (context) => ImageUpdateModal(user: currentUser),
    );
  }
}

class _ProfileStatusView extends StatelessWidget {
  const _ProfileStatusView({required this.child, required this.onLogout});

  final Widget child;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.person_outline, color: Colors.green),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Profile',
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Settings',
                onPressed: () => context.push(Routes.settings),
                icon: const Icon(Icons.settings_outlined),
              ),
              IconButton(
                tooltip: 'Logout',
                onPressed: onLogout,
                icon: const Icon(Icons.logout),
              ),
            ],
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.user,
    required this.onEditProfile,
    required this.onUpdateImage,
    required this.onLogout,
  });

  final UserModel user;
  final VoidCallback onEditProfile;
  final VoidCallback onUpdateImage;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageUrl =
        user.profile_image == null || user.profile_image!.isEmpty
            ? 'https://i.imgur.com/BoN9kdC.png'
            : user.profile_image!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.person_outline, color: Colors.green),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Profile',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Edit profile',
              onPressed: onEditProfile,
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              tooltip: 'Settings',
              onPressed: () => context.push(Routes.settings),
              icon: const Icon(Icons.settings_outlined),
            ),
            IconButton(
              tooltip: 'Logout',
              onPressed: onLogout,
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: onUpdateImage,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 104,
                    height: 104,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.green.withValues(alpha: 0.45),
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder:
                            (context, url) => const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                        errorWidget:
                            (context, url, error) => const Icon(
                              Icons.person,
                              size: 48,
                              color: Colors.grey,
                            ),
                      ),
                    ),
                  ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.scaffoldBackgroundColor,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      size: 17,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: GestureDetector(
                onTap: onEditProfile,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${user.firstName} ${user.lastName}'.trim(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '@${user.username}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withValues(
                          alpha: 0.62,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _RoleBadge(isArtist: user.isArtist),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        GestureDetector(
          onTap: onEditProfile,
          child: Text(
            user.bio == null || user.bio!.isEmpty ? 'Add a bio' : user.bio!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            ),
          ),
        ),
      ],
    );
  }
}

class _ArtistToggleCard extends StatelessWidget {
  const _ArtistToggleCard({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: SwitchListTile(
        value: user.isArtist,
        activeThumbColor: Colors.green,
        secondary: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.mic_external_on_outlined,
            color: Colors.green,
          ),
        ),
        title: Text(
          'Artist Mode',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          user.isArtist
              ? 'Upload music and manage artist releases'
              : 'Turn this on to become an artist',
        ),
        onChanged: (value) {
          context.read<UserDataBloc>().add(
            ToggleArtistStatusEvent(isArtist: value),
          );
        },
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.isArtist});

  final bool isArtist;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color:
            isArtist
                ? Colors.green.withValues(alpha: 0.16)
                : Colors.blueGrey.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isArtist ? 'Artist' : 'Listener',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: isArtist ? Colors.green : Colors.blueGrey,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({required this.icon, required this.message, this.action});

  final IconData icon;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 34,
              color: theme.iconTheme.color?.withValues(alpha: 0.58),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            if (action != null) ...[const SizedBox(height: 12), action!],
          ],
        ),
      ),
    );
  }
}
