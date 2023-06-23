class ZAPP_CL_GOS_SERVICE definition
  public
  inheriting from CL_GOS_SERVICE
  final
  create public .

public section.

  methods EXECUTE
    redefinition .
protected section.
private section.

  data OT_RETURN type TY_T_BAPIRET2 .
  data GT_MESSAGE type ESP1_MESSAGE_TAB_TYPE .

  methods PO_APP_CREATE
    importing
      !EBELN type EBELN .
  methods PR_APP_CREATE
    importing
      value(BANFN) type BANFN optional .
  methods ADD_MSG
    importing
      value(MSGID) type MSGID optional
      value(MSGTY) type MSGTY optional
      value(MSGNO) type SYST_MSGNO optional
      value(MSGV1) type MSGV1 optional
      value(MSGV2) type MSGV2 optional
      value(MSGV3) type MSGV3 optional
      value(MSGV4) type MSGV4 optional .
ENDCLASS.



CLASS ZAPP_CL_GOS_SERVICE IMPLEMENTATION.


  METHOD add_msg.
    data ls_message type esp1_message_wa_type.
    CLEAR ls_message.
    ls_message-msgid = msgid .
    ls_message-msgty = msgty .
    ls_message-msgno = msgno .
    ls_message-msgv1 = msgv1 .
    ls_message-msgv2 = msgv2 .
    ls_message-msgv3 = msgv3 .
    ls_message-msgv4 = msgv4 .
    APPEND ls_message to gt_message.
  ENDMETHOD.


  METHOD execute.
    DATA:ls_ebeln TYPE char10.
    CASE gs_lporb-typeid.
      WHEN 'BUS2012'.
        ls_ebeln = gs_lporb-instid.
        CALL METHOD me->po_app_create
          EXPORTING
            ebeln = ls_ebeln.
      WHEN 'BUS2105' .
        ls_ebeln = gs_lporb-instid.
        CALL METHOD me->pr_app_create
          EXPORTING
            banfn = ls_ebeln.
      WHEN OTHERS .


    ENDCASE.
  ENDMETHOD.


  METHOD po_app_create.

    DATA:ls_purchase_order_mm TYPE REF TO if_purchase_order_mm.

    DATA:ls_mepoheader TYPE  mepoheader.
    DATA:Lv_key1 TYPE char20.
    DATA:Lv_key2 TYPE char20.
    DATA:Lv_key3 TYPE char20.
    DATA:Lv_key4 TYPE char20.
    DATA:Lv_key5 TYPE char20.
    DATA:Lv_key6 TYPE char20.
    data:ls_return type bapiret2.

    DATA:lt_flow_head TYPE TABLE OF zapp_flow_head  .

    CALL FUNCTION 'ZAPP_PO_HEAD_OUTPUT'
      IMPORTING
        purchase_order_mm = ls_purchase_order_mm.

    ls_mepoheader = ls_purchase_order_mm->get_data( ).

    IF ls_mepoheader-ebeln IS INITIAL.
      MESSAGE '请先保存后才可以提交' TYPE 'I' .
      RETURN.
    ENDIF.

    IF ls_purchase_order_mm->is_changeable( ) = 'X'.
      MESSAGE '只有只读状态可以提交审批' TYPE 'I' .
      RETURN.
    ENDIF.

    IF ls_mepoheader-frgke  <> 'B'.
      MESSAGE '采购订单状态不为待提交,无法审批' TYPE 'I' .
      RETURN.
    ENDIF.

    Lv_key1 = ls_mepoheader-ebeln.

    SELECT SINGLE zname1 INTO Lv_key2 FROM
      zscmt0010 WHERE partner = Ls_mepoheader-lifnr.

    SELECT SUM( brtwr ) INTO @DATA(sum_brtwr) FROM
      ekpo WHERE ebeln = @Ls_mepoheader-ebeln.
    LV_key4 = sum_brtwr.

    CALL FUNCTION 'ZAPP_FLOW_CREATE'
      EXPORTING
        object       = 'EKKO'
        line         = Ls_mepoheader
*       key1         = gs_mepoheader-ebeln
        key2         = Lv_key2
        key4         = Lv_key4
        commit       = ''
      TABLES
        et_flow_head = lt_flow_head[]
