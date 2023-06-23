
*&---------------------------------------------------------------------*
*& 包含               demo alv
*&---------------------------------------------------------------------*



DATA: g_grid_300              TYPE REF TO cl_gui_alv_grid,
      gt_fcat_300             TYPE lvc_t_fcat,
      gs_layout_300           TYPE lvc_s_layo,
      gt_sort_300             TYPE lvc_t_sort,
      gt_exclude_300          TYPE ui_functions,
      g_docking_container_300 TYPE REF TO cl_gui_docking_container,
      g_cumtom_container_300  TYPE REF TO cl_gui_custom_container,
      g_container_300         TYPE REF TO cl_gui_container,
      g_splitter_300          TYPE REF TO cl_gui_splitter_container,
      g_toolbar_300           TYPE REF TO cl_gui_toolbar.

CONSTANTS: con_tab_name_300 TYPE char40 VALUE 'GT_ITEM[]'.


FIELD-SYMBOLS:<f_tab_300> TYPE ANY TABLE.
DATA: dyn_table_300 TYPE REF TO data.


*&---------------------------------------------------------------------*
*&       CLASS LCL_EVENT_RECEIVER_GRID DEFINITION
*&---------------------------------------------------------------------*
CLASS:
  lcl_event_receiver_grid_300 DEFINITION DEFERRED.

DATA:
  g_event_receiver_grid_300   TYPE REF TO lcl_event_receiver_grid_300.

CLASS lcl_event_receiver_grid_300 DEFINITION.

  PUBLIC SECTION.
* DATA CHANGED
    METHODS: handle_data_changed
      FOR EVENT data_changed OF cl_gui_alv_grid
      IMPORTING er_data_changed
                e_onf4.

    METHODS handle_double_click
      FOR EVENT double_click
      OF cl_gui_alv_grid
      IMPORTING e_row e_column.

    METHODS  handle_hotspot_click
      FOR EVENT hotspot_click
      OF cl_gui_alv_grid
      IMPORTING
        e_row_id
        e_column_id
        es_row_no.

    METHODS handle_toolbar
      FOR EVENT toolbar
      OF cl_gui_alv_grid
      IMPORTING e_object.

    METHODS: data_changed_finished
      FOR EVENT data_changed_finished
      OF cl_gui_alv_grid
      IMPORTING e_modified et_good_cells.

    METHODS handle_user_command
      FOR EVENT user_command OF cl_gui_alv_grid
      IMPORTING e_ucomm.

ENDCLASS.                    "LCL_EVENT_RECEIVER_GRID DEFINITION

*---------------------------------------------------------------------*
*       CLASS LCL_EVENT_RECEIVER_GRID IMPLEMENTATION
*---------------------------------------------------------------------*
*
*---------------------------------------------------------------------*
CLASS lcl_event_receiver_grid_300 IMPLEMENTATION.
* DATA CHANGED
  METHOD handle_data_changed.
    PERFORM f_handle_data_changed_300
      USING er_data_changed
            e_onf4.
  ENDMETHOD.                    "HANDLE_DATA_CHANGED

  METHOD handle_double_click.
    PERFORM f_handle_double_click_300 USING e_row e_column.
  ENDMETHOD.

  METHOD handle_hotspot_click.
    PERFORM f_handle_hotspot_click_300 USING e_row_id e_column_id .
  ENDMETHOD.

  METHOD handle_toolbar.
    PERFORM f_toolbar_300 USING e_object->mt_toolbar.
  ENDMETHOD.

  METHOD data_changed_finished.
    PERFORM f_data_changed_finished_300 USING e_modified et_good_cells.
  ENDMETHOD.

  METHOD handle_user_command.
    PERFORM f_user_command_300 USING e_ucomm.
  ENDMETHOD.

ENDCLASS.                    "LCL_EVENT_RECEIVER_GRID IMPLEMENTATION

