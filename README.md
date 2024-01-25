# Oracle 19c patching - AAP2

## A single playbook and multiple task and vars files which can be used to apply Oracle 19c patching as code.

### To install the csc ansible-role via the `ansible-galaxy` command you'll need to create a [requirements.yml](roles/requirements.yml) file in "roles/" directory (if one doesn't already exist), with the following contents:

```bash
---
- name: ansible-role_orapatch
  src: https://cscgithub.cscglobal.com/INFRA/ansible-role_orapatch
  scm: git
```

...and install role(s) using the following command from parent directory:

`ansible-galaxy install -p roles -r roles/requirements.yml`

## Default Variables

See [`defaults/main.yml`](defaults/main.yml).

Default Variables listed below: Need to add

## Custom Variables

See [`vars/main.yml`](vars/main.yml).


| Variable | Description |
| --- | --- |
log_dir: | Patch prerequisites and installation related log files to be stored on this location  
rb_log_dir: |  Patch rollback related logs files to stored on this location 
patch_dir: | RU binary files to apply against database and grid infrastructure home  patch_local_dir:| location to copy patch binary to node local directory 
current_version: | current database version (release update version)
host_group: | release update patch will be installed on this host group from the nventory 
gi_patch_id: | grid infrastructure patch id/number 
db_patch_id: | database patch id/number 
patch_id_*: | patch number inside the grid patch folder 

# variables to apply oracle release update 19.16  on the current 19.11 relase update.
log_dir: "/orautl/SOFTWARE/19cSoftware/19.16.PatchSet/ru_apply_log"

rb_log_dir: "/orautl/SOFTWARE/19cSoftware/19.16.PatchSet/ru_rollback_log"

patch_dir: "/orautl/SOFTWARE/19cSoftware/19.16.PatchSet"

patch_local_dir: "/opt/app/oracle/patches"

current_version: 1911

host_group: ora_rac1:ora_rac2

gi_patch_id: 34130714

db_patch_id: 34133642

patch_id_1: 33575402

patch_id_2: 34133642

patch_id_3: 34139601

patch_id_4: 34160635

patch_id_5: 34318175

rac_script: "{{patch_dir}}/scripts"

oracle_sid: "{{DB_NAME}}"

oracle_home_2: "{{ ORACLE_HOME}}"


## The  following are main tasks which  are  included in the main.yml file under the task folder  for executing various patch updates steps for both Non-RAC and RAC Grid as well as DB.
#### Each task names are mentioned below. Each task inturn calls further sub-tasks ( in the same task folder) to execute specific job like pre-check, backup,applying both the Grid and database patches as well as rollback if required. Only one task should be  and  can be run from the Ansible Tower by providing the core of the release update (ru)task like "runinit" or "ruprecheck" etc. These tasks are need to be run in the given order except deinstall (rollback) step. Only if you want to deinstall the patch update you need to run else skip the step.

The tasks are:
---
## install grid infrastructure and database home release update on Non-RAC database 

- include_tasks: ru_apply_init_main.yml
  when: release_update_step == "ruinit"

- include_tasks: ru_apply_prerequisites_main.yml
  when: release_update_step == "ruprecheck"

- include_tasks: ru_apply_main.yml
  when: release_update_step == "ruapply"

- include_tasks: ru_db_sql_main.yml
  when: release_update_step == "rudbsql"

deinstall(rollback) grid infrastructure and database home release update on Non-RAC database :

- include_tasks: rb_ru_rollback_main.yml
  when: release_update_step == "rurollback"


# install grid infrastructure and database home release update on RAC database

- include_tasks: ru_rac_apply_init_main.yml
  when: release_update_step == "ruracinit"

- include_tasks: ru_rac_apply_prerequisites_main.yml
  when: release_update_step == "ruracprecheck"

- include_tasks: ru_rac_apply_main.yml
  when: release_update_step == "ruracapply"

- include_tasks: ru_db_sql_main.yml
  when: release_update_step == "ruracdbsql"


# deinstall(rollback) grid infrastructure and database home release update on RAC database :

- include_tasks: rb_ru_rac_rollback_main.yml
  when: release_update_step == "ruracrollback"

- include_tasks: rb_ru_rac_db_sql_rollback_main.yml
  when: release_update_step == "rudbsqlrollback"

  ## Listing  sub-tasks in each main tasks:

 ### The first main task "ru_apply_init_main.yml" in turn call another yml file to create_backup_and_log_dir.yml. The following sub tasks are run in that order :
create backup location

create release update installation log file directory

create release update deinstallation log file directory

create rac svc relocate and instance start and stop script file directory

create local directory to copy release update files.

copy shell scripts to
### The second main task "ru_apply_prerequisites_main.yml" calls a sub-task "ru_apply_main.yml" which in turn executes the below sub tasks to stop the database, apply database and grid home release update and start the database.

stop_database.yml

db_home_release_update_apply.yml

gi_home_release_update_apply.yml

verify_opatch_apply_status.yml

start_database.yml

start_database.yml


### The third main   task "ru_apply_main.yml" calls a sub-task "ru_apply_main.yml" which in turn executes the below sub tasks:
### The below list of tasks to stop the database, apply database and grid home release update and start the database.

stop_database.yml

db_home_release_update_apply.yml

gi_home_release_update_apply.yml

verify_opatch_apply_status.yml

