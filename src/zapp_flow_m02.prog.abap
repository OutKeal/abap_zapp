*&---------------------------------------------------------------------*
*& 包含               ZAPP_FLOW_M02
*&---------------------------------------------------------------------*

" 反审单据回调过程
FORM frm_reset_appr CHANGING is_head STRUCTURE zapp_head  flag.
  DATA:ls_msg TYPE char40.
  DATA:ls_afono   TYPE zafono,
       lfo_afono  TYPE zafono,
       lfo_bustyp TYPE zafo_bustyp.
  DATA:ls_status TYPE zafo_status.
  DATA:ls_app_status TYPE zapp_status.

  DATA:ls_ebeln TYPE ebeln.

  CASE is_head-object.
    WHEN 'EKKO'.

      ls_ebeln = is_head-key1.

      SELECT ebeln, SUM( wemng ) AS wemng_po" 收货数量
       INTO TABLE @DATA(lt_eket)
       FROM eket
       WHERE ebeln = @ls_ebeln
        GROUP BY ebeln
        HAVING SUM( wemng ) > 0.
      IF sy-subrc EQ 0.
        flag = 'E'.
        ls_msg = '不能冲销，采购订单存在收货'.
      ENDIF.

      IF flag NE 'E'.
        SELECT SINGLE h~zfkdh INTO @DATA(lv_zfkdh1)
          FROM ztfi_fkd_head AS h
          LEFT JOIN ztfi_fkd_item  AS i ON i~zfkdh =  h~zfkdh
          WHERE i~ebeln = @ls_ebeln.
        IF sy-subrc EQ 0.
          flag = 'E'.
          ls_msg = '存在付款单：' && ls_msg && '(' && lv_zfkdh1 && ')'.
        ENDIF.
      ENDIF.

      IF flag NE 'E'.
        CALL FUNCTION 'BAPI_PO_RESET_RELEASE'
          EXPORTING
            purchaseorder            = ls_ebeln
            po_rel_code              = 'P0'
          EXCEPTIONS
            authority_check_fail     = 1
            document_not_found       = 2
            enqueue_fail             = 3
            prerequisite_fail        = 4
            release_already_posted   = 5
            responsibility_fail      = 6
            no_release_already       = 7
            no_new_release_indicator = 8
            OTHERS                   = 9.
        IF sy-subrc NE 0.
          flag = 'E'.
          ls_msg = '标准PO取消审批失败'.
        ELSE.
          flag = 'S'.
          ls_afono = is_head-key1.
          UPDATE zafo_head SET status = 'A' app_status = 'A'
               aedat = sy-datum  aetim = sy-uzeit aenam = sy-uname
               WHERE afono = ls_afono.
          IF sy-subrc NE 0.
            flag = 'E'.
            CALL FUNCTION 'BAPI_PO_RELEASE'
              EXPORTING
                purchaseorder          = ls_ebeln
                po_rel_code            = 'P1'
              EXCEPTIONS
                authority_check_fail   = 1
                document_not_found     = 2
                enqueue_fail           = 3
                prerequisite_fail      = 4
                release_already_posted = 5
                responsibility_fail    = 6
                OTHERS                 = 7.
            ls_msg = '单据状态修改失败'.
          ENDIF.
        ENDIF.
      ENDIF.

    WHEN 'EKKOF'.
      ls_ebeln = is_head-key1.
      CALL FUNCTION 'BAPI_PO_RESET_RELEASE'
        EXPORTING
          purchaseorder            = ls_ebeln
          po_rel_code              = 'P0'
        EXCEPTIONS
          authority_check_fail     = 1
          document_not_found       = 2
          enqueue_fail             = 3
          prerequisite_fail        = 4
          release_already_posted   = 5
          responsibility_fail      = 6
          no_release_already       = 7
          no_new_release_indicator = 8
          OTHERS                   = 9.

      IF sy-subrc NE 0.
        flag = 'E'.
        ls_msg = '标准PO取消审批失败'.
      ELSE.
        flag = 'S'.
        ls_afono = is_head-key1.
        UPDATE zafo_head SET status = 'A' app_status = 'A'
         aedat = sy-datum aetim = sy-uzeit aenam = sy-uname
         WHERE afono = ls_afono.
        IF sy-subrc NE 0.
          flag = 'E'.
          CALL FUNCTION 'BAPI_PO_RELEASE'
            EXPORTING
              purchaseorder          = ls_ebeln
              po_rel_code            = 'P1'
            EXCEPTIONS
              authority_check_fail   = 1
              document_not_found     = 2
              enqueue_fail           = 3
              prerequisite_fail      = 4
              release_already_posted = 5
              responsibility_fail    = 6
              OTHERS                 = 7.
          ls_msg = '单据状态修改失败'.
        ENDIF.
      ENDIF.

    WHEN 'EBAN'.
      DATA:ls_banfn TYPE banfn.
      DATA:ls_bnfpo TYPE bnfpo.
      ls_banfn = is_head-key1.
      SELECT bnfpo INTO TABLE @DATA(lt_bnfpo)
        FROM eban WHERE banfn = @ls_banfn.

      SORT lt_bnfpo BY bnfpo ASCENDING.
      READ TABLE lt_bnfpo INTO DATA(li_bnfpo) INDEX 1.
      ls_bnfpo = li_bnfpo-bnfpo.

      ls_ebeln = is_head-key1.

      SELECT SINGLE zafo_head~afono,zafo_head~bustyp
        INTO (@lfo_afono,@lfo_bustyp)
        FROM zafo_item
        INNER JOIN zafo_head ON zafo_head~afono = zafo_item~afono
        WHERE zafo_item~afono_ref = @ls_ebeln
        AND zafo_head~bustyp <> 'POC01'
        AND zafo_head~status <> 'D'
        AND zafo_head~del_flag <> 'X'
        AND zafo_item~item_status <> 'F'
        AND zafo_item~del_flag = ''.
      IF sy-subrc EQ 0.
        SELECT SINGLE  bustyp_name1 INTO ls_msg
           FROM zafo_bustype
          WHERE bustyp = lfo_bustyp.
        flag = 'E'.
        ls_msg = '存在后续单据：' && ls_msg && '(' && lfo_afono && ')'.
      ENDIF.

      IF flag NE 'E'.

        CALL FUNCTION 'BAPI_REQUISITION_RESET_RELEASE'
          EXPORTING
            number                   = ls_banfn
            item                     = ls_bnfpo
            rel_code                 = 'R0'
          EXCEPTIONS
            authority_check_fail     = 1
            requisition_not_found    = 2
            enqueue_fail             = 3
            prerequisite_fail        = 4
            release_already_posted   = 5
            responsibility_fail      = 6
            no_release_already       = 7
            no_new_release_indicator = 8
            OTHERS                   = 9.
        IF sy-subrc NE 0.
          flag = 'E'.
          ls_msg = '标准R0取消审批失败'.
        ELSE.
          flag = 'S'.
          UPDATE zafo_head
            SET status = 'A'
                app_status = 'A'
                 aedat = sy-datum
                 aetim = sy-uzeit
                 aenam = sy-uname
             WHERE banfn = ls_banfn
               AND afono = ls_banfn.
          IF sy-subrc NE 0.
            flag = 'E'.
          ELSE.
            flag = 'S'.
          ENDIF.
        ENDIF.
      ENDIF.
    WHEN 'OFFER'.
      DATA:ls_zofno TYPE zofno.
      DATA:ls_zofst TYPE zofst.
      ls_zofno = is_head-key1.

