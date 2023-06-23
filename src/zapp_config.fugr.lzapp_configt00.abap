*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZAPP_MANAGER....................................*
DATA:  BEGIN OF STATUS_ZAPP_MANAGER                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZAPP_MANAGER                  .
CONTROLS: TCTRL_ZAPP_MANAGER
            TYPE TABLEVIEW USING SCREEN '0007'.
*...processing: ZAPP_OBJECT.....................................*
DATA:  BEGIN OF STATUS_ZAPP_OBJECT                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZAPP_OBJECT                   .
CONTROLS: TCTRL_ZAPP_OBJECT
            TYPE TABLEVIEW USING SCREEN '0001'.
*...processing: ZAPP_OBJECT_KEY.................................*
DATA:  BEGIN OF STATUS_ZAPP_OBJECT_KEY               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZAPP_OBJECT_KEY               .
CONTROLS: TCTRL_ZAPP_OBJECT_KEY
            TYPE TABLEVIEW USING SCREEN '0002'.
*...processing: ZAPP_PROCESS....................................*
DATA:  BEGIN OF STATUS_ZAPP_PROCESS                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZAPP_PROCESS                  .
CONTROLS: TCTRL_ZAPP_PROCESS
            TYPE TABLEVIEW USING SCREEN '0003'.
*...processing: ZAPP_PROCESS_CON................................*
DATA:  BEGIN OF STATUS_ZAPP_PROCESS_CON              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZAPP_PROCESS_CON              .
CONTROLS: TCTRL_ZAPP_PROCESS_CON
            TYPE TABLEVIEW USING SCREEN '0004'.
*...processing: ZAPP_PROCESS_FLO................................*
DATA:  BEGIN OF STATUS_ZAPP_PROCESS_FLO              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZAPP_PROCESS_FLO              .
CONTROLS: TCTRL_ZAPP_PROCESS_FLO
            TYPE TABLEVIEW USING SCREEN '0005'.
*...processing: ZAPP_REPLACE_USR................................*
DATA:  BEGIN OF STATUS_ZAPP_REPLACE_USR              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZAPP_REPLACE_USR              .
CONTROLS: TCTRL_ZAPP_REPLACE_USR
            TYPE TABLEVIEW USING SCREEN '0006'.
*.........table declarations:.................................*
TABLES: *ZAPP_MANAGER                  .
TABLES: *ZAPP_OBJECT                   .
TABLES: *ZAPP_OBJECT_KEY               .
TABLES: *ZAPP_PROCESS                  .
TABLES: *ZAPP_PROCESS_CON              .
TABLES: *ZAPP_PROCESS_FLO              .
TABLES: *ZAPP_REPLACE_USR              .
TABLES: ZAPP_MANAGER                   .
TABLES: ZAPP_OBJECT                    .
TABLES: ZAPP_OBJECT_KEY                .
TABLES: ZAPP_PROCESS                   .
TABLES: ZAPP_PROCESS_CON               .
TABLES: ZAPP_PROCESS_FLO               .
TABLES: ZAPP_REPLACE_USR               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
