import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:grocery/models/data_models/category.dart';
import 'package:grocery/models/state_models/theme_model.dart';
import 'package:grocery/ui/products_reader.dart';
import 'package:grocery/widgets/transparent_image.dart';

class CategoryCard extends StatelessWidget {
  final Category category;
  const CategoryCard({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context, listen: false);

    return GestureDetector(
      onTap: () {
        ProductReader.create(context, category: category.title);
      },
      child: Container(
        decoration: BoxDecoration(
          color: themeModel.shadowColor,
          borderRadius: const BorderRadius.all(Radius.circular(15)),
        ),
        margin: const EdgeInsets.only(right: 20),
        width: 180,
        height: 180,
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                  child: FadeInImage(
                fit: BoxFit.cover,
                placeholder: MemoryImage(kTransparentImage),
                image: NetworkImage(category.image),
              )),
              Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child: Text(
                    category.title.replaceFirst(
                        category.title[0], category.title[0].toUpperCase()),
                    style: themeModel.theme.textTheme.bodyText1,
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