*      SELECT SINGLE zofst INTO ls_zofst
*        FROM zmmt0050 WHERE zofno = ls_zofno.
*      IF ls_zofst = 'B'.
      UPDATE zmmt0050 SET zofst = 'A'
            modat = sy-datum
            mozet = sy-uzeit
            monam = sy-uname
       WHERE zofno = ls_zofno
       .
      IF sy-subrc NE 0.
        flag = 'E'.
        ls_msg = '单据状态修改失败'.
      ELSE.
        flag = 'S'.
      ENDIF.

    WHEN 'REC' OR 'DUC' OR 'POF' OR 'COST' OR 'CJD' OR 'CLBS'.
      ls_afono = is_head-key1.

      SELECT SINGLE zafo_head~afono,zafo_head~bustyp
        INTO (@lfo_afono,@lfo_bustyp)
        FROM zafo_item
        INNER JOIN zafo_head ON zafo_head~afono = zafo_item~afono
        WHERE zafo_item~afono_ref = @ls_afono
        AND zafo_item~afono <> @ls_afono
        AND zafo_head~bustyp <> 'POC01'
        AND zafo_head~status <> 'D'
        AND zafo_head~del_flag <> 'X'
        AND zafo_item~item_status <> 'F'
        AND zafo_item~del_flag = ''.
      IF sy-subrc EQ 0.
        SELECT SINGLE  bustyp_name1 INTO ls_msg
           FROM zafo_bustype
          WHERE bustyp = lfo_bustyp.
        flag = 'E'.
        ls_msg = '存在后续单据：' && ls_msg && '(' && lfo_afono && ')'.

      ELSE.

        UPDATE zafo_head SET status = 'A'
                              app_status = 'A'
                              aedat = sy-datum
                              aetim = sy-uzeit
                              aenam = sy-uname
                         WHERE afono = ls_afono.
        IF sy-subrc NE 0.
          flag = 'E'.
          ls_msg = '单据状态修改失败'.
        ELSE.
          flag = 'S'.
        ENDIF.
      ENDIF.

    WHEN 'EKKOC' . "采购追加单
      ls_afono = is_head-key1.

      IF is_head-status = 'C'.
        PERFORM frm_add_message USING 'E' 'ZAPP' 036  is_head-name1 '' '' ''."流程审批&1不允许反审核
        RETURN.
      ENDIF.

      UPDATE zafo_head
      SET status = 'A'
          app_status = 'A'
           aedat = sy-datum
           aetim = sy-uzeit
           aenam = sy-uname
       WHERE afono = ls_afono.

      IF sy-subrc NE 0.
        flag = 'E'.
        ls_msg = '单据状态修改失败'.
      ELSE.
        flag = 'S'.
      ENDIF.

    WHEN 'BOMNO'. "bom 审批流程
      DATA lv_zzbom_no TYPE zzbom_no.
      DATA lv_zzversion TYPE zzversion.

      lv_zzbom_no = is_head-key1.
      lv_zzversion = is_head-key2.

      UPDATE ztpp_bom_h
        SET status = 'A'
           aedat = sy-datum
           aezet = sy-uzeit
           aenam = sy-uname
         WHERE zzbom_no = lv_zzbom_no
         AND zzversion = lv_zzversion.

      IF sy-subrc NE 0.
        flag = 'E'.
        ls_msg = '单据状态修改失败'.
      ELSE.
        flag = 'S'.
      ENDIF.

    WHEN 'ZFKD'.
      DATA lv_zfkdh TYPE ztfi_fkd_head-zfkdh.
      lv_zfkdh = is_head-key1.

      UPDATE ztfi_fkd_head
         SET zzt = 'A'
             zspxgr = sy-uname
              ccudt = sy-datum
              ccutm = sy-uzeit
       WHERE zfkdh = lv_zfkdh.

      IF sy-subrc NE 0.
        flag = 'E'.
        ls_msg = '单据状态修改失败'.
      ELSE.
        flag = 'S'.
      ENDIF.

    WHEN 'ZDHD'.
      DATA lv_zppdhd TYPE ztpp0089-zppdhd.
      lv_zppdhd = is_head-key1.

      UPDATE ztpp0089
         SET zdhdzt = 'A'
       WHERE zppdhd = lv_zppdhd.

      IF sy-subrc NE 0.
        flag = 'E'.
        ls_msg = '单据状态修改失败'.
      ELSE.
        flag = 'S'.
      ENDIF.

    WHEN 'DYSQD'."打样申请单

      UPDATE ztpp_poopt_n
        SET status = 'A'
            aenam  = sy-uname
            aedat  = sy-datum
            aezet  = sy-uzeit
        WHERE zsqdh = is_head-key1.

      IF sy-subrc NE 0.
        flag = 'E'.
        ls_msg = '单据状态修改失败'.
      ELSE.
        flag = 'S'.
      ENDIF.

    WHEN 'DYHLD'."打样核料单

      UPDATE ztpp_bom_h
        SET status = 'A'
        WHERE zzbom_no = is_head-key1
        AND zzversion = is_head-key2
        .

      IF sy-subrc NE 0.
        flag = 'E'.
        ls_msg = '单据状态修改失败'.
      ELSE.
        flag = 'S'.
      ENDIF.

    WHEN 'DYGJD'."打样工价单

      UPDATE ztpp_fees
        SET status = 'A'
        WHERE zgjdh = is_head-key1
        AND zzversion = is_head-key2
        .
      IF sy-subrc NE 0.
        flag = 'E'.
        ls_msg = '单据状态修改失败'.
      ELSE.
        flag = 'S'.
      ENDIF.

    WHEN 'DYBJD'."打样报价单

      UPDATE ztpp_bjd_h
        SET status = 'A'
        WHERE zbjdh = is_head-key1
        .
      IF sy-subrc NE 0.
        flag = 'E'.
        ls_msg = '单据状态修改失败'.
      ELSE.
        flag = 'S'.
      ENDIF.


    WHEN 'ZPMB'.

      UPDATE ztpp_pmbom_head SET zstatus = 'A' WHERE zpbom_no = is_head-key1.
      IF sy-subrc NE 0.
        flag = 'E'.
        ls_msg = '单据状态修改失败'.
      ELSE.
        flag = 'S'.
      ENDIF.

    WHEN 'ZWWD'.

      DATA:lv_zhtbh TYPE ztpp_wwht_head-zhtbh.
      DATA: ls_ztpp_wwht_head TYPE ztpp_wwht_head.

      lv_zhtbh = is_head-key1.

      SELECT SINGLE * INTO ls_ztpp_wwht_head FROM  ztpp_wwht_head WHERE zhtbh = lv_zhtbh.
      IF sy-subrc IS INITIAL.
        CALL FUNCTION 'BAPI_PO_RESET_RELEASE'
          EXPORTING
            purchaseorder            = ls_ztpp_wwht_head-ebeln
            po_rel_code              = 'P0'
          EXCEPTIONS
            authority_check_fail     = 1
            document_not_found       = 2
            enqueue_fail             = 3
            prerequisite_fail        = 4
            release_already_posted   = 5
            responsibility_fail      = 6
            no_release_already       = 7
            no_new_release_indicator = 8
            OTHERS                   = 9.

        IF sy-subrc NE 0.
          flag = 'E'.
          ls_msg = '标准PO取消审批失败'.
        ELSE.
          flag = 'S'.
          UPDATE ztpp_wwht_head SET zhtzt = 'A' WHERE zhtbh = lv_zhtbh.
          IF sy-subrc NE 0.
            flag = 'E'.
            ls_msg = '单据状态修改失败'.
          ELSE.
            flag = 'S'.
          ENDIF.
        ENDIF.
      ENDIF.

    WHEN 'PDSP'. " 盘点单反审批
      SELECT SINGLE pdstatus INTO @DATA(lv_pdstatus) FROM zafo_pd_head
        WHERE afopd = @is_head-key1.
      IF sy-subrc EQ 0  AND lv_pdstatus EQ 'B'.
        UPDATE zafo_pd_head SET pdstatus = 'A' WHERE afopd = is_head-key1.
        IF sy-subrc EQ 0.
          flag = 'S'.
        ELSE.
          flag = 'E'.
          ls_msg =  '盘点单审批撤销失败！'.
        ENDIF.
      ELSEIF sy-subrc EQ 0  AND lv_pdstatus EQ 'S'.
        flag = 'E'.
        ls_msg =  '盘点单已审核，不能反审！' .
      ELSE.
        flag = 'E'.
        ls_msg =  '盘点单状态不能执行此操作！' .
      ENDIF.

    WHEN 'ZKPTZ'.  "开票通知单
      DATA: lv_zkptz TYPE zsdzkptzd_hed-zkptzno.
      lv_zkptz = is_head-key1.

      UPDATE zsdzkptzd_hed
      SET zzztbs = 'C'
          aedat = sy-datum
          aezet = sy-uzeit
          aenam = sy-uname
      WHERE zkptzno = lv_zkptz.
      IF sy-subrc NE 0.
        flag = 'E'.
        ls_msg = '单据状态修改失败'.
      ELSE.
        flag = 'S'.
      ENDIF.

    WHEN OTHERS.
      DATA: lv_funcname TYPE zresetfunc,
            lo_excp     TYPE REF TO cx_root.

      SELECT SINGLE resetfunc INTO lv_funcname
        FROM zapp_return WHERE object = is_head-object.
      IF sy-subrc <> 0 OR lv_funcname IS INITIAL.
        flag = 'E'.
        PERFORM frm_add_message USING 'E' 'ZAPP' 037  '' '' '' ''."流程没有配置回写函数，请检查表ZAPP_RETURN
      ELSE.
        TRY .
            TRANSLATE lv_funcname TO UPPER CASE.

            flag = 'S'.

            CALL FUNCTION lv_funcname
              EXPORTING
                is_head = is_head
                iv_step = 'A' "流程重置
              IMPORTING
                ev_msg  = ls_msg
                ev_flag = flag.

            IF flag = 'E'.
              PERFORM frm_add_message USING 'E' 'ZAPP' 038  ls_msg '' '' ''."流程审批错误&1
            ENDIF.

          CATCH cx_root INTO lo_excp.
            ls_msg =  lo_excp->get_text( ).
            PERFORM frm_add_message USING 'E' 'ZAPP' 038  ls_msg '' '' ''."流程审批错误&1
        ENDTRY.
      ENDIF.

  ENDCASE.

  IF flag = 'E'.
    PERFORM frm_add_message USING 'E' 'ZAPP' 039  is_head-appno '' '' ''."流程&1删除失败
    PERFORM frm_add_message USING 'E' 'ZAPP' 000  ls_msg '' '' ''."
    ROLLBACK WORK.
  ELSEIF flag = 'S'.
    PERFORM frm_add_message USING 'S' 'ZAPP' 040  is_head-appno '' '' ''."流程&1删除成功
    COMMIT WORK AND WAIT.
  ENDIF.

