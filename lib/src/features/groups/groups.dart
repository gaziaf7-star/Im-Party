library groups;

export 'package:general/src/core/index.dart';

// domain — entities
export 'package:general/src/features/groups/domain/entities/group_entity.dart';
export 'package:general/src/features/groups/domain/entities/group_member_entity.dart';
export 'package:general/src/features/groups/domain/entities/group_enums.dart';
export 'package:general/src/features/groups/domain/entities/group_permissions.dart';
export 'package:general/src/features/groups/domain/entities/group_params.dart';

// domain — repository + usecases
export 'package:general/src/features/groups/domain/repository/groups_repository.dart';
export 'package:general/src/features/groups/domain/usecases/group_usecases.dart';

// data
export 'package:general/src/features/groups/data/models/group_model.dart';
export 'package:general/src/features/groups/data/models/group_member_model.dart';
export 'package:general/src/features/groups/data/data_source/groups_remote_data_source.dart';
export 'package:general/src/features/groups/data/repository_imp/groups_repository_imp.dart';

// presentation — blocs
export 'package:general/src/features/groups/presentation/groups_list/bloc/groups_list_bloc.dart';
export 'package:general/src/features/groups/presentation/group_detail/bloc/group_detail_bloc.dart';
export 'package:general/src/features/groups/presentation/group_members/bloc/group_members_bloc.dart';
export 'package:general/src/features/groups/presentation/create_group/bloc/create_group_bloc.dart';
export 'package:general/src/features/groups/presentation/join_group/bloc/join_group_bloc.dart';
export 'package:general/src/features/groups/presentation/group_chat/bloc/group_chat_bloc.dart';

// presentation — screens
export 'package:general/src/features/groups/presentation/groups_list/view/groups_list_screen.dart';
export 'package:general/src/features/groups/presentation/create_group/view/create_group_screen.dart';
export 'package:general/src/features/groups/presentation/group_detail/view/group_info_screen.dart';
export 'package:general/src/features/groups/presentation/group_detail/view/group_view_screen.dart';
export 'package:general/src/features/groups/presentation/group_members/view/group_members_screen.dart';
export 'package:general/src/features/groups/presentation/join_group/view/join_group_screen.dart';
export 'package:general/src/features/groups/presentation/group_chat/view/group_chat_screen.dart';
