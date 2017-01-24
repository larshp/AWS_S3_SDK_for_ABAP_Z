*&---------------------------------------------------------------------*
*& Report  ZLNKERS3_LOG_VIEWER
*&
*&---------------------------------------------------------------------*
*& Company: RocketSteam
*& Author: Jordi Escoda, 14th April 2014
*& Log viewer
*&---------------------------------------------------------------------*
REPORT  zlnkers3_log_viewer.

*--------------------------------------------------------------------*
* Types.
*--------------------------------------------------------------------*
TYPE-POOLS: icon.

*--------------------------------------------------------------------*
* Global data
*--------------------------------------------------------------------*
DATA: g_date TYPE datum.
DATA: g_time TYPE uzeit.
DATA: g_log_event TYPE zlnkelog-log_event.

*--------------------------------------------------------------------*
* Selection screen
*--------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
SELECT-OPTIONS: so_date FOR g_date NO-EXTENSION.
SELECT-OPTIONS: so_time FOR g_time NO-EXTENSION.
SELECT-OPTIONS: so_evnt FOR g_log_event.
SELECTION-SCREEN END OF BLOCK b1.
*----------------------------------------------------------------------*
*       CLASS lcl_data_select DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_data_select DEFINITION FINAL.
  PUBLIC SECTION.
    TYPES: typ_range_log_event TYPE RANGE OF zlnkelog-log_event.

    DATA: attr_t_log TYPE STANDARD TABLE OF zlnkelog.

    METHODS:
       select_log IMPORTING i_date_from TYPE datum
                            i_time_from TYPE uzeit
                            i_date_to TYPE datum
                            i_time_to TYPE uzeit
                            i_log_event TYPE typ_range_log_event.

ENDCLASS.                    "lcl_data_select DEFINITION

*----------------------------------------------------------------------*
*       CLASS lcl_salv DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_salv DEFINITION FINAL.
  PUBLIC SECTION.
    TYPES: BEGIN OF typ_alv,
      icon TYPE iconname,
      log_msgtyp TYPE zlnkelog-log_msgtyp,
      log_event	TYPE zlnkelog-log_event,
      log_event_txt TYPE dd07v-ddtext,
      timestamp	TYPE zlnkelog-timestamp,
      guid  TYPE zlnkelog-guid,
      event_user  TYPE zlnkelog-event_user,
  END OF typ_alv.

    CLASS-DATA:
          lr_attr_salv_table TYPE REF TO cl_salv_table,
          lt_attr_alv TYPE STANDARD TABLE OF typ_alv.
    CLASS-METHODS:
          alv_build IMPORTING i_r_data_select
                             TYPE REF TO lcl_data_select,
          show_xml IMPORTING i_row TYPE i.

  PRIVATE SECTION.
    CLASS-DATA:
         attr_r_data_select TYPE REF TO lcl_data_select.
    CLASS-METHODS:
         fill_table,
         alv_set_columns,
         alv_set_functions,
         alv_set_events.

ENDCLASS.                    "lcl_alv DEFINITION


*----------------------------------------------------------------------*
*       CLASS lcl_salv_table_handle_events DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_salv_table_handle_events DEFINITION FINAL.

  PUBLIC SECTION.
    METHODS:
      on_double_click FOR EVENT double_click OF cl_salv_events_table
                      IMPORTING row.
ENDCLASS.                    "lcl_salv_table_handle_events DEFINITION


*----------------------------------------------------------------------*
*       CLASS lcl_data_select IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_data_select IMPLEMENTATION.