ENDFORM.


"单据审批回调过程
FORM frm_complete_appr USING is_head STRUCTURE zapp_head CHANGING flag.
  DATA:ls_afono TYPE zafono.
  DATA:ls_status TYPE zafo_status.
  DATA:ls_app_status TYPE zapp_status.
  DATA:ls_msg TYPE char40.
  CASE is_head-object.
    WHEN 'EKKO'.
      DATA:ls_ebeln TYPE ebeln.
      ls_ebeln = is_head-key1.
      CALL FUNCTION 'BAPI_PO_RELEASE'
        EXPORTING
          purchaseorder          = ls_ebeln
          po_rel_code            = 'P1'
        EXCEPTIONS
          authority_check_fail   = 1
          document_not_found     = 2
          enqueue_fail           = 3
          prerequisite_fail      = 4
          release_already_posted = 5
          responsibility_fail    = 6
          OTHERS                 = 7.
      IF sy-subrc NE 0 AND sy-subrc NE 5.
        flag = 'E'.
        ls_msg = '标准PO审批失败'.
      ELSE.
        flag = 'S'.
        ls_afono = is_head-key1.
        UPDATE zafo_head SET status = 'C' app_status = 'C'
            aedat = sy-datum  aetim = sy-uzeit aenam = sy-uname
         WHERE afono = ls_afono.
        IF sy-subrc NE 0.
          CALL FUNCTION 'BAPI_PO_RESET_RELEASE'
            EXPORTING
              purchaseorder            = ls_ebeln
              po_rel_code              = 'P0'
            EXCEPTIONS
              authority_check_fail     = 1
              document_not_found       = 2
              enqueue_fail             = 3
              prerequisite_fail        = 4
              release_already_posted   = 5
              responsibility_fail      = 6
              no_release_already       = 7
              no_new_release_indicator = 8
              OTHERS                   = 9.
          flag = 'E'.
          ls_msg = '单据状态修改失败'.
        ENDIF.
      ENDIF.

    WHEN 'EKKOF'.
      ls_ebeln = is_head-key1.
      CALL FUNCTION 'BAPI_PO_RELEASE'
        EXPORTING
          purchaseorder          = ls_ebeln
          po_rel_code            = 'P1'
        EXCEPTIONS
          authority_check_fail   = 1
          document_not_found     = 2
          enqueue_fail           = 3
          prerequisite_fail      = 4
          release_already_posted = 5
          responsibility_fail    = 6
          OTHERS                 = 7.
      IF sy-subrc NE 0.
        flag = 'E'.
        ls_msg = '标准PO审批失败'.
      ELSE.
        flag = 'S'.
        ls_afono = is_head-key1.
        UPDATE zafo_head SET status = 'C' app_status = 'C'
            aedat = sy-datum
            aetim = sy-uzeit
            aenam = sy-uname
         WHERE afono = ls_afono.
        IF sy-subrc NE 0.
          CALL FUNCTION 'BAPI_PO_RESET_RELEASE'
            EXPORTING
              purchaseorder            = ls_ebeln
              po_rel_code              = 'P0'
            EXCEPTIONS
              authority_check_fail     = 1
              document_not_found       = 2
              enqueue_fail             = 3
              prerequisite_fail        = 4
              release_already_posted   = 5
              responsibility_fail      = 6
              no_release_already       = 7
              no_new_release_indicator = 8
              OTHERS                   = 9.
          flag = 'E'.
          ls_msg = '单据状态修改失败'.
        ENDIF.
      ENDIF.

    WHEN 'EBAN'.
      DATA:ls_banfn TYPE banfn.
      ls_banfn = is_head-key1.

      SELECT bnfpo INTO TABLE @DATA(lt_bnfpo)
        FROM eban WHERE banfn = @ls_banfn.
      SORT lt_bnfpo BY bnfpo ASCENDING.
      READ TABLE lt_bnfpo INTO DATA(ls_bnfpo) INDEX 1.


      CALL FUNCTION 'BAPI_REQUISITION_RELEASE'
        EXPORTING
          number                 = ls_banfn
          rel_code               = 'R1'
          item                   = ls_bnfpo-bnfpo
        EXCEPTIONS
          authority_check_fail   = 1
          requisition_not_found  = 2
          enqueue_fail           = 3
          prerequisite_fail      = 4
          release_already_posted = 5
          responsibility_fail    = 6
          OTHERS                 = 7.
      IF sy-subrc NE 0.
        flag = 'E'.
      ELSE.
        flag = 'S'.
        UPDATE eban SET frgrl = ''
                        banpr = '05'
                        WHERE banfn = ls_banfn
                        AND frgrl = 'X'.

        UPDATE zafo_head
          SET status = 'C'
              app_status = 'C'
               aedat = sy-datum
               aetim = sy-uzeit
               aenam = sy-uname
           WHERE banfn = ls_banfn
             AND afono = ls_banfn.
        IF sy-subrc NE 0.
          flag = 'E'.
        ELSE.
          flag = 'S'.
          PERFORM frm_send_afo_msg USING is_head.
        ENDIF.
      ENDIF.

    WHEN 'OFFER'.
      DATA:ls_zofno TYPE zofno.
      DATA:ls_zofst TYPE zofst.
      ls_zofno = is_head-key1.

