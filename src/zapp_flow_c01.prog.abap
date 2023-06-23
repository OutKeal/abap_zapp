*&---------------------------------------------------------------------*
*& 包含               ZAPP_FLOW_C01
*&---------------------------------------------------------------------*

FORM frm_free_global.

  CLEAR : gv_object .

  CLEAR:gv_key1 .
  CLEAR:gv_key2 .
  CLEAR:gv_key3 .
  CLEAR:gv_key4 .
  CLEAR:gv_key5 .
  CLEAR:gv_key6 .

  CLEAR:gt_object      .
  CLEAR:gt_object[]      .
  CLEAR:gt_object_key[]  .
  CLEAR:gt_object_key  .
  CLEAR:gt_process     .
  CLEAR:gt_process[]     .
  CLEAR:gt_process_con .
  CLEAR:gt_process_con[] .
  CLEAR:gt_process_flo .
  CLEAR:gt_process_flo[] .
  CLEAR:gt_flow_head .
  CLEAR:gt_flow_head[] .
  CLEAR:gt_flow_item .
  CLEAR:gt_flow_item[] .

  CLEAR:gt_head .
  CLEAR:gt_head[] .
  CLEAR:gt_item .
  CLEAR:gt_item[] .

  CLEAR:ot_return .
  CLEAR:ot_return[] .

  CLEAR gv_error.

  CLEAR gv_uname.
  CLEAR gv_user1 .
  CLEAR gv_user2 .
  CLEAR gv_user3 .




ENDFORM.
FORM frm_init_config.

  IF gv_object IS INITIAL.
    SELECT *
      INTO TABLE gt_object FROM zapp_object
      FOR ALL ENTRIES IN gt_head
      WHERE object = gt_head-object.
    IF sy-subrc NE 0.
      PERFORM frm_add_message USING 'E' 'ZAPP' 005 '' '' '' ''."审批流对象不存在
      RETURN.
    ENDIF.

  ELSE.

    SELECT * FROM zapp_object
      INTO TABLE gt_object
      WHERE object = gv_object.
    IF sy-subrc NE 0.
      PERFORM frm_add_message USING 'E' 'ZAPP' 005 '' '' '' ''."审批流对象不存在
      RETURN.
    ENDIF.

  ENDIF.

  SELECT *
    INTO TABLE gt_object_key
    FROM zapp_object_key
    FOR ALL ENTRIES IN gt_object
    WHERE object = gt_object-object.
  IF sy-subrc NE 0.
    PERFORM frm_add_message USING 'E' 'ZAPP' 006 '' '' '' ''."审批流对象KEY不存在
    RETURN.
  ENDIF.

  SELECT *
    INTO TABLE gt_process
    FROM zapp_process
    FOR ALL ENTRIES IN gt_object
    WHERE object = gt_object-object.
  IF sy-subrc NE 0.
    PERFORM frm_add_message USING 'E' 'ZAPP' 005 '' '' '' ''."审批流流程对象不存在
    RETURN.
  ENDIF.

  SELECT * FROM zapp_process_con
  INTO TABLE gt_process_con
   FOR ALL ENTRIES IN gt_process
  WHERE process = gt_process-process.
  IF sy-subrc NE 0.
    PERFORM frm_add_message USING 'E' 'ZAPP' 007 '' '' '' ''."审批流流程确定条件不存在
    RETURN.
  ENDIF.

  SELECT * FROM zapp_process_flo
    INTO TABLE gt_process_flo
     FOR ALL ENTRIES IN gt_process
    WHERE process = gt_process-process.
  IF sy-subrc NE 0.
    PERFORM frm_add_message USING 'E' 'ZAPP' 008 '' '' '' ''."审批流流程节点条件不存在
    RETURN.
  ENDIF.
ENDFORM.

