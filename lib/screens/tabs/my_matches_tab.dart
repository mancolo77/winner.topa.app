import 'package:flutter/material.dart';
import '../../services/winner_match_service.dart';
import '../../theme/app_theme.dart';

class MyMatchesTab extends StatefulWidget {
  const MyMatchesTab({super.key});

  @override
  State<MyMatchesTab> createState() => _MyMatchesTabState();
}

class _MyMatchesTabState extends State<MyMatchesTab> {
  final _service = WinnerMatchService();

  @override
  void initState() {
    super.initState();
    _service.addListener(_onServiceChanged);
  }

  @override
  void dispose() {
    _service.removeListener(_onServiceChanged);
    super.dispose();
  }

  void _onServiceChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final savedIds = _service.savedMatchIds;
    final favTeams = _service.favoriteTeamNames;

    // Filter matches that are either directly bookmarked OR feature a followed team
    final myMatches = _service.matches.where((m) {
      final isDirectlySaved = savedIds.contains(m.id);
      final isTeamFollowed = favTeams.contains(m.teamA) || favTeams.contains(m.teamB);
      return isDirectlySaved || isTeamFollowed;
    }).toList();

    // Group by Date
    final Map<String, List<RwandaTopaMatch>> grouped = {};
    for (var m in myMatches) {
      grouped.putIfAbsent(m.displayDate, () => []).add(m);
    }

    final isEmpty = myMatches.isEmpty;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(AppTheme.screenPadding, 16, AppTheme.screenPadding, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Matches',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textMain),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Personal schedule & followed club timeline',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primary, width: 1),
                ),
                child: Text(
                  '${myMatches.length} Fixtures',
                  style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppTheme.surfaceCard,
                borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                border: Border.all(color: AppTheme.border.withValues(alpha: 0.3)),
              ),
              child: const Center(
                child: Column(
                  children: [
                    Icon(Icons.bookmark_border_rounded, size: 48, color: AppTheme.textSecondary),
                    SizedBox(height: 10),
                    Text(
                      'No matches saved yet',
                      style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textMain, fontSize: 15),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Bookmark fixtures or follow teams to view personalized schedules here',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
            )
          else
            ...grouped.entries.map((entry) {
              final dateStr = entry.key;
              final list = entry.value;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date timeline header
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppTheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        dateStr.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...list.map((m) {
                    final isSaved = _service.savedMatchIds.contains(m.id);
                    return Container(
                      margin: const EdgeInsets.only(left: 4, bottom: 12),
                      decoration: const BoxDecoration(
                        border: Border(
                          left: BorderSide(color: AppTheme.border, width: 1.5),
                        ),
                      ),
                      padding: const EdgeInsets.only(left: 14),
                      child: Card(
                        color: AppTheme.surfaceCard,
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: AppTheme.border.withValues(alpha: 0.3)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    m.tournament,
                                    style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
                                  ),
                                  if (m.isLive)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                      decoration: BoxDecoration(color: AppTheme.accentRed, borderRadius: BorderRadius.circular(4)),
                                      child: const Text('LIVE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)),
                                    )
                                  else
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                      decoration: BoxDecoration(color: AppTheme.filterBg, borderRadius: BorderRadius.circular(4)),
                                      child: Text(m.status, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          m.teamA,
                                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textMain, fontSize: 14),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          m.teamB,
                                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textMain, fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (m.score != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: AppTheme.filterBg,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.4)),
                                      ),
                                      child: Text(
                                        m.score!,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primary,
                                        ),
                                      ),
                                    )
                                  else
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppTheme.filterBg,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        m.time,
                                        style: const TextStyle(color: AppTheme.textMain, fontWeight: FontWeight.bold, fontSize: 12),
                                      ),
                                    ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                                    icon: Icon(
                                      isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                                      color: isSaved ? AppTheme.primary : AppTheme.textSecondary,
                                      size: 22,
                                    ),
                                    onPressed: () => _service.toggleSaveMatch(m.id),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.stadium_outlined, size: 12, color: AppTheme.textSecondary),
                                  const SizedBox(width: 4),
                                  Text(m.stadium, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 6),
                ],
              );
            }),
        ],
      ),
    );
  }
}
