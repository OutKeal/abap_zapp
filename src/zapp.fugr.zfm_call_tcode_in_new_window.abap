FUNCTION zfm_call_tcode_in_new_window.
*"----------------------------------------------------------------------
*"*"本地接口：
*"  IMPORTING
*"     VALUE(TCODE) TYPE  SY-TCODE
*"     VALUE(OBJECT) TYPE  ZAPP_EOBJECT
*"     VALUE(MEMORYID) TYPE  MEMORYID OPTIONAL
*"     VALUE(KEY1) TYPE  ZAPP_KEY1 OPTIONAL
*"     VALUE(KEY2) TYPE  ZAPP_KEY2 OPTIONAL
*"     VALUE(KEY3) TYPE  ZAPP_KEY3 OPTIONAL
*"     VALUE(KEY4) TYPE  ZAPP_KEY4 OPTIONAL
*"     VALUE(KEY5) TYPE  ZAPP_KEY5 OPTIONAL
*"     VALUE(KEY6) TYPE  ZAPP_KEY6 OPTIONAL
*"----------------------------------------------------------------------

  IF memoryid IS NOT INITIAL.
    SET PARAMETER ID memoryid FIELD key1.
  ENDIF.
  SET PARAMETER ID 'ZAPP_JUMP'FIELD abap_true.
  LEAVE TO TRANSACTION tcode AND SKIP FIRST SCREEN.

ENDFUNCTION.
