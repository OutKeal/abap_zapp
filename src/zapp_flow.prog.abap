*&---------------------------------------------------------------------*
*& REPORT ZAPP_FLOW
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zapp_flow.


INCLUDE zapp_flow_top.
INCLUDE zapp_flow_sel.
INCLUDE zapp_flow_pbo.
INCLUDE zapp_flow_f01.

INITIALIZATION.
  IF sy-calld = 'X'.
    p_ds = ''.
    p_ys = ''.
    p_all = 'X'.
  ELSE.
    IF s_spr[] IS INITIAL.
      s_spr-sign = 'I'.
      s_spr-option = 'EQ'.
      s_spr-low = sy-uname.
      APPEND s_spr.
      CLEAR s_spr.
    ENDIF.
  ENDIF.


AT SELECTION-SCREEN.

AT SELECTION-SCREEN OUTPUT.

  PERFORM frm_set_sel_screen.

START-OF-SELECTION.

*  CASE 'X'.
*    WHEN create.
*
*      PERFORM frm_create_flow.
*
*    WHEN modify.
*
*      PERFORM frm_get_flow TABLES gt_head[] gt_item[].
*
*  ENDCASE.

  PERFORM frm_get_flow TABLES gt_head[] gt_item[].

  gt_item_dis[] = gt_item[].

  CALL FUNCTION 'ZAPP_FLOW_MAINTAIN'
    EXPORTING
*     object  = p_object
      uname   = s_spr-low
    TABLES
      ct_head = gt_head[]
      ct_item = gt_item[].
