import 'package:asset_store/screens/asset_management/asset_buttons.dart';
import 'package:flutter/material.dart';

class CreateAssetDetail extends StatefulWidget {
  const CreateAssetDetail({
    required this.tabController,
    super.key,
  });

  final TabController tabController;

  @override
  State<CreateAssetDetail> createState() => _CreateAssetDetailState();
}

class _CreateAssetDetailState extends State<CreateAssetDetail>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Column(
      children: <Widget>[
        // Primary data entry
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              // Asset name
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.person_2),
                  label: Text('Name'),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),

              // Asset category
              TextField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.category_rounded),
                  label: Text('Category'),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),

              // Asset date
              const TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.calendar_month_rounded),
                  label: Text('Date'),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),

              // Asset price
              const TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.attach_money_rounded),
                  label: Text('Category'),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),

        // Separator bar
        const Padding(
          padding: EdgeInsets.all(10),
          child: Divider(
            indent: 20,
            endIndent: 20,
          ),
        ),

        const Text('Labels'),

        // Separator bar
        const Padding(
          padding: EdgeInsets.all(10),
          child: Divider(
            indent: 20,
            endIndent: 20,
          ),
        ),

        const Placeholder(child: SizedBox(height: 40)),
        const SizedBox(height: 20),
        const Placeholder(child: SizedBox(height: 300)),

        AssetButtons(
          tabController: widget.tabController,
          add: () {},
        ),
      ],
    );
  }
}
