import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rent_and_repair_shop_flutter/services/api_service.dart';
import 'package:rent_and_repair_shop_flutter/l10n/app_localizations.dart';

class DashboardStats {
  final int activeRentals;
  final int pendingRepairs;
  final int availableBoards;
  final double monthlyRevenue;
  DashboardStats({
    required this.activeRentals,
    required this.pendingRepairs,
    required this.availableBoards,
    required this.monthlyRevenue,
  });
}

class _StatData {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _StatData(this.title, this.value, this.icon, this.color, this.onTap);
}

class DashboardOverview extends StatefulWidget {
  const DashboardOverview({super.key});
  @override
  State<DashboardOverview> createState() => _DashboardOverviewState();
}

class _DashboardOverviewState extends State<DashboardOverview> {
  late Future<DashboardStats> _statsFuture;
  StreamSubscription? _rentalSub;
  TabController? _tabController;

  void _onTabChanged() {
    if (_tabController?.index == 0) {
      _loadStats();
    }
  }

  @override
  void initState() {
    super.initState();
    _loadStats();

    // fire whenever createRental() succeeds
    _rentalSub = ApiService().onRentalCreated.listen((_) => _loadStats());

    // fire when user switches back to tab 0
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tabController = DefaultTabController.of(context);
      _tabController?.addListener(_onTabChanged);
    });
  }

  void _loadStats() {
    if (!mounted) return;
    setState(() {
      _statsFuture = _fetchStats();
    });
  }

  Future<DashboardStats> _fetchStats() async {
    final rentals = await ApiService().fetchRentals();
    final repairs = await ApiService().fetchRepairs();
    final boards = await ApiService().fetchSurfboards();
    final bills = await ApiService().fetchBills();
    final now = DateTime.now();

    // count active by “not returned yet”
    final active = rentals.where((r) => r.returnedAt == null).length;

    final revenue = bills
        .where(
          (b) =>
              b.billCreatedAt.year == now.year &&
              b.billCreatedAt.month == now.month,
        )
        .fold<double>(0, (sum, b) => sum + b.totalAmount);

    return DashboardStats(
      activeRentals: active,
      pendingRepairs:
          repairs.where((r) => r.status.toLowerCase() == 'created').length,
      availableBoards: boards.where((b) => b.available).length,
      monthlyRevenue: revenue,
    );
  }

  @override
  void dispose() {
    _rentalSub?.cancel();
    _tabController?.removeListener(_onTabChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final tabController = DefaultTabController.of(context);

    return FutureBuilder<DashboardStats>(
      future: _statsFuture,
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) return Center(child: Text('❌ ${snap.error}'));

        final d = snap.data!;
        final stats = [
          _StatData(
            loc.translate('dashboard_active_rentals'),
            d.activeRentals.toString(),
            Icons.assignment,
            Colors.blueAccent,
            () => tabController.animateTo(1),
          ),
          _StatData(
            loc.translate('dashboard_pending_repairs'),
            d.pendingRepairs.toString(),
            Icons.build,
            Colors.deepOrange,
            () => tabController.animateTo(2),
          ),
          _StatData(
            loc.translate('dashboard_available_boards'),
            d.availableBoards.toString(),
            Icons.inventory_2,
            Colors.green,
            () => tabController.animateTo(3),
          ),
          _StatData(
            loc.translate('dashboard_monthly_revenue'),
            '\$${d.monthlyRevenue.toStringAsFixed(2)}',
            Icons.attach_money,
            Colors.purple,
            () => tabController.animateTo(4),
          ),
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.translate('dashboard_overview'),
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              crossAxisCount: MediaQuery.of(context).size.width > 800 ? 4 : 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children:
                  stats.map((s) {
                    return InkWell(
                      onTap: s.onTap,
                      borderRadius: BorderRadius.circular(4),
                      child: Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          child: Row(
                            children: [
                              Icon(s.icon, size: 32, color: s.color),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      s.title,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      s.value,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ],
        );
      },
    );
  }
}
