import 'package:general/reels_viewer/bloc/reels_viewer_bloc.dart';
import 'package:general/reels_viewer/src/share/bloc/share_reel_bloc.dart';
import 'package:general/src/features/profile/domain/profile_use_case/get_my_level_data_uc.dart';
import 'package:general/src/features/profile/presentation/profile/bloc/bloc_my_level/get_my_level_bloc.dart';
import 'package:general/src/features/room/presentation/gifts/bloc/banners_bloc/banners_bloc.dart';
import 'package:general/src/features/live_room/presentation/component/gifts/bloc/live_send_gift_bloc.dart';
import 'package:general/src/features/room/presentation/manager/room_mode/room_mode_cubit.dart';
import 'package:general/src/features/room/presentation/share/bloc/share_room_bloc.dart';
import 'package:general/src/features/agency/agency.dart';
import 'package:general/src/features/agency/domain/use_case/fetch_form_uc.dart';
import 'package:general/src/features/agency/domain/use_case/fetch_more_info_agency.dart';
import 'package:general/src/features/agency/domain/use_case/get_old_agencies.dart';
import 'package:general/src/features/agency/domain/use_case/hosts_agency_dollars_records_uc.dart';
import 'package:general/src/features/agency/domain/use_case/search_user_agency_uc.dart';
import 'package:general/src/features/agency/domain/use_case/update_host_agency_data_uc.dart';
import 'package:general/src/features/agency/presentation/host_agency/bloc/agency_memeber_charges_history/agency_memeber_charges_history_bloc.dart';
import 'package:general/src/features/agency/presentation/host_agency/bloc/fetch_agency_admins/fetch_agency_admins_bloc.dart';
import 'package:general/src/features/agency/presentation/host_agency/bloc/fetch_agency_heros/fetch_agency_heros_bloc.dart';
import 'package:general/src/features/agency/presentation/host_agency/bloc/fetch_agency_stars/fetch_agency_stars_bloc.dart';
import 'package:general/src/features/agency/presentation/host_agency/bloc/fetch_more_info_agency/fetch_more_info_agency_bloc.dart';
import 'package:general/src/features/agency/presentation/host_agency/bloc/get_old_agencies/get_old_agencies_bloc.dart';
import 'package:general/src/features/agency/presentation/host_agency/bloc/hosts_agency_dollars_records/hosts_agency_dollars_records_bloc.dart';
import 'package:general/src/features/agency/presentation/host_agency/bloc/update_host_agency_data/update_host_agency_data_bloc.dart';
import 'package:general/src/features/auth/auth.dart';
import 'package:general/src/features/auth/domain/use_cases/change_phone_us.dart';
import 'package:general/src/features/auth/domain/use_cases/check_phone.dart';
import 'package:general/src/features/auth/domain/use_cases/config_app_uc.dart';
import 'package:general/src/features/auth/domain/use_cases/forget_password_setting_uc.dart';
import 'package:general/src/features/auth/domain/use_cases/get_agency_badges_uc.dart';
import 'package:general/src/features/auth/domain/use_cases/get_vip_frames_uc.dart';
import 'package:general/src/features/auth/domain/use_cases/get_wabbles_uc.dart';
import 'package:general/src/features/auth/domain/use_cases/replace_cover_image_us.dart';
import 'package:general/src/features/auth/presentation/auth_platform/bloc/auth_platform_bloc.dart';
import 'package:general/src/features/auth/presentation/change_phone/bloc/change_number_bloc.dart';
import 'package:general/src/features/auth/presentation/forget_password_setting/reset_password/reset_password_bloc.dart';
import 'package:general/src/features/auth/presentation/splash/config_app/config_app_bloc.dart';
import 'package:general/src/features/auth/presentation/splash/get_agency_badges_bloc/get_agency_badges_bloc.dart';
import 'package:general/src/features/auth/presentation/splash/get_vip_frames_bloc/get_vip_frames_bloc.dart';
import 'package:general/src/features/auth/presentation/splash/get_wabbles_bloc/get_wabbles_bloc.dart';
import 'package:general/src/features/auth/presentation/terms_and_condition/bloc/privacy_policy_bloc.dart';
import 'package:general/src/features/chats/chats.dart';
import 'package:general/src/features/chats/domain/repository/chats_repository.dart';
import 'package:general/src/features/groups/groups.dart' hide GroupChatBloc;
import 'package:general/src/features/groups/presentation/group_chat/bloc/group_chat_bloc.dart'
as groupchat;
import 'package:general/src/features/chats/domain/usecases/fetch_chat_request_uc.dart';
import 'package:general/src/features/chats/presentation/chat_request/bloc/get_users_chat_request/chat_request_bloc.dart';
import 'package:general/src/features/cp/cp.dart';
import 'package:general/src/features/tasks/tasks.dart';
import 'package:general/src/features/home/domain/use_cases/fetch_host_levels_uc.dart';
import 'package:general/src/features/home/domain/use_cases/pick_box_uc.dart';
import 'package:general/src/features/profile/domain/profile_use_case/change_country_uc.dart';
import 'package:general/src/features/room/domain/use_case/fetch_emojis_category_uc.dart';
import 'package:general/src/features/room/domain/use_case/fetch_gift_category_uc.dart';
import 'package:general/src/features/room/domain/use_case/fetch_users_data_uc.dart';
import 'package:general/src/features/room/domain/use_case/fetch_bad_words_uc.dart';
import 'package:general/src/features/room/presentation/gifts/bloc/lucky_gift_win_bloc/lucky_gift_win_bloc.dart';
import 'package:general/src/features/cp/data/cp_repository_imp/cp_repository_imp.dart';
import 'package:general/src/features/cp/domain/cp_use_case/fetch_ranking_cp_uc.dart';
import 'package:general/src/features/cp/presentation/cp_rank/bloc/cp_bloc.dart';
import 'package:general/src/features/cp/presentation/cp_store/bloc/cp_relations/cp_relations_bloc.dart';
import 'package:general/src/features/cp/presentation/cp_store/bloc/cp_request_bloc/cp_request_bloc.dart';
import 'package:general/src/features/family/family.dart';
import 'package:general/src/features/family/presentation/manger_family/bloc/manager_family_bloc.dart';
import 'package:general/src/features/games/data/repository_imp/repository_imp.dart';
import 'package:general/src/features/games/domain/use_cases/fetch_online_users_uc.dart';
import 'package:general/src/features/games/domain/use_cases/fetch_users_gamers_uc.dart';
import 'package:general/src/features/games/domain/use_cases/stop_gamers_uc.dart';
import 'package:general/src/features/games/games.dart';
import 'package:general/src/features/games/presentation/games/bloc/action/action_bloc.dart';
import 'package:general/src/features/games/presentation/meet/bloc/online_users/online_users_bloc.dart';
import 'package:general/src/features/games/presentation/meet/get_users_profile/get_user_profile_bloc.dart';
import 'package:general/src/features/home/domain/home_use_case/daily_prizes_use_case.dart';
import 'package:general/src/features/home/domain/home_use_case/get_carousel_uc.dart';
import 'package:general/src/features/home/domain/home_use_case/open_daily_prizes_use_case.dart';
import 'package:general/src/features/home/domain/home_use_case/search_use_case.dart';
import 'package:general/src/features/home/domain/use_cases/fetch_live_rooms_uc.dart';
import 'package:general/src/features/home/domain/use_cases/fetch_my_room_data_uc.dart';
import 'package:general/src/features/home/domain/use_cases/fetch_top_user_image_rank_uc.dart';
import 'package:general/src/features/home/home.dart';
import 'package:general/src/features/home/presentation/home/bloc/fetch_my_room_data_manager/fetch_my_room_data_bloc.dart';
import 'package:general/src/features/home/presentation/home/bloc/fetch_top_ranking_manager/fetch_top_ranking_bloc.dart';
import 'package:general/src/features/home/presentation/home/bloc/get_carousel_manager/get_carousel_bloc.dart';
import 'package:general/src/features/home/presentation/search_screen/bloc/search_manager/search_bloc.dart';
import 'package:general/src/features/mall_bag/mall_bag.dart';
import 'package:general/src/features/messages/domain/usecases/upload_video_message_use_case.dart';
import 'package:general/src/features/messages/messages.dart';
import 'package:general/src/features/messages/presentation/messages/blocs/send_message_all/send_message_all_bloc.dart';
import 'package:general/src/features/moment/domain/usecases/fetch_moment_gift_use_case.dart';
import 'package:general/src/features/moment/domain/usecases/report_moment_uc.dart';
import 'package:general/src/features/moment/domain/usecases/send_gift_moment_us.dart';
import 'package:general/src/features/moment/moment.dart';
import 'package:general/src/features/moment/presentation/bloc/moment_gift_bloc/moment_gift_bloc.dart';
import 'package:general/src/features/moment/presentation/bloc/moment_likes_bloc/moment_likes_bloc_bloc.dart';
import 'package:general/src/features/moment/presentation/bloc/send_moment_gift_bloc/send_moment_gift_bloc.dart';
import 'package:general/src/features/payment/data/remotely_data_source/payment_remotely_data_source.dart';
import 'package:general/src/features/payment/data/repository_imp/payment_repository_imp.dart';
import 'package:general/src/features/payment/domain/base_repo/payment_base_repo.dart';
import 'package:general/src/features/payment/domain/use_case/buy_coins_use_case.dart';
import 'package:general/src/features/payment/domain/use_case/get_coins_use_case.dart';
import 'package:general/src/features/payment/domain/use_case/google_pay_use_case.dart';
import 'package:general/src/features/payment/presentation/bloc/buy_coins_bloc/buy_coins_bloc.dart';
import 'package:general/src/features/payment/presentation/bloc/fetch_coins/fetch_coins_bloc.dart';
import 'package:general/src/features/payment/presentation/bloc/goole_pay_bloc/goole_pay_bloc.dart';
import 'package:general/src/features/payment/presentation/view/in_app_purchases.dart';
import 'package:general/src/features/profile/domain/profile_use_case/follow_unfollow_use_case.dart';
import 'package:general/src/features/profile/domain/profile_use_case/get_badges_use_case.dart';
import 'package:general/src/features/profile/domain/profile_use_case/get_friends_or_followers_use_case.dart';
import 'package:general/src/features/profile/domain/profile_use_case/get_gold_coin_prices_use_case.dart';
import 'package:general/src/features/profile/domain/profile_use_case/get_my_all_badge.dart';
import 'package:general/src/features/profile/domain/profile_use_case/get_my_data_use_case.dart';
import 'package:general/src/features/profile/domain/profile_use_case/get_user_data_use_case.dart';
import 'package:general/src/features/profile/domain/profile_use_case/get_user_intro_use_case.dart';
import 'package:general/src/features/profile/domain/profile_use_case/get_user_rooms_uc.dart';
import 'package:general/src/features/profile/domain/profile_use_case/get_user_supporter_user_case.dart';
import 'package:general/src/features/profile/domain/profile_use_case/get_vistors_usecase.dart';
import 'package:general/src/features/profile/domain/profile_use_case/my_store_use_case.dart';
import 'package:general/src/features/profile/domain/profile_use_case/pick_my_badges_uc.dart';
import 'package:general/src/features/profile/domain/profile_use_case/user_badges_use_case.dart';
import 'package:general/src/features/profile/domain/profile_use_case/user_levels_uc.dart';
import 'package:general/src/features/profile/presentation/coins/bloc/my_store_bloc/my_store_bloc.dart';
import 'package:general/src/features/profile/presentation/f_f_f_v/bloc/bloc_get_f_f_f/get_follower_or_following_bloc.dart';
import 'package:general/src/features/profile/presentation/f_f_f_v/bloc/bloc_make_follow_unfollow/follow_bloc.dart';
import 'package:general/src/features/profile/presentation/levels/bloc/levels_bloc/levels_bloc.dart';
import 'package:general/src/features/profile/presentation/medals/bloc/badge_bloc/badges_bloc.dart';
import 'package:general/src/features/profile/presentation/medals/bloc/pick_badge_bloc/pick_my_badges_bloc.dart';
import 'package:general/src/features/profile/presentation/medals/bloc/select_badge_bloc/select_badge_bloc.dart';
import 'package:general/src/features/profile/presentation/profile/bloc/bloc_badge/user_badges_bloc.dart';
import 'package:general/src/features/profile/presentation/profile/bloc/bloc_user_badges/get_user_badges_bloc.dart';
import 'package:general/src/features/profile/presentation/profile/view/page/user_profile/bloc/add_or_delete_block/add_or_delete_block_bloc.dart';
import 'package:general/src/features/profile/presentation/profile/view/page/user_profile/bloc/feed_back/feed_back_bloc.dart';
import 'package:general/src/features/profile/presentation/profile/view/page/user_profile/bloc/get_user_intro_bloc/get_user_intro_bloc.dart';
import 'package:general/src/features/profile/presentation/profile/view/page/user_profile/bloc/get_user_rooms/get_user_rooms_bloc.dart';
import 'package:general/src/features/profile/presentation/profile/view/page/user_profile/bloc/get_user_support/get_user_support_bloc.dart';
import 'package:general/src/features/profile/presentation/profile/view/page/user_profile/bloc/gift_history_bloc/gift_history_bloc.dart';
import 'package:general/src/features/profile/presentation/profile/view/page/user_profile/bloc/user_report_bloc/user_report_bloc.dart';
import 'package:general/src/features/profile/profile.dart';
import 'package:general/src/features/reels/data/data_source/reels_data_source.dart';
import 'package:general/src/features/reels/data/repo_imp/reels_repo_imp.dart';
import 'package:general/src/features/reels/domain/base_repo/reels_base_repo.dart';
import 'package:general/src/features/reels/domain/use_case/delete_reel_use_case.dart';
import 'package:general/src/features/reels/domain/use_case/get_comments_use_case.dart';
import 'package:general/src/features/reels/domain/use_case/get_following_reels_use_case.dart';
import 'package:general/src/features/reels/domain/use_case/get_my_reels_use_case.dart';
import 'package:general/src/features/reels/domain/use_case/get_reels_use_case.dart';
import 'package:general/src/features/reels/domain/use_case/make_comments_use_case.dart';
import 'package:general/src/features/reels/domain/use_case/make_like_use_case.dart';
import 'package:general/src/features/reels/domain/use_case/update_reel_description_use_case.dart';
import 'package:general/src/features/reels/domain/use_case/upload_reel_use_case.dart';
import 'package:general/src/features/reels/presentation/main_reels_page/bloc/get_comments/get_comments_bloc.dart';
import 'package:general/src/features/reels/presentation/main_reels_page/bloc/get_following_reels/get_following_reels_bloc.dart';
import 'package:general/src/features/reels/presentation/main_reels_page/bloc/get_reels/get_reels_bloc.dart';
import 'package:general/src/features/reels/presentation/main_reels_page/bloc/make_comments/make_comments_bloc.dart';
import 'package:general/src/features/reels/presentation/main_reels_page/bloc/make_like/make_like_bloc.dart';
import 'package:general/src/features/reels/presentation/main_reels_page/bloc/upload_reel/upload_reel_bloc.dart';
import 'package:general/src/features/room/data/repository_imp/room_repository_imp.dart';
import 'package:general/src/features/room/domain/use_case/add_room_background_uc.dart';
import 'package:general/src/features/room/domain/use_case/block_comments_uc.dart';
import 'package:general/src/features/room/domain/use_case/create_paid_room_us.dart';
import 'package:general/src/features/room/domain/use_case/delete_song.dart';
import 'package:general/src/features/room/domain/use_case/extra_profile_data_uc.dart';
import 'package:general/src/features/room/domain/use_case/fetch_games_images.dart';

