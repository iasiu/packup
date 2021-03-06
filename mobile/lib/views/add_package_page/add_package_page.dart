import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:packer/config/config.dart';
import 'package:packer/config/router.dart';
import 'package:packer/controllers/add_package_cubit/add_package_cubit.dart';
import 'package:packer/generated/l10n.dart';
import 'package:packer/models/models.dart';
import 'package:packer/utils/app_scanner.dart';
import 'package:packer/views/add_package_page/widgets/pick_delivery_page.dart';
import 'package:packer/views/add_package_page/widgets/pick_receiver_page.dart';
import 'package:packer/views/add_package_page/widgets/pick_sender_page.dart';
import 'package:packer/views/widgets/app_scaffold.dart';
import 'package:packer/views/widgets/app_text_button.dart';
import 'package:packer/utils/app_toaster.dart';
import 'package:packer/views/widgets/app_text_field.dart';
import 'package:packer/views/widgets/error_placeholder.dart';
import 'package:packer/views/widgets/loading_placeholder.dart';

class AddPackagePageArguments {
  AddPackagePageArguments(this.barcode);
  String barcode;
}

class AddPackagePage extends HookWidget {
  AddPackagePage({Key? key}) : super(key: key);

  final formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    final barcode = useState(
        (ModalRoute.of(context)!.settings.arguments as AddPackagePageArguments)
            .barcode);
    final deliveryCompany = useState<DeliveryCompany?>(null);
    final sender = useState<Sender?>(null);
    final receiver = useState<Receiver?>(null);
    final paddingTop = MediaQuery.of(context).padding.top;