*      SELECT SINGLE zofst INTO ls_zofst
*        FROM zmmt0050 WHERE zofno = ls_zofno.
*      IF ls_zofst = 'B'.
      UPDATE zmmt0050  SET zofst = 'C'
                          modat = sy-datum
                          mozet = sy-uzeit
                          monam = sy-uname
                       WHERE zofno = ls_zofno.
      UPDATE zmmt0051 SET zofst_item = 'C'
                      WHERE zofno = ls_zofno.
      IF sy-subrc NE 0.
        flag = 'E'.
      ELSE.
        PERFORM frm_set_offer_msg USING ls_zofno.
        flag = 'S'.
      ENDIF.

    WHEN 'REC' OR 'DUC' OR 'POF' OR 'COST' OR 'CJD' OR 'CLBS'.
      ls_afono = is_head-key1.

      UPDATE zafo_head SET status = 'C'
                           app_status = 'C'
                           aedat = sy-datum
                           aetim = sy-uzeit
                           aenam = sy-uname
                       WHERE afono = ls_afono.

      IF sy-subrc NE 0.
        flag = 'E'.
      ELSE.
        PERFORM frm_send_afo_msg USING is_head.
        flag = 'S'.
      ENDIF.

    WHEN 'EKKOC' .
      ls_afono = is_head-key1.
      DATA  lt_return LIKE TABLE OF ot_return WITH HEADER LINE.

      CALL FUNCTION 'ZAFO_POST'
        EXPORTING
          i_afono   = ls_afono