FORM f_handle_data_changed_300

 USING  u_changed TYPE REF TO cl_alv_changed_data_protocol
   u_onf4    TYPE any.

  DATA:ls_n TYPE netwr.


  DATA: ls_modi LIKE lvc_s_modi.

  FIELD-SYMBOLS:
    <fs_changed> TYPE any,
    <fs_mod>     TYPE any.

  LOOP AT u_changed->mt_good_cells INTO ls_modi.

*    READ TABLE gt_alv  INDEX ls_modi-row_id .
*    IF sy-subrc EQ 0.
*      gt_alv-info = 'X'.
*
*      CALL METHOD u_changed->modify_cell
*        EXPORTING
*          i_row_id    = ls_modi-row_id
*          i_tabix     = ls_modi-tabix
*          i_fieldname = 'INFO'
*          i_value     = 'X'.
*    ENDIF.

  ENDLOOP.

ENDFORM.

FORM f_handle_double_click_300 USING e_row_id TYPE lvc_s_row
                                   e_column_id TYPE lvc_s_col.

*  CLEAR GT_ITEM_DIS[].
*  PERFORM GET_DIS_DATA USING E_ROW_ID-INDEX.
*
*  PERFORM F_REFRESH_GRID_ALV USING G_GRID2.

ENDFORM.

FORM f_handle_user_command_300 USING ok_code.
  DATA:lt_index_rows TYPE  lvc_t_row,
       ls_index_rows TYPE  lvc_s_row,
       lt_row_no     TYPE  lvc_t_roid.
  CASE ok_code.
    WHEN ''.
  ENDCASE.
ENDFORM.

FORM f_toolbar_300 USING ut_toolbar TYPE ttb_button.

*  DATA: ls_toolbar TYPE stb_button.
*
*  CLEAR ls_toolbar.
*  MOVE '&SURE' TO ls_toolbar-function.
*  MOVE icon_checked TO ls_toolbar-icon.
*  MOVE '确认选择' TO ls_toolbar-quickinfo.
*  MOVE ' ' TO ls_toolbar-disabled.
*  MOVE '确认选择' TO ls_toolbar-text.
*  APPEND ls_toolbar TO ut_toolbar.
*  CLEAR ls_toolbar.


ENDFORM.

FORM f_handle_hotspot_click_300 USING e_row_id TYPE lvc_s_row
                                   e_column_id TYPE lvc_s_col.




  CASE e_column_id-fieldname.
    WHEN ''.
  ENDCASE.
ENDFORM.

FORM f_data_changed_finished_300  USING  e_modified
                                   et_good_cells TYPE lvc_t_modi.
  CHECK NOT et_good_cells IS INITIAL.
  LOOP AT et_good_cells INTO DATA(ls_cell).
  ENDLOOP.
ENDFORM.


FORM f_user_command_300 USING ok_code.

  CASE ok_code.
    WHEN ''.
  ENDCASE.

ENDFORM.



MODULE create_object_0300 OUTPUT.

  IF g_grid_300 IS INITIAL.
**-- CREATE CONTAINER
    PERFORM f_create_container_300.
**-- FIELD_CATALOG DEFINE
    PERFORM f_set_grid_field_catalog_300.
*    PERFORM F_SET_GRID_FIELD_CATALOG2.
**-- LAYOUT
    PERFORM f_create_grid_layout_300.
**-- TOOLBAR EXCLUDE
    PERFORM f_create_grid_toolbar_300  CHANGING gt_exclude_300[].
**-- GRID EVENT HANDLER DEFINE
    PERFORM f_assign_grid_handlers_300 CHANGING g_grid_300.
*    PERFORM F_ASSIGN_GRID_EVENT_HANDLERS CHANGING G_GRID2.
**-- REGISTER EVENT
    PERFORM f_register_grid_event_300 USING g_grid_300.
*    PERFORM F_REGISTER_GRID_EVENT2 USING G_GRID2.
**--
    CALL METHOD cl_gui_cfw=>flush.
