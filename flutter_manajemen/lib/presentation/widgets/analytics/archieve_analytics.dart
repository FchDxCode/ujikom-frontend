import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luminova/bloc/analytics_bloc/analytics_event.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../bloc/analytics_bloc/analytics_bloc.dart';
import '../../../bloc/analytics_bloc/analytics_state.dart';
import '../../../data/models/analytics_models.dart';
import '../../constants/colors_items.dart';

class AnalyticsArchives extends StatelessWidget {
  const AnalyticsArchives({super.key});

  @override
  Widget build(BuildContext context) {
    // Get screen width for responsive layout
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 600;

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Arsip Analytics',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    context.read<AnalyticsBloc>().add(FetchAnalyticsArchives());
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            BlocBuilder<AnalyticsBloc, AnalyticsState>(
              builder: (context, state) {
                if (state is AnalyticsLoaded) {
                  if (state.archives == null || state.archives!.isEmpty) {
                    return Center(
                      child: Text(
                        'Tidak ada arsip tersedia',
                        style: GoogleFonts.poppins(),
                      ),
                    );
                  }
                  return Container(
                    constraints: BoxConstraints(
                      maxHeight: isDesktop ? 400 : 300, 
                    ),
                    child: _buildArchivesList(state.archives!, isDesktop),
                  );
                }
                if (state is AnalyticsError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: GoogleFonts.poppins(color: AppColors.red),
                    ),
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArchivesList(List<AnalyticsArchive> archives, bool isDesktop) {
    return ListView.builder(
      shrinkWrap: true,
      // Remove NeverScrollableScrollPhysics to enable scrolling
      physics: const BouncingScrollPhysics(),
      itemCount: archives.length,
      itemBuilder: (context, index) {
        final archive = archives[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            title: Text(
              archive.name,
              style: GoogleFonts.poppins(),
              overflow: TextOverflow.ellipsis, // Handle long text with ellipsis
              maxLines: 1,
            ),
            subtitle: Row(
              children: [
                Expanded(
                  child: Text(
                    'Created: ${_formatDate(archive.created)}',
                    style: GoogleFonts.poppins(fontSize: isDesktop ? 14 : 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  _formatFileSize(archive.size),
                  style: GoogleFonts.poppins(
                    fontSize: isDesktop ? 14 : 12,
                    color: AppColors.slate,
                  ),
                ),
              ],
            ),
            trailing: BlocBuilder<AnalyticsBloc, AnalyticsState>(
              builder: (context, state) {
                if (state is AnalyticsDownloading) {
                  return const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                }
                return IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: () {
                    context.read<AnalyticsBloc>().add(
                      DownloadAnalyticsArchive(archive.name),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    
    return '${date.year}, ${months[date.month - 1]} ${date.day}, $hour:$minute';
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
