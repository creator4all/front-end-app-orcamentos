import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SearchableDropdownWidget extends StatefulWidget {
  final String label;
  final String hint;
  final List<String> items;
  final String? value;
  final Function(String?) onChanged;
  final bool enabled;
  final String searchHint;
  final bool sortItems;

  const SearchableDropdownWidget({
    super.key,
    required this.label,
    required this.hint,
    required this.items,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.searchHint = 'Pesquisar...',
    this.sortItems = true,
  });

  @override
  State<SearchableDropdownWidget> createState() =>
      _SearchableDropdownWidgetState();
}

class _SearchableDropdownWidgetState extends State<SearchableDropdownWidget> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  late List<String> _sortedItems;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _sortedItems = _sortItems(widget.items);
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(SearchableDropdownWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!_listEquals(oldWidget.items, widget.items)) {
      _sortedItems = _sortItems(widget.items);
    }
  }

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  List<String> _sortItems(List<String> items) {
    if (!widget.sortItems) return List<String>.from(items);
    final sorted = List<String>.from(items);
    sorted.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return sorted;
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus && _isOpen) {
      _closeDropdown();
    }
  }

  void _openDropdown() {
    if (_isOpen || !widget.enabled) return;

    setState(() {
      _isOpen = true;
      _searchController.clear();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  void _closeDropdown() {
    if (!_isOpen) return;

    setState(() {
      _isOpen = false;
      _searchController.clear();
    });
  }

  void _selectItem(String item) {
    widget.onChanged(item);
    _closeDropdown();
  }

  List<String> _getFilteredItems() {
    final searchText = _searchController.text.toLowerCase();
    if (searchText.isEmpty) {
      return _sortedItems;
    }
    return _sortedItems
        .where((item) => item.toLowerCase().contains(searchText))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return TapRegion(
      onTapOutside: (_) {
        if (_isOpen) {
          _closeDropdown();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: widget.enabled ? Colors.white : Colors.grey[50],
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: _isOpen ? null : _openDropdown,
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                child: Row(
                  children: [
                    Expanded(
                      child: _isOpen
                          ? TextField(
                              controller: _searchController,
                              focusNode: _focusNode,
                              autofocus: true,
                              decoration: InputDecoration(
                                hintText: widget.searchHint,
                                hintStyle: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey[500],
                                ),
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.black87,
                              ),
                              onChanged: (_) => setState(() {}),
                            )
                          : Text(
                              widget.value ?? widget.hint,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: widget.value != null
                                    ? Colors.black87
                                    : Colors.grey[500],
                              ),
                            ),
                    ),
                    Icon(
                      _isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                      size: 24.sp,
                      color: Colors.grey[600],
                    ),
                  ],
                ),
              ),
            ),

            if (_isOpen) ...[
              Divider(height: 1, color: Colors.grey[300]),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 200.h),
                child: _buildOptionsList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsList() {
    final filteredItems = _getFilteredItems();

    if (filteredItems.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(16.w),
        child: Text(
          'Nenhum resultado encontrado',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[500],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        final item = filteredItems[index];
        final isSelected = item == widget.value;

        return InkWell(
          onTap: () => _selectItem(item),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 12.h,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF117BBD).withOpacity(0.1)
                  : Colors.transparent,
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey[200]!,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color:
                          isSelected ? const Color(0xFF117BBD) : Colors.black87,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check,
                    size: 18.sp,
                    color: const Color(0xFF117BBD),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

