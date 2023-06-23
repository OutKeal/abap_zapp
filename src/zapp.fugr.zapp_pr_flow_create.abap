FUNCTION zapp_pr_flow_create.
*"----------------------------------------------------------------------
*"*"本地接口：
*"  IMPORTING
*"     VALUE(I_REQ) TYPE REF TO  IF_PURCHASE_REQUISITION
*"----------------------------------------------------------------------
  g_req = i_req.

  DATA:ls_req_head TYPE mereq_header.
  DATA:ls_req_item TYPE mmpur_requisition_item.
  DATA:lt_req_items TYPE mmpur_requisition_items.
  DATA:ls_item TYPE mereq_item.
  DATA:ls_AKTVT TYPE aktvt.



  ls_req_head = g_req->get_data( ).

  ls_AKTVT = g_req->get_activity( ).

  lt_req_items = g_req->get_items( ).

*
  READ TABLE  lt_req_items  INDEX 1 INTO ls_req_item.


  ls_item = ls_req_item-item->get_data( ).

  IF ls_AKTVT = 'V'.
    PERFORM frm_add_message USING 'E' 'ZAPP' 022 '' '' '' ''."只有只读状态的采购申请可以提交审批

    PERFORM frm_pop_msg TABLES ot_return.
    RETURN.
  ENDIF.

  IF ls_item-frgkz <> 'B'.
    PERFORM frm_add_message USING 'E' 'ZAPP' 023 '' '' '' ''."状态不为待审批，无法提交

    PERFORM frm_pop_msg TABLES ot_return.

    RETURN.
  ENDIF.

  gv_key1 = ls_req_head-banfn.
  SELECT SINGLE name_textc FROM user_addr
    INTO gv_key2
    WHERE bname = ls_item-ernam.

  CALL FUNCTION 'ZAPP_FLOW_CREATE'
    EXPORTING
      object       = 'EBAN'
      line         = ls_item
      key1         = gv_key1
      key2         = gv_key2
      uname        = ls_item-ernam
      commit       = ''
    TABLES
      et_flow_head = gt_flow_head
      et_flow_item = gt_flow_item
      et_return    = ot_return
    EXCEPTIONS
      error        = 1
      OTHERS       = 2.
  IF sy-subrc <> 0.

    PERFORM frm_pop_msg TABLES ot_return.

  ELSE.
    CALL FUNCTION 'BAPI_REQUISITION_RELEASE'
      EXPORTING
        number                 = ls_req_head-banfn
        rel_code               = 'R0'
        item                   = ls_item-bnfpo
      EXCEPTIONS
        authority_check_fail   = 1
        requisition_not_found  = 2
        enqueue_fail           = 3
        prerequisite_fail      = 4
        release_already_posted = 5
        responsibility_fail    = 6
        OTHERS                 = 7.
    IF sy-subrc <> 0.
      PERFORM frm_add_message USING 'E' 'ZAPP' 024 '' '' '' ''."采购申请提交失败

      PERFORM frm_pop_msg TABLES ot_return.
      ROLLBACK WORK.
      RETURN.
    ENDIF.
    COMMIT WORK AND WAIT.
    READ TABLE gt_flow_head  INDEX 1.
    IF sy-subrc EQ 0.
      PERFORM frm_add_message USING 'S' 'ZAPP' 025 gt_flow_head-name1 gt_flow_head-appno  '' '' ."已创建流程编号
      PERFORM frm_pop_msg TABLES ot_return.
    ENDIF.
  ENDIF.






ENDFUNCTION.