import 'package:general/src/features/room/domain/use_case/get_charisma_extra_data_uc.dart';
import 'package:general/src/features/room/domain/use_case/get_charisma_levels_uc.dart';
import 'package:general/src/features/room/domain/use_case/get_free_games_images_uc.dart';
import 'package:general/src/features/room/domain/use_case/get_music_uc.dart';
import 'package:general/src/features/room/domain/use_case/get_my_background_setting_uc.dart';
import 'package:general/src/features/room/domain/use_case/get_my_music_uc.dart';
import 'package:general/src/features/room/domain/use_case/get_mybackground_uc.dart';
import 'package:general/src/features/room/domain/use_case/get_room_activity_data.dart';
import 'package:general/src/features/room/domain/use_case/get_room_activity_web_view_link_uc.dart';
import 'package:general/src/features/room/domain/use_case/get_super_boom_rules_uc.dart';
import 'package:general/src/features/room/domain/use_case/get_super_boom_videos_uc.dart';

import 'package:general/src/features/room/domain/use_case/lock_comments_uc.dart';
import 'package:general/src/features/room/domain/use_case/open_game_uc.dart';
import 'package:general/src/features/room/domain/use_case/send_yallow_banner_uc.dart';
import 'package:general/src/features/room/domain/use_case/start_charisma_uc.dart';
import 'package:general/src/features/room/domain/use_case/reset_charisma_uc.dart';
import 'package:general/src/features/room/domain/use_case/upload_song_use_case.dart';
import 'package:general/src/features/room/presentation/charisma/bloc/charisma_bloc.dart';
import 'package:general/src/features/room/presentation/component/games/paid_games/games_images_bloc.dart';
import 'package:general/src/features/room/presentation/component/messages/bloc/bubble_padding/get_bubble_padding_bloc.dart';
import 'package:general/src/features/room/presentation/component/messages/bloc/get_free_games_images/get_free_games_images_bloc.dart';
import 'package:general/src/features/room/presentation/component/pk/counter_time_pk_widget.dart';
import 'package:general/src/features/room/presentation/component/profile/bloc/extra_data_profile_bloc.dart';
import 'package:general/src/features/room/presentation/component/room_header/room_activity/bloc/get_room_activity_data_bloc.dart';
import 'package:general/src/features/room/presentation/gifts/bloc/fetch_gift_bloc/fetch_gift_bloc.dart';
import 'package:general/src/features/room/presentation/gifts/bloc/gift_bloc/gift_bloc.dart';
import 'package:general/src/features/room/presentation/gifts/bloc/send_gift_bloc/send_gift_bloc.dart';
import 'package:general/src/features/room/presentation/lucky_box/widgets/dialog_lucky_box.dart';
import 'package:general/src/features/room/presentation/manager/alpha_gift_manager/alpha_gift_manager_bloc.dart';
import 'package:general/src/features/room/presentation/manager/clear_mode_manager/clear_mode_bloc.dart';
import 'package:general/src/features/room/presentation/manager/emojie_manager/emojie_bloc.dart';

import 'package:general/src/features/room/presentation/manager/host_timer_manager/host_timer_bloc.dart';

import 'package:general/src/features/room/presentation/manager/manager_get_config_key/get_config_keys_bloc.dart';
import 'package:general/src/features/room/presentation/manager/manager_pk/pk_bloc.dart';
import 'package:general/src/features/room/presentation/manager/open_game_manager/open_game_bloc.dart';
import 'package:general/src/features/room/presentation/music/bloc/music_room_bloc.dart';
import 'package:general/src/features/room/presentation/room_comments/block_comments_bloc/block_comments_bloc.dart';
import 'package:general/src/features/room/presentation/super_bomb/bloc/get_super_bombs_bloc/get_super_bombs_bloc.dart';
import 'package:general/src/features/room/presentation/super_bomb/bloc/get_super_bombs_theme_bloc/get_super_bombs_theme_bloc.dart';
import 'package:general/src/features/room/presentation/theme/bloc/manager_add_room_backGround/add_room_background_bloc.dart';
import 'package:general/src/features/room/presentation/theme/bloc/manger_get_my_background/get_my_background_bloc.dart';
import 'package:general/src/features/room/presentation/theme/bloc/manger_get_my_background_setting/get_my_background_setting_bloc.dart';
import 'package:general/src/features/room/presentation/youtube/bloc/get_youtube_videos/get_youtube_videos_bloc.dart';
import 'package:general/src/features/room/presentation/youtube/bloc/youtube/youtube_bloc.dart';
import 'package:general/src/features/room/room.dart';
import 'package:general/src/features/room/presentation/music/server_bloc/delete_song/delete_song_bloc.dart';
import 'package:general/src/features/room/presentation/music/server_bloc/upload_song/upload_song_bloc.dart';
import 'package:general/src/features/setting/data/data_source/remote_data_source.dart';
import 'package:general/src/features/setting/data/repo_imp/settings_repo_imp.dart';
import 'package:general/src/features/setting/domain/base_repo/settings_base_repository.dart';
import 'package:general/src/features/setting/domain/use_case/add_invitation_code.dart';
import 'package:general/src/features/setting/domain/use_case/claim_invite_bonus_us.dart';
import 'package:general/src/features/setting/domain/use_case/delete_account_uc.dart';
import 'package:general/src/features/setting/domain/use_case/explain_invitation_us.dart';
import 'package:general/src/features/setting/domain/use_case/extract_invite_coins_us.dart';
import 'package:general/src/features/setting/domain/use_case/get_block_list_usecase.dart';
import 'package:general/src/features/setting/domain/use_case/get_invite_user_us.dart';
import 'package:general/src/features/setting/domain/use_case/get_my_earn_invite.dart';
import 'package:general/src/features/setting/domain/use_case/privacy_policy_uc.dart';
import 'package:general/src/features/setting/domain/use_case/send_invitation_code_us.dart';
import 'package:general/src/features/setting/presentation/account_setting/bind_number/bind_number_bloc.dart';
import 'package:general/src/features/setting/presentation/bloc_list/bloc/block_list_bloc.dart';
import 'package:general/src/features/setting/presentation/delete_account/bloc/delete_account_bloc.dart';
import 'package:general/src/features/setting/presentation/invitation/bloc/invite_bloc.dart';
import 'package:general/src/features/setting/setting.dart';
import 'package:general/src/features/vip/data/vip_repository_imp/vip_repository_imp.dart';
import 'package:general/src/features/vip/domain/use_case/buy_vip_use_case.dart';
import 'package:general/src/features/vip/domain/use_case/get_vip_center_use_case.dart';
import 'package:general/src/features/vip/domain/use_case/send_vip_uc.dart';
import 'package:general/src/features/vip/domain/use_case/use_vip.dart';
import 'package:general/src/features/vip/vip.dart';
import 'package:general/src/core/database/app_database.dart';
import 'package:general/src/core/database/daos/rooms_dao.dart';
import 'package:general/src/core/database/daos/messages_dao.dart';
import 'package:general/src/core/database/daos/outbox_dao.dart';
import 'package:general/src/core/database/daos/media_uploads_dao.dart';
import 'package:general/src/core/database/daos/sync_state_dao.dart';
import 'package:general/src/core/realtime/realtime_http.dart';
import 'package:general/src/core/services/bootstrap_service.dart';
import 'package:general/src/core/realtime/dio_realtime_http.dart';
import 'package:general/src/core/realtime/realtime_token_service.dart';
import 'package:general/src/core/realtime/realtime_client.dart';
import 'package:general/src/core/realtime/sync_engine.dart';
import 'package:general/src/core/realtime/outbox_worker.dart';
import 'package:general/src/core/realtime/media_upload_worker.dart';
import 'package:general/src/core/realtime/chat_repository.dart';
import 'package:general/src/core/realtime/in_app_chat_notifier.dart';
import 'package:general/src/features/chats/data/contact_discovery_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/agency/presentation/host_agency/bloc/search_manager/search_user_agency_bloc.dart';
import '../../features/auth/domain/use_cases/fetch_colors_uc.dart';
import '../../features/auth/domain/use_cases/realtime_settings_uc.dart';
import '../../features/auth/presentation/splash/colors_bloc/colors_bloc.dart';
import '../../features/auth/presentation/splash/realtime_settings_bloc/realtime_settings_bloc.dart';
import '../../features/family/domain/use_case/get_all_family_use_case.dart';
import '../../features/family/presentation/family_rank/bloc/get_all_family/get_all_family_bloc.dart';
import '../../features/home/domain/home_use_case/get_banner_usecase.dart';
import '../../features/home/presentation/banner/banner_bloc/banner_bloc.dart';
import '../../features/mall_bag/domain/mall_bag_use_case/send_from_bag_use_case.dart';
import '../../features/mall_bag/domain/mall_bag_use_case/send_from_mall_use_case.dart';
import '../../features/mall_bag/presentation/bag/bloc/bag_send_bloc/bag_send_bloc.dart';
import '../../features/mall_bag/presentation/mall/bloc/mall_send_bloc/mall_send_bloc.dart';
import '../../features/messages/domain/usecases/send_message_all_uc.dart';
import '../../features/messages/presentation/messages/blocs/text_field_bloc/text_field__bloc.dart';
import '../../features/moment/domain/usecases/get_moment_likes_uc.dart';
import '../../features/payment/domain/use_case/redirect_link_use_case.dart';
import '../../features/profile/domain/profile_use_case/coin_seller_use_cases.dart';
import '../../features/profile/domain/profile_use_case/get_exchange_logs_uc.dart';
import '../../features/profile/domain/profile_use_case/get_exchange_settings_uc.dart';
import '../../features/profile/domain/profile_use_case/levels_badges_uc.dart';
import '../../features/profile/domain/profile_use_case/make_exchange_v2_uc.dart';
import '../../features/profile/domain/profile_use_case/make_wallet_withdraw_uc.dart';
import '../../features/profile/domain/profile_use_case/wallet_withdraw_use_cases.dart';
import '../../features/profile/domain/profile_use_case/room_level_badges_uc.dart';
import '../../features/profile/presentation/coin_seller/bloc/coin_seller_bloc.dart';
import '../../features/profile/presentation/exchange_diamond/bloc/exchange_v2_bloc/exchange_v2_bloc.dart';
import '../../features/profile/presentation/wallet_withdraw/bloc/wallet_withdraw_bloc.dart';
import '../../features/room/domain/use_case/check_admin_owner_uc.dart';
import '../../features/room/domain/use_case/get_bubble_pading_uc.dart';
import '../../features/room/domain/use_case/get_super_bomb_uc.dart';
import '../../features/room/presentation/manager/check_admin_owner_manager/check_admin_owner_bloc.dart';
import '../../features/vip/domain/use_case/get_vip_user_bag_uc.dart';
import '../../features/vip/domain/use_case/get_vip_theme_settings_uc.dart';

