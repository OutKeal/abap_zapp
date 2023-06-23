*&---------------------------------------------------------------------*
*& 包含               ZAPP_FLOW_SEL
*&---------------------------------------------------------------------*



SELECTION-SCREEN BEGIN OF BLOCK bl WITH FRAME TITLE TEXT-001.
*  PARAMETERS: create TYPE c RADIOBUTTON GROUP g2 USER-COMMAND singleclick, "创建
*              modify TYPE c RADIOBUTTON GROUP g2 DEFAULT 'X'. "查询修改
  PARAMETERS: p_object LIKE zapp_object-object  AS LISTBOX VISIBLE LENGTH 20  MEMORY ID app_object.
SELECTION-SCREEN END OF BLOCK bl.


SELECTION-SCREEN BEGIN OF BLOCK b4 WITH FRAME TITLE TEXT-004.
  PARAMETERS: p_key1 TYPE zapp_flow_head-key1 MODIF ID c,
              p_key2 TYPE zapp_flow_head-key2 MODIF ID c,
              p_key3 TYPE zapp_flow_head-key3 MODIF ID c,
              p_key4 TYPE zapp_flow_head-key4 MODIF ID c,
              p_key5 TYPE zapp_flow_head-key5 MODIF ID c,
              p_key6 TYPE zapp_flow_head-key6 MODIF ID c.
SELECTION-SCREEN END OF BLOCK b4.


SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-002.
  SELECT-OPTIONS: s_appno FOR zapp_flow_head-appno MEMORY ID zappno MODIF ID m,
                  s_key1 FOR zapp_flow_head-key1 MODIF ID m,
                  s_erdat FOR zapp_flow_head-erdat MODIF ID m.
SELECTION-SCREEN END OF BLOCK b2.


SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE TEXT-003.
  SELECT-OPTIONS: s_dep FOR zapp_flow_item-department MODIF ID m  NO INTERVALS,
                  s_spr FOR suid_st_bname-bname MODIF ID m NO INTERVALS.
SELECTION-SCREEN END OF BLOCK b3.

SELECTION-SCREEN BEGIN OF BLOCK b5 WITH FRAME TITLE TEXT-005.
  PARAMETERS: p_ds  TYPE c RADIOBUTTON GROUP g1 USER-COMMAND singleclick, "我的待处理
              p_ys  TYPE c RADIOBUTTON GROUP g1 , "我的所有
              p_all TYPE c RADIOBUTTON GROUP g1.  "所有人的作业
SELECTION-SCREEN END OF BLOCK b5.