*       ET_FLOW_ITEM =
        et_return    = ot_return
      EXCEPTIONS
        error        = 1
        OTHERS       = 2.

    IF sy-subrc <> 0.
      LOOP AT ot_return INTO ls_return.
        CALL METHOD me->add_msg
          EXPORTING
            msgid = ls_return-id
            msgty = ls_return-type
            msgno = ls_return-number
            msgv1 = ls_return-message_v1
            msgv2 = ls_return-message_v2
            msgv3 = ls_return-message_v3
            msgv4 = ls_return-message_v4.
      ENDLOOP.

      IF sy-subrc EQ 0.
        CALL FUNCTION 'C14Z_MESSAGES_SHOW_AS_POPUP'
          TABLES
            i_message_tab = gt_message[].
        CLEAR gt_message[].
      ENDIF.


    ELSE.

      CALL FUNCTION 'BAPI_PO_RELEASE'
        EXPORTING
          purchaseorder          = ls_mepoheader-ebeln
          po_rel_code            = 'P0'
        EXCEPTIONS
          authority_check_fail   = 1
          document_not_found     = 2
          enqueue_fail           = 3
          prerequisite_fail      = 4
          release_already_posted = 5
          responsibility_fail    = 6
          OTHERS                 = 7.
      IF sy-subrc <> 0.
        MESSAGE '采购订单审批失败' TYPE 'I'.
        ROLLBACK WORK.
        RETURN.
      ENDIF.
      COMMIT WORK AND WAIT.
      MESSAGE '审批流程创建成功' TYPE 'I'.
*      READ TABLE lt_flow_head INTO ls_head INDEX 1.
*      IF sy-subrc EQ 0.
*        MOVE-CORRESPONDING ls_head TO gt_head.
*        PERFORM frm_set_head_icon CHANGING gt_head.

*      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD pr_app_create.
    DATA:ls_eban TYPE eban.
    DATA:ls_PURCHASE_REQUISITION TYPE REF TO if_PURCHASE_REQUISITION.

    DATA:ls_req_head TYPE mereq_header.
    DATA:ls_req_item TYPE mmpur_requisition_item.
    DATA:lt_req_items TYPE mmpur_requisition_items.


    DATA:ls_return TYPE bapiret2.
    DATA:ls_item TYPE mereq_item.

    DATA:ls_AKTVT TYPE aktvt.


    DATA:Lv_key1 TYPE char20.
    DATA:Lv_key2 TYPE char20.
    DATA:Lv_key3 TYPE char20.
    DATA:Lv_key4 TYPE char20.
    DATA:Lv_key5 TYPE char20.
    DATA:Lv_key6 TYPE char20.
    CALL FUNCTION 'ZAPP_PR_HEAD_OUTPUT'
      IMPORTING
        purchase_requisition = ls_purchase_requisition.


    ls_req_head = ls_purchase_requisition->get_data( ).

    ls_aktvt = ls_purchase_requisition->get_activity( ).

    lt_req_items = ls_purchase_requisition->get_items( ).

    READ TABLE  lt_req_items  INDEX 1 INTO ls_req_item.

    ls_item = ls_req_item-item->get_data( ).

    IF ls_AKTVT = 'V'.

      MESSAGE i000(app)  WITH '只有只读状态的采购申请可以提交审批'.

      RETURN.
    ENDIF.

    IF ls_item-frgkz <> 'B'.
      MESSAGE i000(app)  WITH '状态不为待审批，无法提交'.
      RETURN.
    ENDIF.


    Lv_key1 = ls_req_head-banfn.
    SELECT SINGLE name_textc FROM user_addr
      INTO Lv_key2
      WHERE bname = ls_item-ernam.

    CALL FUNCTION 'ZAPP_FLOW_CREATE'
      EXPORTING
        object    = 'EBAN'
        line      = ls_item
        key1      = Lv_key1
        key2      = Lv_key2
        uname     = ls_item-ernam
        commit    = ''
      TABLES
*       et_flow_head = gt_flow_head
*       et_flow_item = gt_flow_item
        et_return = ot_return
      EXCEPTIONS
        error     = 1
        OTHERS    = 2.

    IF sy-subrc <> 0.

      LOOP AT ot_return INTO ls_return.
        CALL METHOD me->add_msg
          EXPORTING
            msgid = ls_return-id
            msgty = ls_return-type
            msgno = ls_return-number
            msgv1 = ls_return-message_v1
            msgv2 = ls_return-message_v2
            msgv3 = ls_return-message_v3
            msgv4 = ls_return-message_v4.
      ENDLOOP.

      IF sy-subrc EQ 0.
        CALL FUNCTION 'C14Z_MESSAGES_SHOW_AS_POPUP'
          TABLES
            i_message_tab = gt_message[].
        CLEAR gt_message[].
      ENDIF.

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
        MESSAGE i000(app)  WITH '采购申请提交失败'.

        ROLLBACK WORK.
        RETURN.
      ENDIF.
      COMMIT WORK AND WAIT.
      IF sy-subrc EQ 0.
        MESSAGE s000(app)  WITH '采购申请提交成功'.      ENDIF.

    ENDIF.

  ENDMETHOD.
ENDCLASS.