*--------------------------------------------------------------------*
* Data select to ZLNKELOG
*--------------------------------------------------------------------*
  METHOD select_log.
    DATA: l_timestamp_c TYPE char21.
    DATA: l_timestamp_from TYPE timestamp,
          l_timestamp_to TYPE timestamp.

    l_timestamp_c(8) = i_date_from.
    l_timestamp_c+8(6) = i_time_from.
    l_timestamp_from = l_timestamp_c.
    l_timestamp_c(8) = i_date_to.
    l_timestamp_c+8(6) = i_time_to.
    l_timestamp_to = l_timestamp_c.

    SELECT *                                            "#EC CI_NOFIELD
        INTO CORRESPONDING FIELDS OF TABLE attr_t_log
    FROM zlnkelog
    WHERE timestamp >= l_timestamp_from
      AND timestamp <= l_timestamp_to
      AND log_event IN i_log_event
    ORDER BY timestamp.

  ENDMETHOD.                    "select_log

ENDCLASS.                    "lcl_data_select IMPLEMENTATION

*----------------------------------------------------------------------*
*       CLASS lcl_salv IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_salv IMPLEMENTATION.

*--------------------------------------------------------------------*
* Builds ALV
*--------------------------------------------------------------------*
  METHOD alv_build.
    DATA: lr_cx_root TYPE REF TO cx_root.
    DATA: l_text_error TYPE string.

*   Avoids building every PBO
    CHECK lr_attr_salv_table IS NOT BOUND.

    attr_r_data_select = i_r_data_select.

    fill_table( ).

    TRY.
        cl_salv_table=>factory(
          IMPORTING
            r_salv_table = lr_attr_salv_table
          CHANGING
            t_table      = lt_attr_alv ).
      CATCH cx_salv_msg INTO lr_cx_root.
        l_text_error = lr_cx_root->get_text( ).
        MESSAGE e208(00) WITH l_text_error.
    ENDTRY.

    alv_set_columns( ).
    alv_set_functions( ).
    alv_set_events( ).

    lr_attr_salv_table->display( ).

  ENDMETHOD.                    "alv_build


*--------------------------------------------------------------------*
* ALV Columns
*--------------------------------------------------------------------*
  METHOD alv_set_columns.
    DATA: lr_salv_columns TYPE REF TO cl_salv_columns.
    DATA: lr_salv_column_table TYPE REF TO cl_salv_column_table.
    DATA: l_edit_mask TYPE lvc_edtmsk.

    lr_salv_columns = lr_attr_salv_table->get_columns( ).
    lr_salv_columns->set_optimize( abap_true ).

    TRY.
*       Sets mask for timestamp
        lr_salv_column_table ?= lr_salv_columns->get_column(
                                              columnname = 'TIMESTAMP' ).
        l_edit_mask = '____-__-__ __:__:__ ms ___'.
        lr_salv_column_table->set_edit_mask( l_edit_mask ).

      CATCH cx_salv_not_found .
                                                       "#EC NO_HANDLER)
    ENDTRY.


  ENDMETHOD.                    "alv_set_columns

*--------------------------------------------------------------------*
* ALV Buttons
*--------------------------------------------------------------------*
  METHOD alv_set_functions.
    DATA: lr_functions TYPE REF TO cl_salv_functions_list.

    lr_functions = lr_attr_salv_table->get_functions( ).
    lr_functions->set_all( abap_true ).

  ENDMETHOD.                    "alv_set_functions

*--------------------------------------------------------------------*
* Sets event handler
*--------------------------------------------------------------------*
  METHOD alv_set_events.
    DATA: lr_salv_events_table TYPE REF TO cl_salv_events_table.
    DATA: lr_event_handler TYPE REF TO lcl_salv_table_handle_events.

    lr_salv_events_table = lr_attr_salv_table->get_event( ).

    CREATE OBJECT lr_event_handler.

    SET HANDLER lr_event_handler->on_double_click FOR lr_salv_events_table.

  ENDMETHOD.                    "alv_set_events

