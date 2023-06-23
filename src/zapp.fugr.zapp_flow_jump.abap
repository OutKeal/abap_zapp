FUNCTION zapp_flow_jump.
*"----------------------------------------------------------------------
*"*"本地接口：
*"  IMPORTING
*"     REFERENCE(IS_HEAD) TYPE  ZAPP_HEAD
*"----------------------------------------------------------------------
  FIELD-SYMBOLS:<fs_value> TYPE any.
  DATA:ls_text1 TYPE char20,
       ls_text2 TYPE char20,
       ls_head  TYPE zapp_head.
  DATA:lv_first TYPE char1.
  RANGES :r_zppdhd FOR ztpp0112-zppdhd,
          r_werks FOR ztpp0112-werks,
          r_zzfldm FOR ztpp001-zzfldm.
  MOVE is_head TO ls_head. "导入进来的参数值不能更改，所以另定义一个结构

  GET PARAMETER ID 'ZAPP_FIRST' FIELD lv_first.
  SET PARAMETER ID 'ZAPP_FIRST'FIELD abap_false.
  SET PARAMETER ID 'ZAPP_JUMP'FIELD abap_true.
  IF gt_object[] IS INITIAL.
    SELECT *
     INTO TABLE gt_object FROM zapp_object
     WHERE object = ls_head-object.
    IF sy-subrc NE 0.
      MESSAGE e005(zapp)."审批流对象不存在
      RETURN.
    ENDIF.
  ENDIF.
  IF gt_object_key[] IS INITIAL.
    SELECT *
     INTO TABLE gt_object_key
     FROM zapp_object_key
     WHERE object = ls_head-object.
    IF sy-subrc NE 0.
      MESSAGE e006(zapp)."审批流对象KEY不存在
      RETURN.
    ENDIF.
  ENDIF.

  READ TABLE gt_object WITH KEY object = ls_head-object .
  IF sy-subrc EQ 0.
    IF gv_object IS INITIAL.
      LOOP AT gt_object_key WHERE object = ls_head-object.
        ASSIGN COMPONENT gt_object_key-key_type OF STRUCTURE ls_head TO <fs_value>.
        IF sy-subrc EQ 0.
          FIND ':' IN <fs_value>.
          IF sy-subrc = 0.
            SPLIT <fs_value> AT ':' INTO ls_text1 <fs_value>.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.

    IF gt_object-memoryid IS NOT INITIAL.
      SET PARAMETER ID gt_object-memoryid FIELD ls_head-key1.
    ENDIF.

    CASE ls_head-object.
      WHEN 'DYGJD'.
        SET PARAMETER ID 'ZZVERSION' FIELD ls_head-key2.
      WHEN 'DYHLD' OR 'DYXHD'.
        SET PARAMETER ID 'ZZVERSION' FIELD ls_head-key2.
      WHEN OTHERS.
    ENDCASE.

    IF gt_object-tcode = 'ZAFO'.
      DATA:ls_afono TYPE zafono.
      ls_afono = ls_head-key1.
      CALL FUNCTION 'ZAFO_CALL_TRANSACTION'
        EXPORTING
          afono = ls_afono
          first = lv_first.
      RETURN.
    ENDIF.

    IF ls_head-object = 'BOMNO'.

      SELECT SINGLE *
        INTO @DATA(ls_bom_h)
        FROM ztpp_bom_h
       WHERE zzbom_no = @ls_head-key1
         AND zzversion = @ls_head-key2.

      r_zppdhd-sign = 'I'.
      r_zppdhd-option = 'EQ'.
      r_zppdhd-low = ls_bom_h-zppdhd.
      APPEND r_zppdhd.

      r_werks-sign = 'I'.
      r_werks-option = 'EQ'.
      r_werks-low = ls_bom_h-werks.
      APPEND r_werks.

      r_zzfldm-sign = 'I'.
      r_zzfldm-option = 'EQ'.
      r_zzfldm-low = ls_bom_h-zzfldm.
      APPEND r_zzfldm.

      IF lv_first = abap_true.
        SUBMIT zppr_bom_main WITH s_werk   IN r_werks
                             WITH s_zzfldm IN r_zzfldm[]
                             WITH s_zppdhd IN r_zppdhd AND RETURN.
      ELSE.
        SUBMIT zppr_bom_main WITH s_werk   IN r_werks
                           WITH s_zzfldm IN r_zzfldm[]
                           WITH s_zppdhd IN r_zppdhd.
      ENDIF.

    ELSE.
      IF lv_first = abap_true.
        CALL TRANSACTION gt_object-tcode AND SKIP FIRST SCREEN.
*        CALL FUNCTION 'ZFM_CALL_TCODE_IN_NEW_WINDOW' STARTING NEW TASK 'TEST'
*          DESTINATION 'NONE'
*          EXPORTING
*            tcode    = gt_object-tcode
*            object   = ls_head-object
*            memoryid = gt_object-memoryid
*            key1     = ls_head-key1
*            key2     = ls_head-key2
*            key3     = ls_head-key3
*            key4     = ls_head-key4
*            key5     = ls_head-key5
*            key6     = ls_head-key6.
      ELSE.
        LEAVE TO TRANSACTION gt_object-tcode AND SKIP FIRST SCREEN.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFUNCTION.
