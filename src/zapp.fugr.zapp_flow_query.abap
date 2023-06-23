FUNCTION zapp_flow_query.
*"----------------------------------------------------------------------
*"*"本地接口：
*"  IMPORTING
*"     VALUE(USERNAME) TYPE  SY-UNAME
*"  EXPORTING
*"     VALUE(RETURN) TYPE  BAPIRETURN1
*"  TABLES
*"      TB_FLOWS STRUCTURE  ZAPP_FLOW_HEAD
*"----------------------------------------------------------------------

  DATA: lt_head TYPE TABLE OF zapp_flow_head WITH HEADER LINE,
        type    TYPE  bapireturn-type,
        msg     TYPE sy-msgv1.


  CALL FUNCTION 'ZAPP_WRITE_LOG'
    EXPORTING
      name = username.

  SELECT DISTINCT h~*  FROM zapp_flow_head AS h
          INNER JOIN zapp_flow_item AS i
          ON h~appno = i~appno AND h~flow_point = i~flow_point
          INTO CORRESPONDING FIELDS OF TABLE @lt_head
          WHERE person = @username
          AND status = 'B'
          AND zresult = 'A'.



  IF sy-subrc NE 0.
    type = 'E'.
    msg = '无数据！'.
  ELSE.
    type = 'S'.
    msg = '请求成功！'.
  ENDIF.

  DELETE ADJACENT DUPLICATES FROM tb_flows COMPARING appno.

  LOOP AT lt_head.
    APPEND lt_head TO tb_flows.
  ENDLOOP.

  CALL FUNCTION 'BALW_BAPIRETURN_GET1'
    EXPORTING
      type       = type
      cl         = 'ZAPP'
      number     = '000'
      par1       = msg
    IMPORTING
      bapireturn = return
    EXCEPTIONS
      OTHERS     = 1.


ENDFUNCTION.
