*&---------------------------------------------------------------------*
*& 包含               ZAPP_FLOW_PBO
*&---------------------------------------------------------------------*

FORM frm_set_sel_screen.

*  LOOP AT SCREEN.
*    IF  screen-group1 = 'C'.
*      IF create = 'X'.
*        screen-active = '1'.
*      ELSE .
*        screen-active = '0'.
*      ENDIF.
*    ENDIF.
*
*    IF screen-group1 = 'M'.
*      IF modify = 'X'.
*        screen-active = '1'.
*      ELSE .
*        screen-active = '0'.
*      ENDIF.
*    ENDIF.
*
*    MODIFY SCREEN.
*  ENDLOOP.
*

  LOOP AT SCREEN.
    IF screen-group1 = 'C'.
        screen-active = '0'.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

ENDFORM.
