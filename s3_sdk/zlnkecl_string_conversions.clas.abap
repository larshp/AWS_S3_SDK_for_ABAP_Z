class ZLNKECL_STRING_CONVERSIONS definition
  public
  final
  create private .

*"* public components of class ZLNKECL_STRING_CONVERSIONS
*"* do not include other source files here!!!
public section.

  class-methods STRING_TO_XSTRING
    importing
      !INPUT type STRING
    exporting
      !OUTPUT type XSTRING .
  class-methods XSTRING_TO_STRING
    importing
      !INPUT type XSTRING
    exporting
      !OUTPUT type STRING .
  class-methods XSTRING_TO_XSTRING_TAB
    importing
      !I_XSTRING type XSTRING
      !I_LINE_LENGTH type I
    returning
      value(E_XSTRING_TABLE) type XSTRING_TABLE .
protected section.
*"* protected components of class ZLNKECL_STRING_CONVERSIONS
*"* do not include other source files here!!!
private section.
*"* private components of class ZLNKECL_STRING_CONVERSIONS
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZLNKECL_STRING_CONVERSIONS IMPLEMENTATION.


METHOD string_to_xstring.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 28th July 2014
* Converts from string to xstring
*--------------------------------------------------------------------*
  DATA: lr_conv_ce TYPE REF TO  cl_abap_conv_out_ce.
  DATA: size TYPE i.                                        "#EC NEEDED

  lr_conv_ce = cl_abap_conv_out_ce=>create( encoding = 'UTF-8' ).

  CALL METHOD lr_conv_ce->write
    EXPORTING
      data = input
    IMPORTING
      len  = size.

  output = lr_conv_ce->get_buffer( ).

ENDMETHOD.


METHOD xstring_to_string.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 28th July 2014
* Converts from xstring to string
*--------------------------------------------------------------------*
  DATA: size TYPE i.                                        "#EC NEEDED
  DATA: lr_conv_ci TYPE REF TO cl_abap_conv_in_ce.

  lr_conv_ci = cl_abap_conv_in_ce=>create( input = input ).

  CALL METHOD lr_conv_ci->read
    IMPORTING
      data = output
      len  = size.

ENDMETHOD.


METHOD xstring_to_xstring_tab.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 28th Nov 2014
* Converts from xstring to xstring table, with specified line length.
*--------------------------------------------------------------------*

  DATA: l_length TYPE i.
  DATA: l_index_start TYPE i.
  DATA: l_xstr_tmp TYPE xstring.
  DATA: l_parts TYPE i.
  DATA: l_mod TYPE i.

  CHECK i_line_length > 0.

  l_length = XSTRLEN( i_xstring ).
  l_parts = l_length DIV i_line_length.
  l_mod = l_length MOD i_line_length.

  l_index_start = 0.
  DO l_parts TIMES.
    l_xstr_tmp = i_xstring+l_index_start(i_line_length).
    l_index_start = l_index_start + i_line_length.
    APPEND l_xstr_tmp TO e_xstring_table.
  ENDDO.
  IF l_mod > 0.
    l_xstr_tmp = i_xstring+l_index_start.
    APPEND l_xstr_tmp TO e_xstring_table.
  ENDIF.

ENDMETHOD.
ENDCLASS.
