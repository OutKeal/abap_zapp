*&---------------------------------------------------------------------*
*& 包含               LZJS_COSTF01
*&---------------------------------------------------------------------*





DATA: g_grid_up           TYPE REF TO cl_gui_alv_grid,
      g_grid_down         TYPE REF TO cl_gui_alv_grid,
      gt_fcat_up          TYPE lvc_t_fcat,
      gt_fcat_down        TYPE lvc_t_fcat,
      gs_layout_down      TYPE lvc_s_layo,
      gs_layout_up        TYPE lvc_s_layo,
      gt_sort             TYPE lvc_t_sort,
      gt_exclude          TYPE ui_functions,
      g_docking_container TYPE REF TO cl_gui_docking_container,
      g_cumtom_container  TYPE REF TO cl_gui_custom_container,
      g_container_1       TYPE REF TO cl_gui_container,
      g_container_2       TYPE REF TO cl_gui_container,
      g_splitter          TYPE REF TO cl_gui_splitter_container,
      g_toolbar           TYPE REF TO cl_gui_toolbar.

DATA:index TYPE sy-tabix.

DATA:
  gt_fieldcat_alv TYPE slis_t_fieldcat_alv WITH HEADER LINE, "定义存放字段信息的内表
  gs_layout       TYPE slis_layout_alv, "定义存放画面布局控制数据的工作区
  gv_grid         TYPE REF TO cl_gui_alv_grid,
  gv_repid        LIKE sy-repid VALUE sy-repid. "报表ID


CLASS:
  lcl_event_receiver_grid DEFINITION DEFERRED.

CONSTANTS:
  cns_extension TYPE i VALUE 3000.  "DOCKING SIZE
DATA:
  g_event_receiver_grid   TYPE REF TO lcl_event_receiver_grid.

*&---------------------------------------------------------------------*
*&       CLASS LCL_EVENT_RECEIVER_GRID DEFINITION
*&---------------------------------------------------------------------*
CLASS lcl_event_receiver_grid DEFINITION.

  PUBLIC SECTION.
* DATA CHANGED
*    METHODS: HANDLE_DATA_CHANGED
*                FOR EVENT DATA_CHANGED OF CL_GUI_ALV_GRID
*      IMPORTING ER_DATA_CHANGED
*                E_ONF4.
    METHODS handle_changed_finished
      FOR EVENT data_changed_finished OF cl_gui_alv_grid
      IMPORTING e_modified et_good_cells.

    METHODS handle_click
      FOR EVENT hotspot_click OF cl_gui_alv_grid
      IMPORTING e_row_id e_column_id es_row_no.

    METHODS toolbar
      FOR EVENT toolbar OF cl_gui_alv_grid
      IMPORTING e_object.

    METHODS handle_user_command
      FOR EVENT user_command OF cl_gui_alv_grid
      IMPORTING e_ucomm.

    METHODS handle_double_click
      FOR EVENT double_click OF cl_gui_alv_grid
      IMPORTING e_row e_column.


    METHODS handle_after_refresh
        FOR EVENT after_refresh OF cl_gui_alv_grid.
ENDCLASS.                    "LCL_EVENT_RECEIVER_GRID DEFINITION

*---------------------------------------------------------------------*
*       CLASS LCL_EVENT_RECEIVER_GRID IMPLEMENTATION
*---------------------------------------------------------------------*
*
*---------------------------------------------------------------------*
CLASS lcl_event_receiver_grid IMPLEMENTATION.
* DATA CHANGED
*  METHOD HANDLE_DATA_CHANGED.
*    PERFORM F_HANDLE_DATA_CHANGED
*      USING ER_DATA_CHANGED
*            E_ONF4.
*  ENDMETHOD.                    "HANDLE_DATA_CHANGED

  METHOD handle_changed_finished.
    PERFORM f_changed_finished USING et_good_cells .

  ENDMETHOD.                    "HANDLE_MODIFY

  METHOD handle_click.
    DATA:ls_modi TYPE lvc_s_modi.
    DATA stbl TYPE lvc_s_stbl.

    PERFORM frm_hotspot_click USING e_column_id e_row_id.
  ENDMETHOD.

  METHOD toolbar.
    PERFORM f_toolbar USING e_object->mt_toolbar.
  ENDMETHOD.

  METHOD handle_user_command.
    PERFORM f_user_command USING e_ucomm.
  ENDMETHOD.

  METHOD handle_double_click.
    PERFORM f_handle_double_click USING e_row e_column.
  ENDMETHOD.

  METHOD handle_after_refresh.
    PERFORM f_handle_after_refresh.
  ENDMETHOD.