start_database.yml
 
 ### The  fourth  main  task "ru_db_sql_main.yml" calls a sub-task "ru_db_sql_main.yml" which in turn executes the below  tasks to complete release update database steps and complile invalid objects.

database_ru_post_installation.yml

compile_invalid_objects.yml

#### The below task will validate database component status, ru apply status, database and service status

release_update_post_validation.yml
 
### The fifth main task "ru_rac_apply_init_main.yml" is for instaling grid infrastructure and database home release update on RAC database.  Which has the following two sub tasks to create initial folder structure to backup current home files and spool patch installation log files.
 
 create_backup_and_log_dir.yml
 
 create_svc_inst_script.yml
 
 ### The sixth  task "ru_rac_apply_prerequisites_main.yml" has other sub-tasks to complete patch conflict check, backup current grid and database home  verify the service, pdb open mode and database component status.
 
 rac_db_home_prerequisites.yml
 
 gi_home_prerequisites.yml
 
 rac_backup_db_and_gi_home_files.yml
 
 list_backup_files.yml
 
 get_db_and_services_status.yml
 
 rac_database_component_status.yml

### The seventh main task "ru_rac_apply_main.yml" has below list of sub-tasks to relocate service, stop instance, apply database and grid home release update and start instance, relocate services back to preffered node

rac_svc_relocate_stop_instance.yml

rac_db_home_release_update_apply.yml

gi_home_release_update_apply.yml

rac_verify_opatch_apply_status.yml

rac_start_inst_svc_relocate.yml

### The eigth main task "ru_db_sql_main.yml"  has the below list of sub-tasks to complete release update, database steps and complile invalid objects.

database_ru_post_installation.yml

compile_invalid_objects.yml

the below task will validate database component status, ru apply status, database and service status 

release_update_post_validation.yml


## DEINSTALL (ROLLBACK ) Of Non-RAC AND RAC PATCH UPDATES

### In case of Non-RAC deinstall(rollback) of grid infrastructure and database home release update  the mian task "rb_ru_rollback_main.yml" need to be executed. This main yml file will execute the below list of tasks to stop the database, rollback database and grid home release update patchand start the database to perform post deinstallation steps

rb_stop_database.yml

rb_db_home_release_update_rollback.yml

rb_gi_home_release_update_rollback.yml

rb_verify_opatch_rollback_status.yml

rb_start_database.yml

rb_db_ru_post_deinstallation.yml

compile_invalid_objects.yml

rb_db_ru_post_deinstall_validation.yml

### In case of deinstall(rollback) grid infrastructure and database home release update on RAC database, two main  tasks "rb_ru_rac_rollback_main.yml"  and "rb_ru_rac_db_sql_rollback_main.yml" are need to be run.  The "rb_ru_rac_rollback_main.yml" will in turn will execute the below list of sub-tasks to stop the instance, rollback database and grid home release update patch and start the instance to perform post deinstallation steps

rb_rac_svc_relocate_stop_instance.yml

rb_rac_db_home_release_update_rollback.yml

rb_gi_home_release_update_rollback.yml

rb_rac_verify_opatch_rollback_status.yml

rb_rac_start_inst_svc_relocate.yml

### The other main task "rb_ru_rac_db_sql_rollback_main.yml" will execute execute the below sub-tasks to complete release update database rollback steps and complile invalid objects

rb_db_ru_post_deinstallation.yml

compile_invalid_objects.yml

rb_db_ru_post_deinstall_validation.yml

rb_ru_rac_db_sql_rollback_main.yml




#    GI and Oracle Home Patch Installation (Apply) for Non-RAC 	#	
     
## The following table summerise the briefly the tasks outlined above.

| Step  |        Step_Main_ymal_File     |           Task File |
|--- | --- | --- |
ruinit:| ru_apply_init_main.yml |        create_backup_and_log_dir.yml
ruprecheck:	| ru_apply_prerequisites_main.yml | db_home_prerequisites.yml 	                                          
  |   | |                                         gi_home_prerequisites.yml 
  |   |  |                                        backup_db_and_gi_home_files.yml 
  |  |  |                                         list_backup_files.yml 
 |  |  |                                          get_db_and_services_status.yml 
| | |                                             database_component_status.yml 
ruapply: |    ru_apply_main.yml	 |                stop_database.yml 
| | |                                             db_home_release_update_apply.yml 
| | |                                             gi_home_release_update_apply.yml 
| | |		                                          verify_opatch_apply_status.yml 
| | |                                             start_database.yml 
rudbsql:	|   ru_db_sql_main.yml	|               database_ru_post_installation.yml
| | |                                             compile_invalid_objects.yml
| | |                                             release_update_post_validation.yml

      
               Patch Deinstallation (Rollback)     	
      

| Step  |        Step_Main_ymal_File     |           Task File |
|--- | --- | --- |
rurollback: |	  rb_ru_rollback_main.yml	  |    rb_stop_database.yml
| | |                                              rb_db_home_release_update_rollback.yml
| | |                                              rb_gi_home_release_update_rollback.yml
| | |                                              rb_verify_opatch_rollback_status.yml
| | |                                              rb_start_database.yml
| | |                                              rb_db_ru_post_deinstallation.yml
| | |                                              compile_invalid_objects.yml
| | |                                              rb_db_ru_post_deinstall_validation.yml