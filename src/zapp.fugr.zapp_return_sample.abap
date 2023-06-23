FUNCTION zapp_return_sample.
*"----------------------------------------------------------------------
*"*"本地接口：
*"  IMPORTING
*"     REFERENCE(IS_HEAD) TYPE  ZAPP_HEAD
*"     REFERENCE(IV_STEP) TYPE  CHAR1
*"  EXPORTING
*"     REFERENCE(EV_MSG) TYPE  CHAR40
*"     REFERENCE(EV_FLAG) TYPE  CHAR1
*"----------------------------------------------------------------------
  CASE iv_step.
    WHEN 'A'."流程删除
*      UPDATE ztpp0100 SET gjstatus = 'A'
*      WHERE gylxno = is_head-key1.
*      IF sy-subrc <> 0.
*        ev_flag = 'E'.
*        ev_msg = '流程回写失败，更新表ZTPP0100错误'(t01).
*      ENDIF.
    WHEN 'C'."流程完成
*      UPDATE ztpp0100 SET gjstatus = 'C'
*      WHERE gylxno = is_head-key1.
*      IF sy-subrc <> 0.
*        ev_flag = 'E'.
*        ev_msg = '流程回写失败，更新表ZTPP0100错误'(t01).
*      ENDIF.
    WHEN OTHERS.
  ENDCASE.

ENDFUNCTION.