final di = GetIt.instance;

class DependencyInjectionService {
  static final Set<String> _initialized = {};

  /// Resets both the GetIt container and the initialization tracking set, then
  /// re-registers everything before returning. Re-registration is folded in so
  /// the container is never observable as empty across an `await` boundary: a
  /// still-mounted widget rebuilding mid-reset (logout / switch / delete) must
  /// not hit `di<...>` on a cleared container ("X is not registered").
  static Future<void> reset() async {
    await _stopRealtime();
    await _wipeChatCache();
    // Warm the only async prerequisites of initCore *before* tearing down the
    // old container, so SharedPreferences + deviceId are already cached. The
    // clear + full re-registration below then runs without an intervening
    // `await`, leaving no window where a rebuilding widget sees an empty
    // container ("ConfigAppBloc / GetSystemChatBloc is not registered").
    await SharedPreferences.getInstance();
    await DioFactory.initDeviceId();
    _initialized.clear();
    await di.reset();
    await init();
  }

  /// Tear down the realtime/offline-first workers (Phase 7 part B) before a
  /// container reset (logout / switch account) so their timers + WebSocket are
  /// released and don't leak across sessions. Guarded + best-effort: a never-
  /// registered or already-disposed worker must not break logout.
  static Future<void> _stopRealtime() async {
    try {
      if (di.isRegistered<OutboxWorker>()) di<OutboxWorker>().stop();
      if (di.isRegistered<MediaUploadWorker>()) di<MediaUploadWorker>().stop();
      if (di.isRegistered<RealtimeClient>()) await di<RealtimeClient>().stop();
      // Reset the in-app chat notifier's per-session dedup + active markers so
      // the next signed-in account doesn't inherit the previous session's
      // last-notified high-water marks (singleton, survives di.reset()).
      InAppChatNotifier.instance.reset();
    } catch (_) {
      // Never let realtime teardown block logout.
    }
  }

  /// Wipes the local chat cache before the container is torn down on any
  /// identity change (login / logout / switch / delete account). The drift DB is
  /// a single shared on-disk file with no per-user scoping, so without this the
  /// next signed-in account would read the previous account's cached
  /// conversations (cross-account leak). Runs while [AppDatabase] is still
  /// registered (before `di.reset()` closes it) and is best-effort so a wipe
  /// failure never blocks logout/switch.
  static Future<void> _wipeChatCache() async {
    try {
      if (di.isRegistered<AppDatabase>()) {
        await di<AppDatabase>().wipeChatData();
      }
    } catch (_) {
      // Never let cache teardown block the identity change.
    }
  }

  /// Registers everything (backward-compatible).
  ///
  /// C16: only [initCore] is async (it resolves SharedPreferences + deviceId).
  /// Every feature module below is SYNCHRONOUS and runs in the SAME microtask
  /// immediately after initCore resumes, with NO `await` between them — so once
  /// the single await boundary clears, the whole container (auth..reels, incl.
  /// chat) registers ATOMICALLY before control returns to the event loop. There
  /// is therefore no window where a rebuilding widget can observe the container
  /// as PARTIALLY registered (e.g. di<ChatRepository> present but
  /// di<GetSystemChatBloc> not yet) — the "Bad state: not registered" race.
  /// DO NOT insert an `await` between these calls: that would re-open the gap.
  static Future<void> init() async {
    await initCore();
    initAuth();
    initHome();
    initProfile();
    initChat();
    initGroups();
    initRoom();
    initAgency();
    initFamily();
    initMoment();
    initPayment();
    initSettings();
    initVip();
    initGames();
    initCp();
    initMallBag();
    initReels();
    initTasks();
  }

  /// Core infrastructure: shared services, ALL data sources, ALL repositories.
  static Future<void> initCore() async {
    if (_initialized.contains('core')) return;
    _initialized.add('core');

    // A reset() overlapping a re-init (logout/switch-account races) could
    // re-register a type that survived the half-cleared container — GetIt
    // then throws 'Type X is already registered' (Crashlytics: DioFactory,
    // 3 users). Reassignment makes the late registration win silently.
    di.allowReassignment = true;

    // Resolve async prerequisites up front so every registration below — and in
    // the synchronous init* modules called after initCore — runs without an
    // `await` gap. This keeps the container from being observable as partially
    // registered while a still-mounted widget rebuilds during a reset.
    final preferences = await SharedPreferences.getInstance();
    await DioFactory.initDeviceId();

    // Shared services
    di.registerLazySingleton<Methods>(() => Methods());
    di.registerLazySingleton<RoomStateManager>(() => RoomStateManager());
    di.registerLazySingleton(() => preferences);
    di.registerLazySingleton<DioFactory>(() => DioFactory());
    di.registerLazySingleton<Dio>(
          () => DioFactory.createDownloadDio(),
      instanceName: 'downloadDio',
    );
    // Single cold-start aggregate fetcher (/bootstrap → my_data + my_store +
    // app_setting in one round-trip). Additive: see BootstrapService docs.
    di.registerLazySingleton<BootstrapService>(
          () => BootstrapService(di<DioFactory>()),
    );
    di.registerLazySingleton<LayoutBloc>(() => LayoutBloc());
    di.registerLazySingleton<LanguageBloc>(() => LanguageBloc(HiveManager()));
    di.registerLazySingleton(() => TimeData());

    // Local chat database (drift/SQLite) + DAOs — single source of truth.
    // The dispose closes the native SQLite connection when the container is torn
    // down via DependencyInjectionService.reset() (login / logout / switch /
    // delete account). Without it, di.reset() only drops the GetIt reference: the
    // old connection stays open and the next login constructs a *second*
    // AppDatabase on the same file -> drift "created multiple times" warning and
    // the race/corruption risk it describes.
    di.registerLazySingleton<AppDatabase>(
          () => AppDatabase(),
      dispose: (db) => db.close(),
    );
    di.registerLazySingleton<RoomsDao>(() => di<AppDatabase>().roomsDao);
    di.registerLazySingleton<MessagesDao>(() => di<AppDatabase>().messagesDao);
    di.registerLazySingleton<OutboxDao>(() => di<AppDatabase>().outboxDao);
    di.registerLazySingleton<MediaUploadsDao>(
            () => di<AppDatabase>().mediaUploadsDao);
    di.registerLazySingleton<SyncStateDao>(
            () => di<AppDatabase>().syncStateDao);

    // Data sources
    di.registerLazySingleton<BaseAuthenticationRemoteDataSource>(
          () => AuthenticationRemoteDataSourceImp(dio: di<DioFactory>()),
    );
    di.registerLazySingleton<BaseMessagesRemoteDataSource>(
          () => MessagesRemoteDataSourceImp(di()),
    );
    di.registerLazySingleton<BaseMallMyBagRemoteDataSource>(
          () => MallMyBagRemoteDataSourceImp(di<DioFactory>()),
    );
    di.registerLazySingleton<BaseGamesRemoteDataSource>(
          () => GamesRemoteDataSoursImp(di<DioFactory>()),
    );
    di.registerLazySingleton<ChatsRemoteDataSource>(
          () => ChatsRemoteDataSourceImp(di<DioFactory>()),
    );
    di.registerLazySingleton<BaseCpRemotelyDataSource>(
          () => CpRemotelyDataSource(dioFactory: di()),
    );
    di.registerLazySingleton<BaseTasksRemotelyDataSource>(
          () => TasksRemotelyDataSource(dioFactory: di()),
    );
    di.registerLazySingleton<BaseRemoteDataSource>(
          () => RemoteDataSource(dioFactory: di()),
    );
    di.registerLazySingleton<BaseHomeRemoteDataSource>(
          () => HomeRemoteDataSourceImp(di()),
    );
    di.registerLazySingleton<BaseAgencyRemoteDataSource>(
          () => AgencyRemotelyDataSource(di()),
    );
    di.registerLazySingleton<BaseFamilyRemoteDataSource>(
          () => FamilyDataSource(dioFactory: di()),
    );
    di.registerLazySingleton<BaseProfileRemotelyDataSource>(
          () => ProfileRemotelyDataSource(dioFactory: di()),
    );
    di.registerLazySingleton<BaseVipRemotelyDataSource>(
          () => VipRemotelyDataSource(dioFactory: di()),
    );
    di.registerLazySingleton<BaseRoomRemoteDataSource>(
          () => RoomRemoteDataSourceImp(di()),
    );
    di.registerLazySingleton<BaseMomentRemoteDataSource>(
          () => MomentRemoteDataSourceImp(di()),
    );
    di.registerLazySingleton<BasePaymentRemotelyDataSource>(
          () => PaymentRemotelyDataSource(dioFactory: di()),
    );
    di.registerLazySingleton<ReelsBaseDataSource>(
          () => ReelsDataSourceImp(di()),
    );

    // Repositories
    di.registerLazySingleton<BaseAuthenticationRepository>(
          () =>
          AuthenticationRepositoryImp(di<BaseAuthenticationRemoteDataSource>()),
    );
    di.registerLazySingleton<BaseMessagesRepository>(
          () => MessagesRepositoryImp(di<BaseMessagesRemoteDataSource>()),
    );
    di.registerLazySingleton<ChatsRepository>(
          () => ChatsRepositoryImp(di()),
    );
    di.registerLazySingleton<BaseMallMyBagRepository>(
          () => MallMyBagRepositoryImp(di<BaseMallMyBagRemoteDataSource>()),
    );
    di.registerLazySingleton<BaseGamesRepository>(
          () => GamesRepositoryImp(di()),
    );
    di.registerLazySingleton<CpBaseRepository>(
          () => CpRepositoryImp(baseCpRemotelyDataSource: di()),
    );
    di.registerLazySingleton<TasksBaseRepository>(
          () => TasksRepositoryImp(baseTasksRemotelyDataSource: di()),
    );
    di.registerLazySingleton<SettingsBaseRepository>(
          () => SettingsRepositoryImp(baseRemoteDataSource: di()),
    );
    di.registerLazySingleton<BaseFamilyRepository>(
          () => FamilyRepositoryImp(baseFamilyRemoteDataSource: di()),
    );
    di.registerLazySingleton<AgencyBaseRepository>(
          () => AgencyRepositoryImp(baseAgencyRemotelyDataSource: di()),
    );
    di.registerLazySingleton<ProfileBaseRepository>(
          () => ProfileRepositoryImp(remotelyDataSource: di()),
    );
    di.registerLazySingleton<VipBaseRepository>(
          () => VipRepositoryImp(baseVipRemotelyDataSource: di()),
    );
    di.registerLazySingleton<BaseHomeRepository>(
          () => HomeRepositoryImp(di()),
    );
    di.registerLazySingleton<RoomBaseRepository>(() => RoomRepositoryImp(di()));
    di.registerLazySingleton<BaseMomentRepository>(
          () => MomentRepositoryImp(di()),
    );
    di.registerLazySingleton<PaymentBaseRepository>(
          () => PaymentRepositoryImp(basePaymentRemotelyDataSource: di()),
    );
    di.registerLazySingleton<ReelsBaseRepo>(
          () => ReelsRepoImp(di()),
    );
  }

