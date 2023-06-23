FUNCTION zapp_flow_get.
*"----------------------------------------------------------------------
*"*"本地接口：
*"  IMPORTING
*"     VALUE(OBJECT) TYPE  ZAPP_EOBJECT
*"     VALUE(KEY1) TYPE  CHAR20 OPTIONAL
*"  EXPORTING
*"     VALUE(ES_FLOW_HEAD) TYPE  ZAPP_FLOW_HEAD
*"  TABLES
*"      ET_FLOW_ITEM STRUCTURE  ZAPP_FLOW_ITEM OPTIONAL
*"  EXCEPTIONS
*"      NODATA
*"----------------------------------------------------------------------

  SELECT SINGLE * FROM zapp_flow_head
    INTO  @es_flow_head
    WHERE object = @object
    AND key1 = @key1
    AND status <> 'D'
    AND status <> 'R'.

  IF sy-subrc NE 0.
    RAISE nodata.
  ENDIF.

  SELECT * FROM zapp_flow_item
    INTO TABLE @et_flow_item
    WHERE appno = @es_flow_head-appno.

ENDFUNCTION.
