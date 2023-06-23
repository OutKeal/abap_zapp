FUNCTION zapp_pr_head_input.
*"----------------------------------------------------------------------
*"*"本地接口：
*"  IMPORTING
*"     REFERENCE(PURCHASE_REQUISITION) TYPE REF TO
*"        IF_PURCHASE_REQUISITION
*"----------------------------------------------------------------------

  gs_pr_head = purchase_requisition.

ENDFUNCTION.
