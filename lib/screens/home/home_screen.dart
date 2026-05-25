import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../models/service_category.dart';
import '../../models/service_item.dart';
import '../../repositories/firebase_marketplace_repository.dart';
import '../../repositories/marketplace_repository.dart';
import '../../services/location_service.dart';
import '../../widgets/common/app_shell.dart';
import '../../widgets/common/dark_input.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/product/category_chip.dart';
import '../../widgets/product/compact_service_tile.dart';
import '../../widgets/product/service_card.dart';

enum _HomeServiceFilter { offers, price, distance, experience }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  final _locationService = const LocationService();

  _HomeServiceFilter _selectedFilter = _HomeServiceFilter.offers;
  String? _selectedCategoryId;
  String _locationLabel = 'Obteniendo ubicación...';

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentLocation() async {
    final label = await _locationService.getCurrentLocationLabel();
    if (!mounted) {
      return;
    }

    final fallbackAddress = context
        .read<MarketplaceRepository>()
        .defaultAddress
        .fullAddress;

    setState(() {
      _locationLabel = label == null
          ? 'Ubicación no disponible'
          : 'Ubicación actual: $label';

      if (label == null && fallbackAddress.trim().isNotEmpty) {
        _locationLabel = 'Ubicación no disponible';
      }
    });
  }

  void _focusSearch() {
    _searchFocusNode.requestFocus();
  }

  void _openProfile(MarketplaceRepository repository) {
    if (repository.currentUser.id.isEmpty) {
      context.go('/login');
      return;
    }

    context.push('/profile');
  }

  void _openService(ServiceItem service) {
    context.push('/service/${service.id}');
  }

  void _selectCategory(ServiceCategory category) {
    setState(() {
      _selectedCategoryId = _selectedCategoryId == category.id
          ? null
          : category.id;
    });
  }

  void _changeFilter(_HomeServiceFilter filter) {
    setState(() {
      _selectedFilter = filter;
    });
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedCategoryId = null;
      _selectedFilter = _HomeServiceFilter.offers;
    });
  }

  List<ServiceItem> _filteredServices(List<ServiceItem> services) {
    final query = _searchController.text.trim().toLowerCase();
    final filtered = services.where((service) {
      return _matchesSearch(service, query) && _matchesCategory(service);
    }).toList();

    return _applyFilter(filtered);
  }

  bool _matchesSearch(ServiceItem service, String query) {
    if (query.isEmpty) {
      return true;
    }

    final searchableText = [
      service.title,
      service.categoryName,
      service.description,
      service.providerName,
      ...service.tags,
    ].join(' ').toLowerCase();

    return searchableText.contains(query);
  }

  bool _matchesCategory(ServiceItem service) {
    final categoryId = _selectedCategoryId;
    return categoryId == null || service.categoryId == categoryId;
  }

  List<ServiceItem> _applyFilter(List<ServiceItem> services) {
    final result = [...services];

    switch (_selectedFilter) {
      case _HomeServiceFilter.offers:
        result.sort((a, b) {
          final aScore = _offerScore(a);
          final bScore = _offerScore(b);
          if (aScore != bScore) {
            return bScore.compareTo(aScore);
          }
          return b.rating.compareTo(a.rating);
        });
      case _HomeServiceFilter.price:
        result.sort((a, b) => a.price.compareTo(b.price));
      case _HomeServiceFilter.distance:
        result.sort((a, b) => _distanceValue(a).compareTo(_distanceValue(b)));
      case _HomeServiceFilter.experience:
        result.sort((a, b) {
          final rating = b.rating.compareTo(a.rating);
          return rating == 0 ? b.reviewCount.compareTo(a.reviewCount) : rating;
        });
    }

    return result;
  }

  int _offerScore(ServiceItem service) {
    final badge = service.badge.toLowerCase();
    if (badge.contains('oferta')) {
      return 3;
    }
    if (service.isFeatured) {
      return 2;
    }
    if (badge.contains('top') || badge.contains('mejor')) {
      return 1;
    }
    return 0;
  }

  double _distanceValue(ServiceItem service) {
    final match = RegExp(r'[\d.]+').firstMatch(service.distance);
    return double.tryParse(match?.group(0) ?? '') ?? double.infinity;
  }

  @override
  Widget build(BuildContext context) {
    final repository = context.watch<MarketplaceRepository>();
    final firebaseRepository = repository is FirebaseMarketplaceRepository
        ? repository
        : null;
    final services = repository.getServices();
    final categories = [...repository.getCategories()]
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final filteredServices = _filteredServices(services);
    final featuredServices = filteredServices.take(4).toList();
    final recommendedServices = filteredServices.skip(2).toList();

    return AppShell(
      currentIndex: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on_rounded, color: AppColors.orange),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ENTREGAR A...',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      _locationLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _focusSearch,
                icon: const Icon(Icons.search_rounded),
              ),
              InkWell(
                customBorder: const CircleBorder(),
                onTap: () => _openProfile(repository),
                child: CircleAvatar(
                  radius: 18,
                  backgroundImage:
                      (repository.currentUser.avatarUrl?.isNotEmpty ?? false)
                      ? NetworkImage(repository.currentUser.avatarUrl!)
                      : null,
                  child: repository.currentUser.avatarUrl == null
                      ? const Icon(Icons.person_outline_rounded, size: 18)
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          DarkInput(
            hint: 'Buscar servicios',
            icon: Icons.search_rounded,
            controller: _searchController,
            focusNode: _searchFocusNode,
            textInputAction: TextInputAction.search,
            onChanged: (_) => setState(() {}),
          ),
          if (firebaseRepository != null) ...[
            _MarketplaceStatus(repository: firebaseRepository),
            const SizedBox(height: 18),
          ],
          const SizedBox(height: 18),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _HomeServiceFilter.values.map((filter) {
                return _FilterChip(
                  label: _filterLabel(filter),
                  selected: filter == _selectedFilter,
                  onTap: () => _changeFilter(filter),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 34),
          SectionHeader(
            title: 'Categorías',
            action: 'VER TODO',
            onAction: () => context.go('/services'),
          ),
          const SizedBox(height: 18),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories.map((category) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: CategoryChipCard(
                    category: category,
                    selected: _selectedCategoryId == category.id,
                    onTap: () => _selectCategory(category),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 36),
          if (filteredServices.isEmpty)
            _EmptyServicesMessage(onClear: _clearFilters)
          else ...[
            SectionHeader(
              title: 'Servicios Destacados',
              eyebrow: _activeListLabel,
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 416,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: featuredServices.length,
                separatorBuilder: (context, index) => const SizedBox(width: 18),
                itemBuilder: (context, index) => ServiceCard(
                  service: featuredServices[index],
                  onTap: () => _openService(featuredServices[index]),
                ),
              ),
            ),
            if (recommendedServices.isNotEmpty) ...[
              const SizedBox(height: 36),
              const SectionHeader(title: 'Recomendados para ti'),
              const SizedBox(height: 18),
              ...recommendedServices.map(
                (service) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: CompactServiceTile(
                    service: service,
                    onTap: () => _openService(service),
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  String get _activeListLabel {
    if (_searchController.text.trim().isNotEmpty) {
      return 'Resultados de búsqueda';
    }
    if (_selectedCategoryId != null) {
      return 'Categoría seleccionada';
    }
    return 'Selección editorial';
  }

  String _filterLabel(_HomeServiceFilter filter) {
    return switch (filter) {
      _HomeServiceFilter.offers => 'Ofertas',
      _HomeServiceFilter.price => 'Precio',
      _HomeServiceFilter.distance => 'Distancia',
      _HomeServiceFilter.experience => 'Experiencia',
    };
  }
}

class _MarketplaceStatus extends StatelessWidget {
  const _MarketplaceStatus({required this.repository});

  final FirebaseMarketplaceRepository repository;

  @override
  Widget build(BuildContext context) {
    if (repository.isLoading) {
      return const LinearProgressIndicator(minHeight: 4);
    }

    final message = repository.errorMessage;
    if (message != null) {
      return _StatusMessage(
        icon: Icons.cloud_off_rounded,
        text: '$message Mostrando datos temporales.',
      );
    }

    if (repository.usingFallback) {
      return const _StatusMessage(
        icon: Icons.info_outline_rounded,
        text: 'Firestore no tiene datos aun. Mostrando datos temporales.',
      );
    }

    return const SizedBox.shrink();
  }
}

class _StatusMessage extends StatelessWidget {
  const _StatusMessage({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.orangeLight, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.orange : AppColors.surfaceSoft,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? AppColors.orangeLight : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _EmptyServicesMessage extends StatelessWidget {
  const _EmptyServicesMessage({required this.onClear});

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.search_off_rounded,
            color: AppColors.orangeLight,
            size: 34,
          ),
          const SizedBox(height: 12),
          Text(
            'No encontramos servicios',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text(
            'Prueba con otra búsqueda, categoría o filtro.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: onClear,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.surfaceHigh,
              foregroundColor: AppColors.orangeLight,
            ),
            child: const Text('Limpiar filtros'),
          ),
        ],
      ),
    );
  }
}
