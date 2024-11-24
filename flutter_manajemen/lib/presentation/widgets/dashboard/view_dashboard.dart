import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../bloc/dashboard_bloc/dashboard_bloc.dart';
import '../../../bloc/dashboard_bloc/dashboard_state.dart';
import '../../../data/models/dashboard_models.dart';
import '../../../presentation/constants/colors_items.dart';

class ViewDashboard extends StatelessWidget {
  const ViewDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DashboardError) {
            return Center(
              child: Text(
                state.message,
                style: GoogleFonts.poppins(color: AppColors.red, fontSize: 16),
              ),
            );
          }

          if (state is DashboardLoaded) {
            return CustomScrollView(
              slivers: [
                // User Section
                SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        _buildUserSection(context, state.stats.users, 3),
                        const SizedBox(height: 32),
                        _buildContentSection(state.stats),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),

                // Analytics Section
                SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                          MediaQuery.of(context).size.width > 600 ? 3 : 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final analytics = state.stats.analytics;
                        final data = [
                          {
                            'title': 'Total Lihat',
                            'value': analytics.totalViews,
                            'icon': Icons.visibility,
                            'color': AppColors.doctorV2
                          },
                          {
                            'title': 'Baru Dilihat',
                            'value': analytics.recentViews,
                            'icon': Icons.trending_up,
                            'color': AppColors.slate
                          },
                          {
                            'title': 'Pengunjung',
                            'value': analytics.uniqueVisitors,
                            'icon': Icons.people_outline,
                            'color': AppColors.cerramic
                          },
                          {
                            'title': 'Sukses Rate',
                            'value': ((analytics.successfulRequests / analytics.totalViews) * 100)
                                .toStringAsFixed(1),
                            'icon': Icons.check_circle_outline,
                            'color': AppColors.stoneground,
                            'isPercentage': true
                          },
                        ];

                        final cardData = data[index];
                        return _buildAnalyticsCard(
                          cardData['title'] as String,
                          cardData['value'] as dynamic,
                          cardData['icon'] as IconData,
                          cardData['color'] as Color,
                          2,
                          isPercentage: cardData['isPercentage'] as bool? ?? false,
                        );
                      },
                      childCount: 4,
                    ),
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildUserSection(
    BuildContext context,
    UserStats stats,
    int animationDuration,
  ) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistik Pengguna',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildColoredStatCard(
                  'Total User',
                  stats.total,
                  Icons.people,
                  AppColors.cerramic,
                  2,
                ),
                _buildColoredStatCard(
                  'Admin',
                  stats.admin,
                  Icons.admin_panel_settings,
                  AppColors.cerramic,
                  2,
                ),
                _buildColoredStatCard(
                  'Petugas',
                  stats.petugas,
                  Icons.support_agent,
                  AppColors.cerramic,
                  2,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentSection(DashboardStats stats) {
    final List<ChartData> chartData = [
      ChartData('Kategori', stats.categories.total),
      ChartData('Album', stats.albums.total),
      ChartData('Foto', stats.photos.total),
      ChartData('Halaman', stats.pages.total),
      ChartData('Blok Konten', stats.contentBlocks.total),
    ];

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Analisis Konten',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: SfCartesianChart(
                primaryXAxis: const CategoryAxis(),
                title: const ChartTitle(text: 'Analisis Konten'),
                series: <CartesianSeries>[
                  ColumnSeries<ChartData, String>(
                    dataSource: chartData,
                    xValueMapper: (ChartData data, _) => data.x,
                    yValueMapper: (ChartData data, _) => data.y,
                    name: 'Total',
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                    color: AppColors.doctorV2,
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColoredStatCard(
    String title,
    int value,
    IconData icon,
    Color color,
    int animationDuration,
  ) {
    return HookBuilder(
      builder: (context) {
        final animationController = useAnimationController(
          duration: Duration(seconds: animationDuration),
        )..forward();
        final animation = useAnimation(
          Tween<double>(begin: 0, end: value.toDouble()).animate(
            CurvedAnimation(
              parent: animationController,
              curve: Curves.easeOut,
            ),
          ),
        );

        return Card(
          elevation: 6,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [color.withOpacity(0.8), color],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 32, color: AppColors.shadow),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.shadow,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    animation.toStringAsFixed(0),
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: AppColors.shadow,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnalyticsCard(
    String title,
    dynamic value,
    IconData icon,
    Color color,
    int animationDuration, {
    bool isPercentage = false,
  }) {
    return HookBuilder(
      builder: (context) {
        final animationController = useAnimationController(
          duration: Duration(seconds: animationDuration),
        )..forward();
        final animation = useAnimation(
          Tween<double>(begin: 0, end: double.parse(value.toString())).animate(
            CurvedAnimation(
              parent: animationController,
              curve: Curves.easeOut,
            ),
          ),
        );

        return Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [color.withOpacity(0.8), color],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 32, color: AppColors.shadow),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.shadow,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isPercentage
                        ? '${animation.toStringAsFixed(1)}%'
                        : animation.toStringAsFixed(0),
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.shadow,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class ChartData {
  final String x;
  final int y;

  ChartData(this.x, this.y);
}