**-- DISPLAY GRID ALV
    PERFORM f_display_grid_alv_300.
*--
    CALL METHOD g_grid_300->set_ready_for_input
      EXPORTING
        i_ready_for_input = 1.
  ELSE.
**--
    PERFORM f_refresh_grid_alv USING g_grid_300.

  ENDIF.

ENDMODULE.

FORM f_create_container_300 .

*  IF g_docking_container_300 IS INITIAL.
*
*    CREATE OBJECT g_docking_container_300
*      EXPORTING
*        style     = cl_gui_control=>ws_child
*        repid     = sy-repid
*        dynnr     = sy-dynnr
*        side      = g_docking_container_300->dock_at_bottom
*        lifetime  = cl_gui_control=>lifetime_imode
*        extension = '3000'
*      EXCEPTIONS
*        OTHERS    = 1.
*    IF sy-subrc <> 0.
*      MESSAGE ID sy-msgid
*            TYPE sy-msgty
*          NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*    ENDIF.
*  ENDIF.

  CREATE OBJECT g_cumtom_container_300
    EXPORTING
      container_name = 'ITEM_300'.


* SPLITTER CONTAINER
  IF g_splitter_300 IS INITIAL.
    CREATE OBJECT g_splitter_300
      EXPORTING
        parent  = g_cumtom_container_300
        rows    = 1
        columns = 1.

    g_container_300  = g_splitter_300->get_container( row = 1 column = 1 ).
*    G_CONTAINER_2  = G_SPLITTER->GET_CONTAINER( ROW = 1 COLUMN = 1 ).

  ENDIF.

  CREATE OBJECT g_grid_300
    EXPORTING
      i_parent = g_container_300.

*  CREATE OBJECT G_GRID2
*    EXPORTING
*      I_PARENT = G_CONTAINER_2.

ENDFORM.


FORM f_set_grid_field_catalog_300 .

  REFRESH: gt_fcat_300.

  FIELD-SYMBOLS:
    <fs_fcat> TYPE lvc_s_fcat.
  DATA:
    lt_fcat TYPE lvc_t_fcat.

  DATA:
    lt_fieldcat TYPE slis_t_fieldcat_alv,
    ls_fieldcat TYPE slis_fieldcat_alv.

  DATA: l_struc_name LIKE  dd02l-tabname .

  l_struc_name = 'ZAPP_ITEM'.

* 取得字段的属性
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = sy-repid
      i_structure_name       = l_struc_name
      i_inclname             = sy-repid
      i_bypassing_buffer     = 'X'
    CHANGING
      ct_fieldcat            = lt_fieldcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

  PERFORM f_transfer_slis_to_lvc
          CHANGING lt_fieldcat
                   lt_fcat.

** 内容编辑
  LOOP AT lt_fcat ASSIGNING <fs_fcat>.
    IF <fs_fcat>-col_pos <= 3.
      <fs_fcat>-fix_column = 'X'.
      <fs_fcat>-emphasize = 'C710'.
    ENDIF.

    CASE <fs_fcat>-fieldname .

      WHEN 'ORGEH'
     OR'PLANS'
     OR'PERNR'
     OR'DEPARTMENT'
     OR'ZPOSITION'
     OR'PERSON'
     OR'SNAME'.
        <fs_fcat>-emphasize = 'C100'.
      WHEN 'APPNO' OR 'LINE_ID' OR 'FLOW_POINT' OR 'FLOW_POINT_NAME1' OR 'EX_FLOW_POINT'.
        <fs_fcat>-emphasize = 'C300'.

      WHEN 'ZRESULT' OR 'OPINION' OR 'APPDATE' OR 'APPTIME'.
        <fs_fcat>-emphasize = 'C500'.

    ENDCASE.
  ENDLOOP.

  gt_fcat_300 = lt_fcat.

ENDFORM.





