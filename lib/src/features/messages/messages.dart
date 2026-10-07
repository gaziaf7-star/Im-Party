library messages;

//data
export 'package:general/src/features/messages/data/data_source/base_messages_remote_data_source.dart';
// repository_impl
export 'package:general/src/features/messages/data/repository_imp/repository_imp.dart';

// models
export 'package:general/src/features/messages/data/models/messages_model.dart';
export 'package:general/src/features/messages/data/models/user_chat_model.dart';
export 'package:general/src/features/messages/data/models/converstaion_model.dart';

//domain
// entities
export 'package:general/src/features/messages/domain/entities/user_chat_entity.dart';
export 'package:general/src/features/messages/domain/entities/user_status_entity.dart';
export 'package:general/src/features/messages/domain/entities/conversation_entity.dart';
export 'package:general/src/features/messages/domain/entities/messages_entity.dart';


// repository
export 'package:general/src/features/messages/domain/repository/base_messages_repository.dart';

// usecases
export 'package:general/src/features/messages/domain/usecases/online_user_uc.dart';
export 'package:general/src/features/messages/domain/usecases/close_chat_uc.dart';
export 'package:general/src/features/messages/domain/usecases/fetch_messages_uc.dart';
export 'package:general/src/features/messages/domain/usecases/delete_message_uc.dart';
export 'package:general/src/features/messages/domain/usecases/make_react_uc.dart';

//presentation
//bloc
export 'package:general/src/features/messages/presentation/messages/blocs/user_online/user_online_bloc.dart';
export 'package:general/src/features/messages/presentation/messages/blocs/send_message/send_messages_bloc.dart';
export 'package:general/src/features/messages/presentation/messages/blocs/fetch_messages/fetch_messages_bloc.dart';
export 'package:general/src/features/messages/presentation/messages/blocs/toggle_app_bar/toggle_app_bar_bloc.dart';
export 'package:general/src/features/messages/presentation/messages/blocs/delete_message/delete_message_bloc.dart';
export 'package:general/src/features/messages/presentation/messages/blocs/make_react/make_react_bloc.dart';

//page

//widgets
