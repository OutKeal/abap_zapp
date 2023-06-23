*&---------------------------------------------------------------------*
*& 包含               ZAPP_FLOW_EXIT
*&---------------------------------------------------------------------*


FORM exit_set_flow_head CHANGING cs_flow_head TYPE zapp_flow_head.

  CASE gv_object.
    WHEN OTHERS.
  ENDCASE.

ENDFORM.

FORM exit_set_flow_item TABLES ct_flow_item STRUCTURE zapp_flow_item
                         USING us_flow_head TYPE zapp_flow_head.

  CASE gv_object.

    WHEN 'ZFKD'.
      PERFORM frm_update_uname TABLES ct_flow_item
                                USING us_flow_head.

    WHEN 'ZWWD'.
      PERFORM frm_update_uname1 TABLES ct_flow_item
                                USING us_flow_head.
    WHEN OTHERS.
  ENDCASE.

ENDFORM.