FORM f_create_grid_layout_300 .

  CLEAR: gs_layout_300.
  gs_layout_300-sel_mode   = 'A'.
  gs_layout_300-cwidth_opt = 'X'.
  gs_layout_300-zebra      = 'X'.
*  GS_LAYOUT-NO_ROWMARK = 'X'.
*  GS_LAYOUT-BOX_FNAME = 'SEL'.

*  gs_layout_300-ctab_fname  = 'CELLCOLOR'.

*  GS_LAYOUT-NUMC_TOTAL = CNS_CHAR_X.

*  GS_LAYOUT-SGL_CLK_HD    = 'X'.
*  GS_LAYOUT-TOTALS_BEF    = 'X'.             " 合计显示在上面
*  GS_LAYOUT-NO_HGRIDLN    = ' '.
*  GS_LAYOUT-NO_VGRIDLN    = ' '.
*  GS_LAYOUT-NO_TOOLBAR    = SPACE.
*  GS_LAYOUT-GRID_TITLE    = ' '.
*  GS_LAYOUT-SMALLTITLE    = ' '.
*  GS_LAYOUT-EXCP_FNAME    = 'ICON'.          " LED
*  GS_LAYOUT-INFO_FNAME    = 'COLOR'.         " LINE COLOR
*  GS_LAYOUT-CTAB_FNAME    = ' '.             " CELL COLOR
*  GS_LAYOUT-BOX_FNAME     = ' '.
*  GS_LAYOUT-DETAILINIT    = ' '.

ENDFORM.


FORM f_create_grid_toolbar_300
  CHANGING  c_t_toolbar TYPE ui_functions.

  DATA: ls_exclude TYPE ui_func.

  CLEAR: c_t_toolbar[].

*  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_EXCL_ALL.
*  APPEND  LS_EXCLUDE  TO C_T_TOOLBAR.

  APPEND cl_gui_alv_grid=>mc_fc_html TO c_t_toolbar.
  APPEND cl_gui_alv_grid=>mc_fc_views TO c_t_toolbar.
  APPEND cl_gui_alv_grid=>mc_fc_detail TO c_t_toolbar.
  APPEND cl_gui_alv_grid=>mc_fc_refresh TO c_t_toolbar.
  APPEND cl_gui_alv_grid=>mc_fc_loc_copy_row TO c_t_toolbar.
  APPEND cl_gui_alv_grid=>mc_fc_loc_copy_row TO c_t_toolbar.
  APPEND cl_gui_alv_grid=>mc_fc_loc_delete_row TO c_t_toolbar.
  APPEND cl_gui_alv_grid=>mc_fc_loc_append_row TO c_t_toolbar.
  APPEND cl_gui_alv_grid=>mc_fc_loc_insert_row TO c_t_toolbar.
  APPEND cl_gui_alv_grid=>mc_fc_loc_move_row TO c_t_toolbar.
  APPEND cl_gui_alv_grid=>mc_fc_loc_copy TO c_t_toolbar.
  APPEND cl_gui_alv_grid=>mc_fc_loc_cut TO c_t_toolbar.
  APPEND cl_gui_alv_grid=>mc_fc_loc_paste TO c_t_toolbar.
  APPEND cl_gui_alv_grid=>mc_fc_loc_paste_new_row TO c_t_toolbar.
  APPEND cl_gui_alv_grid=>mc_fc_loc_undo TO c_t_toolbar.
  APPEND cl_gui_alv_grid=>mc_fc_graph TO c_t_toolbar.
  APPEND cl_gui_alv_grid=>mc_fc_info TO c_t_toolbar.
ENDFORM.

FORM f_assign_grid_handlers_300
  CHANGING c_grid TYPE REF TO cl_gui_alv_grid.

  CREATE OBJECT g_event_receiver_grid_300.

  SET HANDLER g_event_receiver_grid_300->handle_data_changed
          FOR c_grid .

  SET HANDLER g_event_receiver_grid_300->handle_toolbar
          FOR c_grid .
  SET HANDLER g_event_receiver_grid_300->handle_user_command
          FOR c_grid .