FORM frm_add_message USING type id number msg1 msg2 msg3 msg4.
  CLEAR ot_return.
  IF type = 'E'.
    gv_error = 'X'.
  ENDIF.
  ot_return-type = type.
  ot_return-id = id.
  ot_return-number = number.
  ot_return-message_v1 = msg1.
  ot_return-message_v2 = msg2.
  ot_return-message_v3 = msg3.
  ot_return-message_v4 = msg4.
  MESSAGE ID ot_return-id TYPE ot_return-type NUMBER ot_return-number
     INTO ot_return-message WITH ot_return-message_v1
                                 ot_return-message_v2
                                 ot_return-message_v3
                                 ot_return-message_v4.
  APPEND ot_return.

ENDFORM.
FORM frm_get_appno CHANGING appno.


  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr             = '01'
      object                  = 'ZAPPNO'
    IMPORTING
      number                  = appno
    EXCEPTIONS
      interval_not_found      = 1
      number_range_not_intern = 2
      object_not_found        = 3
      quantity_is_0           = 4
      quantity_is_not_1       = 5
      interval_overflow       = 6
      buffer_overflow         = 7
      OTHERS                  = 8.
  IF sy-subrc <> 0.
    PERFORM frm_add_message USING 'E' 'ZAPP' 009 '' '' '' ''."流程编号获取错误
  ENDIF.

ENDFORM.


FORM frm_set_key USING line.

  FIELD-SYMBOLS: <fs_value1> TYPE any.
  FIELD-SYMBOLS: <fs_value2> TYPE any.
  DATA:ls_fname1 TYPE char30.
  DATA:ls_fname2 TYPE char30.
  DATA:ls_head TYPE zapp_flow_head.


  LOOP AT gt_object_key.
    IF <fs_value1> IS ASSIGNED.
      UNASSIGN <fs_value1>.
    ENDIF.

    IF <fs_value2> IS ASSIGNED.
      UNASSIGN <fs_value2>.
    ENDIF.

    ls_fname1 = 'GV_' &&  gt_object_key-key_type.
    ASSIGN (ls_fname1) TO <fs_value1>.
    CHECK <fs_value1> IS ASSIGNED.

    ASSIGN COMPONENT gt_object_key-key_assign OF STRUCTURE line TO <fs_value2>.
    CHECK <fs_value2> IS ASSIGNED.

    <fs_value1> = <fs_value2>.
    CONDENSE <fs_value1> NO-GAPS.
  ENDLOOP.

  IF gv_key1 IS INITIAL.

    PERFORM frm_add_message USING 'E' 'ZAPP' 010 '' '' '' ''."审批KEY1不能为空，请检查配置

  ELSE.
    CASE gv_object.
      WHEN 'DYGJD' OR 'DYHLD'.
        SELECT SINGLE * INTO @ls_head FROM zapp_flow_head
          WHERE object = @gv_object AND key1 = @gv_key1 AND key2 = @gv_key2 AND status NOT IN ( 'D' , 'R' ).
      WHEN OTHERS.
        SELECT SINGLE * INTO @ls_head FROM zapp_flow_head
          WHERE object = @gv_object AND key1 = @gv_key1 AND status NOT IN ( 'D' , 'R' ,'C' ).
    ENDCASE.
    IF sy-subrc EQ 0.
      PERFORM frm_add_message USING 'E' 'ZAPP' 011 '' '' '' ''."审批对象与KEY已存在,请联系管理员
    ENDIF.
  ENDIF.

ENDFORM.


