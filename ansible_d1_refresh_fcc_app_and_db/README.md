# ansible_d1_refresh_fcc_app_and_db

This project is for D-1 to refresh FCC Application and Database


The pipeline will execute sequential follow this lists

- DB: Prepare files for execute (AWX: template_d1_refresh_fcc_app_and_db_job_AI)

- APP: Stop Weblogic application (AWX: RESTART_FCCv14_AllService_GOC)

- DB: Shutdown D-1 DataBase (AWX: template_d1_refresh_fcc_app_and_db_job_AI)
    - genalluser (roles/Dminus1-DB-Prepare-Files/files/genalluser.sh)
    - export FCC data and Weblogic (roles/Dminus1-DB-Prepare-Files/files/expdp_weblogic.sh)
    - shutdown D1 (roles/Dminus1-DB-Prepare-Files/files/shutdown_database.sh)

- INFRA: Unmount D-1 Database Disk (AWX: D-1_INFRA_UnMount_job_AI)

- DB: Freeze PRD DataBase (AWX: template_d1_refresh_fcc_app_and_db_job_AI)
    - freeze db (roles/Dminus1-DB-Prepare-Files/files/flush_db_and_freeze.sh)

- INFRA: Take Snapshot on PRD DataBase (AWX: D-1_INFRA_TakeSnapshot_job_AI)

- DB: UnFreeze PRD DataBase (AWX: template_d1_refresh_fcc_app_and_db_job_AI)
    - unfreeze db (roles/Dminus1-DB-Prepare-Files/files/unfreeze_db.sh)

- INFRA: Mount D-1 DataBase Disk Mount (AWX: D-1 DataBase Disk)

- DB: Startup D-1 Database (AWX: template_d1_refresh_fcc_app_and_db_job_AI)
    - Startup D1 (roles/Dminus1-DB-Prepare-Files/files/start_database.sh)
    - Import FCC user and password (roles/Dminus1-DB-Prepare-Files/files/run_after_refresh.sh)
    - Import Weblogic (roles/Dminus1-DB-Prepare-Files/files/impdp_weblogic.sh)

- APP: Start Weblogic application (AWX: RESTART_FCCv14_AllService_GOC)

- APP: Sync WLS Data and restart WLS (AWX: REFRESH_FCCv14_APP_AI)