*  SET HANDLER G_EVENT_RECEIVER_GRID->HANDLE_ON_F4
*          FOR C_GRID .

*  SET HANDLER G_EVENT_RECEIVER_GRID->HANDLE_TOP_OF_PAGE
*          FOR C_GRID.
  SET HANDLER g_event_receiver_grid_300->handle_hotspot_click
          FOR c_grid .
  SET HANDLER g_event_receiver_grid_300->handle_double_click
          FOR c_grid .
  SET HANDLER g_event_receiver_grid_300->data_changed_finished
          FOR c_grid.

*  SET HANDLER G_EVENT_RECEIVER_GRID->HANDLE_BUTTON_CLICK
*          FOR C_GRID .

ENDFORM.

FORM f_register_grid_event_300
  USING u_grid TYPE REF TO cl_gui_alv_grid.

* ENTER EVENT
  CALL METHOD u_grid->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_enter.
** MODIFY EVENT
  CALL METHOD u_grid->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified.

ENDFORM.



FORM f_display_grid_alv_300 .

  DATA: ls_variant LIKE disvariant.
  ls_variant-report = sy-repid.
  ls_variant-handle = 300 ."g_model.

  ASSIGN (con_tab_name_300) TO <f_tab_300>.

  CALL METHOD g_grid_300->set_table_for_first_display
    EXPORTING
      is_variant           = ls_variant
      i_save               = 'A'
      is_layout            = gs_layout_300
      it_toolbar_excluding = gt_exclude_300[]
      i_default            = 'X'
    CHANGING
      it_outtab            = <f_tab_300>
      it_sort              = gt_sort_300[]
      it_fieldcatalog      = gt_fcat_300[].

ENDFORM.

MODULE user_command_0300.
  DATA:ls_flag TYPE char1.
  DATA:lv_type TYPE char1.
  DATA:ps_head TYPE zapp_head.
  DATA:lv_can  TYPE char1."是否取消自动跳转
  CLEAR gv_error.

  CASE sy-ucomm.
    WHEN '&OK'.
      IF gs_item-opinion IS INITIAL.
        MESSAGE s001.
        RETURN.
      ENDIF.
      LOOP AT gt_item ASSIGNING <gs_item_dis> WHERE flow_point EQ gs_head-flow_point AND zresult EQ 'A' .
        EXIT.
      ENDLOOP.
      CHECK sy-subrc = 0.

      READ TABLE gt_head ASSIGNING <gs_head> INDEX 1.
*      READ TABLE gt_item_dis ASSIGNING <gs_item_dis> WITH KEY line_id = gs_item-line_id.
      PERFORM frm_check_user_auth USING gt_item-person.
      IF gv_error = 'X'.
        PERFORM frm_pop_msg TABLES ot_return.
        RETURN.
      ENDIF.
      gs_item-zresult = 'C'.

*获取用户自定义参数
      CALL FUNCTION 'ZFPP_GET_USER_PARAM'
        EXPORTING
          param_name = 'ZAPP_AUTO_NEXT_CAN'
        IMPORTING
          value      = lv_can.
      IF lv_can IS INITIAL.
        "add by at-yuxs 20211127 在未更新数据库之前，获取下一个审批单号
        PERFORM frm_get_next_app_flow USING <gs_head>-appno CHANGING ps_head.
      ENDIF.
      PERFORM frm_appr_single CHANGING <gs_item_dis>.
      PERFORM frm_update_db.

      PERFORM frm_pop_msg TABLES ot_return.
