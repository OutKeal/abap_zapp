FUNCTION zapp_write_log .
*"----------------------------------------------------------------------
*"*"本地接口：
*"  IMPORTING
*"     REFERENCE(NAME) TYPE  SYUNAME
*"----------------------------------------------------------------------

  DATA:ls_qury_log TYPE zapp_query_log.
  DATA:iv_id TYPE char20.
  DATA:lv_username TYPE ad_namtext,
       lv_uname    TYPE syuname.


  CALL FUNCTION 'ZFM_GET_USERNAME'
    EXPORTING
      userid   = name
    IMPORTING
      username = lv_username.
  lv_uname = lv_username.

  CALL FUNCTION 'NUMBER_GET_NEXT '
    EXPORTING
      nr_range_nr             = '01'
      object                  = 'ZAPP_QUERY'
    IMPORTING
      number                  = iv_id
    EXCEPTIONS
      interval_not_found      = 1
      number_range_not_intern = 2
      object_not_found        = 3
      quantity_is_0           = 4
      quantity_is_not_1       = 5
      interval_overflow       = 6
      buffer_overflow         = 7
      OTHERS                  = 8.

*   记录请求日志
  ls_qury_log-id = iv_id.
  ls_qury_log-query_userid = name.
  ls_qury_log-query_name = lv_uname.
  ls_qury_log-query_date = sy-datum.
  ls_qury_log-query_time = sy-uzeit.

  INSERT zapp_query_log FROM ls_qury_log.


ENDFUNCTION.
