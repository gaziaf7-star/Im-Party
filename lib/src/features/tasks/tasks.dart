library tasks;

//data
export 'package:general/src/features/tasks/data/tasks_remotely_data_source/tasks_remotely_data_source.dart';
export 'package:general/src/features/tasks/data/tasks_repository_imp/tasks_repository_imp.dart';

//model
export 'package:general/src/features/tasks/data/models/task_models.dart';

//domain
export 'package:general/src/features/tasks/domain/tasks_base_repository/tasks_base_repository.dart';

//use case
export 'package:general/src/features/tasks/domain/tasks_use_case/get_tasks_progress_uc.dart';
export 'package:general/src/features/tasks/domain/tasks_use_case/collect_task_points_uc.dart';

//bloc
export 'package:general/src/features/tasks/presentation/bloc/tasks_bloc.dart';

//view
export 'package:general/src/features/tasks/presentation/view/tasks_page.dart';
