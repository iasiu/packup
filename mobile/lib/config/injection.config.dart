// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import '../client_service.dart' as _i3;
import '../controllers/add_package_cubit/add_package_cubit.dart' as _i5;
import '../controllers/edit_cubit/edit_cubit.dart' as _i6;
import '../controllers/history_cubit/history_cubit.dart' as _i7;
import '../controllers/pass_package_cubit/pass_package_cubit.dart' as _i8;
import '../repository.dart' as _i4; // ignore_for_file: unnecessary_lambdas

// ignore_for_file: lines_longer_than_80_chars
/// initializes the registration of provided dependencies inside of [GetIt]
_i1.GetIt $initGetIt(_i1.GetIt get,
    {String? environment, _i2.EnvironmentFilter? environmentFilter}) {
  final gh = _i2.GetItHelper(get, environment, environmentFilter);
  gh.lazySingleton<_i3.ClientService>(() => _i3.ClientService());
  gh.lazySingleton<_i4.Repository>(
      () => _i4.Repository(get<_i3.ClientService>()));
  gh.singleton<_i5.AddPackageCubit>(_i5.AddPackageCubit(get<_i4.Repository>()));
  gh.singleton<_i6.EditCubit>(_i6.EditCubit(get<_i4.Repository>()));
  gh.singleton<_i7.HistoryCubit>(_i7.HistoryCubit(get<_i4.Repository>()));
  gh.singleton<_i8.PassPackageCubit>(
      _i8.PassPackageCubit(get<_i4.Repository>()));
  return get;
}