* IMPORTING
*         ES_HEAD   =
        TABLES
          et_return = lt_return
*         et_item   =
        EXCEPTIONS
          error     = 1
          OTHERS    = 2.
      IF sy-subrc <> 0.
        LOOP AT lt_return.
          PERFORM frm_add_message USING lt_return-type
                                        lt_return-id
                                        lt_return-number
                                        lt_return-message_v1
                                        lt_return-message_v2
                                        lt_return-message_v3
                                        lt_return-message_v4.
        ENDLOOP.
      ENDIF.
      IF gv_error = 'X'.
        flag = 'E'.
      ELSE.
        UPDATE zafo_head
          SET status = 'C'
            app_status = 'C'
            aedat = sy-datum
            aetim = sy-uzeit
            aenam = sy-uname
          WHERE afono = ls_afono.
        IF sy-subrc NE 0.
          flag = 'E'.
        ELSE.
          flag = 'S'.
        ENDIF.
      ENDIF.

    WHEN 'BOMNO'. "bom 审批流程

      DATA lv_zzbom_no TYPE zzbom_no.
      DATA lv_zzversion TYPE zzversion.

      lv_zzbom_no = is_head-key1.
      lv_zzversion = is_head-key2.

      UPDATE ztpp_bom_h
        SET status = 'C'
           aedat = sy-datum
           aezet = sy-uzeit
           aenam = sy-uname
         WHERE zzbom_no = lv_zzbom_no
         AND zzversion = lv_zzversion.

      IF sy-subrc NE 0.
        flag = 'E'.
      ELSE.
        flag = 'S'.
      ENDIF.

    WHEN 'ZFKD'.

      DATA lv_zfkdh TYPE ztfi_fkd_head-zfkdh.
      lv_zfkdh = is_head-key1.

      UPDATE ztfi_fkd_head
         SET zzt = 'C'
             zspxgr = sy-uname
              ccudt = sy-datum
              ccutm = sy-uzeit
       WHERE zfkdh = lv_zfkdh.

      IF sy-subrc NE 0.
        flag = 'E'.
      ELSE.
        flag = 'S'.
      ENDIF.

    WHEN 'ZDHD'.
      DATA lv_zppdhd TYPE ztpp0089-zppdhd.
      lv_zppdhd = is_head-key1.

      UPDATE ztpp0089
         SET zdhdzt = 'C'
       WHERE zppdhd = lv_zppdhd.

      IF sy-subrc NE 0.
        flag = 'E'.
      ELSE.
        flag = 'S'.
      ENDIF.

    WHEN 'DYSQD'."打样申请单

      UPDATE ztpp_poopt_n
        SET status = 'C'
            aenam  = sy-uname
            aedat  = sy-datum
            aezet  = sy-uzeit
        WHERE zsqdh = is_head-key1.

      "2021/3/21取消核审时间自动创建以下单据

