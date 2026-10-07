import 'dart:developer';
import 'dart:io';
import 'package:general/src/core/index.dart';

class AddRoomCover extends StatefulWidget {
  const AddRoomCover({
    this.img,
    this.imageQuality,
    this.radius,
    required this.canEdit,
    super.key,
  });
  final int? imageQuality;
  final double? radius;
  final String? img;
  final bool canEdit;

  @override
  State<AddRoomCover> createState() => AddRoomCoverState();
}

class AddRoomCoverState extends State<AddRoomCover> {
  static File? image;
  String? imagePath;

  Future pickImage() async {
    try {
      final image = await Methods.pickImageSafely(ImagePicker(),
          imageQuality: widget.imageQuality, source: ImageSource.gallery);
      if (image == null) return;
      final imageTemporary = File(image.path);
      setState(() {
        AddRoomCoverState.image = imageTemporary;
      });
    } on PlatformException {
      log("Error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (() {
        if (widget.canEdit) {
          pickImage();
        }
      }),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          15.hBox,
          image != null
              ? Container(
                  height: 90.h,
                  width: 90.w,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: Image.file(
                    image!,
                    fit: BoxFit.cover,
                  ),
                )
              : (widget.img == "" || widget.img == null)
                  ? Container(
                      height: 90.h,
                      width: 90.w,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: imagePath == null
                          ? const Icon(Icons.add)
                          : ImageViewWidget(
                              boxFit: BoxFit.cover,
                              height: 90.h,
                              width: 90.w,
                              shape: BoxShape.circle,
                              url: imagePath ?? '',
                            ),
                    )
                  : ImageViewWidget(
                      url: EndPoints.getImage(widget.img),
                      height: 90.h,
                      width: 90.w,
                      radius: 100.r,
                    ),
        ],
      ),
    );
  }
}