FORM frm_set_head_process USING line.

  FIELD-SYMBOLS: <fs_value1> TYPE any.
  FIELD-SYMBOLS: <fs_value2> TYPE any.
  DATA:ls_fname1 TYPE char30.
  DATA:ls_fname2 TYPE char30.
  DATA:l_ture TYPE char1.

  gt_flow_head-appno = gv_appno.
  gt_flow_head-key1 = gv_key1.
  gt_flow_head-key2 = gv_key2.
  gt_flow_head-key3 = gv_key3.
  gt_flow_head-key4 = gv_key4.
  gt_flow_head-key5 = gv_key5.
  gt_flow_head-key6 = gv_key6.
  gt_flow_head-status = 'B'.
  gt_flow_head-erdat = sy-datum.
  gt_flow_head-erzet = sy-uzeit.
  gt_flow_head-ernam = sy-uname.
  gt_flow_head-modat = sy-datum.
  gt_flow_head-mozet = sy-uzeit.
  gt_flow_head-monam = sy-uname.

  SORT gt_process BY priority.

  LOOP AT gt_process.
    CLEAR l_ture.

    LOOP AT gt_process_con WHERE process = gt_process-process.

      IF <fs_value1> IS ASSIGNED.
        UNASSIGN <fs_value1>.
      ENDIF.

      IF <fs_value2> IS ASSIGNED.
        UNASSIGN <fs_value2>.
      ENDIF.

      IF  gt_process_con-key_type IS NOT INITIAL.
        ls_fname1 = 'GV_' &&  gt_process_con-key_type.
        ASSIGN (ls_fname1) TO <fs_value1>.
      ELSEIF gt_process_con-key_assign IS NOT INITIAL.

        ASSIGN COMPONENT gt_process_con-key_assign OF STRUCTURE line TO <fs_value1>.

        IF <fs_value1> IS NOT ASSIGNED.
          CASE gt_process_con-key_assign.
            WHEN 'GVBM'.
              SELECT SINGLE department INTO @DATA(lv_department)
                FROM zapp_addr
                WHERE person = @gv_uname.
              IF sy-subrc EQ 0.
                ASSIGN ('lv_department') TO <fs_value1>.
              ENDIF.

          ENDCASE.
        ENDIF.

      ENDIF.

      IF <fs_value1> IS NOT ASSIGNED."配置错误
        EXIT.
      ENDIF.

      PERFORM frm_compare_value USING gt_process_con <fs_value1> CHANGING l_ture.
      IF l_ture <> 'X'.
        EXIT.
      ENDIF.

    ENDLOOP.

    IF sy-subrc EQ 0 AND l_ture = 'X'.
      gt_flow_head-process = gt_process-process.
      gt_flow_head-object = gt_process-object.
      gt_flow_head-name1 = gt_process-name1.
      EXIT.
    ENDIF.

  ENDLOOP.

  PERFORM exit_set_flow_head CHANGING gt_flow_head.

  IF gt_flow_head-process IS INITIAL.
    PERFORM frm_add_message USING 'E' 'ZAPP' 012 '' '' '' ''."审批流程确认失败,请检查PROCESS配置
    EXIT.
  ENDIF.

ENDFORM.


FORM frm_compare_value USING is_con STRUCTURE zapp_process_con i_value CHANGING c_ture.

  CLEAR c_ture.

  CASE is_con-symbol.
    WHEN '='.
      IF i_value = is_con-value.
        c_ture = 'X'.
      ENDIF.
    WHEN '>='.
      IF i_value >= is_con-value.
        c_ture = 'X'.
      ENDIF.
    WHEN '<='.
      IF i_value <= is_con-value.
        c_ture = 'X'.
      ENDIF.
    WHEN '<>'.
      IF i_value <> is_con-value.
        c_ture = 'X'.
      ENDIF.
    WHEN '>'.
      IF i_value > is_con-value.
        c_ture = 'X'.
      ENDIF.
    WHEN '<'.
      IF i_value < is_con-value.
        c_ture = 'X'.
      ENDIF.
    WHEN 'CP'.
      IF i_value CP is_con-value.
        c_ture = 'X'.
      ENDIF.
    WHEN 'CS'.
      FIND i_value IN is_con-value.
      IF sy-subrc EQ 0.
        c_ture = 'X'.
      ENDIF.

  ENDCASE.

ENDFORM.


