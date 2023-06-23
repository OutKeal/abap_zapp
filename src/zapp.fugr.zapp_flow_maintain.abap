FUNCTION zapp_flow_maintain.
*"----------------------------------------------------------------------
*"*"本地接口：
*"  IMPORTING
*"     REFERENCE(UNAME) TYPE  XUBNAME OPTIONAL
*"  TABLES
*"      CT_HEAD STRUCTURE  ZAPP_FLOW_HEAD
*"      CT_ITEM STRUCTURE  ZAPP_FLOW_ITEM
*"----------------------------------------------------------------------

  PERFORM frm_free_global.
  LOOP AT ct_head.
    IF sy-tabix = 1.
      gv_object = ct_head-object.
    ENDIF.

    IF gv_object IS NOT INITIAL.
      IF ct_head-object <> gv_object.
        CLEAR gv_object.
      ENDIF.
    ENDIF.


*    CALL FUNCTION 'ENQUEUE_EZAPP_FLOW_HEAD'
*      EXPORTING
*        mode_zapp_flow_head = 'E'
*        mandt               = sy-mandt
*        appno               = ct_head-appno
*      EXCEPTIONS
*        foreign_lock        = 1
*        system_failure      = 2
*        OTHERS              = 3.
*    IF sy-subrc <> 0.
*      ct_head-status = 'L'.
*    ENDIF.

    MOVE-CORRESPONDING ct_head TO gt_head.
    PERFORM frm_set_head_icon CHANGING gt_head.
    APPEND gt_head.
  ENDLOOP.


  IF uname IS NOT INITIAL.
    gv_uname = uname.
  ELSE.
    gv_uname = sy-uname.
  ENDIF.

  LOOP AT ct_item.
    MOVE-CORRESPONDING ct_item TO gt_item.

    PERFORM frm_set_item_icon CHANGING gt_item.
    APPEND gt_item.
  ENDLOOP.
  SORT gt_item BY appno line_id.

  gt_item_dis[] = gt_item[].

  PERFORM frm_init_config.

  IF gv_object IS INITIAL.
    LOOP AT gt_head ASSIGNING <gs_head>.
      PERFORM frm_set_head_text CHANGING <gs_head>.
    ENDLOOP.
  ENDIF.

  CALL SCREEN 100.

ENDFUNCTION.
