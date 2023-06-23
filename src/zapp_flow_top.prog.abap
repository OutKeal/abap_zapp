*&---------------------------------------------------------------------*
*& 包含               ZAPP_FLOW_TOP
*&---------------------------------------------------------------------*


DATA:gt_object TYPE TABLE OF zapp_object WITH HEADER LINE.
DATA:gt_object_key TYPE TABLE OF zapp_object_key WITH HEADER LINE.
DATA:gt_process TYPE TABLE OF zapp_process WITH HEADER LINE.
DATA:gt_process_con TYPE TABLE OF zapp_process_con WITH HEADER LINE.
DATA:gt_process_flo TYPE TABLE OF zapp_process_flo WITH HEADER LINE.


DATA:gt_head TYPE TABLE OF zapp_flow_head WITH HEADER LINE.
DATA:gt_item TYPE TABLE OF zapp_flow_item WITH HEADER LINE.
DATA:gt_item_dis TYPE TABLE OF zapp_flow_item WITH HEADER LINE.


FIELD-SYMBOLS: <gs_head> TYPE  zapp_flow_head.
FIELD-SYMBOLS: <gs_item> TYPE  zapp_flow_item.

DATA:ot_return TYPE TABLE OF bapiret2 WITH HEADER LINE.

TABLES:zapp_flow_head.
TABLES:zapp_flow_item.
TABLES:suid_st_bname.

DATA gt_message TYPE TABLE OF esp1_message_wa_type WITH HEADER LINE.