  /// Auth: login, register, splash, config, credentials
  static void initAuth() {
    if (_initialized.contains('auth')) return;
    _initialized.add('auth');

    // Use cases
    di.registerLazySingleton<FetchCountriesUc>(() => FetchCountriesUc(di()));
    di.registerLazySingleton(() => LoginUC(di()));
    di.registerLazySingleton(() => GuestLoginUC(di()));
    di.registerLazySingleton(() => CheckPhoneUC(di()));
    di.registerLazySingleton(() => FetchColorsUc(di()));
    di.registerLazySingleton(() => RegisterUc(di()));
    di.registerLazySingleton(() => AddInfoUc(di()));
    di.registerLazySingleton(() => ReplaceCoverImageUseCase(repo: di()));
    di.registerLazySingleton(() => ForgetPasswordUC(di()));
    di.registerLazySingleton(() => SignInWithGoogleUC(di()));
    di.registerLazySingleton(() => SignInWithAppleUC(di()));
    di.registerLazySingleton(() => SignInWithHuaweiUC(di()));
    di.registerLazySingleton(() => GetVipFramesUc(di()));
    di.registerLazySingleton(() => GetAgencyBadgesUc(di()));
    di.registerLazySingleton(() => GetWabblesUc(di()));
    di.registerLazySingleton(() => GetConfigAppUseCase(repo: di()));
    di.registerLazySingleton(() => RealtimeSettingsUc(di()));
    di.registerLazySingleton(() => GetFirebaseCustomTokenUc(di()));
    di.registerLazySingleton(() => ChangeNumberUseCase(repo: di()));
    di.registerLazySingleton(
            () => ChangeForgetPassUseCase(baseRepository: di()));
    di.registerLazySingleton(() => LogOutUseCase(baseRepository: di()));
    di.registerLazySingleton(() => PrivacyPolicyUseCase(di()));
    di.registerLazySingleton<FetchCountryCategoriesUc>(
            () => FetchCountryCategoriesUc(di()));
    di.registerLazySingleton<FetchCountriesByCategoryUc>(
            () => FetchCountriesByCategoryUc(di()));

    // Blocs
    di.registerFactory<LoginBloc>(
            () => LoginBloc(loginUC: di(), checkPhoneUC: di()));
    di.registerFactory<RegisterBloc>(() => RegisterBloc(di()));
    di.registerLazySingleton<AddInformationBloc>(
          () => AddInformationBloc(addInfoUc: di()),
    );
    di.registerLazySingleton<ShowBannersBloc>(() => ShowBannersBloc());
    di.registerFactory<SplashBloc>(() => SplashBloc());
    di.registerLazySingleton<FirebasePhoneAuthService>(
            () => FirebasePhoneAuthService());
    di.registerLazySingleton<OtpBloc>(
            () => OtpBloc(di<FirebasePhoneAuthService>()));
    di.registerLazySingleton<CountriesBloc>(
            () => CountriesBloc(di(), di(), di()));
    di.registerFactory<SendCodeBloc>(
            () => SendCodeBloc(di<FirebasePhoneAuthService>()));
    di.registerFactory<RecoverPasswordBloc>(
            () => RecoverPasswordBloc(di<ForgetPasswordUC>()));
    di.registerLazySingleton<AuthPlatformBloc>(
          () => AuthPlatformBloc(
        signInWithGoogleUC: di(),
        signInWithAppleUC: di(),
        signInWithHuaweiUC: di(),
        guestLoginUC: di(),
      ),
    );
    di.registerLazySingleton(() => GetVipFramesBloc(di()));
    di.registerLazySingleton(() => GetAgencyBadgesBloc(di()));
    di.registerLazySingleton(() => GetWabblesBloc(di()));
    di.registerLazySingleton(() => ConfigAppBloc(configAppUseCase: di()));
    di.registerLazySingleton(() => ColorsBloc(di()));
    di.registerLazySingleton(() => RealtimeSettingsBloc(di()));
    di.registerLazySingleton(() => FirebaseCustomTokenBloc(di()));
    di.registerFactory(() => ResetPasswordBloc(changePasswordUc: di()));
    di.registerFactory(() => ChangePhoneBloc(changeNumberUseCase: di()));
    di.registerLazySingleton<PrivacyPolicyBloc>(
            () => PrivacyPolicyBloc(privacyPolicyUseCase: di()));
    di.registerLazySingleton(() => LogOutBloc(logOutUseCase: di()));
  }

  /// Home: rooms, search, carousel, ranking, explore, daily prizes
  static void initHome() {
    if (_initialized.contains('home')) return;
    _initialized.add('home');

    // Use cases
    di.registerLazySingleton<FetchRoomsUC>(() => FetchRoomsUC(di()));
    di.registerLazySingleton<FetchLiveRoomsUC>(() => FetchLiveRoomsUC(di()));
    di.registerLazySingleton<FetchMyRoomDataUc>(() => FetchMyRoomDataUc(di()));
    di.registerLazySingleton<FetchHostLevelsUc>(() => FetchHostLevelsUc(di()));
    di.registerLazySingleton<PickBoxUC>(() => PickBoxUC(di()));
    di.registerLazySingleton(() => GetBannerUseCase(di()));
    di.registerLazySingleton(() => GetCarouselUc(di()));
    di.registerLazySingleton(() => SearchUseCase(di()));
    di.registerLazySingleton(() => DailyPrizesUseCase(di()));
    di.registerLazySingleton(() => OpenDailyPrizeUC(di()));
    di.registerLazySingleton<FetchTopUserImageRankUc>(
            () => FetchTopUserImageRankUc(di()));
    // Explore
    di.registerLazySingleton<FetchGamesUC>(() => FetchGamesUC(di()));
    di.registerLazySingleton<FetchRankingUC>(() => FetchRankingUC(di()));
    di.registerLazySingleton<FetchGamesRoomUC>(() => FetchGamesRoomUC(di()));
    di.registerLazySingleton<FetchUsersUC>(() => FetchUsersUC(di()));
    di.registerLazySingleton<IgnoreUserUC>(() => IgnoreUserUC(di()));
    di.registerLazySingleton<LikeUserUC>(() => LikeUserUC(di()));

    // Blocs
    di.registerLazySingleton(() => BannerBloc(getBannerUseCase: di()));
    di.registerLazySingleton(() => GetCarouselBloc(getCarouselUc: di()));
    di.registerLazySingleton(() => SearchBloc(searchUseCase: di()));
    di.registerLazySingleton(() => FetchTopUserImageBloc(di()));
    di.registerLazySingleton(
            () => FetchMyRoomDataBloc(fetchMyRoomDataUc: di()));
    di.registerLazySingleton<DailyPrizesBloc>(() =>
        DailyPrizesBloc(dailyPrizesUseCase: di(), openDailyPrizeUC: di()));
    di.registerLazySingleton<ExploreBloc>(
            () => ExploreBloc(di(), di(), di(), di(), di()));
    di.registerLazySingleton<HomeBloc>(() => HomeBloc(di(), di(), di(), di()));
  }