ENDCLASS.                    "LCL_EVENT_RECEIVER_GRID IMPLEMENTATION
*&---------------------------------------------------------------------*
*& 包含               ZJS_COST_ALV
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& MODULE STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  DATA fcode TYPE TABLE OF sy-ucomm.

  CLEAR: fcode.

  SELECT SINGLE name1 INTO @DATA(ls_name)
    FROM zapp_object WHERE object = @gv_object.


  APPEND '&MYDETAIL' TO fcode.

  SET TITLEBAR 'TT001' WITH '-' ls_name '-' gv_object .
  SET PF-STATUS 'S100' EXCLUDING fcode.
ENDMODULE.


CLASS lcl_event_handler DEFINITION DEFERRED.

DATA: go_timer    TYPE REF TO cl_gui_timer,
      go_evt_hndl TYPE REF TO lcl_event_handler,
      gv_datum    TYPE sy-datum,
      gv_uzeit    TYPE sy-uzeit.

CLASS lcl_event_handler DEFINITION.

  PUBLIC SECTION.
    METHODS:
      handle_timer FOR EVENT finished OF cl_gui_timer.

ENDCLASS.                    "lcl_event_handler DEFINITION

*&---------------------------------------------------------------------*

*&      CLASS lcl_event_handler IMPLEMENTATION

*&---------------------------------------------------------------------*

CLASS lcl_event_handler IMPLEMENTATION.

  METHOD handle_timer.

    CALL METHOD cl_gui_cfw=>set_new_ok_code
      EXPORTING
        new_code = '&REFRESH'.

    CALL METHOD go_timer->run "必须重新激活定时器
      EXCEPTIONS
        OTHERS = 9.

  ENDMETHOD.                 "handle_timer

ENDCLASS.                    "lcl_event_handler IMPLEMENTATION


FORM init_timer.

  CHECK go_timer IS INITIAL.

  CREATE OBJECT go_timer
    EXCEPTIONS
      OTHERS = 9.

  CREATE OBJECT go_evt_hndl.

  SET HANDLER go_evt_hndl->handle_timer FOR go_timer.

  go_timer->interval = 300.  "设置间隔为10秒

  CALL METHOD go_timer->run "激活定时器
    EXCEPTIONS
      OTHERS = 9.

ENDFORM.                    " INIT_TIMER


MODULE init_timer OUTPUT.
  PERFORM init_timer.
ENDMODULE.


MODULE create_object_0100 OUTPUT.

  IF g_grid_up IS INITIAL.
**-- CREATE CONTAINER
    PERFORM f_create_container.
**-- LAYOUT
    PERFORM f_create_grid_layout.
**-- TOOLBAR EXCLUDE
    PERFORM f_create_grid_exclude_toolbar  CHANGING gt_exclude[].

    PERFORM f_set_grid_field_catalog_up.

    PERFORM f_set_sort_up.

    PERFORM f_assign_grid_handlers_up CHANGING g_grid_up.

    PERFORM f_register_grid_event USING g_grid_up.

***-- DISPLAY GRID ALV
*    CALL METHOD CL_GUI_CFW=>FLUSH.
    PERFORM f_display_grid_alv_up .

  ELSE .
    PERFORM f_refresh_grid_alv USING g_grid_up.
  ENDIF.


  IF g_grid_down IS INITIAL.

    CREATE OBJECT g_grid_down
      EXPORTING
        i_parent = g_container_2.