*      "创建核料单
*      PERFORM frm_hld_create USING is_head-key1.
*      "创建工价单
*      PERFORM frm_gjd_create USING is_head-key1.

      IF sy-subrc NE 0.
        flag = 'E'.
      ELSE.
        flag = 'S'.
      ENDIF.

    WHEN 'DYHLD'."打样核料单

      UPDATE ztpp_bom_h
        SET status = 'C'
        WHERE zzbom_no = is_head-key1
        AND zzversion = is_head-key2
        .
      IF sy-subrc NE 0.
        flag = 'E'.
      ELSE.
        PERFORM frm_send_ypd_msg USING is_head.   "核料单及工价单审批完成发消息给打样申请单创建人
        flag = 'S'.
      ENDIF.

    WHEN 'DYGJD'."打样工价单

      UPDATE ztpp_fees
        SET status = 'C'
        WHERE zgjdh = is_head-key1
        AND zzversion = is_head-key2
        .
      IF sy-subrc NE 0.
        flag = 'E'.
      ELSE.
        PERFORM frm_send_ypd_msg USING is_head.   "核料单及工价单审批完成发消息给打样申请单创建人
        flag = 'S'.
      ENDIF.

    WHEN 'DYBJD'."打样报价单

      UPDATE ztpp_bjd_h
        SET status = 'C'
        WHERE zbjdh = is_head-key1
        .
      IF sy-subrc NE 0.
        flag = 'E'.
      ELSE.
        flag = 'S'.
      ENDIF.

    WHEN 'ZPMB'.

      UPDATE ztpp_pmbom_head SET zstatus = 'C' WHERE zpbom_no = is_head-key1.
      IF sy-subrc NE 0.
        flag = 'E'.
      ELSE.
        flag = 'S'.
      ENDIF.

    WHEN 'ZWWD'.

      DATA:lv_zhtbh TYPE ztpp_wwht_head-zhtbh.
      DATA: ls_ztpp_wwht_head TYPE ztpp_wwht_head.

      lv_zhtbh = is_head-key1.

      SELECT SINGLE * INTO ls_ztpp_wwht_head FROM  ztpp_wwht_head WHERE zhtbh = lv_zhtbh.
      IF sy-subrc IS INITIAL.
        CALL FUNCTION 'BAPI_PO_RELEASE'
          EXPORTING
            purchaseorder            = ls_ztpp_wwht_head-ebeln
            po_rel_code              = 'P1'
          EXCEPTIONS
            authority_check_fail     = 1
            document_not_found       = 2
            enqueue_fail             = 3
            prerequisite_fail        = 4
            release_already_posted   = 5
            responsibility_fail      = 6
            no_release_already       = 7
            no_new_release_indicator = 8
            OTHERS                   = 9.

        IF sy-subrc NE 0.
          flag = 'E'.
        ELSE.
          flag = 'S'.
          UPDATE ztpp_wwht_head SET zhtzt = 'C' WHERE zhtbh = lv_zhtbh.
          IF sy-subrc NE 0.
            flag = 'E'.
          ELSE.
            flag = 'S'.
          ENDIF.
        ENDIF.
      ENDIF.

    WHEN 'PDSP'. " 盘点单审批
      UPDATE zafo_pd_head SET pdstatus = 'C' WHERE afopd = is_head-key1.
      IF sy-subrc NE 0.
        flag = 'E'.
      ELSE.
        flag = 'S'.
        DATA:gt_pd_head TYPE TABLE OF zafo_pd_head WITH HEADER LINE.
        DATA:gt_pd_item TYPE TABLE OF zafo_pd_item WITH HEADER LINE.
        DATA:ls_head TYPE  zafo_head .
        DATA:lt_item TYPE TABLE OF zafo_sitem WITH HEADER LINE.
        CLEAR lt_return .
        SELECT SINGLE * FROM zafo_pd_head
          WHERE afopd = @is_head-key1
          INTO @gt_pd_head.

        SELECT * FROM zafo_pd_item
          WHERE afopd = @is_head-key1
          INTO TABLE @gt_pd_item.

        LOOP AT gt_pd_item WHERE menge_cy <> 0 .
          MOVE-CORRESPONDING gt_pd_item TO lt_item.
          lt_item-menge1 = gt_pd_item-menge_sp.
          lt_item-menge2 = gt_pd_item-menge_yc.
          lt_item-menge4 = gt_pd_item-menge.
          lt_item-menge = gt_pd_item-menge_cy.
          lt_item-vbeln_va = gt_pd_item-vbeln.
          lt_item-posnr_va = gt_pd_item-posnr.
          APPEND lt_item.
          CLEAR lt_item.
        ENDLOOP.
        IF lt_item[] IS INITIAL.
          gt_pd_head-pdstatus = 'S'.
          UPDATE zafo_pd_head SET pdstatus = 'S'
            WHERE afopd = gt_pd_head-afopd.
          COMMIT WORK AND WAIT.
        ELSE.
          ls_head-werks = gt_pd_head-werks.
          ls_head-lgort = gt_pd_head-lgort.

          CALL FUNCTION 'ZAFO_CREATE_SAVE'
            EXPORTING
              i_bustyp     = '5001'
              no_authcheck = 'X'
              i_post       = 'X'
            TABLES
              et_return    = lt_return
              ct_item      = lt_item