  /// Profile: user data, badges, followers, levels, store
  static void initProfile() {
    if (_initialized.contains('profile')) return;
    _initialized.add('profile');

    // Use cases
    di.registerLazySingleton(
            () => FetchMyDataUseCase(baseRepositoryProfile: di()));
    di.registerLazySingleton(
            () => GetMyLevelDataUseCase(baseRepositoryProfile: di()));
    di.registerLazySingleton(
            () => FetchUserDataUseCase(baseRepositoryProfile: di()));
    di.registerLazySingleton(
            () => GiftHistoryUseCase(baseRepositoryProfile: di()));
    di.registerLazySingleton(
            () => GetUserIntroUseCase(baseRepositoryProfile: di()));
    di.registerLazySingleton(
            () => GetUserSupporterUserCase(baseRepositoryProfile: di()));
    di.registerLazySingleton(
            () => GetUserRoomsUseCase(baseRepositoryProfile: di()));
    di.registerLazySingleton(() => GetVisitorsUc(baseRepositoryProfile: di()));
    di.registerLazySingleton(
            () => MakeFollowUseCase(profileBaseRepository: di()));
    di.registerLazySingleton(
            () => MakeUnFollowUseCase(profileBaseRepository: di()));
    di.registerLazySingleton(
            () => GetFriendsOrFollowersUseCase(profileBaseRepository: di()));
    di.registerLazySingleton(() => MyStoreUseCase(baseRepositoryProfile: di()));
    di.registerLazySingleton(
            () => GetGoldCoinPricesUseCase(baseRepositoryProfile: di()));
    di.registerLazySingleton(
            () => AllLevelsUseCase(baseRepositoryProfile: di()));
    di.registerLazySingleton<LevelsBadgesUc>(
            () => LevelsBadgesUc(baseRepositoryProfile: di()));
    di.registerLazySingleton<RoomLevelBadgesUc>(
            () => RoomLevelBadgesUc(baseRepositoryProfile: di()));
    di.registerLazySingleton<UserLevelsUc>(
            () => UserLevelsUc(baseRepositoryProfile: di()));
    di.registerLazySingleton(() => PickMyBadgesUC(di()));
    di.registerLazySingleton(() => GetMyAllBadgeUC(di()));
    di.registerLazySingleton(() => GetBadgesUC(di()));
    di.registerLazySingleton(() => GetUserBadgeUc(baseRepositoryProfile: di()));
    di.registerLazySingleton(() => UserBadgeUc(baseRepositoryProfile: di()));
    di.registerLazySingleton(
            () => AddBlockUseCase(baseRepositoryProfile: di()));
    di.registerLazySingleton(
            () => RemoveBlockUseCase(baseRepositoryProfile: di()));
    di.registerLazySingleton(
            () => UserReportUseCase(baseRepositoryProfile: di()));
    di.registerLazySingleton(
            () => GetBlockListUseCase(baseRepositoryProfile: di()));
    di.registerLazySingleton(() => ChangeCountryUC(repository: di()));
    di.registerLazySingleton(() => ChangePassUseCase(baseRepository: di()));
    di.registerLazySingleton(() => BindNumberUseCase(baseRepository: di()));
    di.registerLazySingleton(() => BindGoogleUseCase(baseRepository: di()));
    di.registerLazySingleton(
            () => MakeProblemReportUseCase(baseRepository: di()));
    di.registerLazySingleton(() => ExchangeDiamondsUC(di()));
    di.registerLazySingleton(() => GetReplaceWithGoldUC(di()));
    di.registerLazySingleton(() => GetCoinSellerProfileUC(di()));
    di.registerLazySingleton(() => TransferCoinSellerUC(di()));
    di.registerLazySingleton(() => GetCoinSellerHistoryUC(di()));
    // New v2 diamond <-> coin exchange + new withdraw system use cases.
    di.registerLazySingleton(() => GetExchangeSettingsUC(di()));
    di.registerLazySingleton(() => MakeExchangeV2UC(di()));
    di.registerLazySingleton(() => GetExchangeLogsUC(di()));
    di.registerLazySingleton(() => MakeWalletWithdrawUC(di()));
    di.registerLazySingleton(() => WalletWithdrawUseCases(di()));

    // Blocs
    di.registerLazySingleton(
          () => FetchUserDataBloc(
        di(),
        di(),
        di(),
      ),
    );
    di.registerLazySingleton<EditInformationBloc>(
          () => EditInformationBloc(
        addInfoUc: di(),
        replaceCoverImageUseCase: di(),
        changeCountryUC: di(),
      ),
    );
    di.registerFactory(() => GiftHistoryBloc(giftHistoryUseCase: di()));
    di.registerFactory(() => GetUserIntroBloc(getUserIntroUseCase: di()));
    di.registerLazySingleton(() => FeedbackBloc());
    di.registerLazySingleton(() => GetFollowerOrFollowingBloc(
      getFriendsOrFollowersUseCase: di(),
      getVisitorsUc: di(),
    ));
    di.registerLazySingleton(() => FollowBloc(
      makeFollowUseCase: di(),
      makeUnFollowUseCase: di(),
    ));
    di.registerLazySingleton(() => LevelBloc(
      levelsBadgesUc: di(),
      userLevelUc: di(),
      roomLevelBadgesUc: di(),
    ));
    di.registerLazySingleton(
            () => GoldCoinBloc(getGoldCoinPricesUseCase: di()));
    di.registerLazySingleton(() => MyStoreBloc(getMyStoreUseCase: di()));
    di.registerLazySingleton(() => DiamondBloc(
        getReplaceWithGoldUseCase: di(), exchangeDiamondsUseCase: di()));
    di.registerLazySingleton(() => ExchangeV2Bloc(
      getExchangeSettingsUseCase: di(),
      makeExchangeUseCase: di(),
      getExchangeLogsUseCase: di(),
    ));
    di.registerLazySingleton(() => WalletWithdrawBloc(useCases: di()));
    di.registerLazySingleton(() => CoinSellerBloc(
      getCoinSellerProfileUC: di(),
      transferCoinSellerUC: di(),
      getCoinSellerHistoryUC: di(),
    ));
    di.registerLazySingleton(() => GetBadgesBloc(
      getBadgesUseCase: di(),
      getMyAllBadgeUC: di(),
    ));
    di.registerLazySingleton(() => PickMyBadgesBloc(pickMyBadgesUC: di()));
    di.registerLazySingleton(() => SelectionBloc());
    di.registerLazySingleton(() => UserReportBloc(userReportUseCase: di()));
    di.registerFactory(() => GetSupporterBloc(getSupporterDataUseCase: di()));
    di.registerLazySingleton(() => AddOrRemoveBlock(
      removeBlockUseCase: di(),
      addBlockUseCase: di(),
    ));
    di.registerLazySingleton(() => GetBlockListBloc(getBlockListUseCase: di()));
    di.registerLazySingleton(() => MakeProblemReportBloc(
      makeProblemReportUseCase: di(),
    ));
    di.registerLazySingleton(() => GetMyLevelBloc(getMyLevelDataUseCase: di()));
    di.registerFactory(() => UserBadgesBloc(getUserBadgeUc: di()));
    // Was registerFactory: every di<GetUserBadgesBloc>() call made a brand
    // new, empty-state instance, so whichever call site dispatched
    // GetUserBadgesData and whichever BlocBuilder read the result almost
    // never shared the same bloc -- the fetched badges landed in an instance
    // nothing was listening to. Every call site (Mine tab, visitor profile
    // header, room profile sheet, my_vip_card) expects one shared "badges of
    // the profile currently in view" cache, same as the other *lazySingleton
    // blocs around it.
    di.registerLazySingleton(() => GetUserBadgesBloc(userBadgeUc: di()));
    di.registerFactory(() => GetUserRoomsBloc(getUserRoomsUseCase: di()));
    di.registerLazySingleton(() => AccountBloc(
      bindGoogleUseCase: di(),
      bindNumberUseCase: di(),
      changePassUseCase: di(),
    ));
  }

  /// Chat & Messages
  static void initChat() {
    if (_initialized.contains('chat')) return;
    _initialized.add('chat');

    // Use cases
    di.registerLazySingleton(() => OnlineUserUC(di()));
    di.registerLazySingleton(() => CloseChatUC(di()));
    di.registerLazySingleton(() => DeleteChatUC(di()));
    di.registerLazySingleton(() => DeleteMessageUC(di()));
    di.registerLazySingleton(() => FetchMessagesUC(di()));
    di.registerLazySingleton(() => MakeReactUC(di()));
    di.registerLazySingleton(
            () => SendMessageAllUseCase(baseRepositoryChat: di()));
    di.registerLazySingleton(() => GetBillHistoryUC(di()));
    di.registerLazySingleton(() => GetSystemChatUC(di()));
    di.registerLazySingleton(() => FetchChatRequestUC(di()));
    di.registerLazySingleton(() => FetchChatUC(di()));
    di.registerLazySingleton(() => GetPreSignedUrlmessageVideoUseCase(
      baseMessagesRepository: di(),
    ));
    di.registerLazySingleton(() => UploadFileToStorageMessageVideoUseCase(
      baseMessagesRepository: di(),
    ));

    // Blocs
    di.registerLazySingleton(() => FetchChatRequestBloc(di()));
    di.registerLazySingleton(() => DeleteMessageBloc(di()));
    di.registerLazySingleton(() => DeleteChatBloc(deleteChatUseCase: di()));
    di.registerLazySingleton(() => UserOnlineBloc(di()));
    di.registerLazySingleton<TextFieldBloc>(() => TextFieldBloc(),
        dispose: (bloc) => bloc.close());
    di.registerLazySingleton<BillBloc>(() => BillBloc(getBillHistoryUC: di()));
    di.registerLazySingleton<GetSystemChatBloc>(
            () => GetSystemChatBloc(getSystemChatUC: di()));
    di.registerLazySingleton(
            () => FetchUsersChatBloc(di(), di<RoomsDao>()));
    di.registerLazySingleton(() =>
        SendMessagesBloc(di(), di(), di<ChatRepository>()));
    di.registerLazySingleton(() => SendMessageAllBloc(di()));
    di.registerLazySingleton(() => MakeReactBloc(di()));
    di.registerLazySingleton(() => FetchMessagesBloc(
        di(), di<ChatRepository>(), di<RealtimeClient>()));
    di.registerLazySingleton(() => ToggleAppBarBloc());

    // Realtime / offline-first infrastructure (Phase 5). These are wired into
    // the chat BLoCs in the next task; registering them here keeps them lazy and
    // available without changing any existing send/receive behavior yet.
    di.registerLazySingleton<RealtimeHttp>(
          () => DioRealtimeHttp(di<DioFactory>()),
    );
    di.registerLazySingleton<RealtimeTokenService>(
          () => RealtimeTokenService(di<DioFactory>()),
    );
    di.registerLazySingleton<OutboxWorker>(
          () => OutboxWorker(
        http: di<RealtimeHttp>(),
        outboxDao: di<OutboxDao>(),
        messagesDao: di<MessagesDao>(),
        roomsDao: di<RoomsDao>(),
        mediaUploadsDao: di<MediaUploadsDao>(),
        sendMessagePath: EndPoints.sendMessage,
        onRecoverableDbError: (e, s, context) =>
            Methods.recordNonFatal(e, s, reason: context),
      ),
    );
    di.registerLazySingleton<MediaUploadWorker>(
          () => MediaUploadWorker(
        mediaUploadsDao: di<MediaUploadsDao>(),
        remote: di<BaseMessagesRemoteDataSource>(),
        // After an upload finishes, nudge the outbox so the now-sendable
        // message goes out immediately instead of waiting for the next tick.
        onUploadDone: () => di<OutboxWorker>().drainOnce(),
      ),
    );
    di.registerLazySingleton<SyncEngine>(
          () => SyncEngine(
        http: di<RealtimeHttp>(),
        messagesDao: di<MessagesDao>(),
        roomsDao: di<RoomsDao>(),
        syncStateDao: di<SyncStateDao>(),
        sinceSeqUrl: EndPoints.roomMessagesSince,
        beforeSeqUrl: EndPoints.roomMessagesBefore,
        roomsListUrl: EndPoints.syncRooms,
        onRecoverableDbError: (e, s, context) =>
            Methods.recordNonFatal(e, s, reason: context),
      ),
    );
    di.registerLazySingleton<RealtimeClient>(
          () => RealtimeClient(
        tokenService: di<RealtimeTokenService>(),
        messagesDao: di<MessagesDao>(),
        roomsDao: di<RoomsDao>(),
        syncStateDao: di<SyncStateDao>(),
        syncEngine: di<SyncEngine>(),
      ),
    );

    // Drift-backed local-first chat repository (Plan section 7.5). The 1:1 chat
    // BLoCs send/read through this; it owns optimistic insert + outbox enqueue +
    // recovery so the UI never touches the network directly. Registering it here
    // keeps it lazy and available without changing existing behavior yet.
    di.registerLazySingleton<ChatRepository>(
          () => ChatRepository(
        roomsDao: di<RoomsDao>(),
        messagesDao: di<MessagesDao>(),
        outboxDao: di<OutboxDao>(),
        mediaUploadsDao: di<MediaUploadsDao>(),
        syncEngine: di<SyncEngine>(),
        currentUserId: () => MyDataModel.getInstance().id ?? 0,
        // HTTP seam + URL for the lightweight 1:1 get-or-create-room resolution,
        // so a conversation opened/sent without a known chat_id resolves its real
        // server room id before the seq-keyed sync + outbox send (never room 0).
        http: di<RealtimeHttp>(),
        ensureRoomUrl: EndPoints.ensureChatRoom,
        // Drain the outbox the instant a message is enqueued instead of waiting
        // for the periodic tick.
        onEnqueued: () => di<OutboxWorker>().drainOnce(),
      ),
    );

    // Contact discovery (chat rebuild §3) — used by the new-chat friend picker.
    di.registerLazySingleton<ContactDiscoveryService>(
          () => ContactDiscoveryService(di<DioFactory>()),
    );
  }