**-- FIELD_CATALOG DEFINE
    PERFORM f_set_grid_field_catalog_down.
**-- GRID EVENT HANDLER DEFINE
    PERFORM f_assign_grid_handlers_down CHANGING g_grid_down.
**-- REGISTER EVENT
    PERFORM f_register_grid_event USING g_grid_down.
****-- DISPLAY GRID ALV
*    CALL METHOD CL_GUI_CFW=>FLUSH.
    PERFORM f_display_grid_alv_down USING gt_item_dis[].

  ELSE.
**--
    PERFORM f_refresh_grid_alv USING g_grid_down.
  ENDIF.

ENDMODULE.


MODULE exit INPUT.
  LOOP AT gt_head.
    CALL FUNCTION 'DEQUEUE_EZAPP_FLOW_HEAD'
      EXPORTING
        mode_zapp_flow_head = 'E'
        mandt               = sy-mandt
        appno               = gt_head-appno.

  ENDLOOP.


  CASE sy-ucomm.
    WHEN 'BACK'.
      CLEAR sy-ucomm.
      LEAVE TO SCREEN 0.

    WHEN 'CANCEL'.
      CLEAR sy-ucomm.
      SET SCREEN 0.
      LEAVE SCREEN.

    WHEN 'EXIT' OR 'QUIT'.
      CLEAR sy-ucomm.

      IF sy-calld IS INITIAL.
        LEAVE TO SCREEN 0.
      ELSE.
        LEAVE PROGRAM.
      ENDIF.
  ENDCASE.

ENDMODULE.


MODULE user_command_0100 INPUT.
  PERFORM frm_user_command_0100.
ENDMODULE.


FORM f_create_container.

  IF g_docking_container IS INITIAL.
    CREATE OBJECT g_docking_container
      EXPORTING
        style     = cl_gui_control=>ws_child
        repid     = sy-repid
        dynnr     = sy-dynnr
        side      = g_docking_container->dock_at_left
        lifetime  = cl_gui_control=>lifetime_imode
        extension = cns_extension
      EXCEPTIONS
        OTHERS    = 1.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid
            TYPE sy-msgty
          NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.

*  CREATE OBJECT g_cumtom_container
*    EXPORTING
*      container_name = 'ITEM'.


* SPLITTER CONTAINER
  IF g_splitter IS INITIAL.
    CREATE OBJECT g_splitter
      EXPORTING
        parent  = g_docking_container
        rows    = 2
        columns = 1.


    CALL METHOD g_splitter->set_row_height
      EXPORTING
        id     = 1
        height = 50.
*
*    CALL METHOD G_SPLITTER->SET_ROW_HEIGHT
*      EXPORTING
*        ID     = 2
*        HEIGHT = 400.

    g_container_1  = g_splitter->get_container( row = 1 column = 1 ).
    CREATE OBJECT g_grid_up
      EXPORTING
        i_parent = g_container_1.

    g_container_2  = g_splitter->get_container( row = 2 column = 1 ).

  ENDIF.
ENDFORM.


FORM f_set_grid_field_catalog_up .

  REFRESH: gt_fcat_up.
  REFRESH: gt_fieldcat_alv[].


  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
*     I_PROGRAM_NAME         =
*     I_INTERNAL_TABNAME     =
      i_structure_name       = 'ZAPP_HEAD'
      i_client_never_display = 'X'
*     I_INCLNAME             =
*     I_BYPASSING_BUFFER     =
*     I_BUFFER_ACTIVE        =
    CHANGING
      ct_fieldcat            = gt_fieldcat_alv[]
