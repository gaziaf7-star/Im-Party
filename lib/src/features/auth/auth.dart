library auth;

//data
export 'package:general/src/features/auth/data/data_source/base_auth_remote_data_source.dart';
export 'package:general/src/features/auth/data/repository_imp/repository_imp.dart';
// models
export 'package:general/src/features/auth/data/model/apple_model.dart';
export 'package:general/src/features/auth/data/model/google_model.dart';
export 'package:general/src/features/auth/data/model/country_model.dart';
export 'package:general/src/features/auth/data/model/country_category_model.dart';
export 'package:general/src/features/auth/domain/entities/profile_room_entity.dart';
export 'package:general/src/features/auth/data/model/close_effect_model.dart';
export 'package:general/src/features/auth/data/model/family_model.dart';
export 'package:general/src/features/auth/data/model/level_model.dart';
export 'package:general/src/features/auth/data/model/manager_type_model.dart';
export 'package:general/src/features/auth/data/model/my_agency_model.dart';
export 'package:general/src/features/auth/data/model/my_store_model.dart';
export 'package:general/src/features/auth/data/model/now_room_model.dart';
export 'package:general/src/features/auth/data/model/profile_room_model.dart';
export 'package:general/src/features/auth/data/model/vip_model.dart';
export 'package:general/src/features/auth/data/model/my_data_model.dart';
export 'package:general/src/features/auth/data/model/user_model.dart';
export 'package:general/src/features/auth/data/model/chat_settings_model.dart';
export 'package:general/src/features/auth/data/model/multi_images_model.dart';
export 'package:general/src/features/auth/data/model/statistic_model.dart';
export 'package:general/src/features/auth/data/model/huawei_model.dart';
//domain
// entities
export 'package:general/src/features/auth/domain/entities/country_entity.dart';
export 'package:general/src/features/auth/domain/entities/country_category_entity.dart';
export 'package:general/src/features/auth/domain/entities/level_entity.dart';
export 'package:general/src/features/auth/domain/entities/family_entity.dart';
export 'package:general/src/features/auth/domain/entities/vip_entity.dart';
export 'package:general/src/features/auth/domain/entities/my_agency_entity.dart';
export 'package:general/src/features/auth/domain/entities/my_store_entity.dart';
export 'package:general/src/features/auth/domain/entities/now_room_entity.dart';
export 'package:general/src/features/auth/domain/entities/close_effect_entity.dart';
export 'package:general/src/features/auth/domain/entities/manager_type_entity.dart';
export 'package:general/src/features/auth/domain/entities/my_data_entity.dart';
export 'package:general/src/features/auth/domain/entities/apple_entity.dart';
export 'package:general/src/features/auth/domain/entities/google_entity.dart';
export 'package:general/src/features/auth/domain/entities/chat_settings_entity.dart';
export 'package:general/src/features/auth/domain/entities/statistic_entity.dart';
export 'package:general/src/features/auth/domain/entities/multi_images_entity.dart';
export 'package:general/src/features/auth/domain/entities/user_entity.dart';
export 'package:general/src/features/auth/domain/entities/huawei_entity.dart';

// repository
export 'package:general/src/features/auth/domain/repository/base_auth_repository.dart';
// usecases
export 'package:general/src/features/auth/domain/use_cases/google_sign_in_uc.dart';
export 'package:general/src/features/auth/domain/use_cases/sign_with_apple_uc.dart';
export 'package:general/src/features/auth/domain/use_cases/fetch_countries_uc.dart';
export 'package:general/src/features/auth/domain/use_cases/fetch_country_categories_uc.dart';
export 'package:general/src/features/auth/domain/use_cases/fetch_countries_by_category_uc.dart';
export 'package:general/src/features/auth/domain/use_cases/add_info_uc.dart';
export 'package:general/src/features/auth/domain/use_cases/login_uc.dart';
export 'package:general/src/features/auth/domain/use_cases/guest_login_uc.dart';
export 'package:general/src/features/auth/domain/use_cases/forget_password_uc.dart';
export 'package:general/src/features/auth/domain/use_cases/register_uc.dart';
export 'package:general/src/features/auth/domain/use_cases/get_firebase_custom_token_uc.dart';
export 'package:general/src/features/auth/domain/use_cases/sign_with_huawei_uc.dart';

//presentation
//bloc
export 'package:general/src/features/auth/presentation/login/bloc/login_bloc.dart';
export 'package:general/src/features/auth/presentation/register/bloc/register_bloc.dart';
export 'package:general/src/features/auth/presentation/add_information/bloc/add_information_bloc.dart';
export 'package:general/src/features/auth/presentation/country/bloc/countries_bloc.dart';
export 'package:general/src/features/auth/presentation/splash/bloc/splash_bloc.dart';
export 'package:general/src/features/auth/presentation/otp/bloc/otp_bloc.dart';
export 'package:general/src/features/auth/presentation/global/send_code/send_code_bloc.dart';
export 'package:general/src/features/auth/presentation/recover_password_auth/bloc/recover_password_bloc.dart';
export 'package:general/src/features/auth/presentation/splash/firebase_custom_token_bloc/firebase_custom_token_bloc.dart';

//page
export 'package:general/src/features/auth/presentation/login/view/login_page.dart';
export 'package:general/src/features/auth/presentation/splash/view/splash_page.dart';
export 'package:general/src/features/auth/presentation/register/view/register_page.dart';
export 'package:general/src/features/auth/presentation/add_information/view/add_information_page.dart';
export 'package:general/src/features/auth/presentation/otp/view/otp_page.dart';
export 'package:general/src/features/auth/presentation/recover_password_auth/view/recover_password_page.dart';
export 'package:general/src/features/auth/presentation/recover_password_auth/view/new_password_page.dart';

//widgets
export 'package:general/src/core/widgets/date_picker_widget.dart';
export 'package:country_picker/country_picker.dart';
