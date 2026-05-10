import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../models/mock_data.dart';
import '../../widgets/guest_card_widget.dart';
import '../../widgets/guest_entry_modal.dart';

class LiveFeedScreen extends StatefulWidget {
  const LiveFeedScreen({super.key});

  @override
  State<LiveFeedScreen> createState() => _LiveFeedScreenState();
}

class _LiveFeedScreenState extends State<LiveFeedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _filter = 'All';
  final _filters = ['All', 'Active', 'Expiring', 'Expired'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _filters.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _filter = _filters[_tabController.index]);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<GuestEntry> get _filtered {
    switch (_filter) {
      case 'Active':
        return MockData.guestEntries
            .where((e) => !e.isExpired && e.remaining.inMinutes >= 30)
            .toList();
      case 'Expiring':
        return MockData.guestEntries
            .where((e) => !e.isExpired && e.remaining.inMinutes < 30)
            .toList();
      case 'Expired':
        return MockData.guestEntries.where((e) => e.isExpired).toList();
      default:
        return MockData.guestEntries;
    }
  }

  @override
  Widget build(BuildContext context) {
    final entries = _filtered;

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            backgroundColor: AppColors.darkBg,
            pinned: true,
            floating: false,
            expandedHeight: 0,
            toolbarHeight: 72,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Live Parking Feed',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${MockData.guestEntries.length} total · ${MockData.guestEntries.where((e) => !e.isExpired).length} active',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            actions: [
              _LiveBadge(),
              const SizedBox(width: 16),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: _FilterTabs(controller: _tabController, filters: _filters),
            ),
          ),
        ],
        body: entries.isEmpty
            ? _EmptyState(filter: _filter)
            : RefreshIndicator(
                color: AppColors.electricBlue,
                backgroundColor: AppColors.darkCard,
                onRefresh: () async =>
                    await Future.delayed(const Duration(seconds: 1)),
                child: ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  itemCount: entries.length + 1,
                  itemBuilder: (_, i) {
                    if (i == entries.length) {
                      return const SizedBox(height: 80);
                    }
                    return GuestCardWidget(
                      entry: entries[i],
                      onRevoke: () {},
                    );
                  },
                ),
              ),
      ),
      floatingActionButton: _AddGuestFab(
        onTap: () => GuestEntryModal.show(context),
      ),
    );
  }
}

class _LiveBadge extends StatefulWidget {
  @override
  State<_LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<_LiveBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulse = Tween(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, _) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.danger.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: AppColors.danger.withOpacity(0.35 * _pulse.value)),
        ),
        child: Row(
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: AppColors.danger.withOpacity(_pulse.value),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'LIVE',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.danger,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterTabs extends StatelessWidget {
  final TabController controller;
  final List<String> filters;

  const _FilterTabs({required this.controller, required this.filters});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      alignment: Alignment.centerLeft,
      child: TabBar(
        controller: controller,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
        indicator: const BoxDecoration(),
        dividerHeight: 0,
        tabs: filters.map((f) => _FilterTab(label: f)).toList(),
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  final String label;

  const _FilterTab({required this.label});

  @override
  Widget build(BuildContext context) {
    final selected = DefaultTabController.of(context).index ==
        ['All', 'Active', 'Expiring', 'Expired'].indexOf(label);
    // Using TabBar's own selection state via TabController
    return Tab(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(colors: AppColors.blueGradient)
              : null,
          color: selected ? null : AppColors.darkCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.electricBlue : AppColors.darkBorder,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String filter;

  const _EmptyState({required this.filter});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.darkBorder),
            ),
            child: const Icon(Icons.local_parking_rounded,
                color: AppColors.textMuted, size: 36),
          ),
          const SizedBox(height: 16),
          Text(
            'No $filter entries',
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            'Guest vehicles will appear here',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddGuestFab extends StatelessWidget {
  final VoidCallback onTap;

  const _AddGuestFab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: AppColors.blueGradient),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.electricBlue.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add_rounded, color: Colors.white, size: 22),
            const SizedBox(width: 8),
            Text(
              'Add Guest',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
