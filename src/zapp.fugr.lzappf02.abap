*----------------------------------------------------------------------*
***INCLUDE LZAPPF02.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form frm_send_ypd_msg
*&---------------------------------------------------------------------*
*& "核料单及工价单审批完成发消息给打样申请单创建人
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> IS_HEAD
*&---------------------------------------------------------------------*
FORM frm_send_ypd_msg  USING ps_head STRUCTURE zapp_head.

  DATA: lv_zsqdh  TYPE ztpp_poopt_n-zsqdh,
        ls_dysq   TYPE ztpp_poopt_n,
        lv_ifsend TYPE char1.

  DATA:lt_user     TYPE TABLE OF zmsg_suser WITH HEADER LINE,
       l_object_id TYPE TABLE OF zmsg_object_id WITH HEADER LINE,
       ls_datah    TYPE zmsg_data_h.

  CASE ps_head-object.
    WHEN 'DYHLD'.

      "核料单数据
      SELECT SINGLE *
        INTO @DATA(ls_ztpp_bom_h)
        FROM ztpp_bom_h
        WHERE zzbom_no = @ps_head-key1
          AND zzversion = @ps_head-key2.

      "取工价单数据
      SELECT COUNT( * )
        FROM ztpp_fees
       WHERE zsqdh = ls_ztpp_bom_h-zsqdh
         AND status = 'C'.
      IF sy-subrc IS INITIAL.
        lv_ifsend = 'X'.
      ENDIF.

      lv_zsqdh = ls_ztpp_bom_h-zsqdh.

    WHEN 'DYGJD'.

      "工价单数据
      SELECT SINGLE *
        INTO @DATA(ls_ztpp_fees)
        FROM ztpp_fees
       WHERE zgjdh = @ps_head-key1
         AND zzversion = @ps_head-key2.

      "取核料单数据
      SELECT COUNT(*)
        FROM ztpp_bom_h
        WHERE zsqdh = ls_ztpp_fees-zsqdh
         AND status = 'C'.
      IF sy-subrc IS INITIAL.
        lv_ifsend = 'X'.
      ENDIF.

      lv_zsqdh = ls_ztpp_fees-zsqdh.

    WHEN OTHERS.
  ENDCASE.

  IF lv_ifsend IS NOT INITIAL.
    SELECT SINGLE * INTO ls_dysq FROM ztpp_poopt_n WHERE zsqdh = lv_zsqdh.
    IF sy-subrc IS INITIAL.

      lt_user-uname = ls_dysq-ernam.

      SELECT SINGLE name
        INTO lt_user-name1
        FROM zapp_addr
        WHERE person = lt_user-uname.
      APPEND lt_user.

      l_object_id = lv_zsqdh.

      ls_datah-object = 'DYSQD'.
      ls_datah-object_id = l_object_id.
      ls_datah-text = text-003."'核料单\工价单已完成,请查看'.

      CALL FUNCTION 'ZMSG_SAVE_DATA'
        EXPORTING
          is_datah = ls_datah
        TABLES
          it_data  = lt_user[].

    ENDIF.
  ENDIF.

ENDFORM.
