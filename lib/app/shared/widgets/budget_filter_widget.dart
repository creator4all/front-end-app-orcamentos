import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BudgetFilterWidget extends StatefulWidget {
  final Function(String)? onSearchChanged;
  final Function(List<String>)? onFiltersChanged;
  final VoidCallback? onReset;

  const BudgetFilterWidget({
    super.key,
    this.onSearchChanged,
    this.onFiltersChanged,
    this.onReset,
  });

  @override
  State<BudgetFilterWidget> createState() => _BudgetFilterWidgetState();
}

class _BudgetFilterWidgetState extends State<BudgetFilterWidget> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _selectedFilters = [
    'pending'
  ]; // Pendentes marcado por padrão

  final List<Map<String, String>> _filterOptions = [
    {'key': 'approved', 'label': 'Aprovados'},
    {'key': 'not_approved', 'label': 'Não aprovados'},
    {'key': 'expired', 'label': 'Expirados'},
    {'key': 'pending', 'label': 'Pendentes'},
    {'key': 'archived', 'label': 'Arquivados'},
  ];

  @override
  void initState() {
    super.initState();
    // Informa ao widget pai que "Pendentes" já está selecionado por padrão
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onFiltersChanged?.call(_selectedFilters);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleFilter(String filterKey) {
    setState(() {
      if (_selectedFilters.contains(filterKey)) {
        _selectedFilters.remove(filterKey);
      } else {
        _selectedFilters.add(filterKey);
      }
    });
    widget.onFiltersChanged?.call(_selectedFilters);
  }

  void _resetFilters() {
    setState(() {
      _selectedFilters.clear();
      _selectedFilters.add('pending'); // Volta ao padrão com "Pendentes"
      _searchController.clear();
    });
    widget.onFiltersChanged?.call(_selectedFilters);
    widget.onSearchChanged?.call('');
    widget.onReset?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 0.h, horizontal: 10.w),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFF3A99D9),
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header com título e botão resetar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filtros',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.normal,
                  color: const Color(0xFF484848),
                ),
              ),
              GestureDetector(
                onTap: _resetFilters,
                child: Text(
                  'Resetar',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.normal,
                    color: const Color(0xFF484848),
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 8.h),

          // Campo de busca
          TextField(
            controller: _searchController,
            onChanged: widget.onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Busca por código ou cidade',
              hintStyle: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.normal,
                color: const Color(0xFF8C8C8C),
              ),
              prefixIcon: Icon(
                Icons.search,
                color: const Color(0xFF8C8C8C),
                size: 20.sp,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              filled: true,
              fillColor: const Color(0xFFF9F9F9),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 10.w,
                vertical: 10.h,
              ),
            ),
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF484848),
            ),
          ),

          SizedBox(height: 8.h),

          // Chips de filtro em grid responsivo
          Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            children: _filterOptions.map((filter) {
              final isSelected = _selectedFilters.contains(filter['key']);

              return GestureDetector(
                onTap: () => _toggleFilter(filter['key']!),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 4.w,
                    vertical: 2.h,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF2830F2)
                        : const Color(0xFFECECEC),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    filter['label']!,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.normal,
                      color: isSelected
                          ? const Color(0xFFFFFFFF)
                          : const Color(0xFF484848),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
