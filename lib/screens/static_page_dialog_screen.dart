import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:almalhy_store/cubit/static_page/static_page_cubit.dart';
import 'package:almalhy_store/cubit/static_page/static_page_state.dart';

void showStaticPageDialog(BuildContext context, String endpoint) {
  final cubit = context.read<StaticPageCubit>();
  cubit.loadPage(endpoint);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: BlocBuilder<StaticPageCubit, StaticPageState>(
                builder: (context, state) {
                  if (state is StaticPageLoading) {
                    return Center(child: CircularProgressIndicator());
                  } else if (state is StaticPageError) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 48,
                          ),
                          SizedBox(height: 16),
                          Text(state.message, style: TextStyle(fontSize: 16)),
                        ],
                      ),
                    );
                  } else if (state is StaticPageLoaded) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                state.title,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.close),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                        Divider(thickness: 1),
                        // Content
                        Expanded(
                          child: SingleChildScrollView(
                            controller: scrollController,
                            child:
                                state.content is String
                                    ? Text(
                                      state.content,
                                      style: TextStyle(
                                        fontSize: 16,
                                        height: 1.5,
                                      ),
                                    )
                                    : _buildContactInfo(
                                      state.content as Map<String, dynamic>,
                                    ),
                          ),
                        ),
                      ],
                    );
                  }
                  return SizedBox.shrink();
                },
              ),
            ),
          );
        },
      );
    },
  );
}

Widget _buildContactInfo(Map<String, dynamic> info) {
  final items = <Widget>[];
  void addTile(IconData icon, String label, {String? link}) {
    items.add(
      ListTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(label, style: TextStyle(fontSize: 16)),
        onTap: link != null ? () => _launchUrl(link) : null,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  addTile(Icons.location_on, info['location'] ?? '');
  addTile(Icons.phone, info['phone'] ?? '', link: 'tel:${info['phone']}');
  addTile(Icons.print, info['fax'] ?? '');
  addTile(Icons.email, info['email'] ?? '', link: 'mailto:${info['email']}');

  // Social links
  info.forEach((platform, url) {
    if (['facebook', 'twitter', 'linkedin', 'instagram'].contains(platform) &&
        url != null) {
      addTile(Icons.link, platform.capitalize(), link: url as String);
    }
  });

  return Column(children: items);
}

Future<void> _launchUrl(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    debugPrint('Could not launch \$url');
  }
}

extension StringExtension on String {
  String capitalize() =>
      length > 0 ? this[0].toUpperCase() + substring(1) : this;
}
