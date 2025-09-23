import 'package:flutter/material.dart';
import 'package:sonique/Data/models/user_model.dart';

class UserDetailCard extends StatelessWidget {
  const UserDetailCard({super.key, required this.user});
  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account Information',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.person,
              'Full Name',
              "${user.firstName} ${user.lastName}".trim(),
              context,
            ),
            _buildInfoRow(
              Icons.alternate_email,
              'Username',
              "@${user.username}",
              context,
            ),
            _buildInfoRow(Icons.email_outlined, 'Email', user.email, context),
            _buildInfoRow(
              Icons.calendar_today,
              'Member Since',
              "${DateTime.parse(user.createdAt).day.toString().padLeft(2, '0')}/"
                  "${DateTime.parse(user.createdAt).month.toString().padLeft(2, '0')}/"
                  "${DateTime.parse(user.createdAt).year}",
              context,
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildInfoRow(
  IconData icon,
  String label,
  String value,
  BuildContext context,
) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).primaryColor),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
            Text(
              value.isEmpty ? 'Not provided' : value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ],
    ),
  );
}
