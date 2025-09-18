import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:billora/src/features/home/presentation/widgets/notification_widget.dart';
import 'package:billora/src/features/home/presentation/widgets/user_profile_popup.dart';
import 'package:billora/src/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:billora/src/core/services/user_service.dart';
import 'package:billora/src/core/services/avatar_service.dart';
import 'package:billora/src/core/di/injection_container.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
	final String? pageTitle;
	final int currentTabIndex;
	final List<Widget>? actions;
	final PreferredSizeWidget? bottom;
	final AuthCubit? authCubit;

	const AppHeader({
		super.key,
		this.pageTitle,
		required this.currentTabIndex,
		this.actions,
		this.bottom,
		this.authCubit,
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
												const NotificationWidget(),
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
		return GestureDetector(
			onTap: () => _showProfilePopup(context),
			child: FutureBuilder<UserProfile?>(
				future: sl<UserService>().getUserProfileCached(),
				builder: (context, snapshot) {
					if (snapshot.hasData && snapshot.data != null) {
						final profile = snapshot.data!;
						if (profile.avatarUrl != null) {
							return ClipOval(
								child: Image.network(
									profile.avatarUrl!,
									width: 40,
									height: 40,
									fit: BoxFit.cover,
									// Prevent flicker by keeping old frame until new completes
									frameBuilder: (context, child, frame, wasSyncLoaded) {
										if (wasSyncLoaded) return child;
										return AnimatedOpacity(
											opacity: frame == null ? 0.0 : 1.0,
											duration: const Duration(milliseconds: 200),
											child: child,
										);
									},
									errorBuilder: (context, error, stack) {
										return AvatarService.buildAvatar(
											name: profile.displayName,
											size: 40,
										);
									},
								),
							);
						}
						return AvatarService.buildAvatar(
							name: profile.displayName,
							size: 40,
						);
					}

					// Fallback to default avatar
					return const CircleAvatar(
						radius: 20,
						backgroundColor: Colors.black,
						child: Icon(Icons.person, color: Colors.white, size: 24),
					);
				},
			),
		);
	}

	void _showProfilePopup(BuildContext context) {
		if (authCubit == null) {
			// If no AuthCubit provided, try to get it from context
			try {
				final cubit = context.read<AuthCubit>();
				Navigator.push(
					context,
					MaterialPageRoute(
						builder: (context) => BlocProvider.value(
							value: cubit,
							child: const UserProfilePopup(),
						),
					),
				);
			} catch (e) {
				// If AuthCubit is not available, show error message
				ScaffoldMessenger.of(context).showSnackBar(
					const SnackBar(
						content: Text('Authentication service not available'),
						backgroundColor: Colors.red,
					),
				);
			}
		} else {
			// Use provided AuthCubit
			Navigator.push(
				context,
				MaterialPageRoute(
					builder: (context) => BlocProvider.value(
						value: authCubit!,
						child: const UserProfilePopup(),
					),
				),
			);
		}
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