*add by at-yuxs 20211226 自动跳转到下一个审批
      IF ps_head IS NOT INITIAL.
        PERFORM frm_get_app_flow USING <gs_head>-appno 'C'  ps_head.
      ENDIF.

      LEAVE TO SCREEN 0.

    WHEN '&CANCEL'.
      IF gs_item-opinion IS INITIAL.
        MESSAGE s001.
        RETURN.
      ENDIF.
      IF gs_item-opinion = TEXT-002."同意.
        gs_item-opinion = TEXT-008."拒绝.
      ENDIF.

      LOOP AT gt_item ASSIGNING <gs_item_dis>  .
        IF  <gs_item_dis>-zresult EQ 'A' .
          EXIT.
        ENDIF.
      ENDLOOP.
      CHECK sy-subrc EQ 0.

      READ TABLE gt_head ASSIGNING <gs_head> INDEX 1.
*      READ TABLE gt_item_dis ASSIGNING <gs_item_dis> WITH KEY line_id = gs_item-line_id.
      IF g_flag = 'A'.
        LOOP AT gt_item ASSIGNING <gs_item_dis>  WHERE zresult EQ 'A'.
          EXIT.
        ENDLOOP.
        CHECK sy-subrc = 0.
        PERFORM frm_check_user_auth USING <gs_item_dis>-person.

      ELSEIF g_flag = 'B'.
        PERFORM frm_check_user_auth USING gs_head-ernam.

      ELSEIF g_flag = 'C'.
        PERFORM frm_check_user_auth USING <gs_item_dis>-person.
      ENDIF.

      IF gv_error = 'X'.
        PERFORM frm_pop_msg TABLES ot_return.
        RETURN.
      ENDIF.

      gs_item-zresult = 'R'.
      CLEAR ls_flag.
      PERFORM frm_appr_reset_single USING 'R' CHANGING gs_head ls_flag.
      PERFORM frm_update_db.
      PERFORM frm_pop_msg TABLES ot_return.

      LEAVE TO SCREEN 0.

    WHEN '&TRANS'.
      DATA:lt_flds TYPE TABLE OF sval.
      DATA:ls_flds TYPE sval.
      DATA: p_gv_ret_code TYPE c.
      DATA: l_name TYPE char12.
      CLEAR lt_flds[].
      CLEAR ls_flds.
      ls_flds-tabname = 'ZAPP_FLOW_ITEM'.
      ls_flds-fieldname = 'PERSON'.
      ls_flds-fieldtext = TEXT-009."'转发人'.
      ls_flds-value = ''.
      ls_flds-field_obl = 'X'.
      APPEND ls_flds TO lt_flds.

      CALL FUNCTION 'POPUP_GET_VALUES'
        EXPORTING
          popup_title     = TEXT-001
        IMPORTING
          returncode      = p_gv_ret_code
        TABLES
          fields          = lt_flds
        EXCEPTIONS
          error_in_fields = 1
          OTHERS          = 2.
      CLEAR l_name.
      IF sy-subrc EQ 0 AND p_gv_ret_code <> 'A'.

        READ TABLE lt_flds INTO ls_flds INDEX 1.
        l_name = ls_flds-value.
        IF l_name IS NOT INITIAL.

          SELECT SINGLE * INTO @DATA(ls_addr) FROM zapp_addr WHERE person = @l_name.
          IF sy-subrc NE 0.
            MESSAGE s003 DISPLAY LIKE 'E'. "WITH '转发人不存在' DISPLAY LIKE 'E'.
            RETURN.
          ENDIF.
          LOOP AT gt_item ASSIGNING <gs_item> WHERE zresult = 'A'.
            EXIT.
          ENDLOOP.
          IF sy-subrc EQ 0.
            PERFORM frm_check_user_auth USING gt_item-person.
            CHECK gv_error IS INITIAL.
            <gs_item>-person = ls_addr-person.
            <gs_item>-department = ls_addr-department.
            <gs_item>-zposition = ls_addr-zposition.
            <gs_item>-name = ls_addr-name.
            UPDATE zapp_flow_item SET person = ls_addr-person
                                      department = ls_addr-department
                                      zposition = ls_addr-zposition
                                      name = ls_addr-name
                                      WHERE appno = <gs_item>-appno
                                      AND line_id = <gs_item>-line_id.
            MESSAGE s004 ."WITH '转发成功' .
            COMMIT WORK.
          ENDIF.

        ENDIF.
      ENDIF.

    WHEN '&PREV'."上一个
      lv_type = 'P'.
    WHEN '&NEXT'."下一个
      lv_type = 'N'.
  ENDCASE.

  IF lv_type IS NOT INITIAL.
    READ TABLE gt_head INDEX 1.
    PERFORM frm_get_app_flow USING gt_head-appno
                                   lv_type
                                   '' .
  ENDIF.