FORM frm_set_item .

  DATA:lt_item TYPE TABLE OF zapp_flow_item WITH HEADER LINE.

  DATA:ls_item TYPE zapp_flow_item.
  CLEAR gt_flow_item[].
  CLEAR gt_flow_item.

  LOOP AT gt_process_flo WHERE process = gt_flow_head-process.
    MOVE-CORRESPONDING gt_process_flo TO gt_flow_item.
    gt_flow_item-appno = gv_appno.
    gt_flow_item-zresult = 'A'.
    APPEND gt_flow_item.
    CLEAR gt_flow_item.
  ENDLOOP.

  SORT gt_flow_item.
  READ TABLE gt_flow_item INDEX 1.
  IF sy-subrc EQ 0.
    gt_flow_head-flow_point = gt_flow_item-flow_point.
    gt_flow_head-flow_point_name1 = gt_flow_item-flow_point_name1.
  ENDIF.
  IF sy-subrc NE 0.
    PERFORM frm_add_message USING 'E' 'ZAPP' 013 '' '' '' ''."审批流程节点不存在,请检查PROCESS_FLOW配置
    RETURN.
  ENDIF.


  PERFORM frm_init_commit_item CHANGING ls_item.

  IF gv_error = 'X'.
    RETURN.
  ENDIF.

  INSERT ls_item INTO gt_flow_item INDEX 1.

  LOOP AT gt_flow_item.

    PERFORM frm_get_app_addr CHANGING gt_flow_item-person
                                      gt_flow_item-name
                                      gt_flow_item-department
                                      gt_flow_item-zposition.
    MODIFY gt_flow_item.

  ENDLOOP.

  PERFORM exit_set_flow_item TABLES gt_flow_item[] USING gt_flow_head  .


  CLEAR lt_item[].
  LOOP AT gt_flow_item.

    CHECK gt_flow_item-line_id <> 1.

    IF gt_flow_item-person IS INITIAL.
      gs_msg =  '审批流程' && gt_flow_head-appno && '流程节点' && gt_flow_item-flow_point
        && gt_flow_item-flow_point_name1 && '无法确定人员,请联系管理员'.
      PERFORM frm_add_message USING 'E' 'ZAPP' 014 gt_flow_head-name1 gt_flow_item-flow_point_name1  '' ''.
      RETURN.
    ENDIF.

    READ TABLE lt_item WITH KEY person = gt_flow_item-person.
    IF sy-subrc EQ 0.
      DELETE gt_flow_item.
      CONTINUE.
    ELSE.
      APPEND gt_flow_item TO lt_item.
    ENDIF.

  ENDLOOP.

ENDFORM.


