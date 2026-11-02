import 'package:flutter/material.dart';
import '../../services/winner_match_service.dart';
import '../../theme/app_theme.dart';

class TeamsTab extends StatefulWidget {
  const TeamsTab({super.key});

  @override
  State<TeamsTab> createState() => _TeamsTabState();
}

class _TeamsTabState extends State<TeamsTab> {
  final _service = WinnerMatchService();
  String _search = '';
  int _viewMode = 0; // 0 = Standings Table, 1 = Club Directory Grid

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

  void _openTeamDetails(RwandaTopaTeam t) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.cardRadius)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppTheme.screenPadding),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.filterBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.primary, width: 1.5),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      t.name.split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join(),
                      style: const TextStyle(fontSize: 18, color: AppTheme.primary, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.name,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textMain),
                        ),
                        Text(
                          '${t.city} • ${t.stadium}',
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _service.favoriteTeamNames.contains(t.name) ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: AppTheme.primary,
                      size: 26,
                    ),
                    onPressed: () {
                      _service.toggleFavoriteTeam(t.name);
                      Navigator.pop(ctx);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.filterBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.emoji_events_rounded, color: AppTheme.primary, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Rwanda League Titles: ${t.titles}',
                      style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text('Recent Form', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textMain)),
              const SizedBox(height: 8),
              ...t.recentResults.map((res) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: res.startsWith('W')
                                ? const Color(0xFF2E7D32)
                                : res.startsWith('D')
                                    ? const Color(0xFFF57F17)
                                    : AppTheme.accentRed,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            res.substring(0, 1),
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(res, style: const TextStyle(color: AppTheme.textMain, fontSize: 13)),
                      ],
                    ),
                  )),
              const SizedBox(height: 14),
              const Text('Upcoming Fixtures', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textMain)),
              const SizedBox(height: 8),
              ...t.upcomingMatches.map((fix) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 14, color: AppTheme.primary),
                        const SizedBox(width: 8),
                        Text(fix, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                      ],
                    ),
                  )),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final teams = _service.teams;
    final filtered = teams
        .where((t) =>
            t.name.toLowerCase().contains(_search.toLowerCase()) ||
            t.city.toLowerCase().contains(_search.toLowerCase()))
        .toList();

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
                    'Rwanda Clubs',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textMain),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'League standings & club database',
                    style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                ],
              ),
              // Segmented view toggle
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.border.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => setState(() => _viewMode = 0),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: _viewMode == 0 ? AppTheme.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text(
                          'Standings',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _viewMode == 0 ? const Color(0xFF121212) : AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => setState(() => _viewMode = 1),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: _viewMode == 1 ? AppTheme.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text(
                          'Grid',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _viewMode == 1 ? const Color(0xFF121212) : AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Search Bar
          TextField(
            style: const TextStyle(color: AppTheme.textMain),
            decoration: InputDecoration(
              hintText: 'Search club or city...',
              hintStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              prefixIcon: const Icon(Icons.search, color: AppTheme.primary, size: 18),
              filled: true,
              fillColor: AppTheme.surfaceCard,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppTheme.border.withValues(alpha: 0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppTheme.border.withValues(alpha: 0.3)),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            onChanged: (v) => setState(() => _search = v),
          ),
          const SizedBox(height: 14),

          if (_viewMode == 0)
            _buildStandingsTable(filtered)
          else
            _buildClubGrid(filtered),
        ],
      ),
    );
  }

  Widget _buildStandingsTable(List<RwandaTopaTeam> list) {
    // Fictional realistic standings data for Rwanda Premier League
    final stats = [
      {'rank': '1', 'p': '8', 'w': '6', 'd': '2', 'l': '0', 'gd': '+11', 'pts': '20'},
      {'rank': '2', 'p': '8', 'w': '5', 'd': '2', 'l': '1', 'gd': '+8', 'pts': '17'},
      {'rank': '3', 'p': '8', 'w': '4', 'd': '3', 'l': '1', 'gd': '+4', 'pts': '15'},
      {'rank': '4', 'p': '8', 'w': '4', 'd': '1', 'l': '3', 'gd': '+2', 'pts': '13'},
      {'rank': '5', 'p': '8', 'w': '3', 'd': '2', 'l': '3', 'gd': '0', 'pts': '11'},
      {'rank': '6', 'p': '8', 'w': '2', 'd': '3', 'l': '3', 'gd': '-2', 'pts': '9'},
      {'rank': '7', 'p': '8', 'w': '2', 'd': '1', 'l': '5', 'gd': '-5', 'pts': '7'},
      {'rank': '8', 'p': '8', 'w': '1', 'd': '2', 'l': '5', 'gd': '-7', 'pts': '5'},
      {'rank': '9', 'p': '8', 'w': '1', 'd': '1', 'l': '6', 'gd': '-8', 'pts': '4'},
      {'rank': '10', 'p': '8', 'w': '0', 'd': '3', 'l': '5', 'gd': '-9', 'pts': '3'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.filterBg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: const Row(
              children: [
                SizedBox(width: 24, child: Text('#', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.bold))),
                Expanded(child: Text('CLUB', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.bold))),
                SizedBox(width: 26, child: Text('P', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.bold))),
                SizedBox(width: 26, child: Text('W', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.bold))),
                SizedBox(width: 26, child: Text('D', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.bold))),
                SizedBox(width: 26, child: Text('L', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.bold))),
                SizedBox(width: 32, child: Text('GD', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.bold))),
                SizedBox(width: 34, child: Text('PTS', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          // Rows
          ...list.asMap().entries.map((entry) {
            final idx = entry.key;
            final t = entry.value;
            final s = idx < stats.length ? stats[idx] : {'rank': '${idx + 1}', 'p': '8', 'w': '1', 'd': '1', 'l': '6', 'gd': '-4', 'pts': '4'};
            final isFav = _service.favoriteTeamNames.contains(t.name);

            return InkWell(
              onTap: () => _openTeamDetails(t),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppTheme.border.withValues(alpha: 0.15)),
                  ),
                  color: isFav ? AppTheme.primary.withValues(alpha: 0.05) : Colors.transparent,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 24,
                      child: Text(
                        s['rank']!,
                        style: TextStyle(
                          color: idx < 3 ? AppTheme.primary : AppTheme.textSecondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: AppTheme.filterBg,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              t.name.split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join(),
                              style: const TextStyle(color: AppTheme.primary, fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              t.name,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textMain, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 26, child: Text(s['p']!, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12))),
                    SizedBox(width: 26, child: Text(s['w']!, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12))),
                    SizedBox(width: 26, child: Text(s['d']!, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12))),
                    SizedBox(width: 26, child: Text(s['l']!, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12))),
                    SizedBox(width: 32, child: Text(s['gd']!, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12))),
                    SizedBox(
                      width: 34,
                      child: Text(
                        s['pts']!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildClubGrid(List<RwandaTopaTeam> list) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.15,
      ),
      itemCount: list.length,
      itemBuilder: (ctx, i) {
        final t = list[i];
        final isFav = _service.favoriteTeamNames.contains(t.name);
        return Card(
          color: AppTheme.surfaceCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: AppTheme.border.withValues(alpha: 0.3)),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _openTeamDetails(t),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppTheme.filterBg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.primary.withValues(alpha: 0.6)),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          t.name.split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join(),
                          style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        icon: Icon(
                          isFav ? Icons.star_rounded : Icons.star_outline_rounded,
                          color: isFav ? AppTheme.primary : AppTheme.textSecondary,
                          size: 20,
                        ),
                        onPressed: () => _service.toggleFavoriteTeam(t.name),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppTheme.textMain, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        t.city,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.emoji_events_outlined, size: 13, color: AppTheme.primary),
                      const SizedBox(width: 4),
                      Text('${t.titles} titles', style: const TextStyle(color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.w600)),
                    ],
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