*   EXCEPTIONS
*     INCONSISTENT_INTERFACE = 1
*     PROGRAM_ERROR          = 2
*     OTHERS                 = 3
    .


  PERFORM f_transfer_slis_to_lvc CHANGING gt_fieldcat_alv[]
                                          gt_fcat_up[].

  LOOP AT gt_fcat_up ASSIGNING FIELD-SYMBOL(<fs_fcat>).

    CASE <fs_fcat>-fieldname .
      WHEN 'ICON'.
        <fs_fcat>-scrtext_s = <fs_fcat>-scrtext_m =
        <fs_fcat>-scrtext_l = <fs_fcat>-reptext = TEXT-004."'状态'.
      WHEN 'TEXT'.
        <fs_fcat>-scrtext_s = <fs_fcat>-scrtext_m =
        <fs_fcat>-scrtext_l = <fs_fcat>-reptext = TEXT-005."'消息'.
      WHEN 'KEY1'.
        <fs_fcat>-hotspot = 'X'.
      WHEN 'OBJECT'.
        <fs_fcat>-tech = 'X'.

    ENDCASE.

    IF <fs_fcat>-fieldname+0(3) = 'KEY'.
      READ TABLE gt_object_key WITH KEY key_type = <fs_fcat>-fieldname .
      IF sy-subrc EQ 0.
        IF gv_object IS NOT INITIAL.
          <fs_fcat>-scrtext_s = <fs_fcat>-scrtext_m =
          <fs_fcat>-scrtext_l = <fs_fcat>-reptext = gt_object_key-name1.
        ENDIF.
      ELSE.
        <fs_fcat>-tech = 'X'.
      ENDIF.
    ENDIF.

    IF <fs_fcat>-col_pos <= 9.
      <fs_fcat>-fix_column = 'X'.
      <fs_fcat>-emphasize = 'C710'.
    ENDIF.

  ENDLOOP.

ENDFORM.


FORM f_set_grid_field_catalog_down .

  REFRESH: gt_fcat_down.
  REFRESH: gt_fieldcat_alv[].
  DATA:ls_tabname TYPE dd02l-tabname.

  ls_tabname = 'ZAPP_ITEM'.


  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
*     I_PROGRAM_NAME         =
*     I_INTERNAL_TABNAME     =
      i_structure_name       = ls_tabname
      i_client_never_display = 'X'
*     I_INCLNAME             =
*     I_BYPASSING_BUFFER     =
*     I_BUFFER_ACTIVE        =
    CHANGING
      ct_fieldcat            = gt_fieldcat_alv[]
*   EXCEPTIONS
*     INCONSISTENT_INTERFACE = 1
*     PROGRAM_ERROR          = 2
*     OTHERS                 = 3
    .


  PERFORM f_transfer_slis_to_lvc CHANGING gt_fieldcat_alv[]
                                          gt_fcat_down[].

  LOOP AT gt_fcat_down ASSIGNING FIELD-SYMBOL(<fs_fcat>).

    IF <fs_fcat>-col_pos <= 3.
      <fs_fcat>-fix_column = 'X'.
      <fs_fcat>-emphasize = 'C710'.
    ENDIF.

    CASE <fs_fcat>-fieldname .
      WHEN 'ORGEH' OR'PLANS' OR'PERNR' OR'DEPARTMENT' OR'ZPOSITION' OR'PERSON' OR'SNAME'.
        <fs_fcat>-emphasize = 'C100'.
      WHEN 'APPNO' OR 'LINE_ID' OR 'FLOW_POINT' OR 'FLOW_POINT_NAME1' OR 'EX_FLOW_POINT'.
        <fs_fcat>-emphasize = 'C300'.

      WHEN 'ZRESULT' OR 'OPINION' OR 'APPDATE' OR 'APPTIME'.
        <fs_fcat>-emphasize = 'C500'.
    ENDCASE.

  ENDLOOP.

ENDFORM.


FORM f_transfer_slis_to_lvc
  CHANGING ct_fieldcat TYPE slis_t_fieldcat_alv
           ct_fcat     TYPE lvc_t_fcat..

  DATA: lt_fieldcat TYPE kkblo_t_fieldcat.

  CALL FUNCTION 'REUSE_ALV_TRANSFER_DATA'
    EXPORTING
      it_fieldcat = ct_fieldcat
    IMPORTING
      et_fieldcat = lt_fieldcat.

  CALL FUNCTION 'LVC_TRANSFER_FROM_KKBLO'
    EXPORTING
      it_fieldcat_kkblo = lt_fieldcat
    IMPORTING
      et_fieldcat_lvc   = ct_fcat.