  /// Groups: group management feature (Phase 7 part A). Data source, repository,
  /// use cases and BLoCs for create/info/settings/members/roles/join.
  static void initGroups() {
    if (_initialized.contains('groups')) return;
    _initialized.add('groups');

    // Data source + repository
    di.registerLazySingleton<GroupsRemoteDataSource>(
          () => GroupsRemoteDataSourceImp(di<DioFactory>()),
    );
    di.registerLazySingleton<GroupsRepository>(
          () => GroupsRepositoryImp(di<GroupsRemoteDataSource>()),
    );

    // Use cases
    di.registerLazySingleton(() => FetchGroupsUC(di()));
    di.registerLazySingleton(() => FetchGroupDetailUC(di()));
    di.registerLazySingleton(() => CreateGroupUC(di()));
    di.registerLazySingleton(() => UpdateGroupUC(di()));
    di.registerLazySingleton(() => DeleteGroupUC(di()));
    di.registerLazySingleton(() => FetchGroupMembersUC(di()));
    di.registerLazySingleton(() => AddGroupMembersUC(di()));
    di.registerLazySingleton(() => KickGroupMemberUC(di()));
    di.registerLazySingleton(() => PromoteGroupMemberUC(di()));
    di.registerLazySingleton(() => DemoteGroupMemberUC(di()));
    di.registerLazySingleton(() => MuteGroupMemberUC(di()));
    di.registerLazySingleton(() => TransferGroupOwnershipUC(di()));
    di.registerLazySingleton(() => LeaveGroupUC(di()));
    di.registerLazySingleton(() => JoinGroupUC(di()));

    // BLoCs
    di.registerLazySingleton(() => GroupsListBloc(di(), di<RealtimeClient>()));
    di.registerLazySingleton(() => GroupDetailBloc(di(), di(), di(), di(), di()));
    di.registerLazySingleton(
            () => GroupMembersBloc(di(), di(), di(), di(), di(), di()));
    di.registerLazySingleton(() => CreateGroupBloc(di()));
    di.registerLazySingleton(() => JoinGroupBloc(di()));

    // Group chat screen (Phase 7 part B) — drift/realtime stack. Reuses the
    // shared ChatRepository/RealtimeClient/OutboxWorker from initChat().
    // Factory (not singleton): each group chat screen needs its own BLoC
    // so that opening group B from group A doesn't show A's messages.
    di.registerFactory(() => groupchat.GroupChatBloc(
      di<ChatRepository>(),
      di<RealtimeClient>(),
      di<OutboxWorker>(),
      di<RealtimeHttp>(),
      di<FetchGroupMembersUC>(),
    ));
  }

  /// Room: audio room management, gifts, charisma, PK, themes, music
  static void initRoom() {
    if (_initialized.contains('room')) return;
    _initialized.add('room');

    // Use cases
    di.registerLazySingleton(() => CreateRoomUC(di()));
    di.registerLazySingleton(() => GetAllRoomTypesUC(di()));
    di.registerLazySingleton(() => StartCharismaUC(di()));
    di.registerLazySingleton(() => ResetCharismaUC(di()));
    di.registerLazySingleton(() => GetCharismaExtraDataUC(di()));
    di.registerLazySingleton(() => GetCharismaLevelsUC(di()));
    di.registerLazySingleton(() => ExtraProfileDataUc(di()));
    di.registerLazySingleton(() => CheckAdminOwnerUc(di()));
    di.registerLazySingleton<GetSuperBombUC>(() => GetSuperBombUC(di()));
    di.registerLazySingleton<GetSuperBoomVideosUC>(
            () => GetSuperBoomVideosUC(di()));
    di.registerLazySingleton<GetSuperBoomRulesUC>(
            () => GetSuperBoomRulesUC(di()));
    di.registerLazySingleton<GetRoomBoomThemesUC>(
            () => GetRoomBoomThemesUC(di()));
    di.registerLazySingleton(() => GetFreeGamesImagesUC(di()));
    di.registerLazySingleton(() => FetchGiftCategoryUC(di()));
    di.registerLazySingleton(() => FetchUsersDataUc(di()));
    di.registerLazySingleton(() => FetchBadWordsUC(di()));

    di.registerLazySingleton(() => OpenGameUseCase(di()));
    di.registerLazySingleton(() => GetMyBackgroundUseCase(di()));
    di.registerLazySingleton(() => GetMyBackgroundSettingUc(di()));
    di.registerLazySingleton(() => AddRoomBackGroundUseCase(di()));

    di.registerLazySingleton(() => GetRoomActivityDataUC(di()));
    di.registerLazySingleton(() => GetRoomActivityWebViewLinkUC(di()));
    di.registerLazySingleton(() => RemovePassRoomUC(di()));
    di.registerLazySingleton(() => ClearModeUC(di()));
    di.registerLazySingleton(() => EnterRoomUC(di()));

    di.registerLazySingleton(() => LockCommentsUC(di()));
    di.registerLazySingleton(() => UnLockCommentsUC(di()));
    di.registerLazySingleton(() => SendYallowBannerUC(di()));
    di.registerLazySingleton(() => SendLuckyGiftUC(di()));
    di.registerLazySingleton(() => GetTopRoomUC(di()));
    di.registerLazySingleton(() => UpdateRoomUC(di()));
    di.registerLazySingleton(() => ChangeRoomModeUC(di()));
    di.registerLazySingleton(() => BackGroundUC(di()));
    di.registerLazySingleton(() => EmojiUC(di()));
    di.registerLazySingleton(() => FetchEmojisCategoryUc(di()));
    di.registerLazySingleton(() => ShowPKUC(di()));
    di.registerLazySingleton(() => StartPKUC(di()));
    di.registerLazySingleton(() => BlockCommentsUC(di()));
    di.registerLazySingleton(() => ClosePKUC(di()));
    di.registerLazySingleton(() => HidePKUC(di()));
    di.registerLazySingleton(() => GetConfigKeyUC(di()));
    di.registerLazySingleton(() => SendGiftUC(di()));
    di.registerLazySingleton(() => FetchGiftsUC(di()));
    di.registerLazySingleton(() => GetLuckyBoxUC(di()));
    di.registerLazySingleton(() => PickUpLuckyBoxUc(di()));
    di.registerLazySingleton(() => SendLuckyBoxUc(di()));
    di.registerLazySingleton(() => CreatePaidRoomUs(di()));
    di.registerLazySingleton(() => GetBubblePaddingUc(di()));
    di.registerLazySingleton(() => FetchGamesImagesUc(di()));
    di.registerLazySingleton(
            () => GetPreSignedUrlSongUseCase(roomBaseRepo: di()));
    di.registerLazySingleton(
            () => UploadFileSongToStorageUseCase(roomBaseRepo: di()));
    di.registerLazySingleton(
            () => NotifyBackendSongUseCase(roomBaseRepo: di()));
    di.registerLazySingleton(() => GetMusicUc(di()));
    di.registerLazySingleton(() => GetMyMusicUc(di()));
    di.registerLazySingleton(() => DeleteSongUC(di()));

    // Blocs
    di.registerLazySingleton<CharismaBloc>(() => CharismaBloc(
        startCharismaUC: di(),
        resetCharismaUC: di(),
        getCharismaExtraDataUC: di(),
        getCharismaLevelsUC: di()));
    di.registerLazySingleton(() => FetchExtraDataBloc(di()));
    di.registerLazySingleton(() => CheckAdminOwnerBloc(di()));
    di.registerLazySingleton(() => HostTimerBloc());
    di.registerLazySingleton<GetSuperBombsBloc>(
            () => GetSuperBombsBloc(di(), di(), di()));
    di.registerLazySingleton<GetSuperBombsThemeBloc>(
            () => GetSuperBombsThemeBloc(di()));
    di.registerLazySingleton(() => GetFreeGamesImagesBloc(di()));
    di.registerLazySingleton<CreateRoomBloc>(
            () => CreateRoomBloc(di(), di(), di()));
    di.registerLazySingleton(() => RoomOverlayCubit());
    di.registerLazySingleton(() => RoomHandlerBloc(enterRoomUC: di()));
    di.registerLazySingleton(() => SendGiftBloc(di()));
    di.registerLazySingleton(() => LiveSendGiftBloc(di()));
    di.registerLazySingleton(() => FetchGiftBloc(di(), di()));
    di.registerFactory(() => GetConfigKeysBloc(getConfigKeyUc: di()));
    di.registerLazySingleton(() => EmojieBloc(
      emojieUseCase: di(),
      emojisCategoryUc: di(),
    ));
    di.registerLazySingleton(() => RankingRoomBloc(di()));
    di.registerLazySingleton(() => ThemeBloc(di()));
    di.registerLazySingleton(() => OnRoomBloc(
      backGroundUseCase: di(),
      removePassRoomUC: di(),
      sendYallowBannerUC: di(),
      lockCommentsUC: di(),
      unLockCommentsUC: di(),
    ));
    di.registerLazySingleton(() => PKBloc(
      showPKUC: di(),
      startPKUC: di(),
      closePKUC: di(),
      hidePKUC: di(),
    ));
    di.registerLazySingleton(() => BlockCommentsBloc(di()));
    di.registerLazySingleton(() => LuckyGiftBannerBloc(sendLuckyGiftUc: di()));
    di.registerLazySingleton(() => LuckyGiftBannerForReciverBloc());
    di.registerLazySingleton(() => LuckyGiftWinBloc());
    di.registerLazySingleton(() => LuckyGiftAnaimationManagerBloc());
    di.registerLazySingleton(() => AlphaGiftManagerBloc());
    di.registerLazySingleton(() => ClearModeBloc(clearModeUC: di()));
    di.registerLazySingleton(() => UpdateRoomBloc(di()));
    di.registerLazySingleton(() => AdminRoomBloc());
    di.registerLazySingleton<MusicRoomBloc>(() => MusicRoomBloc(),
        dispose: (bloc) => bloc.close());
    di.registerLazySingleton(
            () => UploadSongBloc(di(), di(), di(), di(), di()));
    di.registerLazySingleton(() => DeleteSongBloc(di()));
    di.registerLazySingleton(() => LuckyBoxBloc(di(), di(), di()));
    di.registerFactory(() => GetRoomActivityDataBloc(di(), di()));
    di.registerLazySingleton(() => GiftBloc());

    di.registerLazySingleton(() => OpenGameBloc(openGameUseCase: di()));
    di.registerLazySingleton(
            () => AddRoomBackgroundBloc(addRoomBackgroundUseCase: di()));
    di.registerLazySingleton(() => GetMyBackgroundBloc(di()));
    di.registerLazySingleton(() => GetMyBackgroundSettingBloc(di()));
    di.registerLazySingleton(() => YoutubeBloc());

    di.registerLazySingleton(() => GetYoutubeVideosBloc());
    di.registerLazySingleton(() => GetBubblePaddingBloc(di()));
    di.registerLazySingleton(() => GamesImagesBloc(di()));
    di.registerLazySingleton(() => ShareRoomBloc());
    di.registerLazySingleton(() => RankingBloc(di(), di()));
    di.registerLazySingleton<SetTimerPK>(() => SetTimerPK());
    di.registerLazySingleton(() => SetTimerLuckyBox());
  }

