import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gallery_fe/bloc/analytics_bloc/analytics_event.dart';
import 'package:gallery_fe/presentation/constants/colors_items.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../bloc/analytics_bloc/analytics_bloc.dart';
import '../../../bloc/analytics_bloc/analytics_state.dart';
import '../../../data/models/analytics_models.dart';
import 'archieve_analytics.dart';

class ViewAnalytics extends StatefulWidget {
  const ViewAnalytics({super.key});

  @override
  State<ViewAnalytics> createState() => _ViewAnalyticsState();
}

class _ViewAnalyticsState extends State<ViewAnalytics> {
  @override
  void initState() {
    super.initState();
    context.read<AnalyticsBloc>().add(FetchAnalyticsStats());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AnalyticsBloc, AnalyticsState>(
        builder: (context, state) {
          if (state is AnalyticsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AnalyticsError) {
            return Center(
              child: Text(
                state.message,
                style: GoogleFonts.poppins(color: AppColors.red, fontSize: 16),
              ),
            );
          }

          if (state is AnalyticsLoaded) {
            return CustomScrollView(
              slivers: [
                // Overview Cards Section
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
                        final stats = state.stats;
                        final data = [
                          {
                            'title': 'Total Lihat',
                            'value': stats.totalViews,
                            'icon': Icons.visibility,
                            'color': AppColors.doctorV2
                          },
                          {
                            'title': 'Baru Dilihat',
                            'value': stats.recentViews,
                            'icon': Icons.trending_up,
                            'color': AppColors.slate
                          },
                          {
                            'title': 'Pengunjung',
                            'value': stats.uniqueVisitors,
                            'icon': Icons.people,
                            'color': AppColors.cerramic
                          },
                          {
                            'title': 'Sukses Rate',
                            'value': ((stats.successfulRequests / stats.totalViews) * 100)
                                .toStringAsFixed(1),
                            'icon': Icons.check_circle,
                            'color': AppColors.stoneground,
                            'isPercentage': true
                          },
                        ];

                        final cardData = data[index];
                        return _buildStatCard(
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

                // Views Chart Section
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 32),
                      _buildViewsChart(state.stats),
                      const SizedBox(height: 32),
                      _buildRequestsChart(state.stats),
                      const SizedBox(height: 32),
                      const AnalyticsArchives(),
                      const SizedBox(height: 32),
                    ]),
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

  Widget _buildStatCard(
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

  Widget _buildViewsChart(AnalyticsStats stats) {
    final List<ChartData> chartData = [
      ChartData('Total Lihat', stats.totalViews),
      ChartData('Baru Dilihat', stats.recentViews),
      ChartData('Pengunjung', stats.uniqueVisitors),
    ];

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SfCartesianChart(
          title: ChartTitle(
            text: 'Analisis Pengunjung',
            textStyle: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          legend: const Legend(isVisible: true),
          primaryXAxis: const CategoryAxis(),
          primaryYAxis: const NumericAxis(
            labelFormat: '{value}',
            majorGridLines: MajorGridLines(width: 0),
          ),
          series: <CartesianSeries<ChartData, String>>[
            ColumnSeries<ChartData, String>(
              dataSource: chartData,
              xValueMapper: (ChartData data, _) => data.x,
              yValueMapper: (ChartData data, _) => data.y,
              name: 'Pengunjung',
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              color: AppColors.doctorV2,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildRequestsChart(AnalyticsStats stats) {
    final List<ChartData> chartData = [
      ChartData('Sukses', stats.successfulRequests),
      ChartData('Gagal', stats.totalViews - stats.successfulRequests),
    ];

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SfCircularChart(
          title: ChartTitle(
            text: 'Analisis Request',
            textStyle: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          legend: const Legend(
            isVisible: true,
            overflowMode: LegendItemOverflowMode.wrap,
          ),
          series: <CircularSeries>[
            DoughnutSeries<ChartData, String>(
              dataSource: chartData,
              xValueMapper: (ChartData data, _) => data.x,
              yValueMapper: (ChartData data, _) => data.y,
              dataLabelSettings: const DataLabelSettings(isVisible: true),
              innerRadius: '60%',
              pointColorMapper: (ChartData data, _) =>
                  data.x == 'Sukses' ? AppColors.green : AppColors.red,
            )
          ],
        ),
      ),
    );
  }
}

class ChartData {
  final String x;
  final int y;

  ChartData(this.x, this.y);
}
