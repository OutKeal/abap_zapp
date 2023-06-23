FUNCTION zapp_flow_create.
*"----------------------------------------------------------------------
*"*"本地接口：
*"  IMPORTING
*"     VALUE(OBJECT) TYPE  ZAPP_EOBJECT
*"     VALUE(LINE) OPTIONAL
*"     VALUE(KEY1) OPTIONAL
*"     VALUE(KEY2) OPTIONAL
*"     VALUE(KEY3) OPTIONAL
*"     VALUE(KEY4) OPTIONAL
*"     VALUE(KEY5) OPTIONAL
*"     VALUE(KEY6) OPTIONAL
*"     VALUE(USER1) TYPE  XUBNAME OPTIONAL
*"     VALUE(USER2) TYPE  XUBNAME OPTIONAL
*"     VALUE(USER3) TYPE  XUBNAME OPTIONAL
*"     VALUE(UNAME) TYPE  ZAPP_PERSON OPTIONAL
*"     VALUE(COMMIT) TYPE  CHAR1 DEFAULT 'X'
*"  TABLES
*"      ET_FLOW_HEAD STRUCTURE  ZAPP_FLOW_HEAD OPTIONAL
*"      ET_FLOW_ITEM STRUCTURE  ZAPP_FLOW_ITEM OPTIONAL
*"      ET_RETURN STRUCTURE  BAPIRET2 OPTIONAL
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
  PERFORM frm_free_global.

  gv_object = object.
  gv_key1 = key1.
  CONDENSE gv_key1 NO-GAPS.
  gv_key2 = key2.
  CONDENSE gv_key2 NO-GAPS.
  gv_key3 = key3.
  CONDENSE gv_key3 NO-GAPS.
  gv_key4 = key4.
  CONDENSE gv_key4 NO-GAPS.
  gv_key5 = key5.
  CONDENSE gv_key5 NO-GAPS.
  gv_key6 = key6.
  CONDENSE gv_key6 NO-GAPS.
  gv_user1 = user1.
  gv_user2 = user2.
  gv_user3 = user3.

  gv_uname = uname.

  IF gv_uname IS INITIAL.
    gv_uname = sy-uname.
  ENDIF.


  PERFORM frm_init_config.

  IF gv_error = 'X'.
    et_return[] = ot_return[].
    RAISE error.
  ENDIF.

  PERFORM frm_get_appno CHANGING gv_appno.
  IF gv_error = 'X'.
    et_return[] = ot_return[].
    RAISE error.
  ENDIF.

  PERFORM frm_set_key USING line.

  IF gv_error = 'X'.
    et_return[] = ot_return[].
    RAISE error.
  ENDIF.

  PERFORM frm_set_head_process USING line.
  IF gv_error = 'X'.
    et_return[] = ot_return[].
    RAISE error.
  ENDIF.


  PERFORM frm_set_item.

  APPEND gt_flow_head.

  IF gv_error = 'X'.
    et_return[] = ot_return[].
    RAISE error.
  ELSE.

    PERFORM frm_add_message USING 'S' 'ZAPP' 002 gv_appno ''  '' ''.
    et_flow_head[] = gt_flow_head[].
    et_flow_item[] = gt_flow_item[].
    et_return[] = ot_return[].


    MODIFY zapp_flow_head FROM TABLE gt_flow_head.
    MODIFY zapp_flow_item FROM TABLE gt_flow_item.

    READ TABLE gt_flow_head INDEX 1.
    READ TABLE gt_flow_item INDEX 2.
    PERFORM frm_send_first_msg USING gt_flow_head gt_flow_item.
    IF commit = 'X'.
      COMMIT WORK AND WAIT.
    ENDIF.
  ENDIF.



ENDFUNCTION.
