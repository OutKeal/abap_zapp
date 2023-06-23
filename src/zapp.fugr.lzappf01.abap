*----------------------------------------------------------------------*
***INCLUDE LZAPPF01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form frm_update_uname
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM frm_update_uname TABLES p_ct_flow_item STRUCTURE zapp_flow_item
                       USING p_us_flow_head TYPE zapp_flow_head.

  DATA :wa_zapp_flow_item TYPE zapp_flow_item.
  CLEAR:wa_zapp_flow_item.

*根据 付款单审批财务节点配置表 ZTFI_015  增改 ZAPP_FLOW_ITEM表
  IF p_us_flow_head-key1 IS NOT INITIAL .

    SELECT SINGLE * INTO  @DATA(wa_fkd)
      FROM ztfi_fkd_head
     WHERE zfkdh = @p_us_flow_head-key1.


    IF wa_fkd IS NOT INITIAL .
      SELECT SINGLE * INTO @DATA(wa_ztfi015) FROM ztfi015
         WHERE zcglx = @wa_fkd-zcglx
           AND bukrs = @wa_fkd-bukrs .

      CHECK wa_ztfi015 IS  NOT INITIAL .

      wa_zapp_flow_item-appno      = p_us_flow_head-appno.
      wa_zapp_flow_item-line_id    = 30.
      wa_zapp_flow_item-flow_point = 'A3'.
      wa_zapp_flow_item-flow_point_name1 = '财务'.
      wa_zapp_flow_item-person = wa_ztfi015-person.
      wa_zapp_flow_item-name   = wa_ztfi015-username.
      wa_zapp_flow_item-ex_flow_point = 'A2'.
      wa_zapp_flow_item-zresult = 'A'.


      READ TABLE p_ct_flow_item INTO DATA(wa_flow) WITH KEY line_id = 30.
      IF sy-subrc <> 0 .
*没有30行 则在ZAPP_FLOW_ITEM表中新增一行 30行，
        APPEND wa_zapp_flow_item TO p_ct_flow_item.

*同时将ZAPP_FLOW_ITEM-LINE_ID = 40 行的 EX_FLOW_POINT 字段改为A3
        LOOP AT p_ct_flow_item ASSIGNING FIELD-SYMBOL(<fs_flow_item>) WHERE  line_id = 40 .
          <fs_flow_item>-ex_flow_point  = 'A3'.
        ENDLOOP.

        SORT p_ct_flow_item BY line_id .
      ENDIF.

    ENDIF.
  ENDIF.

ENDFORM.

*2021-12-20 LK加委外合同一审人可选
FORM frm_update_uname1 TABLES p_ct_flow_item STRUCTURE zapp_flow_item
                       USING p_us_flow_head TYPE zapp_flow_head.

  DATA :wa_zapp_flow_item TYPE zapp_flow_item.
  CLEAR:wa_zapp_flow_item.

  IF p_us_flow_head-key1 IS NOT INITIAL AND p_us_flow_head-key4 IS NOT INITIAL.

    SELECT SINGLE * INTO  @DATA(wa_wwd) FROM ztpp_wwht_head
     WHERE zhtbh = @p_us_flow_head-key1.

    CHECK wa_wwd IS NOT INITIAL AND wa_wwd-zzprid IS NOT INITIAL.

    wa_zapp_flow_item-appno      = p_us_flow_head-appno.
    wa_zapp_flow_item-line_id    = 2.
    wa_zapp_flow_item-flow_point = 'B1'.
    wa_zapp_flow_item-flow_point_name1 = '一级审批'.
    wa_zapp_flow_item-person = wa_wwd-zzprid.
    wa_zapp_flow_item-name   = wa_wwd-zzpr.
    wa_zapp_flow_item-ex_flow_point = 'B0'.
    wa_zapp_flow_item-zresult = 'A'.
    p_us_flow_head-flow_point = 'B1'.

    READ TABLE p_ct_flow_item INTO DATA(wa_flow) WITH   KEY  line_id    = 2.
    IF sy-subrc <> 0 .

*没有2行 则在zapp_flow_item表中新增一行 2行，
      APPEND wa_zapp_flow_item TO p_ct_flow_item.
      SORT p_ct_flow_item BY line_id .
    ENDIF.
  ENDIF.
  UPDATE zapp_flow_head SET flow_point = 'B1' WHERE appno = @p_us_flow_head-appno.

ENDFORM.
