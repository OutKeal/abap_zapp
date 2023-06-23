*&---------------------------------------------------------------------*
*& 包含               ZAPP_FLOW_F01
*&---------------------------------------------------------------------*

FORM frm_add_msg USING msgid
                        msgty
                        msgno
                        msgv1
                        msgv2
                        msgv3
                        msgv4.

  CLEAR gt_message.
  gt_message-msgid = msgid .
  gt_message-msgty = msgty .
  gt_message-msgno = msgno .
  gt_message-msgv1 = msgv1 .
  gt_message-msgv2 = msgv2 .
  gt_message-msgv3 = msgv3 .
  gt_message-msgv4 = msgv4 .
  APPEND gt_message.

ENDFORM.


FORM frm_create_flow.

  CLEAR ot_return[].
  CALL FUNCTION 'ZAPP_FLOW_CREATE'
    EXPORTING
      object       = p_object
      key1         = p_key1
      key2         = p_key2
      key3         = p_key3
      key4         = p_key4
      key5         = p_key5
      key6         = p_key6
    TABLES
      et_flow_head = gt_head
      et_flow_item = gt_item
      et_return    = ot_return
    EXCEPTIONS
      error        = 1
      OTHERS       = 2.
  CLEAR gt_message[].

  LOOP AT ot_return.
    PERFORM frm_add_msg USING ot_return-id
                              ot_return-type
                              ot_return-number
                              ot_return-message_v1
                              ot_return-message_v2
                              ot_return-message_v3
                              ot_return-message_v4.
  ENDLOOP.
  IF sy-subrc EQ 0.

    CALL FUNCTION 'C14Z_MESSAGES_SHOW_AS_POPUP'
      TABLES
        i_message_tab = gt_message[].
    CLEAR gt_message[].
  ENDIF.

ENDFORM.


FORM frm_get_flow TABLES ct_head STRUCTURE zapp_flow_head
                         ct_item STRUCTURE zapp_flow_item
                             .
  RANGES: s_object FOR zapp_object-object.
  DATA: lv_key1 TYPE zapp_key1.

  CLEAR s_object[].

  IF p_object IS NOT INITIAL.
    s_object-sign = 'I'.
    s_object-option = 'EQ'.
    s_object-low = p_object.
    APPEND s_object.
  ENDIF.

  IF s_key1-low  IS NOT INITIAL.
    lv_key1 = '%' && s_key1-low.
  ENDIF.

  CASE 'X'.
    WHEN p_all.

      SELECT DISTINCT h~* FROM zapp_flow_head AS h
        INNER JOIN zapp_flow_item AS i ON h~appno = i~appno
        INTO CORRESPONDING FIELDS OF TABLE @ct_head
        WHERE h~object IN @s_object
          AND h~appno IN @s_appno
          AND ( h~key1 IN @s_key1 OR h~key1 LIKE @lv_key1 )
          AND h~status IN ('B','C')
          AND h~erdat IN @s_erdat
          AND i~department IN @s_dep
          AND i~person IN @s_spr.
    WHEN p_ds.
      SELECT DISTINCT h~* FROM zapp_flow_head AS h
        INNER JOIN zapp_flow_item AS i ON h~appno = i~appno AND h~flow_point = i~flow_point
        INTO CORRESPONDING FIELDS OF TABLE @ct_head
        WHERE h~object IN @s_object
          AND h~appno IN @s_appno
          AND ( h~key1 IN @s_key1 OR h~key1 LIKE @lv_key1 )
          AND h~status IN ('B','C')
          AND h~erdat IN @s_erdat
          AND i~department IN @s_dep
          AND i~person IN @s_spr
          AND i~zresult = 'A'.
    WHEN p_ys.
      SELECT DISTINCT h~* FROM zapp_flow_head AS h
        INNER JOIN zapp_flow_item AS i ON h~appno = i~appno
        INTO CORRESPONDING FIELDS OF TABLE @ct_head
        WHERE h~object IN @s_object
          AND h~appno IN @s_appno
          AND ( h~key1 IN @s_key1 OR h~key1 LIKE @lv_key1 )
          AND h~status IN ('B','C')
          AND h~erdat IN @s_erdat
          AND i~department IN @s_dep
          AND i~person IN @s_spr
          AND i~zresult = 'C'.
  ENDCASE.


  IF sy-subrc NE 0.
    RETURN.
*    MESSAGE '无有效数据' TYPE 'S' DISPLAY LIKE 'E'.
*    STOP.
  ENDIF.

  DELETE ADJACENT DUPLICATES FROM ct_head COMPARING appno.
  SORT ct_head BY erdat DESCENDING erzet DESCENDING. "add by at-yuxs

  SELECT * FROM zapp_flow_item
    INTO TABLE ct_item
    FOR ALL ENTRIES IN ct_head
    WHERE appno = ct_head-appno.

ENDFORM.
