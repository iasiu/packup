import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:packer/config/config.dart';
import 'package:packer/controllers/add_package_cubit/add_package_cubit.dart';
import 'package:packer/views/widgets/app_scaffold.dart';
import 'package:packer/views/widgets/app_text_button.dart';
import 'package:packer/views/widgets/app_text_field.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:packer/views/widgets/loading_placeholder.dart';

class AddReceiverPageRoute extends MaterialPageRoute<void> {
  AddReceiverPageRoute()
      : super(builder: (BuildContext context) => AddReceiverPage());
}

class AddReceiverPage extends StatelessWidget {
  AddReceiverPage({
    Key? key,
  }) : super(key: key);

  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    final required = FormBuilderValidators.required(context);

    return BlocBuilder<AddPackageCubit, AddPackageState>(
      builder: (context, state) {
        return Stack(
          children: [
            AppScaffold(
              height: 60,
              title: const Text(
                'New receiver',
                style: TextStyles.white24,
              ),
              body: GestureDetector(
                onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: FormBuilder(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Name*',
                              style: TextStyles.white20,
                            ),
                            const SizedBox(height: 4),
                            AppTextField(
                              name: 'name',
                              validator: FormBuilderValidators.required(context),
                              padding: 12,
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Email address*',
                              style: TextStyles.white20,
                            ),
                            const SizedBox(height: 4),
                            AppTextField(
                              name: 'email',
                              validator: FormBuilderValidators.compose([
                                required,
                                FormBuilderValidators.email(context),
                              ]),
                              padding: 12,
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Phone number',
                              style: TextStyles.white20,
                            ),
                            const SizedBox(height: 4),
                            AppTextField(
                              name: 'phone',
                              maxLength: 20,
                              validator: FormBuilderValidators.numeric(context),
                              padding: 12,
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Office',
                              style: TextStyles.white20,
                            ),
                            const SizedBox(height: 4),
                            const AppTextField(
                              name: 'office',
                              maxLength: 20,
                              padding: 12,
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.streetAddress,
                            ),
                            const SizedBox(height: 12),
                            AppTextButton(
                              text: 'Save',
                              onPressed: () async {
                                if (_formKey.currentState!.saveAndValidate()) {
                                  final value = _formKey.currentState!.value;
                                  final receiver = await context
                                      .read<AddPackageCubit>()
                                      .addReceiver(
                                        name: value['name'],
                                        emailAddress: value['email'],
                                        phoneNumber: value['phone'],
                                        officeNumber: value['office'],
                                      );
                                  Navigator.of(context).pop(receiver);
                                }
                              },
                            ),
                          ],
                        )),
                  ),
                ),
              ),
            ),
            if (state is AddPackageInProgress) const LoadingPlaceholder(),
          ],
        );
      },
    );
  }
}