ENDMODULE.

MODULE status_0300 OUTPUT.
  DATA: l_msg TYPE char40.
  DATA:lt_fcode TYPE TABLE OF sy-ucomm .

  l_msg = gs_head-name1 && '-' && gs_head-flow_point_name1.

  APPEND '' TO lt_fcode.
  SET PF-STATUS 'S300' EXCLUDING lt_fcode.
  SET TITLEBAR 'T300' WITH l_msg.

ENDMODULE.

MODULE screen_0300 OUTPUT.
  DATA l_error TYPE char1.
  CLEAR l_error.
  CLEAR g_flag.
  SORT gt_item BY line_id.

  IF gs_head-status = 'B'.
    LOOP AT gt_item WHERE zresult EQ 'A'.
      PERFORM frm_return_user_auth USING gt_item-person CHANGING l_error.
      IF l_error = 'S'.
        g_flag = 'A'.
        gs_item-opinion = TEXT-002."同意.
        g_msg = gt_item-send_msg.
      ENDIF.
      EXIT .
    ENDLOOP.

    IF g_flag IS INITIAL.
      PERFORM frm_return_user_auth USING gs_head-ernam CHANGING l_error.
      IF l_error = 'S'.
        g_flag = 'B'.
        gs_item-opinion = TEXT-010."'撤销'.
      ENDIF.
    ENDIF.


  ELSEIF gs_head-status = 'C'.
    LOOP AT gt_item.
    ENDLOOP.
    PERFORM frm_return_user_auth USING gt_item-person CHANGING l_error.
    IF gs_head-object = 'EKKO' AND sy-uname = '10005440'.
      l_error = 'S'.
    ENDIF.
    IF l_error = 'S'.
      g_flag = 'C'.
      gs_item-opinion = TEXT-011."'退回'.
      g_msg = 'X'.
    ENDIF.
  ELSE.
  ENDIF.

  IF g_flag IS INITIAL.
    gs_item-opinion = ''.
  ENDIF.
  IF g_flag = 'B'.
    CLEAR g_msg.
  ENDIF.

  LOOP AT SCREEN.
    CASE g_flag.
      WHEN 'A'.
        screen-input = 1.
      WHEN 'B'.
        IF screen-name = 'CANCEL' OR screen-name = 'GS_ITEM-OPINION'.
          screen-input = 1.
        ELSE.
          screen-input = 0.
        ENDIF.
      WHEN 'C'.
        IF screen-name = 'CANCEL' OR screen-name = 'GS_ITEM-OPINION' OR screen-name = 'G_MSG'.
          screen-input = 1.
        ELSE.
          screen-input = 0.
        ENDIF.
      WHEN OTHERS.
        screen-input = 0.
    ENDCASE.
    MODIFY SCREEN.

  ENDLOOP.



ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT_COMMAND  INPUT
*&---------------------------------------------------------------------*
*       text
*-----------------------------
MODULE exit_command INPUT.

  CASE sy-ucomm.
    WHEN 'BACK'.
      CLEAR sy-ucomm.
      LEAVE TO SCREEN 0.

    WHEN 'CANCEL'.
      CLEAR sy-ucomm.
      SET SCREEN 0.
      LEAVE SCREEN.

    WHEN 'EXIT'.
      CLEAR sy-ucomm.
      LEAVE PROGRAM.
  ENDCASE.



ENDMODULE.                 " EXIT_COMMAND  INPUT
