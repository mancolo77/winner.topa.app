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
          const Text(
            'My Matches',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppTheme.textMain),
          ),
          const SizedBox(height: 4),
          const Text(
            'Saved fixtures and followed teams matches by date',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 16),

          if (isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppTheme.surfaceCard,
                borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                border: Border.all(color: AppTheme.border),
              ),
              child: const Center(
                child: Column(
                  children: [
                    Icon(Icons.event_available_rounded, size: 48, color: AppTheme.textSecondary),
                    SizedBox(height: 10),
                    Text(
                      'No matches saved yet',
                      style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textMain, fontSize: 15),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Bookmark matches or follow clubs to see them listed here',
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.filterBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      dateStr,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...list.map((m) {
                    final isSaved = _service.savedMatchIds.contains(m.id);
                    return Card(
                      color: AppTheme.surfaceCard,
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.cardRadius)),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        m.tournament,
                                        style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                                      ),
                                      if (m.isLive) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                          decoration: BoxDecoration(color: AppTheme.accentRed, borderRadius: BorderRadius.circular(4)),
                                          child: const Text('LIVE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${m.teamA} vs ${m.teamB}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textMain, fontSize: 14),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${m.time} • ${m.stadium}',
                                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            if (m.score != null)
                              Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: AppTheme.filterBg, borderRadius: BorderRadius.circular(6)),
                                child: Text(
                                  m.score!,
                                  style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ),
                            IconButton(
                              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                              icon: Icon(
                                isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                                color: isSaved ? AppTheme.primary : AppTheme.textSecondary,
                                size: 22,
                              ),
                              onPressed: () => _service.toggleSaveMatch(m.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 10),
                ],
              );
            }),
        ],
      ),
    );
  }
}