*             CT_ITEM_PO   =
*             CT_ITEM_COST =
            CHANGING
              cs_head      = ls_head
            EXCEPTIONS
              error        = 1
              OTHERS       = 2.
          IF sy-subrc <> 0.

          ENDIF.

          IF ls_head-afono IS NOT INITIAL.
            gt_pd_head-afono = ls_head-afono.
            gt_pd_head-pdstatus = 'S'.
            UPDATE zafo_pd_head
            SET pdstatus = 'S'
                afono = ls_head-afono
            WHERE afopd = gt_pd_head-afopd.
            COMMIT WORK AND WAIT.
            MESSAGE '盘点单差异生成成功' TYPE 'S'  .
          ELSE.
            MESSAGE '盘点单差异生成失败' TYPE 'S'  DISPLAY LIKE 'E'.
          ENDIF.
        ENDIF.
      ENDIF.

    WHEN 'ZKPTZ'.  "开票通知单
      DATA: lv_zkptz TYPE zsdzkptzd_hed-zkptzno.
      lv_zkptz = is_head-key1.

      UPDATE zsdzkptzd_hed
      SET zzztbs = 'A'
          aedat = sy-datum
          aezet = sy-uzeit
          aenam = sy-uname
      WHERE zkptzno = lv_zkptz.
      IF sy-subrc NE 0.
        flag = 'E'.
      ELSE.
        flag = 'S'.
      ENDIF.

    WHEN OTHERS.
      DATA: lv_funcname TYPE zresetfunc,
            lo_excp     TYPE REF TO cx_root.

      SELECT SINGLE resetfunc INTO lv_funcname
        FROM zapp_return WHERE object = is_head-object.
      IF sy-subrc <> 0 OR lv_funcname IS INITIAL.
        flag = 'E'.
        PERFORM frm_add_message USING 'E' 'ZAPP' 037  ls_msg '' '' ''."流程没有配置回写函数，请检查表ZAPP_RETURN
      ELSE.
        TRY .
            TRANSLATE lv_funcname TO UPPER CASE.

            flag = 'S'.

            CALL FUNCTION lv_funcname
              EXPORTING
                is_head = is_head
                iv_step = 'C' "流程完成
              IMPORTING
                ev_msg  = ls_msg
                ev_flag = flag.

            IF flag = 'E'.
              ls_msg =  ls_msg.
              PERFORM frm_add_message USING 'E' 'ZAPP' 038  ls_msg '' '' ''."流程审批错误:&1
            ENDIF.

          CATCH cx_root INTO lo_excp.
            ls_msg = lo_excp->get_text( ).
            PERFORM frm_add_message USING 'E' 'ZAPP' 038  ls_msg '' '' ''."流程审批错误:&1
        ENDTRY.
      ENDIF.
  ENDCASE.

  IF flag = 'E' OR flag = ''.
    PERFORM frm_add_message USING 'E' 'ZAPP' 042  is_head-appno '' '' ''."流程&1审批失败
    PERFORM frm_add_message USING 'E' 'ZAPP' 000  ls_msg '' '' ''."
    ROLLBACK WORK.
  ELSEIF flag = 'S'.
    PERFORM frm_add_message USING 'S' 'ZAPP' 043  is_head-appno '' '' ''."流程&1审批成功
    COMMIT WORK AND WAIT.
  ENDIF.

ENDFORM.


FORM frm_hld_create USING p_key1.
  DATA lv_string TYPE zspp_poopt_n-zsqdh.

  lv_string = p_key1.

  CALL FUNCTION 'ZFPP_HLD_CREATE'
    EXPORTING
      i_zsqdh     = lv_string
      i_zzversion = '00'
*   IMPORTING
*     E_ZZBOM_NO  =
*     E_ZZVERSION =
    .
ENDFORM.


FORM frm_gjd_create USING p_key1.

  DATA lv_string TYPE zspp_poopt_n-zsqdh.

  lv_string = p_key1.


  CALL FUNCTION 'ZFPP_GJD_CREATE'
    EXPORTING
      i_zsqdh     = lv_string
      i_zzversion = '00'
*   IMPORTING
*     E_ZGJDH     =
*     E_ZZVERSION =
    .
ENDFORM.


FORM frm_send_next_msg USING us_head TYPE zapp_head u_item TYPE zapp_item.
  CHECK g_msg = 'X'.

  DATA:ls_text TYPE zmsg_text.
  DATA:ls_object_id TYPE zmsg_object_id.
  DATA:lt_user TYPE TABLE OF zmsg_suser WITH HEADER LINE.
  CLEAR lt_user[].

  ls_text = us_head-name1 && us_head-key1 && TEXT-025."'上级已审批,请查阅并完成审批'.
  ls_object_id = us_head-appno.
  lt_user-uname = u_item-person.
  lt_user-name1 = u_item-name.
  APPEND lt_user.
  CLEAR lt_user.

  PERFORM frm_send_msg TABLES lt_user USING ls_text ls_object_id 'ZAPP'.

