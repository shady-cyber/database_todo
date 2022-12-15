import 'package:flutter/material.dart';

Widget defaultFormField({
  required TextEditingController controller,
  required TextInputType type,
  void Function(String)? onSubmit,
  void Function(String)? onChange,
  void Function()? onTap,
  bool isPassword = false,
  required String Function(String?) validate,
  required String label,
  required IconData prefix,
  IconData? suffix,
  Function? suffixPressed,
  bool isClickable = true,
  }) => TextFormField(
  controller: controller,
  keyboardType: type,
  obscureText: isPassword,
  //readOnly: isClickable,
  onFieldSubmitted: onSubmit,
  onChanged: onChange,
  onTap: onTap,
  validator: validate,
  decoration: InputDecoration(
    labelText: label,
    prefixIcon: Icon(prefix),
    suffixIcon: suffix != null ? IconButton(
        onPressed: suffixPressed!(),
        icon: Icon(
          suffix,
        ),
    ) : null,
    border: const OutlineInputBorder(),
  ),
);

Widget buildTaskItem(Map model) => Padding(
  padding: const EdgeInsets.all(20.0),
  child: Row(
    children: [
      CircleAvatar(
        radius: 40.0,
        child: Text(
            '${model['time']}',
        ),
      ),
      const SizedBox(
        width: 20.0,
      ),
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${model['title']}',
            style: const TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '${model['date']}',
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),


        ],
      ),
    ],
  ),
);