import 'package:flutter/material.dart';
import 'package:grocery/models/data_models/product.dart';
import 'package:grocery/models/state_models/theme_model.dart';
import 'package:grocery/widgets/transparent_image.dart';
import 'package:provider/provider.dart';

class ProductCard extends StatelessWidget {
  final Product product;



  final void Function() onTap;

  const ProductCard({
    required this.product,
    required this.onTap,

  });

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);

    return GestureDetector(
      child: Container(
        margin: const EdgeInsets.all(6),
        decoration: BoxDecoration(
            color: themeModel.secondBackgroundColor,
            borderRadius: const BorderRadius.all(Radius.circular(15)),
            boxShadow: [
              BoxShadow(
                  blurRadius: 2,
                  offset: Offset(0, 5),
                  color: themeModel.shadowColor)
            ]),
        child: Padding(
          padding: EdgeInsets.all(5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: Hero(
                  tag: product.reference,
                  child: FadeInImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(product.image),
                    placeholder: MemoryImage(kTransparentImage),
                  ))),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  product.title,
                  style: themeModel.theme.textTheme.bodyText1,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,

                ),

              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: GestureDetector(
                  child:

                  Text(
                    "${(product.pricePerKg == null)
                        ? product.pricePerPiece
                        : product.pricePerKg}\$",
                    style: themeModel.theme.textTheme.bodyText1!.apply(
                        color: themeModel.priceColor
                    ),

                  ),

                  onTap: () {},
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: onTap,
    );
  }
}