  /// Agency
  static void initAgency() {
    if (_initialized.contains('agency')) return;
    _initialized.add('agency');

    // Use cases
    di.registerLazySingleton(() => SearchUserAgencyUc(di()));
    di.registerLazySingleton(() => ShowAgencyUC(repository: di()));
    di.registerLazySingleton(() => ChargeDollarsForUserUC(repository: di()));
    di.registerLazySingleton(() => ChargeToUC(repository: di()));
    di.registerLazySingleton(() => JoinToAgencyUC(repository: di()));
    di.registerLazySingleton(() => MakeUserAdminUC(repository: di()));
    di.registerLazySingleton(() => LeaveAgencyUC(repository: di()));
    di.registerLazySingleton(() => KickOutAgencyUC(repository: di()));
    di.registerLazySingleton(() => InformationAgencyUC(repository: di()));
    di.registerLazySingleton(() => AgencyRequestsActionUC(repository: di()));
    di.registerLazySingleton(() => AgencyRequestsUC(repository: di()));
    di.registerLazySingleton(() => AgencyMemberUC(repository: di()));
    di.registerLazySingleton(() => AgencyHistoryUC(repository: di()));
    di.registerLazySingleton(() => AgencySearchUC(repository: di()));
    di.registerLazySingleton(() => AgencyHostReportUC(repository: di()));
    di.registerLazySingleton(
            () => HostsAgencyDollarsRecordsUC(repository: di()));
    di.registerLazySingleton(
            () => AgencyMemberChargesHistoryUC(repository: di()));
    di.registerLazySingleton(() => FetchFormUc(repository: di()));
    di.registerLazySingleton(() => GetOldAgenciesUC(repository: di()));
    di.registerLazySingleton(() => FetchMoreInfoAgencyUC(repository: di()));
    di.registerLazySingleton(() => HostSAgencyDataUC(repository: di()));
    di.registerLazySingleton(() => GetHostRequestsUC(repository: di()));
    di.registerLazySingleton(() => HostRequestActionUC(repository: di()));
    di.registerLazySingleton(() => UpdateHostAgencyDataUc(di()));
    di.registerLazySingleton(() => FetchAgencyRankingUC(di()));
    di.registerLazySingleton(() => FetchAgencyAdminsUC(repository: di()));
    di.registerLazySingleton(() => FetchAgencyHerosUC(repository: di()));
    di.registerLazySingleton(() => FetchAgencyStarsUC(repository: di()));
    di.registerLazySingleton(() => UpdateAgencyInfoUC(repository: di()));
    di.registerLazySingleton(() => GetChargeAgencyDetailsUC(repository: di()));
    di.registerLazySingleton(() => GetAgencyInfoUC(repository: di()));
    di.registerLazySingleton(
            () => SendTransferConfirmationRequestUC(repository: di()));
    di.registerLazySingleton(
            () => GetShippingAgentsFullDataUC(repository: di()));
    di.registerLazySingleton(() => ChargeCoinForUserUC(repository: di()));

    // Blocs
    di.registerLazySingleton(() => SearchUserAgencyBloc(di()));
    di.registerLazySingleton(() => ShowAgencyBloc(showAgencymUsecase: di()));
    di.registerLazySingleton(() => JoinToAgenciesBloc(joinToAgencyUC: di()));
    di.registerLazySingleton(
            () => MakeUserAdminBloc(makeUserAdminUseCase: di()));
    di.registerLazySingleton(() => LeaveAgencyBloc(leaveAgencyUC: di()));
    di.registerLazySingleton(() => KickOutAgencyBloc(kickOutAgencyUC: di()));
    di.registerLazySingleton(
            () => InformationAgencyBloc(informationAgencyUC: di()));
    di.registerLazySingleton(
            () => AgencyRequestsActionBloc(agencyRequestsActionUC: di()));
    di.registerLazySingleton(() => AgencyRequestsBloc(agencyRequestsUC: di()));
    di.registerLazySingleton(() => AgencyMemberBloc(agencyMemberUC: di()));
    di.registerLazySingleton(() => AgencyTimeBloc(agencyHistoryUC: di()));
    di.registerLazySingleton(
            () => AgencySearchBloc(agencySearchUC: di(), fetchFormUc: di()));
    di.registerLazySingleton(() => AgencyHostReportBloc(useCase: di()));
    di.registerLazySingleton(() => ChargeToBloc(chargeToUseCases: di()));
    di.registerLazySingleton(
            () => ChargeDollarsForUserBloc(chargeDollarsForUserUC: di()));
    di.registerLazySingleton(() => FetchAgencyAdminsBloc(di()));
    di.registerLazySingleton(() => FetchAgencyHerosBloc(di()));
    di.registerLazySingleton(() => FetchAgencyStarsBloc(di()));
    di.registerLazySingleton(() => FetchMoreInfoAgencyBloc(di(), di()));
    di.registerLazySingleton(() => HostRequestsBloc(
      getHostRequestsUseCase: di(),
      hostRequestActionUseCase: di(),
    ));
    di.registerLazySingleton(() => GetSettingBloc(getSettingUC: di()));
    di.registerLazySingleton(() => HostsAgencyDollarsRecordsBloc(di()));
    di.registerLazySingleton(() => AgencyMemeberChargesHistoryBloc(di()));
    di.registerLazySingleton(() => GetOldAgenciesBloc(di()));
    di.registerLazySingleton<UpdateHostAgencyDataBloc>(
            () => UpdateHostAgencyDataBloc(di()));
    di.registerLazySingleton(() => GetChargeAgencyDetailsBloc(
      getAgencyDetailsInfoUseCase: di(),
    ));
    di.registerLazySingleton(() => GetChargeAgencyBloc(getAgencyInfoUC: di()));
    di.registerLazySingleton(
            () => UpdateChargeAgencyBloc(updateChargeAgencyUC: di()));
    di.registerLazySingleton(() => SendConfirmationRequestBloc(useCase: di()));
    di.registerLazySingleton(() => GetShippingAgentsFullDataModelBloc(
      getShippingAgentsFullDataModel: di(),
    ));
    di.registerLazySingleton(
            () => ChargeCoinForUserBloc(chargeCoinForUserUC: di()));
  }

  /// Family
  static void initFamily() {
    if (_initialized.contains('family')) return;
    _initialized.add('family');

    // Use cases
    di.registerLazySingleton(() => CreateFamilyUC(baseFamilyRepository: di()));
    di.registerLazySingleton(() => DeleteFamilyUC(baseFamilyRepository: di()));
    di.registerLazySingleton(
            () => GetAllFamilyUseCase(baseFamilyRepository: di()));
    di.registerLazySingleton(
            () => ChangeFamilyUserTypeUC(baseFamilyRepository: di()));
    di.registerLazySingleton(
            () => GetFamilyMemberUC(baseFamilyRepository: di()));
    di.registerLazySingleton(
            () => RemoveFamilyUserUC(baseFamilyRepository: di()));
    di.registerLazySingleton(
            () => GetFamilyRankingUC(baseFamilyRepository: di()));
    di.registerLazySingleton(() => JoinFamilyUC(baseFamilyRepository: di()));
    di.registerLazySingleton(
            () => FamilyTakeActionUC(baseFamilyRepository: di()));
    di.registerLazySingleton(
            () => GetFamilyRequestsRoomsUC(baseFamilyRepository: di()));
    di.registerLazySingleton(() => EditFamilyUC(baseFamilyRepository: di()));
    di.registerLazySingleton(() => ExitFamilyUC(baseFamilyRepository: di()));
    di.registerLazySingleton(
            () => GetFamilyRoomsUC(baseFamilyRepository: di()));
    di.registerLazySingleton(() => ShowFamilyUC(baseFamilyRepository: di()));

    // Blocs
    di.registerLazySingleton<ManagerFamilyBloc>(
            () => ManagerFamilyBloc(createFamilyUseCase: di(), editFamilyUC: di()));
    di.registerLazySingleton(() => DeleteFamilyBloc(deleteFamilyUseCse: di()));
    di.registerLazySingleton(() => GetAllFamilyBloc(getAllFamilyUseCase: di()));
    di.registerLazySingleton(
            () => ChangeUserTypeBloc(changeFamilyUserTypeUC: di()));
    di.registerLazySingleton(() => FamilyMemberBloc(getFamilyMember: di()));
    di.registerLazySingleton(
            () => FamilyRemoveUserBloc(removeFamilyUserUC: di()));
    di.registerLazySingleton(
            () => GetFamilyRankingBloc(getFamilyRankingUseCase: di()));
    di.registerLazySingleton(() => JoinFamilyBloc(joinFamilyUseCase: di()));
    di.registerLazySingleton(() => TakeActionBloc(familyTakeActionUC: di()));
    di.registerLazySingleton(
            () => FamilyRequestBloc(getFamilyRequestsRoomsUC: di()));
    di.registerLazySingleton(() => ExitFamilyBloc(exitFamilyUseCase: di()));
    di.registerLazySingleton(() => FamilyRoomBloc(getFamilyRoomsUseCase: di()));
    di.registerLazySingleton(() => ShowFamilyBloc(showFamilyUseCase: di()));
  }

  /// Moment
  static void initMoment() {
    if (_initialized.contains('moment')) return;
    _initialized.add('moment');

    // Use cases
    di.registerLazySingleton(
            () => FetchMomentUseCase(baseMomentRepository: di()));
    di.registerLazySingleton(
            () => AddMomentUseCase(baseMomentRepository: di()));
    di.registerLazySingleton(
            () => DeleteMomentUseCase(baseMomentRepository: di()));
    di.registerLazySingleton(
            () => LikeMomentUseCase(baseMomentRepository: di()));
    di.registerLazySingleton(() => ReportMomentUC(baseRepositoryMoment: di()));
    di.registerLazySingleton(
            () => AddMomentCommentUseCase(baseMomentRepository: di()));
    di.registerLazySingleton(
            () => DeleteMomentCommentUseCase(baseMomentRepository: di()));
    di.registerLazySingleton(
            () => FetchMomentCommentUseCase(baseMomentRepository: di()));
    di.registerLazySingleton(
            () => GetMomentLikeUseCase(baseMomentRepository: di()));
    di.registerLazySingleton(
            () => FetchMomentGiftUseCase(baseMomentRepository: di()));
    di.registerLazySingleton(
            () => SendGiftMomentUsGiftUC(baseMomentRepository: di()));

    // Blocs
    di.registerLazySingleton(() => MomentBloc(
      fetchMomentUseCase: di(),
      addMomentUseCase: di(),
      deleteMomentUseCase: di(),
      likeMomentUseCase: di(),
      reportMomentUC: di(),
    ));
    di.registerLazySingleton(() => MomentCommentBloc(
      addMomentCommentUseCase: di(),
      deleteMomentCommentUseCase: di(),
      fetchMomentCommentUseCase: di(),
    ));
    di.registerLazySingleton(
            () => GetMomentLikesBloc(getMomentLikeUseCase: di()));
    di.registerLazySingleton(() => MomentGiftBloc(fetchMomentUseCase: di()));
    di.registerLazySingleton(() => SendMomentGiftBloc(sendMomentGiftUC: di()));
  }