ENDFORM.


FORM f_create_grid_exclude_toolbar CHANGING  c_t_toolbar TYPE ui_functions.

  DATA: ls_exclude TYPE ui_func.

  CLEAR: c_t_toolbar[].

*  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_EXCL_ALL.
*  APPEND  LS_EXCLUDE  TO C_T_TOOLBAR.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy_row.
  APPEND ls_exclude TO c_t_toolbar.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_delete_row.
  APPEND ls_exclude TO c_t_toolbar.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_append_row.
  APPEND ls_exclude TO c_t_toolbar.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_insert_row.
  APPEND ls_exclude TO c_t_toolbar.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_move_row.
  APPEND ls_exclude TO c_t_toolbar.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy.
  APPEND ls_exclude TO c_t_toolbar.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_cut.
  APPEND ls_exclude TO c_t_toolbar.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_paste.
  APPEND ls_exclude TO c_t_toolbar.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_paste_new_row.
  APPEND ls_exclude TO c_t_toolbar.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_undo.
  APPEND ls_exclude TO c_t_toolbar.
  ls_exclude = cl_gui_alv_grid=>mc_fc_graph.
  APPEND ls_exclude TO c_t_toolbar.
  ls_exclude = cl_gui_alv_grid=>mc_fc_info.
  APPEND ls_exclude TO c_t_toolbar.
ENDFORM.


FORM f_assign_grid_handlers_down CHANGING c_grid TYPE REF TO cl_gui_alv_grid.

  CREATE OBJECT g_event_receiver_grid.

  SET HANDLER g_event_receiver_grid->handle_changed_finished
          FOR c_grid .
*  SET HANDLER G_EVENT_RECEIVER_GRID->HANDLE_TOOLBAR
*          FOR C_GRID .
  SET HANDLER g_event_receiver_grid->handle_user_command
          FOR c_grid .
*  SET HANDLER G_EVENT_RECEIVER_GRID->HANDLE_ON_F4
*          FOR C_GRID .

*  SET HANDLER G_EVENT_RECEIVER_GRID->HANDLE_TOP_OF_PAGE
*          FOR C_GRID.
  SET HANDLER g_event_receiver_grid->handle_click
          FOR c_grid .

  SET HANDLER g_event_receiver_grid->toolbar FOR c_grid .

*  SET HANDLER G_EVENT_RECEIVER_GRID->HANDLE_BUTTON_CLICK
*          FOR C_GRID .
ENDFORM.


FORM f_set_sort_up.
  CLEAR gt_sort[].
  DATA:ls_sort TYPE lvc_s_sort.

  ls_sort-spos = 1.
  ls_sort-fieldname = 'ERDAT'.
  ls_sort-down = 'X'.
  APPEND ls_sort TO gt_sort.
  CLEAR ls_sort.

  ls_sort-spos = 2.
  ls_sort-fieldname = 'ERZET'.
  ls_sort-down = 'X'.
  APPEND ls_sort TO gt_sort.
  CLEAR ls_sort.

ENDFORM.


FORM f_assign_grid_handlers_up CHANGING c_grid TYPE REF TO cl_gui_alv_grid.

  CREATE OBJECT g_event_receiver_grid.

  SET HANDLER g_event_receiver_grid->handle_changed_finished FOR c_grid .

*  SET HANDLER G_EVENT_RECEIVER_GRID->HANDLE_TOOLBAR FOR C_GRID .

  SET HANDLER g_event_receiver_grid->handle_user_command FOR c_grid .
*  SET HANDLER G_EVENT_RECEIVER_GRID->HANDLE_ON_F4 FOR C_GRID .

