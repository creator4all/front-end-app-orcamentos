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

  const SearchableDropdownWidget({
    super.key,
    required this.label,
    required this.hint,
    required this.items,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.searchHint = 'Pesquisar...',
  });

  @override
  State<SearchableDropdownWidget> createState() =>
      _SearchableDropdownWidgetState();
}

class _SearchableDropdownWidgetState extends State<SearchableDropdownWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late List<String> _sortedItems;

  @override
  void initState() {
    super.initState();
    _sortedItems = _sortItems(widget.items);

    if (widget.value != null) {
      _controller.text = widget.value!;
    }
  }

  @override
  void didUpdateWidget(SearchableDropdownWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.items != widget.items) {
      _sortedItems = _sortItems(widget.items);
    }

    if (oldWidget.value != widget.value) {
      _controller.text = widget.value ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  List<String> _sortItems(List<String> items) {
    final sorted = List<String>.from(items);
    sorted.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return _sortedItems;
        }

        final filtered = _sortedItems.where((String option) {
          return option
              .toLowerCase()
              .contains(textEditingValue.text.toLowerCase());
        }).toList();

        return filtered;
      },
      onSelected: (String selection) {
        widget.onChanged(selection);
        _controller.text = selection;
      },
      fieldViewBuilder: (
        BuildContext context,
        TextEditingController textEditingController,
        FocusNode focusNode,
        VoidCallback onFieldSubmitted,
      ) {
        textEditingController.text = _controller.text;

        return TextField(
          controller: textEditingController,
          focusNode: focusNode,
          enabled: widget.enabled,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[500],
            ),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.grey[600],
              size: 18.sp,
            ),
            suffixIcon: textEditingController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: Colors.grey[600],
                      size: 18.sp,
                    ),
                    onPressed: () {
                      textEditingController.clear();
                      _controller.clear();
                      widget.onChanged(null);
                    },
                  )
                : Icon(
                    Icons.arrow_drop_down,
                    color: Colors.grey[600],
                    size: 24.sp,
                  ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: Color(0xFF117BBD), width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            filled: true,
            fillColor: widget.enabled ? Colors.white : Colors.grey[50],
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          ),
          style: TextStyle(
            fontSize: 16.sp,
            color: Colors.black87,
          ),
        );
      },
      optionsViewBuilder: (
        BuildContext context,
        AutocompleteOnSelected<String> onSelected,
        Iterable<String> options,
      ) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(8.r),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: 200.h,
              ),
              width: MediaQuery.of(context).size.width - 32.w,
              child: options.isEmpty
                  ? Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Text(
                        'Nenhum resultado encontrado',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[500],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (BuildContext context, int index) {
                        final String option = options.elementAt(index);
                        final bool isSelected = option == widget.value;

                        return InkWell(
                          onTap: () {
                            onSelected(option);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
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
                                    option,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: isSelected
                                          ? const Color(0xFF117BBD)
                                          : Colors.black87,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check,
                                    color: const Color(0xFF117BBD),
                                    size: 18.sp,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        );
      },
    );
  }
}
