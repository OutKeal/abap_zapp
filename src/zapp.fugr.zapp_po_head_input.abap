FUNCTION ZAPP_PO_HEAD_INPUT.
*"----------------------------------------------------------------------
*"*"本地接口：
*"  IMPORTING
*"     REFERENCE(PURCHASE_ORDER_MM) TYPE REF TO  IF_PURCHASE_ORDER_MM
*"----------------------------------------------------------------------

  gs_po_head = purchase_order_mm.

  gs_mepoheader = gs_po_head->get_data( ).



ENDFUNCTION.