*  SET HANDLER G_EVENT_RECEIVER_GRID->HANDLE_TOP_OF_PAGE FOR C_GRID.
  SET HANDLER g_event_receiver_grid->handle_click FOR c_grid.

  SET HANDLER g_event_receiver_grid->handle_double_click FOR c_grid.

  SET HANDLER g_event_receiver_grid->handle_after_refresh FOR c_grid.
*  SET HANDLER G_EVENT_RECEIVER_GRID->TOOLBAR FOR C_GRID .

*  SET HANDLER G_EVENT_RECEIVER_GRID->HANDLE_BUTTON_CLICK FOR C_GRID .

ENDFORM.


FORM f_register_grid_event USING u_grid TYPE REF TO cl_gui_alv_grid.

* ENTER EVENT
  CALL METHOD u_grid->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_enter.
** MODIFY EVENT
  CALL METHOD u_grid->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified.

*** DOUBLE CLICK EVENT
*  CALL METHOD U_GRID->REGISTER_EDIT_EVENT
*    EXPORTING
*      I_EVENT_ID = CL_GUI_ALV_GRID=>EVT_DBLCLICK_ROW_COL.

ENDFORM.


FORM f_display_grid_alv_up .

  DATA: ls_variant LIKE disvariant.
  ls_variant-report = sy-repid.
  ls_variant-handle = 'UP'.

  CALL METHOD g_grid_up->set_table_for_first_display
    EXPORTING
      is_variant           = ls_variant
      i_save               = 'A'
      is_layout            = gs_layout_up
      it_toolbar_excluding = gt_exclude[]
      i_default            = 'X'
    CHANGING
      it_outtab            = gt_head[]
      it_sort              = gt_sort[]
      it_fieldcatalog      = gt_fcat_up[].

ENDFORM.

FORM f_display_grid_alv_down USING tab.

  DATA: ls_variant LIKE disvariant.
  ls_variant-report = sy-repid.
  ls_variant-handle = 'DOWN'.

  CALL METHOD g_grid_down->set_table_for_first_display
    EXPORTING
      is_variant           = ls_variant
      i_save               = 'A'
      is_layout            = gs_layout_down
      it_toolbar_excluding = gt_exclude[]
      i_default            = 'X'
    CHANGING
      it_outtab            = tab
*     IT_SORT              = GT_SORT[]
      it_fieldcatalog      = gt_fcat_down[].
ENDFORM.


FORM f_refresh_grid_alv USING u_grid TYPE REF TO cl_gui_alv_grid..

  DATA: ls_scroll TYPE lvc_s_stbl.

  CLEAR: ls_scroll.
  ls_scroll-row = 'X'.
  ls_scroll-col = 'X'.


  CALL METHOD u_grid->set_frontend_layout
    EXPORTING
      is_layout = gs_layout_down.
  CALL METHOD u_grid->refresh_table_display
    EXPORTING
      is_stable      = ls_scroll
      i_soft_refresh = 'X'.

ENDFORM.


FORM f_create_grid_layout .

  CLEAR: gs_layout_down , gs_layout_up.
  gs_layout_down-sel_mode   = 'A'.
  gs_layout_down-cwidth_opt = 'X'.
  gs_layout_down-zebra      = 'X'.
*  GS_LAYOUT-NO_ROWMARK = 'X'.
*  GS_LAYOUT_DOWN-BOX_FNAME = 'SELECTED'.
  IF g_grid_up IS NOT INITIAL.
    gs_layout_up-sel_mode   = 'A'.
    gs_layout_up-cwidth_opt = 'X'.
    gs_layout_up-zebra      = 'X'.
  ENDIF.

*  GS_LAYOUT-STYLEFNAME = 'CELLTAB'.

*  GS_LAYOUT-NUMC_TOTAL = CNS_CHAR_X.