*--------------------------------------------------------------------*
* Fills table to show in ALV
*--------------------------------------------------------------------*
  METHOD fill_table.
    DATA: lt_dd07v TYPE STANDARD TABLE OF dd07v.
    FIELD-SYMBOLS: <fs_log> TYPE zlnkelog.
    FIELD-SYMBOLS: <fs_alv> TYPE typ_alv.
    FIELD-SYMBOLS: <fs_dd07v> TYPE dd07v.

    CALL FUNCTION 'DD_DOMVALUES_GET'
      EXPORTING
        domname        = 'ZLNKELOG_EVENT_DO'
        text           = abap_true
        langu          = sy-langu
      TABLES
        dd07v_tab      = lt_dd07v
      EXCEPTIONS
        wrong_textflag = 1
        OTHERS         = 2.
    IF sy-subrc <> 0.
      CLEAR lt_dd07v[].
    ENDIF.

*   Completes information: Icon and event text
    LOOP AT attr_r_data_select->attr_t_log ASSIGNING <fs_log>.
      APPEND INITIAL LINE TO lt_attr_alv ASSIGNING <fs_alv>.
      MOVE-CORRESPONDING <fs_log> TO <fs_alv>.
      CASE <fs_log>-log_msgtyp.
        WHEN zlnkecl_log=>c_log_msgtyp_abort.
          <fs_alv>-icon = icon_message_critical_small.
        WHEN zlnkecl_log=>c_log_msgtyp_error.
          <fs_alv>-icon = icon_message_error_small.
        WHEN zlnkecl_log=>c_log_msgtyp_info.
          <fs_alv>-icon  = icon_message_information_small.
        WHEN zlnkecl_log=>c_log_msgtyp_success.
          <fs_alv>-icon  = icon_led_green.
        WHEN zlnkecl_log=>c_log_msgtyp_warning.
          <fs_alv>-icon  = icon_message_warning_small.
      ENDCASE.

      READ TABLE lt_dd07v WITH KEY domvalue_l = <fs_log>-log_event
                          ASSIGNING <fs_dd07v>.
      IF sy-subrc = 0.
        <fs_alv>-log_event_txt = <fs_dd07v>-ddtext.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.                    "fill_table

*--------------------------------------------------------------------*
* Shows XML in a dialog.
*--------------------------------------------------------------------*
  METHOD show_xml.
    DATA: ls_log TYPE zlnkelog.

    READ TABLE attr_r_data_select->attr_t_log INDEX i_row
                                              INTO ls_log.
    IF sy-subrc = 0.
      CALL METHOD zlnkecl_xml_utils=>show_xxml_in_dialog
        EXPORTING
          i_xxml = ls_log-rawdata.
    ENDIF.
  ENDMETHOD.                    "show_xml
ENDCLASS.                    "lcl_salv IMPLEMENTATION

*----------------------------------------------------------------------*
*       CLASS lcl_salv_table_handle_events IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_salv_table_handle_events IMPLEMENTATION.
  METHOD on_double_click.
    lcl_salv=>show_xml( row ).
  ENDMETHOD.                    "on_double_click
ENDCLASS.                    "lcl_salv_table_handle_events IMPLEMENTATION


*--------------------------------------------------------------------*
* INITIALIZATION.
*--------------------------------------------------------------------*
INITIALIZATION.
  so_date-sign = 'I'.
  so_date-option = 'BT'.
  so_date-low = sy-datum.
  so_date-high = sy-datum.
  APPEND so_date.

  so_time-sign = 'I'.
  so_time-option = 'BT'.
  so_time-low = '000000'.
  so_time-high = '235959'.
  APPEND so_time.

*--------------------------------------------------------------------*
* START-OF-SELECTION.
*--------------------------------------------------------------------*
START-OF-SELECTION.
  DATA: lr_data_select TYPE REF TO lcl_data_select.

  CREATE OBJECT lr_data_select.
  lr_data_select->select_log( i_date_from = so_date-low
                              i_time_from = so_time-low
                              i_date_to = so_date-high
                              i_time_to = so_time-high
                              i_log_event =  so_evnt[] ).

  lcl_salv=>alv_build( lr_data_select ).
