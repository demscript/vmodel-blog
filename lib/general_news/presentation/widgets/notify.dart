import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

alert(BuildContext context, type, String message) {
  showTopSnackBar(
    Overlay.of(context),
    type == "error"
        ? CustomSnackBar.error(
            message: message,
          )
        : CustomSnackBar.success(
            message: message,
          ),
  );
}

// successalert(BuildContext context, String title, String message) {
//   return showDialog<void>(
//     context: context,
//     builder: (BuildContext context) {
//       return Dialog(
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.all(
//             Radius.circular(32.0),
//           ),
//         ),
//         child: Container(
//           decoration: const BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.all(
//               Radius.circular(20),
//             ),
//           ),
//           height: height / 2,
//           child: Column(
//             children: [
//               SizedBox(
//                 height: height / 10,
//               ),
//               Image.asset(
//                 "images/paymentsuccess.png",
//                 height: height / 5,
//               ),
//               SizedBox(
//                 height: height / 40,
//               ),
//               Text(
//                 title,
//                 style: TextStyle(
//                   color: const Color.fromRGBO(73, 73, 214, 1),
//                   fontFamily: 'Gilroy Bold',
//                   fontSize: height / 40,
//                 ),
//               ),
//               SizedBox(
//                 height: height / 100,
//               ),
//               Center(
//                 child: Text(
//                   message,
//                   style: TextStyle(
//                     color: const Color(0xff686578),
//                     fontFamily: 'Gilroy Bold',
//                     fontSize: height / 60,
//                   ),
//                 ),
//               ),
//               SizedBox(
//                 height: height / 30,
//               )
//             ],
//           ),
//         ),
//       );
//     },
//   );
// }
