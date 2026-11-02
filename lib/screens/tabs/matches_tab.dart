import 'package:flutter/material.dart';
import '../../services/winner_match_service.dart';
import '../../theme/app_theme.dart';

class MatchesTab extends StatefulWidget {
  const MatchesTab({super.key});

  @override
  State<MatchesTab> createState() => _MatchesTabState();
}

class _MatchesTabState extends State<MatchesTab> {
  final _service = WinnerMatchService();
  String _selectedDate = 'Today'; // 'Yesterday', 'Today', 'Tomorrow', 'All Dates'
  String _statusTab = 'All'; // 'All', 'LIVE', 'Results'
  String _tournament = 'All Tournaments';

  final List<Map<String, String>> _dateCards = [
    {'key': 'Yesterday', 'label': 'OCT 31', 'sub': 'Yesterday'},
    {'key': 'Today', 'label': 'NOV 01', 'sub': 'Today'},
    {'key': 'Tomorrow', 'label': 'NOV 02', 'sub': 'Tomorrow'},
    {'key': 'All Dates', 'label': 'ALL', 'sub': 'Fixtures'},
  ];

  final List<String> _tournaments = [
    'All Tournaments',
    'Rwanda Premier League',
    'Peace Cup Rwanda',
  ];

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

  void _openDetails(RwandaTopaMatch m) {
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    m.tournament,
                    style: const TextStyle(color: AppTheme.primary, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.filterBg,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: const Text('Demo', style: TextStyle(color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Scoreboard Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                  border: Border.all(color: AppTheme.border.withValues(alpha: 0.6)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppTheme.filterBg,
                          radius: 18,
                          child: Text(
                            m.teamA.substring(0, 1),
                            style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            m.teamA,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textMain),
                          ),
                        ),
                        Text(
                          m.score != null ? m.score!.split(' - ')[0] : '-',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.primary),
                        ),
                      ],
                    ),
                    const Divider(color: AppTheme.border, height: 20),
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppTheme.filterBg,
                          radius: 18,
                          child: Text(
                            m.teamB.substring(0, 1),
                            style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            m.teamB,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textMain),
                          ),
                        ),
                        Text(
                          m.score != null ? m.score!.split(' - ')[1] : '-',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.filterBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${m.displayDate} • ${m.time}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                          Text(m.status, style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Icon(Icons.stadium_outlined, color: AppTheme.textSecondary, size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(m.stadium, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                  ),
                ],
              ),
              const Divider(color: AppTheme.border, height: 24),

              const Text(
                'Match Events',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textMain),
              ),
              const SizedBox(height: 10),

              if (m.events.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'No timeline events available for this fixture.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                  ),
                )
              else
                ...m.events.map((e) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.background,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.border.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Text("${e.minute}'", style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                        const SizedBox(width: 10),
                        Icon(
                          e.type == 'yellow_card'
                              ? Icons.square
                              : e.type == 'red_card'
                                  ? Icons.square
                                  : e.type == 'sub'
                                      ? Icons.swap_horiz
                                      : Icons.sports_soccer,
                          size: 16,
                          color: e.type == 'yellow_card'
                              ? Colors.amber
                              : e.type == 'red_card'
                                  ? AppTheme.accentRed
                                  : e.type == 'sub'
                                      ? AppTheme.primary
                                      : Colors.white,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(e.player, style: const TextStyle(color: AppTheme.textMain, fontWeight: FontWeight.w600, fontSize: 13)),
                        ),
                        Text(e.team, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                      ],
                    ),
                  );
                }),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var list = _service.matches;

    // Filter by date
    if (_selectedDate != 'All Dates') {
      list = list.where((m) => m.displayDate == _selectedDate).toList();
    }

    // Filter by status tab
    if (_statusTab == 'LIVE') {
      list = list.where((m) => m.isLive).toList();
    } else if (_statusTab == 'Results') {
      list = list.where((m) => m.score != null && !m.isLive).toList();
    }

    // Filter by tournament
    if (_tournament != 'All Tournaments') {
      list = list.where((m) => m.tournament == _tournament).toList();
    }

    // Group by Tournament
    final Map<String, List<RwandaTopaMatch>> grouped = {};
    for (var m in list) {
      grouped.putIfAbsent(m.tournament, () => []).add(m);
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.darkNav,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tournament Match Center',
              style: TextStyle(color: AppTheme.textMain, fontSize: 19, fontWeight: FontWeight.bold),
            ),
            Text(
              'Live Feed • Updated ${_service.lastUpdated.hour.toString().padLeft(2, '0')}:${_service.lastUpdated.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Center(
              child: Text(
                'Demo',
                style: TextStyle(color: AppTheme.buttonTextDark, fontWeight: FontWeight.bold, fontSize: 11),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _service.refresh,
        color: AppTheme.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppTheme.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Horizontal Date Ribbon Carousel
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _dateCards.map((d) {
                    final isSel = _selectedDate == d['key'];
                    return GestureDetector(
                      onTap: () => setState(() => _selectedDate = d['key']!),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSel ? AppTheme.primary : AppTheme.surfaceCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSel ? AppTheme.primary : AppTheme.border.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              d['label']!,
                              style: TextStyle(
                                color: isSel ? AppTheme.buttonTextDark : AppTheme.textMain,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              d['sub']!,
                              style: TextStyle(
                                color: isSel ? AppTheme.buttonTextDark : AppTheme.textSecondary,
                                fontSize: 10,
                                fontWeight: isSel ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 14),

              // Status Filter Buttons (All, LIVE, Results)
              Row(
                children: ['All', 'LIVE', 'Results'].map((st) {
                  final isSel = _statusTab == st;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: ElevatedButton(
                        onPressed: () => setState(() => _statusTab = st),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSel ? AppTheme.primary : AppTheme.surfaceCard,
                          foregroundColor: isSel ? AppTheme.buttonTextDark : Colors.white,
                          elevation: 0,
                          minimumSize: const Size(0, 38),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(
                          st,
                          style: TextStyle(fontSize: 12, fontWeight: isSel ? FontWeight.bold : FontWeight.normal),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),

              // Tournament Dropdown Filter
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.border.withValues(alpha: 0.5)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _tournament,
                    dropdownColor: AppTheme.surfaceCard,
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down, color: AppTheme.primary),
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    onChanged: (val) {
                      if (val != null) setState(() => _tournament = val);
                    },
                    items: _tournaments.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Matches Grouped Under Tournament Headers
              if (grouped.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceCard,
                    borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.event_busy_rounded, size: 48, color: AppTheme.textSecondary),
                      SizedBox(height: 12),
                      Text(
                        'No fixtures match the selected filters.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                      ),
                    ],
                  ),
                )
              else
                ...grouped.entries.map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Distinct Tournament Header Banner
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        margin: const EdgeInsets.only(top: 6, bottom: 10),
                        decoration: BoxDecoration(
                          color: AppTheme.filterBg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.border.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.emoji_events, size: 16, color: AppTheme.primary),
                                const SizedBox(width: 8),
                                Text(
                                  entry.key,
                                  style: const TextStyle(color: AppTheme.textMain, fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ],
                            ),
                            Text(
                              '${entry.value.length} matches',
                              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      ...entry.value.map((m) => _buildScoreboardCard(m)),
                      const SizedBox(height: 8),
                    ],
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreboardCard(RwandaTopaMatch m) {
    final isSaved = _service.savedMatchIds.contains(m.id);
    return Card(
      color: AppTheme.surfaceCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppTheme.border.withValues(alpha: 0.4)),
      ),
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openDetails(m),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            children: [
              // Top info row: Venue & Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${m.displayDate} • ${m.time}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                  Row(
                    children: [
                      if (m.isLive)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(color: AppTheme.accentRed, borderRadius: BorderRadius.circular(4)),
                          child: const Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        )
                      else
                        Text(m.status, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => _service.toggleSaveMatch(m.id),
                        child: Icon(
                          isSaved ? Icons.star_rounded : Icons.star_outline_rounded,
                          color: isSaved ? AppTheme.primary : AppTheme.textSecondary,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Team A vs Team B Scoreboard Strip
              Row(
                children: [
                  Expanded(
                    child: Text(
                      m.teamA,
                      style: const TextStyle(color: AppTheme.textMain, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.background,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppTheme.border.withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      m.score ?? 'VS',
                      style: TextStyle(
                        color: m.score != null ? AppTheme.primary : AppTheme.textSecondary,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      m.teamB,
                      textAlign: TextAlign.right,
                      style: const TextStyle(color: AppTheme.textMain, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  m.stadium,
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