FORM frm_get_app_addr CHANGING person name department zposition.

  CLEAR gt_app_addr.

  IF person = 'USER1'.
    person = gv_user1.
  ENDIF.

  IF person = 'USER2'.
    person = gv_user2.
  ENDIF.

  IF person = 'USER3'.
    person = gv_user3.
  ENDIF.

  IF person IS NOT INITIAL.
    READ TABLE gt_app_addr WITH KEY person = person.
    IF sy-subrc NE 0.
      SELECT SINGLE * INTO gt_app_addr
        FROM zapp_addr
        WHERE person = person.
      IF sy-subrc EQ 0.
        APPEND gt_app_addr.
      ENDIF.
    ENDIF.

    IF gt_app_addr IS NOT INITIAL.
      person = gt_app_addr-person.
      name = gt_app_addr-name.
      department = gt_app_addr-department.
      g_department = gt_app_addr-department.
      zposition = gt_app_addr-zposition.
    ENDIF.

    RETURN.
  ENDIF.


  IF department IS INITIAL. "若部门为空，则获取上一级部门
    department = g_department.
  ENDIF.


  IF zposition = 'MANAGER'.
    SELECT SINGLE manager INTO @DATA(ls_manager)
      FROM zapp_manager
      WHERE department = @department.
    IF sy-subrc EQ 0.
      SELECT SINGLE * INTO gt_app_addr
        FROM zapp_addr
        WHERE person = ls_manager.
      IF sy-subrc EQ 0.
        person = gt_app_addr-person.
        name = gt_app_addr-name.
        department = gt_app_addr-department.
        g_department = gt_app_addr-department.
        zposition = gt_app_addr-zposition.
      ENDIF.
    ENDIF.

    RETURN.
  ENDIF.

  IF zposition = 'MANAGER1'.
    SELECT SINGLE manager1 INTO @DATA(ls_manager1)
      FROM zapp_manager
      WHERE department = @department.
    IF sy-subrc EQ 0.
      SELECT SINGLE * INTO gt_app_addr
        FROM zapp_addr
        WHERE person = ls_manager1.
      IF sy-subrc EQ 0.
        person = gt_app_addr-person.
        name = gt_app_addr-name.
        department = gt_app_addr-department.
        g_department = gt_app_addr-department.
        zposition = gt_app_addr-zposition.
      ENDIF.
    ENDIF.

    RETURN.

  ENDIF.


  IF department IS NOT INITIAL AND zposition IS NOT INITIAL.
    READ TABLE gt_app_addr WITH KEY department = department
                                    zposition = zposition.
    IF sy-subrc NE 0.
      SELECT SINGLE * INTO gt_app_addr
        FROM zapp_addr
        WHERE department = department
        AND zposition = zposition.
      IF sy-subrc EQ 0.
        APPEND gt_app_addr.
      ENDIF.
    ENDIF.

    IF gt_app_addr IS NOT INITIAL.
      person = gt_app_addr-person.
      name = gt_app_addr-name.
      department = gt_app_addr-department.
      g_department = gt_app_addr-department.
      zposition = gt_app_addr-zposition.
    ENDIF.

    RETURN.

  ENDIF.

*  IF department IS INITIAL AND zposition IS NOT INITIAL.
*
*    READ TABLE gt_app_addr WITH KEY department = g_department zposition = zposition.
*    IF sy-subrc NE 0.
*      SELECT SINGLE * INTO gt_app_addr
*        FROM zapp_addr
*        WHERE department = g_department
*        AND zposition = zposition.
*      IF sy-subrc EQ 0.
*        APPEND gt_app_addr.
*      ENDIF.
*    ENDIF.
*
*    IF gt_app_addr IS NOT INITIAL.
*      person = gt_app_addr-person.
*      name = gt_app_addr-name.
*      department = gt_app_addr-department.
*      g_department = gt_app_addr-department.
*      zposition = gt_app_addr-zposition.
*    ENDIF.
*    RETURN.
*  ENDIF.
ENDFORM.


FORM frm_init_commit_item CHANGING cs_item STRUCTURE zapp_flow_item.

  CLEAR cs_item.

  cs_item-appno = gv_appno.
  cs_item-line_id = '000001'.
  cs_item-flow_point = 'A0'.
  cs_item-flow_point_name1 = TEXT-015."'发起'.
  cs_item-person = gv_uname.
  cs_item-zresult  = 'C'.
  cs_item-opinion  = TEXT-012."'已提交审批'."
  cs_item-appdate  = sy-datum.
  cs_item-apptime  = sy-uzeit.


  PERFORM frm_get_app_addr CHANGING sy-uname
                                    cs_item-name
                                    cs_item-department
                                    cs_item-zposition.

*  PERFORM FRM_GET_ORGEH USING CS_ITEM-PERSON
*          CHANGING CS_ITEM-PERNR
*            CS_ITEM-SNAME
*            CS_ITEM-ORGEH
*            CS_ITEM-DEPARTMENT
*            CS_ITEM-PLANS
*            CS_ITEM-ZPOSITION .
*

ENDFORM.


