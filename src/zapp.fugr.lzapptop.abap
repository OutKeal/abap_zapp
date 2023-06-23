FUNCTION-POOL zapp MESSAGE-ID zapp.                         "MESSAGE-ID ..

* INCLUDE LZAPPD...                          " LOCAL CLASS DEFINITION

DATA:gv_object TYPE zapp_eobject.

TABLES : zmms0050.


DATA:gv_key1 TYPE zapp_key1.
DATA:gv_key2 TYPE zapp_key2.
DATA:gv_key3 TYPE zapp_key3.
DATA:gv_key4 TYPE zapp_key4.
DATA:gv_key5 TYPE zapp_key5.
DATA:gv_key6 TYPE zapp_key6.
DATA:gv_user1 TYPE xubname.
DATA:gv_user2 TYPE xubname.
DATA:gv_user3 TYPE xubname.

DATA:gt_object TYPE TABLE OF zapp_object WITH HEADER LINE.
DATA:gt_object_key TYPE TABLE OF zapp_object_key WITH HEADER LINE.
DATA:gt_process TYPE TABLE OF zapp_process WITH HEADER LINE.
DATA:gt_process_con TYPE TABLE OF zapp_process_con WITH HEADER LINE.
DATA:gt_process_flo TYPE TABLE OF zapp_process_flo WITH HEADER LINE.


DATA:gt_flow_head TYPE TABLE OF zapp_flow_head WITH HEADER LINE.
DATA:gt_flow_item TYPE TABLE OF zapp_flow_item WITH HEADER LINE.

DATA:gt_flow_head_modify TYPE TABLE OF zapp_flow_head WITH HEADER LINE.
DATA:gt_flow_item_modify TYPE TABLE OF zapp_flow_item WITH HEADER LINE.


DATA:gs_head TYPE zapp_head.
DATA:gt_head TYPE TABLE OF zapp_head WITH HEADER LINE.
DATA:gt_item TYPE TABLE OF zapp_item WITH HEADER LINE.
DATA:gt_item_dis TYPE TABLE OF zapp_item WITH HEADER LINE.

FIELD-SYMBOLS: <gs_head> TYPE  zapp_head.
FIELD-SYMBOLS: <gs_item> TYPE  zapp_item.
FIELD-SYMBOLS: <gs_item_dis> TYPE  zapp_item.

DATA:gs_item TYPE zapp_item."APP界面


DATA:gv_appno TYPE zappno.

DATA: ot_return TYPE TABLE OF bapiret2  WITH HEADER LINE.
DATA:gv_error TYPE char1.

DATA:gv_uname TYPE zapp_person.

DATA gt_message TYPE TABLE OF esp1_message_wa_type WITH HEADER LINE.

TABLES:ci_ekkodb.
DATA:gs_mepoheader TYPE  mepoheader.
DATA:gs_po_head TYPE REF TO if_purchase_order_mm.
DATA:gs_pr_head TYPE REF TO if_purchase_requisition.

DATA: g_req     TYPE REF TO if_purchase_requisition.

DATA:gt_app_addr TYPE TABLE OF zapp_addr WITH HEADER LINE .

DATA:g_department TYPE  ad_dprtmnt  .

DATA:gs_msg TYPE char50.

DATA:g_msg TYPE char1.

DATA:g_flag TYPE char1.

DATA:g_mydetail TYPE char1.
