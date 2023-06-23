*&---------------------------------------------------------------------*
*& 包含               ZAPP_FLOW_GRAPHICS
*&---------------------------------------------------------------------*

INCLUDE lcnetdat.                      "allg. Datendeklarationen
INCLUDE lcnetcon.                      "Konstanten
FORM frm_display_graphics USING appno.
  profile-gruppe = 'DEMO'.
  profile-name   = '000000000001'.
  profile-index  = '1'.

  DATA:lt_item TYPE TABLE OF zapp_item WITH HEADER LINE.

  LOOP AT gt_item INTO lt_item WHERE appno = appno.
    APPEND lt_item.
    CLEAR lt_item.
  ENDLOOP.

  DATA:lv_tabix_l TYPE sy-tabix.
  DATA:lv_tabix TYPE sy-tabix.
  LOOP AT lt_item.
    lv_tabix = sy-tabix.

    PERFORM make_nodes TABLES net_nodes_tab
                      nvals_tab
                      USING lv_tabix
                            lt_item-flow_point_name1
                            lt_item-person
                            lt_item-text.
    IF lv_tabix <> 1.
      lv_tabix_l = lv_tabix - 1.
      PERFORM make_lines TABLES lines_tab lvals_tab
                                USING lv_tabix lv_tabix_l lv_tabix.
    ENDIF.




  ENDLOOP.

  DO.
* Aufrufen der Netzplangrafik
    CALL FUNCTION 'CNET_GRAPHIC_NETWORK'
      EXPORTING
        profile   = profile
        stat      = stat
      IMPORTING
        m_typ     = m_typ
      TABLES
        clusters  = clusters_tab
        cvals     = cvals_tab
        deletions = delete_tab
        inodes    = inodes_tab
        lines     = lines_tab
        lvals     = lvals_tab
        nodes     = net_nodes_tab
        nvals     = nvals_tab
        positions = positions_tab.

    CASE m_typ.
      WHEN net_const-m_typ_d.
        EXIT.
      WHEN net_const-m_typ_i.
        stat = net_const-stat_4.
    ENDCASE.
  ENDDO.
ENDFORM.


FORM make_nodes TABLES
                       nodes STRUCTURE cng_nodes
                       nvals STRUCTURE net_nvals
                       USING id
                             point_name
                             person
                             text.

  nodes-id   = id.
  nodes-type   = net_const-type_4.
  APPEND nodes.
  nvals-id   = id.
  nvals-fl   = 0.
  nvals-val  = point_name.                                    "Node 1
  APPEND nvals.

  nvals-id   = id.
  nvals-fl   = 1.
  nvals-val  = person.                                    "Node 1
  APPEND nvals.

  nvals-id   = id.
  nvals-fl   = 2.
  nvals-val  = text.                                    "Node 1
  APPEND nvals.


ENDFORM.

FORM make_lines TABLES lines STRUCTURE cng_lines
                       lvals STRUCTURE net_lvals
                       USING id pre suc .

  lines-id   = id.
  lines-pre  = pre.
  lines-suc  = suc.
  lines-type  = '1'.
  lines-ab   = net_const-aob_aa.       "Normalbeziehung
  APPEND lines.
  lvals-id   = lines-id.
  lvals-fl   = net_const-text_index_0.
  lvals-val  = TEXT-013."'审批'.
  APPEND lvals.

  lvals-fl   = net_const-mark_at_end.
  lvals-val  = '40'.
  APPEND lvals.


ENDFORM.
