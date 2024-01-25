## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##
#    GI and Oracle Home Patch Installation (Apply) for Non-RAC 	#	
#   =========================================================== #
## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##

Step          Step_Main_ymal_File                Task File
===================================================================
1) ruinit	      ru_apply_init_main.yml	          create_backup_and_log_dir.yml

2) ruprecheck	  ru_apply_prerequisites_main.yml	  db_home_prerequisites.yml
		                                              gi_home_prerequisites.yml
		                                              backup_db_and_gi_home_files.yml
		                                              list_backup_files.yml
		                                              get_db_and_services_status.yml
		                                              database_component_status.yml

3) ruapply	    ru_apply_main.yml	                stop_database.yml
		                                              db_home_release_update_apply.yml
		                                              gi_home_release_update_apply.yml
		                                              verify_opatch_apply_status.yml
		                                              start_database.yml

4) rudbsql	    ru_db_sql_main.yml	              database_ru_post_installation.yml
		                                              compile_invalid_objects.yml
		                                              release_update_post_validation.yml

      ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## #
      #         Patch Deinstallation (Rollback)     	#
      ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## #	

Step              Step_Main_ymal_File                Task File
==========================================================================
1)  rurollback	  rb_ru_rollback_main.yml	        rb_stop_database.yml
		                                              rb_db_home_release_update_rollback.yml
		                                              rb_gi_home_release_update_rollback.yml
		                                              rb_verify_opatch_rollback_status.yml
		                                              rb_start_database.yml
		                                              rb_db_ru_post_deinstallation.yml
		                                              compile_invalid_objects.yml
		                                              rb_db_ru_post_deinstall_validation.yml