*  GS_LAYOUT_DOWN-SGL_CLK_HD    = 'X'.
*  GS_LAYOUT_DOWN-TOTALS_BEF    = 'X'.             " 合计显示在上面
*  GS_LAYOUT_DOWN-NO_HGRIDLN    = ' '.
*  GS_LAYOUT_DOWN-NO_VGRIDLN    = ' '.
*  GS_LAYOUT_DOWN-NO_TOOLBAR    = SPACE.
*  GS_LAYOUT_DOWN-GRID_TITLE    = ' '.
*  GS_LAYOUT_DOWN-SMALLTITLE    = ' '.
*  GS_LAYOUT_DOWN-EXCP_FNAME    = 'ICON'.          " LED
*  GS_LAYOUT_DOWN-INFO_FNAME    = 'COLOR'.         " LINE COLOR
*  GS_LAYOUT_DOWN-CTAB_FNAME    = ' '.             " CELL COLOR
*  GS_LAYOUT_DOWN-BOX_FNAME     = ' '.
*  GS_LAYOUT_DOWN-DETAILINIT    = ' '.

ENDFORM.


FORM f_changed_finished USING et_good_cells TYPE lvc_t_modi.
  DATA: ls_good_cells TYPE lvc_s_modi.
*    BREAK-POINT.
  DATA stbl TYPE lvc_s_stbl.

*  LOOP AT ET_GOOD_CELLS INTO LS_GOOD_CELLS.
*    READ TABLE GT_ITEM_DIS ASSIGNING <GS_ITEM_DIS> INDEX LS_GOOD_CELLS-ROW_ID.
*    IF SY-SUBRC EQ 0.
*      <GS_ITEM_DIS>-ICON = ICON_LED_YELLOW.
*      <GS_ITEM_DIS>-MSG = '已修改'.
*
*      READ TABLE GT_ITEM ASSIGNING <GS_ITEM> WITH KEY ZJS_VGBEL = <GS_ITEM_DIS>-ZJS_VGBEL COST_LINE = <GS_ITEM_DIS>-COST_LINE.
*      IF SY-SUBRC EQ 0.
*        <GS_ITEM> = <GS_ITEM_DIS>.
*      ENDIF.
*    ENDIF.
*  ENDLOOP.
*  IF SY-SUBRC = 0.
*    PERFORM F_REFRESH_GRID_ALV USING G_GRID_DOWN.
*  ENDIF.

ENDFORM.


FORM f_toolbar USING ut_toolbar TYPE ttb_button.
  DATA: ls_toolbar TYPE stb_button.

  MOVE '&MASS_APP' TO ls_toolbar-function.
  MOVE icon_release TO ls_toolbar-icon.
  MOVE TEXT-006 TO ls_toolbar-quickinfo."'批量审批'
  MOVE ' ' TO ls_toolbar-disabled.
  MOVE TEXT-006  TO ls_toolbar-text."'批量审批'
  APPEND ls_toolbar TO ut_toolbar.
  CLEAR ls_toolbar.
  MOVE '&UNAPP' TO ls_toolbar-function.
  MOVE icon_booking_stop TO ls_toolbar-icon.
  MOVE TEXT-007 TO ls_toolbar-quickinfo." '拒绝&反审核'
  MOVE ' ' TO ls_toolbar-disabled.
  MOVE TEXT-007 TO ls_toolbar-text." '拒绝&反审核'
  APPEND ls_toolbar TO ut_toolbar.
  CLEAR ls_toolbar.
  MOVE '&MYDETAIL' TO ls_toolbar-function.
  MOVE icon_personal_settings TO ls_toolbar-icon.
  MOVE TEXT-034 TO ls_toolbar-quickinfo."我的待处理
  MOVE ' ' TO ls_toolbar-disabled.
  MOVE TEXT-034 TO ls_toolbar-text."我的待处理
  APPEND ls_toolbar TO ut_toolbar.
  CLEAR ls_toolbar.

ENDFORM.


FORM f_user_command USING VALUE(iv_ucomm) TYPE sy-ucomm.
  PERFORM frm_user_command_down USING iv_ucomm.
ENDFORM.

FORM frm_free_grid_down.
  CALL METHOD g_grid_down->free.
  FREE  g_grid_down.
ENDFORM.