ENDFORM.

FORM frm_send_first_msg USING us_head TYPE zapp_flow_head u_item TYPE zapp_flow_item.
  DATA:ls_text TYPE zmsg_text.
  DATA:ls_object_id TYPE zmsg_object_id.
  DATA:lt_user TYPE TABLE OF zmsg_suser WITH HEADER LINE.
  CLEAR lt_user[].

  ls_text = us_head-name1 && us_head-key1 && TEXT-025."'上级已审批,请查阅并完成审批'.
  ls_object_id = us_head-appno.
  lt_user-uname = u_item-person.
  lt_user-name1 = u_item-name.
  APPEND lt_user.
  CLEAR lt_user.

  PERFORM frm_send_msg TABLES lt_user USING ls_text ls_object_id 'ZAPP'.

ENDFORM.


FORM frm_send_complete_msg USING us_head TYPE zapp_head.
  DATA:ls_text TYPE zmsg_text.
  DATA:ls_object_id TYPE zmsg_object_id.
  DATA:lt_user TYPE TABLE OF zmsg_suser WITH HEADER LINE.

  CLEAR lt_user[].

  READ TABLE gt_item INTO DATA(ls_item) WITH KEY appno = us_head-appno line_id = 1.
  CHECK sy-subrc EQ 0.
  CHECK ls_item-flow_point = 'A0'.

  ls_text = us_head-process && us_head-key1 && TEXT-026."已审批完成
  ls_object_id = us_head-appno.
  lt_user-uname = ls_item-person.
  lt_user-name1 = ls_item-name.
  APPEND lt_user.
  CLEAR lt_user.

  PERFORM frm_send_msg TABLES lt_user USING ls_text ls_object_id 'ZAPP'.

ENDFORM.


FORM frm_send_msg TABLES lt_user STRUCTURE zmsg_suser USING u_text u_object_id object.

  DATA:ls_datah TYPE zmsg_data_h .
  ls_datah-object = object.
  ls_datah-object_id = u_object_id.
  ls_datah-text = u_text.

  CALL FUNCTION 'ZMSG_SAVE_DATA'
    EXPORTING
      is_datah = ls_datah
*     URGENT   =
*   IMPORTING
*     ES_RETURN =
    TABLES
      it_data  = lt_user
    EXCEPTIONS
      error    = 1
      OTHERS   = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ELSE.
    COMMIT WORK AND WAIT.
  ENDIF.

ENDFORM.


FORM frm_set_offer_msg USING zofno.
  DATA:lt_user TYPE TABLE OF zmsg_suser WITH HEADER LINE.
  DATA:l_object_id TYPE TABLE OF zmsg_object_id WITH HEADER LINE.
  DATA:ls_datah TYPE zmsg_data_h.
  CHECK zofno IS NOT INITIAL.

  SELECT SINGLE * INTO @DATA(ls_0050) FROM zmmt0050
    WHERE zofno = @zofno.
  CHECK sy-subrc EQ 0.

  CHECK ls_0050-zywy IS NOT INITIAL.

  SPLIT ls_0050-zywy AT '/' INTO TABLE lt_user[].

  LOOP AT lt_user.
    SELECT SINGLE name
      INTO lt_user-name1
      FROM zapp_addr
      WHERE person = lt_user-uname.
  ENDLOOP.

  l_object_id = zofno.

  ls_datah-object = 'OFFER'.
  ls_datah-object_id = l_object_id.
  ls_datah-text = TEXT-027."'报价单已完成,请查看报价信息'.

  CALL FUNCTION 'ZMSG_SAVE_DATA'
    EXPORTING
      is_datah = ls_datah
*     URGENT   =
*   IMPORTING
*     ES_RETURN =
    TABLES
      it_data  = lt_user[]
*   EXCEPTIONS
*     ERROR    = 1
*     OTHERS   = 2
    .
ENDFORM.


FORM frm_send_afo_msg USING is_head STRUCTURE zapp_head.
  DATA:ls_text TYPE zmsg_text.
  DATA:ls_object_id TYPE zmsg_object_id.
  DATA:lt_user TYPE TABLE OF zmsg_suser WITH HEADER LINE.

  CASE is_head-object.
    WHEN 'EBAN'.
      ls_text = TEXT-028 &&  is_head-key1 && TEXT-029.
*      ls_text = '采购申请' &&  is_head-key1 && '已审批通过,请处理'.
    WHEN 'REC'.
      ls_text = TEXT-030 &&  is_head-key1 && TEXT-031.
*      ls_text = '库存申请单' &&  is_head-key1 && '已审批通过,请处理'.
    WHEN OTHERS.
      RETURN.
  ENDCASE.

  SELECT SINGLE * INTO @DATA(ls_afo_head) FROM zafo_head
    WHERE afono = @is_head-key1.

  CHECK sy-subrc EQ 0.

  CHECK ls_afo_head-nenam IS NOT INITIAL.


  ls_object_id = ls_afo_head-afono.
  lt_user-uname = ls_afo_head-nenam.

  SELECT SINGLE name INTO lt_user-name1 FROM zapp_addr WHERE person = lt_user-uname.

  APPEND lt_user.
  CLEAR lt_user.

  PERFORM frm_send_msg TABLES lt_user USING ls_text ls_object_id 'ZAFO'.

ENDFORM.