FORM frm_get_orgeh USING uname CHANGING pernr sname orgeh stext1 plans stext2.

  SELECT SINGLE pernr INTO @pernr
    FROM pa0105
    WHERE subty = '0001'
    AND usrid = @uname
    AND begda <= @sy-datum
    AND endda >= @sy-datum.

  IF sy-subrc NE 0.
    PERFORM frm_add_message USING 'E' 'ZAPP' 015 '' '' '' ''."获取HR编号失败
    RETURN.
  ENDIF.

  SELECT SINGLE sname ,orgeh , plans INTO ( @sname , @orgeh , @plans )
    FROM pa0001
    WHERE pernr = @pernr
    AND begda <= @sy-datum
    AND endda >= @sy-datum.
  IF sy-subrc NE 0.
    PERFORM frm_add_message USING 'E' 'ZAPP' 016 '' '' '' ''."获取HR编号部门失败
    RETURN.
  ENDIF.

  SELECT SINGLE stext INTO @stext1
    FROM hrp1000
    WHERE plvar = '01'
    AND otype = 'O'
    AND objid = @orgeh
    AND begda <= @sy-datum
    AND endda >= @sy-datum.
  IF sy-subrc NE 0.
    PERFORM frm_add_message USING 'E' 'ZAPP' 017 '' '' '' ''."获取HR部门名称失败
    RETURN.
  ENDIF.


  SELECT SINGLE stext INTO @stext2
    FROM hrp1000
    WHERE plvar = '01'
    AND otype = 'S'
    AND objid = @plans
    AND begda <= @sy-datum
    AND endda >= @sy-datum.
  IF sy-subrc NE 0.
    PERFORM frm_add_message USING 'E' 'ZAPP' 018 '' '' '' ''."获取HR岗位名称失败
    RETURN.
  ENDIF.


ENDFORM.

FORM frm_get_manager USING orgeh CHANGING uname.

  SELECT SINGLE sobid INTO @DATA(ls_sobid)
    FROM hrp1001
    WHERE plvar = '01'
    AND otype = 'O'
    AND rsign = 'B'
    AND relat = '012'
    AND objid = @orgeh
    AND begda <= @sy-datum
    AND endda >= @sy-datum.
  IF sy-subrc NE 0.
    PERFORM frm_add_message USING 'E' 'ZAPP' 019 '' '' '' ''."获取部门的岗位ID失败
    RETURN.
  ENDIF.


  SELECT SINGLE sobid INTO @DATA(ls_sobid1)
    FROM hrp1001
    WHERE plvar = '01'
    AND otype = 'S'
    AND rsign = 'A'
    AND relat = '008'
    AND objid = @ls_sobid
    AND begda <= @sy-datum
    AND endda >= @sy-datum.
  IF sy-subrc NE 0.
    PERFORM frm_add_message USING 'E' 'ZAPP' 020 '' '' '' ''."获取部门岗位的用户ID失败
    RETURN.
  ENDIF.


  SELECT SINGLE usrid INTO @uname
    FROM pa0105
    WHERE subty = '0001'
    AND pernr = @ls_sobid1
    AND begda <= @sy-datum
    AND endda >= @sy-datum.
  IF sy-subrc NE 0.
    PERFORM frm_add_message USING 'E' 'ZAPP' 021 '' '' '' ''."获取部门岗位的用户的SAP账号失败
    RETURN.
  ENDIF.



ENDFORM.

FORM frm_pop_msg TABLES ct_return STRUCTURE bapiret2.
  LOOP AT ct_return.
    PERFORM frm_add_msg USING ct_return-id
                              ct_return-type
                              ct_return-number
                              ct_return-message_v1
                              ct_return-message_v2
                              ct_return-message_v3
                              ct_return-message_v4.
  ENDLOOP.
  IF sy-subrc EQ 0.
    CLEAR ct_return[].
  ENDIF.

  DATA(lv_line) = lines( gt_message ) .

  IF lv_line > 1.
    CALL FUNCTION 'C14Z_MESSAGES_SHOW_AS_POPUP'
      TABLES
        i_message_tab = gt_message[].
    CLEAR gt_message[].
  ELSE.
    READ TABLE gt_message INDEX 1.
    MESSAGE ID gt_message-msgid TYPE 'S'  NUMBER gt_message-msgno
            WITH gt_message-msgv1 gt_message-msgv2 gt_message-msgv3 gt_message-msgv4
            DISPLAY LIKE gt_message-msgty .
    CLEAR gt_message[].
    CLEAR gt_message.
  ENDIF.