    return BlocBuilder<AddPackageCubit, AddPackageState>(
      builder: (context, state) {
        return AppScaffold(
          height: 60,
          title: Text(
            S.of(context).AddPack,
            style: TextStyles.white24,
          ),
          actions: state is AddPackageFetched ? [
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        if (barcode.value.length >= 4) {
                          if (deliveryCompany.value != null) {
                            if (sender.value != null) {
                              if (receiver.value != null) {
                                formKey.currentState!.saveAndValidate();
                                final value = formKey.currentState!.value;
                                context.read<AddPackageCubit>().addPackage(
                                      barcode: barcode.value,
                                      deliveryCompanyId:
                                          deliveryCompany.value!.id,
                                      senderId: sender.value!.id,
                                      receiverId: receiver.value!.id,
                                      comment: value['comment'] ?? '',
                                    );
                                Navigator.of(context).popUntil(
                                  (route) =>
                                      route.settings.name ==
                                      AppPages.home.route,
                                );
                              } else {
                                AppToaster.show(
                                  text: S.of(context).AddPackagePage_PleasePickDelivery,
                                  bgColor: Colors.red,
                                  textColor: AppColors.cultured,
                                );
                              }
                            } else {
                              AppToaster.show(
                                text: S.of(context).AddPackagePage_PleasePickSender,
                                bgColor: Colors.red,
                                textColor: AppColors.cultured,
                              );
                            }
                          } else {
                            AppToaster.show(
                              text: S.of(context).AddPackagePage_PleasePickDelivery,
                              bgColor: Colors.red,
                              textColor: AppColors.cultured,
                            );
                          }
                        } else {
                          AppToaster.show(
                            text: S.of(context).AddPackagePage_BarcodeShort,
                            bgColor: Colors.red,
                            textColor: AppColors.cultured,
                          );
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          S.of(context).AddPackagePage_Save,
                            style: TextStyles.white16.copyWith(
                              color: AppColors.inpost,
                            )),
                      ),
                    ),
                  ),
                ]
              : null,
          body: state.maybeMap(
            orElse: () => const ErrorPlaceholder(errorText: null),
            failure: (failure) => ErrorPlaceholder(errorText: failure.message),
            inProgress: (_) => const LoadingPlaceholder(
              backgroundColor: Colors.transparent,
            ),
            fetched: (fetched) => GestureDetector(
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 16.0,
                  ),
                  child: _AddPackageForm(
                    barcode: barcode,
                    deliveryCompany: deliveryCompany,
                    paddingTop: paddingTop,
                    sender: sender,
                    receiver: receiver,
                    formKey: formKey,
                    fetched: fetched,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AddPackageForm extends StatelessWidget {
  const _AddPackageForm({
    Key? key,
    required this.barcode,
    required this.deliveryCompany,
    required this.paddingTop,
    required this.sender,
    required this.receiver,
    required this.formKey,
    required this.fetched,
  }) : super(key: key);

  final ValueNotifier<String> barcode;
  final ValueNotifier<DeliveryCompany?> deliveryCompany;
  final double paddingTop;
  final ValueNotifier<Sender?> sender;
  final ValueNotifier<Receiver?> receiver;
  final GlobalKey<FormBuilderState> formKey;
  final AddPackageFetched fetched;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).AddPackagePage_Barcode,
          style: TextStyles.white20,
        ),
        AppTextButton(
          text: barcode.value,
          color: AppColors.jet,
          textColor: AppColors.cultured,
          textAlign: TextAlign.start,
          onPressed: () {
            AppScanner.barcode().then((barcodeScanRes) {
              if (barcodeScanRes != '-1') {
                barcode.value = barcodeScanRes;
              }
            });
          },
        ),
        const SizedBox(height: 16),
        Text(
          S.of(context).AddPackagePage_Delivery,
          style: TextStyles.white20,
        ),
        AppTextButton(
          color: AppColors.jet,
          textColor: AppColors.cultured,
          text: deliveryCompany.value?.name ?? S.of(context).AddPackagePage_PickDelivery,
          textAlign: TextAlign.start,
          onPressed: () async {
            final deliveryRes = await showModalBottomSheet<DeliveryCompany>(
              context: context,
              isScrollControlled: true,
              enableDrag: false,
              backgroundColor: AppColors.jet,
              builder: (context) => Padding(
                padding: EdgeInsets.only(
                  top: paddingTop,
                ),
                child: PickDeliveryPage(
                  deliveryCompanies: fetched.deliveryCompanies,
                ),
              ),
            );
            if (deliveryRes != null) {
              deliveryCompany.value = deliveryRes;
            }
          },
        ),
        const SizedBox(height: 16),
        Text(
          S.of(context).AddPackagePage_Sender,
          style: TextStyles.white20,
        ),
        AppTextButton(
          color: AppColors.jet,
          textColor: AppColors.cultured,
          text: sender.value?.name ?? S.of(context).AddPackagePage_PickSender,
          textAlign: TextAlign.start,
          onPressed: () async {
            final senderRes = await showModalBottomSheet<Sender>(
              context: context,
              isScrollControlled: true,
              enableDrag: false,
              backgroundColor: AppColors.jet,
              builder: (context) => Padding(
                padding: EdgeInsets.only(
                  top: paddingTop,
                ),
                child: PickSenderPage(
                  senders: fetched.senders,
                  paddingTop: paddingTop,
                ),
              ),
            );
            if (senderRes != null) {
              sender.value = senderRes;
            }
          },
        ),
        const SizedBox(height: 16),
        Text(
          S.of(context).AddPackagePage_Receiver,
          style: TextStyles.white20,
        ),
        AppTextButton(
          color: AppColors.jet,
          textColor: AppColors.cultured,
          text: receiver.value?.name ?? S.of(context).AddPackagePage_PickReceiver,
          textAlign: TextAlign.start,
          onPressed: () async {
            final receiverRes = await showModalBottomSheet<Receiver>(
              context: context,
              isScrollControlled: true,
              enableDrag: false,
              backgroundColor: AppColors.jet,
              builder: (context) => Padding(
                padding: EdgeInsets.only(
                  top: paddingTop,
                ),
                child: PickReceiverPage(
                  receivers: fetched.receivers,
                ),
              ),
            );
            if (receiverRes != null) {
              receiver.value = receiverRes;
            }
          },
        ),
        const SizedBox(height: 16),
        _CommentForm(formKey: formKey),
      ],
    );
  }
}

class _CommentForm extends StatelessWidget {
  const _CommentForm({
    Key? key,
    required this.formKey,
  }) : super(key: key);

  final GlobalKey<FormBuilderState> formKey;

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: formKey,
      enabled: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).AddPackagePage_Comment,
            style: TextStyles.white20,
          ),
          const AppTextField(
            name: 'comment',
            lines: 5,
          ),
        ],
      ),
    );
  }
}
