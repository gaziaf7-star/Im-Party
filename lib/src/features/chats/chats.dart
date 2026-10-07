library chats;

export 'package:flutter_bloc/flutter_bloc.dart';

//parameters
export 'package:general/src/core/base/parameters.dart';
export 'package:general/src/core/constants/asset_manager.dart';

//constant
export 'package:general/src/core/constants/constants_manager.dart';
export 'package:general/src/core/constants/string_manager.dart';

//shared
export 'package:general/src/core/index.dart';

//data
export 'package:general/src/features/chats/data/data_source/chats_remote_data_source.dart';
export 'package:general/src/features/chats/data/models/delete_chat_model.dart';

//model
export 'package:general/src/features/chats/data/models/user_all_chat_request_model.dart';
export 'package:general/src/features/chats/data/models/user_all_chat_model.dart';
export 'package:general/src/features/chats/data/models/system_chat_model.dart';
export 'package:general/src/features/chats/data/repository_imp/repository_imp.dart';

//entity
export 'package:general/src/features/chats/domain/entities/app_messages_entity.dart';
export 'package:general/src/features/chats/domain/entities/delete_chat_entity.dart';
export 'package:general/src/features/chats/domain/usecases/delete_chat_uc.dart';
export 'package:general/src/features/chats/domain/usecases/fetch_chat_uc.dart';

//usecase
export 'package:general/src/features/chats/domain/usecases/get_system_chat_uc.dart';
export 'package:general/src/features/chats/presentation/chats/bloc/delete_chat_manager/delete_chat_bloc.dart';
export 'package:general/src/features/chats/presentation/chats/bloc/manager_get_users_chat/get_users_chat_bloc.dart';
export 'package:general/src/features/chats/presentation/chats/view/widgets/chat_room_card.dart';

//widgets
export 'package:general/src/features/chats/presentation/chats/view/widgets/chat_upper_tab.dart';
export 'package:general/src/features/chats/presentation/chats/view/widgets/message_icon_type.dart';
export 'package:general/src/features/chats/presentation/chats/view/widgets/seen_widget.dart';
export 'package:general/src/features/chats/presentation/chats/view/widgets/styles.dart';
export 'package:general/src/features/chats/presentation/chats/view/widgets/contact_quick_view.dart';

//bloc
export 'package:general/src/features/chats/presentation/system_official_chat/bloc/system_chat_bloc/system_chat_bloc.dart';
export 'package:general/src/features/chats/presentation/system_official_chat/view/system_messages_screen.dart';
