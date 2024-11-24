import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gallery_fe/bloc/users_bloc/users_bloc.dart';
import 'package:gallery_fe/bloc/users_bloc/users_event.dart';
import 'package:gallery_fe/bloc/users_bloc/users_state.dart';
import 'package:gallery_fe/presentation/constants/colors_items.dart';
import 'package:gallery_fe/presentation/widgets/users/add_users.dart';
import 'package:gallery_fe/presentation/widgets/users/delete_users.dart';
import 'package:gallery_fe/presentation/widgets/users/edit_users.dart';
import 'package:gallery_fe/data/models/users_models.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:gallery_fe/presentation/widgets/header_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animations/animations.dart';

class ViewUsers extends StatefulWidget {
  const ViewUsers({super.key});

  @override
  State<ViewUsers> createState() => _ViewUsersState();
}

class _ViewUsersState extends State<ViewUsers> {
  final TextEditingController _searchController = TextEditingController();
  final RefreshController _refreshController = RefreshController();
  final ScrollController _scrollController = ScrollController();

  int _currentPage = 0;
  String _searchQuery = '';
  bool _showHeader = true;

  late final PageController _pageController = PageController(
    viewportFraction: 1.0,
    keepPage: true,
  );

  @override
  void initState() {
    super.initState();
    context.read<UsersBloc>().add(FetchUsers());
  }

  @override
  void dispose() {
   _scrollController.dispose();
    _pageController.dispose();
    _searchController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: AppColors.marble,
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: _showHeader ? null : 0,
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                  ),
                  child: HeaderView(
                    title: 'Manajemen User',
                    onAddContentBlock: () {
                      showModal(
                        context: context,
                        configuration: const FadeScaleTransitionConfiguration(
                          barrierDismissible: true,
                          transitionDuration: Duration(milliseconds: 300),
                          reverseTransitionDuration: Duration(milliseconds: 200),
                        ),
                        builder: (BuildContext context) =>
                            const AddUserDialog(),
                      );
                    },
                    searchController: _searchController,
                    searchQuery: _searchQuery,
                    searchHintText: 'Cari Pengguna...',
                    onSearchChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    showPageDropdown: false,
                  ),
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) =>
                      BlocBuilder<UsersBloc, UsersState>(
                    builder: (context, state) {
                      if (state is UsersLoaded) {
                        return _buildUserGrid(
                            context, state.users, constraints);
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserGrid(
      BuildContext context, List<User> users, BoxConstraints constraints) {
    final filteredUsers = _getFilteredUsers(users);
    final totalPages = (filteredUsers.length / 10).ceil();
    final List<List<User>> pageGroups = List.generate(totalPages, (pageIndex) {
      final startIndex = pageIndex * 10;
      final endIndex = (startIndex + 10).clamp(0, filteredUsers.length);
      return filteredUsers.sublist(startIndex, endIndex);
    });

    return Column(
      children: [
        if (filteredUsers.length > 1)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Halaman ${_currentPage + 1} dari $totalPages',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.slate,
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: totalPages,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            onPageChanged: (page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, pageIndex) {
              final usersOnCurrentPage = pageGroups[pageIndex];
              final listViewScrollController = ScrollController();
              return NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is ScrollUpdateNotification) {
                    if (notification.metrics.pixels <= 0) {
                      if (!_showHeader) setState(() => _showHeader = true);
                    } else {
                      if (_showHeader) setState(() => _showHeader = false);
                    }
                  }
                  return false;
                },
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                  ),
                  child: ListView.builder(
                    controller: listViewScrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: usersOnCurrentPage.length,
                    cacheExtent: 1000,
                    addAutomaticKeepAlives: false,
                    addRepaintBoundaries: false,
                    itemBuilder: (context, index) {
                      final user = usersOnCurrentPage[index];
                      return RepaintBoundary(
                        child: AnimatedBuilder(
                          animation: _pageController,
                          builder: (context, child) {
                            return _buildUserCard(context, user);
                          },
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
        if (totalPages > 1)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(totalPages, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  width: _currentPage == index ? 12.0 : 8.0,
                  height: _currentPage == index ? 12.0 : 8.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? AppColors.shadow
                        : AppColors.slate,
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }

  List<User> _getFilteredUsers(List<User> users) {
    if (_searchQuery.isEmpty) {
      return users;
    }

    final searchLower = _searchQuery.toLowerCase();
    return users.where((user) {
      final usernameLower = user.username.toLowerCase();
      final roleLower = user.role?.toLowerCase() ?? '';

      return usernameLower.contains(searchLower) ||
          roleLower.contains(searchLower);
    }).toList();
  }

  Widget _buildUserCard(BuildContext context, User user) {
    return Hero(
      tag: 'user-${user.id}',
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.shadow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      user.username.substring(0, 1).toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.stoneground,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.username.length > 20 
                            ? '${user.username.substring(0, 20)}...'
                            : user.username,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.bark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.role?.toUpperCase() ?? 'Tidak Di Ketahui',
                        style: GoogleFonts.poppins(
                          color: AppColors.slate,
                          fontSize: 14,
                          height: 1.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        _buildActionButton(
                          icon: Icons.edit,
                          color: AppColors.bark,
                          onPressed: () => _showEditDialog(context, user),
                          tooltip: 'Edit Pengguna',
                        ),
                        const SizedBox(width: 8),
                        _buildActionButton(
                          icon: Icons.delete,
                          color: AppColors.red,
                          onPressed: () => _showDeleteConfirmation(context, user),
                          tooltip: 'Hapus Pengguna',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ID: ${user.id ?? 'N/A'}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.slate,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Material(
      color: Colors.transparent,
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: color, size: 25),
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, User user) {
    showModal(
      context: context,
      configuration: const FadeScaleTransitionConfiguration(
        barrierDismissible: true,
        transitionDuration: Duration(milliseconds: 400),
        reverseTransitionDuration: Duration(milliseconds: 200),
      ),
      builder: (context) => EditUserDialog(user),
    );
  }

  void _showDeleteConfirmation(BuildContext context, User user) {
    showModal(
      context: context,
      configuration: const FadeScaleTransitionConfiguration(
        barrierDismissible: true,
        transitionDuration: Duration(milliseconds: 400),
        reverseTransitionDuration: Duration(milliseconds: 200),
      ),
      builder: (context) => DeleteUserDialog(user),
    );
  }
}
