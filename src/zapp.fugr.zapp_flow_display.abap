FUNCTION zapp_flow_display.
*"----------------------------------------------------------------------
*"*"本地接口：
*"  IMPORTING
*"     VALUE(OBJECT) TYPE  ZAPP_EOBJECT
*"     VALUE(KEY1) TYPE  CHAR20 OPTIONAL
*"     VALUE(KEY2) TYPE  CHAR20 OPTIONAL
*"  EXCEPTIONS
*"      NODATA
*"----------------------------------------------------------------------
  PERFORM frm_free_global.

  IF key2 IS INITIAL.
    SELECT  * FROM zapp_flow_head
      INTO TABLE @DATA(lt_head)
      WHERE object = @object
      AND key1 = @key1  AND status <> 'R' AND status <> 'D'.
  ELSE.
    SELECT  * FROM zapp_flow_head
      INTO TABLE @lt_head
      WHERE object = @object
      AND key1 = @key1  AND key2 = @key2 AND status <> 'R' AND status <> 'D'.
  ENDIF.

  IF sy-subrc NE 0.
    RAISE nodata.
  ENDIF.

  SORT lt_head BY appno DESCENDING.

  LOOP AT lt_head INTO DATA(ls_head).

    IF sy-tabix = 1 .
      MOVE-CORRESPONDING ls_head TO gs_head .
      APPEND gs_head TO gt_head.
      CONTINUE.
    ELSE.
      DELETE lt_head INDEX  sy-tabix.
    ENDIF.
  ENDLOOP.

  SELECT * FROM zapp_flow_item
    INTO TABLE @DATA(lt_item)
    FOR ALL ENTRIES IN @lt_head
    WHERE appno = @lt_head-appno
   .
  LOOP AT lt_item INTO DATA(ls_item).
    MOVE-CORRESPONDING ls_item TO gt_item.

    PERFORM frm_set_item_icon CHANGING gt_item.
    APPEND gt_item.
  ENDLOOP.
  SORT gt_item BY appno line_id.

  gt_item_dis[] = gt_item[].

*    CALL FUNCTION 'ZAPP_FLOW_MAINTAIN'
*      EXPORTING
**        object        = object
*        uname         = sy-uname
*      TABLES
*        ct_head       = lt_head
*        ct_item       = lt_item.

  gs_item-zresult = 'C'.
  gs_item-opinion = TEXT-002."同意.
  gs_item-appdate = sy-datum.
  gs_item-apptime = sy-uzeit.
  CALL SCREEN 300 STARTING AT 10 5 ENDING AT 100 15.

ENDFUNCTION.