  /// Payment: coins, google pay, shipping
  static void initPayment() {
    if (_initialized.contains('payment')) return;
    _initialized.add('payment');

    // Use cases
    di.registerLazySingleton(
            () => GetCoinsUseCase(paymentBaseRepository: di()));
    di.registerLazySingleton(
            () => BuyCoinsUseCase(paymentBaseRepository: di()));
    di.registerLazySingleton(
            () => GooglePayUseCase(paymentBaseRepository: di()));
    di.registerLazySingleton(
            () => RedirectLinkUseCase(paymentBaseRepository: di()));
    di.registerLazySingleton(() => GetPaymentGetwaysUC(repository: di()));
    di.registerLazySingleton(() => SendWithdrawalRequestUC(repository: di()));
    di.registerLazySingleton(
            () => GetShippingAgentRequestsUC(repository: di()));
    di.registerLazySingleton(
            () => GetShippingMoneyCountriesUC(repository: di()));
    di.registerLazySingleton(
            () => MakeShippingAgentRequestActionUC(repository: di()));
    di.registerLazySingleton(
            () => MakeShippingAgentToAdminWithdrawalRequestUC(repository: di()));
    di.registerLazySingleton(() => GetChargeCoinsHistoryUC(repository: di()));
    di.registerLazySingleton(() => GetGoogleCoinsHistoryUC(repository: di()));

    // Blocs
    di.registerLazySingleton(() => FetchCoinsBloc(getCoinsUseCase: di()));
    di.registerLazySingleton(() => GooglePayBloc(googlePayUseCase: di()));
    di.registerLazySingleton(() => BuyCoinsBloc(
      buyCoinsUseCase: di(),
      redirectLinkUseCase: di(),
    ));
    di.registerLazySingleton(() => GetPaymentsGetwaysDataBloc(
      getPaymentGetwaysUseCase: di(),
    ));
    di.registerLazySingleton(() => GetShippingAgentsRequestsBloc(
      getShippingAgentRequestsUseCase: di(),
    ));
    di.registerLazySingleton(() => SendWithdrawalRequestBloc(
      sendWithdrawalRequestUseCase: di(),
    ));
    di.registerLazySingleton(() => GetShippingCountriesBloc(
      getShippingMoneyCountriesUseCase: di(),
    ));
    di.registerLazySingleton(() => MakeShippingAgentRequestActionBloc(
      shippingAgentRequestActionUseCase: di(),
    ));
    di.registerLazySingleton(
            () => MakeShippingAgentToAdminWithdrawalRequestBloc(
          useCase: di(),
        ));
    di.registerLazySingleton(() => PurchaseService());
  }

  /// Settings: account, block list, invitations
  static void initSettings() {
    if (_initialized.contains('settings')) return;
    _initialized.add('settings');

    // Use cases
    di.registerLazySingleton(() => DeleteAccountUc(di()));
    di.registerLazySingleton(() => GetSettingUC(repository: di()));
    di.registerLazySingleton(() => AddInviteCodeUseCase(baseRepository: di()));
    di.registerLazySingleton(
            () => SendInvitationCodeUseCase(baseRepository: di()));
    di.registerLazySingleton(
            () => GetMyEarnInviteUseCase(baseRepository: di()));
    di.registerLazySingleton(() => GetInviteUserUseCase(baseRepository: di()));
    di.registerLazySingleton(() => ExplainInviteUseCase(baseRepository: di()));
    di.registerLazySingleton(
            () => ExtractInviteCoinsUseCase(baseRepository: di()));
    di.registerLazySingleton(
            () => ClaimInviteBonusUseCase(baseRepository: di()));

    // Blocs
    di.registerLazySingleton<DeleteAccountBloc>(
            () => DeleteAccountBloc(deleteAccountUc: di()));
    di.registerLazySingleton(() => SendInviteBloc(
      sendInvitationCodeUseCase: di(),
      getMyEarnInviteUseCase: di(),
      getEarnInviteUserUseCase: di(),
      explainInviteUseCase: di(),
      addInviteCodeUseCase: di(),
      extractInviteCoinsUseCase: di(),
      claimInviteBonusUseCase: di(),
    ));
  }

  /// VIP
  static void initVip() {
    if (_initialized.contains('vip')) return;
    _initialized.add('vip');

    // Use cases
    di.registerLazySingleton(() => UseVipUseCase(vipBaseRepository: di()));
    di.registerLazySingleton(() => SendVipUc(vipBaseRepository: di()));
    di.registerLazySingleton(() => GetVipUserBagUc(vipBaseRepository: di()));
    di.registerLazySingleton(() => GetVipThemeSettingsUc(di()));
    di.registerLazySingleton(
            () => GetVipCenterUseCase(vipBaseRepository: di()));
    di.registerLazySingleton(() => BuyVipUseCase(vipBaseRepository: di()));
    di.registerLazySingleton(() => ActivePrivacyUseCase(baseRepository: di()));
    di.registerLazySingleton(
            () => DisActivePrivacyUseCase(baseRepository: di()));
    di.registerLazySingleton(() => GetVipPrivacyUseCase(baseRepository: di()));

    // Blocs
    di.registerLazySingleton(
            () => MangerGetVipPrevBloc(getVipPrevUseCase: di()));
    di.registerLazySingleton(() => PrivacyBloc(
      activePrivacyUseCase: di(),
      disActivePrivacyUseCase: di(),
    ));
    di.registerLazySingleton(() => BuyVipBloc(buyVipUseCase: di()));
    di.registerLazySingleton(() => VipCenterBloc(
      useVipUseCase: di(),
      fetchVipCenterUseCase: di(),
      sendVips: di(),
      getVipMyBag: di(),
    ));
    di.registerLazySingleton(() => GetVipThemeSettingsBloc(di()));
  }

  /// Games
  static void initGames() {
    if (_initialized.contains('games')) return;
    _initialized.add('games');

    // Use cases
    di.registerLazySingleton(() => FetchUsersGamersUC(di()));
    di.registerLazySingleton(() => StopGamersUc(di()));
    di.registerLazySingleton(() => FetchOnlineUsersUc(di()));

    // Blocs
    di.registerLazySingleton<ActionBloc>(() => ActionBloc(di(), di()));
    di.registerLazySingleton(() => OnlineUsersBloc(di()));
    di.registerLazySingleton<GetUserProfilesBloc>(
            () => GetUserProfilesBloc(getAllProfileUsersUseCase: di()));
  }

  /// Daily tasks
  static void initTasks() {
    if (_initialized.contains('tasks')) return;
    _initialized.add('tasks');

    // Use cases
    di.registerLazySingleton(() => GetTasksProgressUseCase(di()));
    di.registerLazySingleton(() => CollectTaskPointsUseCase(di()));

    // Blocs
    di.registerLazySingleton(() => TasksBloc(di(), di()));
  }

  /// CP (couple)
  static void initCp() {
    if (_initialized.contains('cp')) return;
    _initialized.add('cp');

    // Use cases
    di.registerLazySingleton(() => CpRequestUseCase(di()));
    di.registerLazySingleton(() => GetCpRelationsUseCase(di()));
    di.registerLazySingleton<FetchRankingCpUC>(() => FetchRankingCpUC(di()));
    di.registerLazySingleton(() => CpBuySeatsUseCase(di()));
    di.registerLazySingleton(() => CpProfileUseCase(di()));
    di.registerLazySingleton(() => CpRequestRespondUseCase(di()));
    di.registerLazySingleton(() => GetCpLevelsGiftsUC(di()));
    di.registerLazySingleton(() => GetRelationsCpSpecialFriendUC(di()));

    // Blocs
    di.registerLazySingleton(() => CpBloc(di()));
    di.registerLazySingleton(() => CpRequestBloc(cpRequestUseCase: di()));
    di.registerLazySingleton(() => CpRelationsLevelsBloc(di(), di()));
    di.registerLazySingleton(() => GetCpRelationsBloc(di(), di()));
    di.registerFactory(() => CpProfileBloc(
      cpProfileUseCase: di(),
      cpBuySeatsUseCase: di(),
    ));
  }

  /// Mall & Bag
  static void initMallBag() {
    if (_initialized.contains('mallBag')) return;
    _initialized.add('mallBag');

    // Use cases
    di.registerLazySingleton(
            () => GetBackBagUseCase(mallBagBaseRepository: di()));
    di.registerLazySingleton(
            () => UnUseBagItemUseCase(mallBagBaseRepository: di()));
    di.registerLazySingleton(
            () => UseBagItemUseCase(mallBagBaseRepository: di()));
    di.registerLazySingleton(
            () => GetMallDataUseCase(mallBagBaseRepository: di()));
    di.registerLazySingleton(
            () => BuyFromMallUseCase(mallBagBaseRepository: di()));
    di.registerLazySingleton(
            () => SendFromMallUseCase(mallBagBaseRepository: di()));
    di.registerLazySingleton(
            () => SendFromBagUseCase(mallBagBaseRepository: di()));
    di.registerLazySingleton(
            () => BuyMallSpecialIdUC(mallBagBaseRepository: di()));
    di.registerLazySingleton(
            () => UseUnUseBagItemSpecialIdUC(mallBagBaseRepository: di()));

    // Blocs
    di.registerLazySingleton(() => UseUnUseBloc(
      unUseBagItemUseCase: di(),
      useBagItemUseCase: di(),
      unUseBagItemSpecialIdUC: di(),
    ));
    di.registerLazySingleton(() => MallBuyBloc(
      buyUseCase: di(),
      buyMallSpecialIdUC: di(),
    ));
    di.registerLazySingleton(() => MallSendBloc(sendUseCase: di()));
    di.registerLazySingleton(() => MyBagBloc(getBackPackUseCase: di()));
    di.registerLazySingleton(() => MallBloc(getMallDataUseCase: di()));
    di.registerLazySingleton(() => BagSendBloc(sendUseCase: di()));
  }

  /// Reels
  static void initReels() {
    if (_initialized.contains('reels')) return;
    _initialized.add('reels');

    // Use cases
    di.registerLazySingleton<GetPreSignedUrlUseCase>(
            () => GetPreSignedUrlUseCase(baseRepositoryReels: di()));
    di.registerLazySingleton<UploadFileToStorageUseCase>(
            () => UploadFileToStorageUseCase(baseRepositoryReels: di()));
    di.registerLazySingleton<NotifyBackendUseCase>(
            () => NotifyBackendUseCase(baseRepositoryReels: di()));
    di.registerLazySingleton<MakeLikeUseCase>(
            () => MakeLikeUseCase(baseRepositoryReels: di()));
    di.registerLazySingleton<MakeCommentsUseCase>(
            () => MakeCommentsUseCase(baseRepositoryReels: di()));
    di.registerLazySingleton<GetFollowingReelsUseCase>(
            () => GetFollowingReelsUseCase(baseRepositoryReels: di()));
    di.registerLazySingleton<GetCommentsUseCase>(
            () => GetCommentsUseCase(baseRepositoryReels: di()));
    di.registerLazySingleton<GetReelsUseCase>(
            () => GetReelsUseCase(baseRepositoryReels: di()));
    di.registerLazySingleton<GetOneReelsUseCase>(
            () => GetOneReelsUseCase(baseRepositoryReels: di()));
    di.registerLazySingleton<GetMyReelsUseCase>(
            () => GetMyReelsUseCase(baseRepositoryReels: di()));
    di.registerLazySingleton<UpdateReelDescriptionUseCase>(
            () => UpdateReelDescriptionUseCase(baseRepositoryReels: di()));
    di.registerLazySingleton<DeleteReelUseCase>(
            () => DeleteReelUseCase(baseRepositoryReels: di()));

    // Blocs
    di.registerLazySingleton<ReelViewerBloc>(() => ReelViewerBloc());
    di.registerLazySingleton<ShareReelBloc>(() => ShareReelBloc());
    di.registerLazySingleton<GetReelsBloc>(
            () => GetReelsBloc(di(), di(), di(), di(), di()));
    di.registerLazySingleton<GetCommentsBloc>(() => GetCommentsBloc(di()));
    di.registerLazySingleton<GetFollowingReelsBloc>(
            () => GetFollowingReelsBloc(di()));
    di.registerLazySingleton<MakeCommentsBloc>(() => MakeCommentsBloc(di()));
    di.registerLazySingleton<MakeLikeBloc>(() => MakeLikeBloc(di()));
    di.registerLazySingleton<UploadReelBloc>(
            () => UploadReelBloc(di(), di(), di()));
  }
}
