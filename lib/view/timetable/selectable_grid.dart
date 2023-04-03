import 'package:fiwi/cubits/timetable/selectable_grid_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

class SelectableGrid extends StatefulWidget {
  final int itemCount;
  final item;
  final Widget Function(BuildContext, int, bool) itemBuilder;

  const SelectableGrid({super.key, 
    required this.itemCount,
    required this.item,
    required this.itemBuilder,
  });
  @override
  State<StatefulWidget> createState() => _SelectableGridState();

}

class _SelectableGridState extends State<SelectableGrid> {
  Box box = Hive.box('user');
  List courseList = [];
  
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SelectableGridCubit(widget.itemCount),
      child: Builder(
        builder: (context) => ListView.builder(
          itemCount: widget.itemCount,
          
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                context.read<SelectableGridCubit>().toggleItem(index,widget.item);
                
              },
              child: BlocBuilder<SelectableGridCubit, List<bool>>(
                builder: (context, selection) {
                  return Container(
                    padding: EdgeInsets.symmetric(vertical: 8,horizontal: 10),
                    decoration: BoxDecoration(
                      color: selection[index] ? Colors.purple : Colors.white,
                      border: Border.all(
                        color: selection[index] ? Colors.white : Colors.purple,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(10)
                    ),
                    child: widget.itemBuilder(context, index, selection[index]),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
