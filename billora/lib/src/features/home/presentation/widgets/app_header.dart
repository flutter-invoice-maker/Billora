import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:billora/src/features/auth/presentation/cubit/auth_cubit.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
	final String? pageTitle;
	final int currentTabIndex;
	final List<Widget>? actions;
	final PreferredSizeWidget? bottom;

	const AppHeader({
		super.key,
		this.pageTitle,
		required this.currentTabIndex,
		this.actions,
		this.bottom,
	});

	static const double _headerRowHeight = 56;
	static const double _dividerThickness = 1;

	@override
	Size get preferredSize => Size.fromHeight(
			_headerRowHeight + (bottom?.preferredSize.height ?? 0) + _dividerThickness,
		);

	@override
	Widget build(BuildContext context) {
		return Material(
			color: Colors.white,
			child: Column(
				mainAxisSize: MainAxisSize.min,
				children: [
					SizedBox(
						height: _headerRowHeight,
						child: Padding(
							padding: const EdgeInsets.symmetric(horizontal: 16),
							child: Stack(
								alignment: Alignment.center,
								children: [
									// Centered title across full width
									Center(
										child: Text(
											pageTitle ?? _titleForIndex(currentTabIndex),
											style: const TextStyle(
												fontSize: 18,
												fontWeight: FontWeight.w600,
												color: Colors.black,
											),
										),
									),
									// Right-side actions
									Positioned(
										right: 0,
										child: Row(
											mainAxisSize: MainAxisSize.min,
											children: [
												IconButton(
													icon: const Icon(Icons.notifications_none_rounded, color: Colors.black),
													onPressed: () {},
												),
												const SizedBox(width: 8),
												_buildAvatarWithMenu(context),
											],
										),
									),
								],
							),
						),
					),
					if (bottom != null) bottom!,
					const Divider(height: _dividerThickness, thickness: _dividerThickness, color: Color(0xFFE0E0E0)),
				],
			),
		);
	}

	Widget _buildAvatarWithMenu(BuildContext context) {
		return PopupMenuButton<String>(
			offset: const Offset(0, 50),
			shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
			child: const CircleAvatar(
				radius: 20,
				backgroundColor: Colors.black,
				child: Icon(Icons.person, color: Colors.white, size: 24),
			),
			itemBuilder: (context) => [
				_buildMenuItem(context, 'Profile', Icons.person_outline),
				_buildMenuItem(context, 'Settings', Icons.settings_outlined),
				const PopupMenuDivider(),
				_buildMenuItem(context, 'Logout', Icons.logout),
			],
			onSelected: (value) {
				switch (value) {
					case 'Profile':
						Navigator.pushNamed(context, '/profile');
						break;
					case 'Settings':
						ScaffoldMessenger.of(context).showSnackBar(
							const SnackBar(content: Text('Settings page coming soon!')),
						);
						break;
					case 'Logout':
						context.read<AuthCubit>().logout();
						Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
						break;
				}
			},
		);
	}

	PopupMenuItem<String> _buildMenuItem(BuildContext context, String title, IconData icon) {
		return PopupMenuItem<String>(
			value: title,
			child: Row(
				children: [
					Icon(icon, size: 18, color: Colors.black87),
					const SizedBox(width: 12),
					Text(title, style: const TextStyle(fontSize: 14)),
				],
			),
		);
	}

	String _titleForIndex(int index) {
		switch (index) {
			case 0:
				return 'Billora';
			case 1:
				return 'Customers';
			case 3:
				return 'Products';
			case 4:
				return 'Invoices';
			default:
				return 'Billora';
		}
	}
}