ENDFORM.

*&---------------------------------
*&frm_get_next_appno
*&add by at-yuxs 20211226
*&获取上一个或下一个审批流
*&---------------------------------
FORM frm_get_next_app_flow USING pv_appno CHANGING ps_head.
  DATA: lt_head TYPE TABLE OF zapp_head.
  SELECT DISTINCT h~*  FROM zapp_flow_head AS h
          INNER JOIN zapp_flow_item AS i
          ON h~appno = i~appno AND h~flow_point = i~flow_point
          INTO CORRESPONDING FIELDS OF TABLE @lt_head
          WHERE person = @sy-uname
          AND status = 'B'
          AND zresult = 'A'.
  IF sy-subrc NE 0.
    RETURN.
  ENDIF.
  SORT lt_head BY erdat DESCENDING erzet DESCENDING.
  DATA(lv_len) = lines( lt_head ).
  DATA lv_idx TYPE i.
  READ TABLE lt_head TRANSPORTING  NO FIELDS WITH KEY appno = pv_appno.
  IF sy-subrc = 0 AND sy-tabix NE lv_len.
    lv_idx = sy-tabix + 1.
    READ TABLE lt_head INTO ps_head INDEX lv_idx.
  ENDIF.
ENDFORM.



*&---------------------------------
*&frm_get_app_flow
*&add by at-yuxs 20211226
*&获取上一个或下一个审批流
*&---------------------------------
FORM frm_get_app_flow USING pv_appno
                            pv_type
                            ps_head.
  DATA: lt_head TYPE TABLE OF zapp_head.
  DATA: ls_head TYPE  zapp_head.

*跳转到当前指定的审批
  IF pv_type = 'C' AND ps_head IS NOT INITIAL.
    CALL FUNCTION 'ZAPP_FLOW_JUMP'
      EXPORTING
        is_head = ps_head.
*    LEAVE PROGRAM.
  ENDIF.

  SELECT DISTINCT h~*  FROM zapp_flow_head AS h
          INNER JOIN zapp_flow_item AS i
          ON h~appno = i~appno AND h~flow_point = i~flow_point
          INTO CORRESPONDING FIELDS OF TABLE @lt_head
          WHERE person = @sy-uname
          AND status = 'B'
          AND zresult = 'A'.
  IF sy-subrc NE 0.
    MESSAGE i046(zapp).
    RETURN.
  ENDIF.
  SORT lt_head BY erdat DESCENDING erzet DESCENDING.
  DATA(lv_len) = lines( lt_head ).
  DATA lv_idx TYPE i.
  READ TABLE lt_head TRANSPORTING  NO FIELDS WITH KEY appno = pv_appno.
  IF sy-subrc = 0.
    CASE pv_type.
      WHEN 'P'."上一个
        IF sy-tabix = 1.
          MESSAGE i044(zapp).
          RETURN.
        ENDIF.
        lv_idx = sy-tabix - 1.

      WHEN 'N'."下一个
        IF sy-tabix = lv_len.
          MESSAGE i045(zapp).
          RETURN.
        ENDIF.
        lv_idx = sy-tabix + 1.
    ENDCASE.
  ELSE."当前审批已完成，自动跳转到下一个审批
    IF lv_len IS NOT INITIAL AND pv_type = 'N'.
      lv_idx = 1.
    ENDIF.
  ENDIF.
  IF lv_idx IS NOT INITIAL.
    READ TABLE lt_head INTO ls_head INDEX lv_idx.
    CALL FUNCTION 'ZAPP_FLOW_JUMP'
      EXPORTING
        is_head = ls_head.
*    LEAVE PROGRAM.
  ENDIF.
ENDFORM.
