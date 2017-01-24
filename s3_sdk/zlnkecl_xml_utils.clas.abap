class ZLNKECL_XML_UTILS definition
  public
  final
  create private .

*"* public components of class ZLNKECL_XML_UTILS
*"* do not include other source files here!!!
public section.

  class-methods SHOW_XML_IN_DIALOG
    importing
      !I_XML type STRING .
  class-methods SHOW_XXML_IN_DIALOG
    importing
      !I_XXML type XSTRING .
  class-methods CONVERT_IXML_DOC_TO_XSTRING
    importing
      !I_IXML_DOCUMENT type ref to IF_IXML_DOCUMENT
    returning
      value(E_XML_XSTRING) type XSTRING .
  class-methods CONVERT_STRING_TO_IXMLDOC
    importing
      !I_XML_STRING type STRING
    returning
      value(E_IXMLDOC) type ref to IF_IXML_DOCUMENT .
  class-methods GET_NODE_VALUE
    importing
      !I_IXML_DOC type ref to IF_IXML_DOCUMENT
      !I_NODE_NAME type STRING
    returning
      value(E_NODE_VALUE) type STRING .
  class-methods GET_NODE_VALUES_FROM_XMLSTRING
    importing
      !I_XML_STRING type STRING
      !I_NODE_NAME type STRING
    returning
      value(E_NODE_VALUES) type STRING_TABLE .
  class-methods GET_NODE_VALUE_FROM_XMLSTRING
    importing
      !I_XML_STRING type STRING
      !I_NODE_NAME type STRING
    returning
      value(E_NODE_VALUE) type STRING .
protected section.
*"* protected components of class ZLNKECL_XML_UTILS
*"* do not include other source files here!!!
private section.
*"* private components of class ZLNKECL_XML_UTILS
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZLNKECL_XML_UTILS IMPLEMENTATION.


METHOD convert_ixml_doc_to_xstring.
*-------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 28th March 2014
* Given an IXML document, converts it to xstring
*--------------------------------------------------------------------*
  DATA: lr_ixml TYPE REF TO if_ixml,
        lr_ixml_stream_factory TYPE REF TO if_ixml_stream_factory,
        lr_ixml_ostream TYPE REF TO if_ixml_ostream,
        lr_ixml_renderer TYPE REF TO if_ixml_renderer.

  lr_ixml = cl_ixml=>create( ).

  lr_ixml_stream_factory = lr_ixml->create_stream_factory( ).

  lr_ixml_ostream = lr_ixml_stream_factory->create_ostream_xstring(
                                                     e_xml_xstring ).

  lr_ixml_renderer = lr_ixml->create_renderer(
                           document = i_ixml_document
                           ostream = lr_ixml_ostream ).

  lr_ixml_renderer->set_normalizing( ).

  lr_ixml_renderer->render( ).

ENDMETHOD.


METHOD convert_string_to_ixmldoc.
*-------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 30th April 2014
* Given an XML string, converts it to ixml document
*--------------------------------------------------------------------*
  DATA lr_ixml          TYPE REF TO if_ixml.
  DATA lr_streamfactory TYPE REF TO if_ixml_stream_factory.
  DATA lr_istream       TYPE REF TO if_ixml_istream.
  DATA lr_ixmlparser    TYPE REF TO if_ixml_parser.

  lr_ixml = cl_ixml=>create( ).
  e_ixmldoc = lr_ixml->create_document( ).
  lr_streamfactory = lr_ixml->create_stream_factory( ).
  lr_istream = lr_streamfactory->create_istream_string( i_xml_string ).
  lr_ixmlparser = lr_ixml->create_parser( stream_factory = lr_streamfactory
                                          istream        = lr_istream
                                          document       = e_ixmldoc ).
  lr_ixmlparser->parse( ).

ENDMETHOD.


METHOD get_node_value.
*-------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 30th April 2014
* Given an IXML document and a node name, returns the node value
*--------------------------------------------------------------------*
  DATA: lr_node_filter   TYPE REF TO if_ixml_node_filter.
  DATA: lr_node_iterator TYPE REF TO if_ixml_node_iterator.
  DATA: lr_node          TYPE REF TO if_ixml_node.

  lr_node_filter = i_ixml_doc->create_filter_name( i_node_name ).

  lr_node_iterator = i_ixml_doc->create_iterator_filtered( lr_node_filter ).

  lr_node ?= lr_node_iterator->get_next( ).
  IF lr_node IS NOT INITIAL.
    e_node_value = lr_node->get_value( ).
  ENDIF.

ENDMETHOD.


METHOD get_node_values_from_xmlstring.
*-------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 30th April 2014
* Given an XML string and a node name, returns the node value
*--------------------------------------------------------------------*
  DATA: lr_ixml_document TYPE REF TO if_ixml_document.
  DATA: lr_node_filter   TYPE REF TO if_ixml_node_filter.
  DATA: lr_node_iterator TYPE REF TO if_ixml_node_iterator.
  DATA: lr_node          TYPE REF TO if_ixml_node.
  DATA: l_node_value TYPE string.

  lr_ixml_document = convert_string_to_ixmldoc( i_xml_string ).

  lr_node_filter = lr_ixml_document->create_filter_name( i_node_name ).

  lr_node_iterator = lr_ixml_document->create_iterator_filtered( lr_node_filter ).

  lr_node ?= lr_node_iterator->get_next( ).
  WHILE lr_node IS NOT INITIAL.
    l_node_value = lr_node->get_value( ).
    APPEND l_node_value TO e_node_values.
    lr_node ?= lr_node_iterator->get_next( ).
  ENDWHILE.

ENDMETHOD.


METHOD GET_NODE_VALUE_FROM_XMLSTRING.
*-------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 30th April 2014
* Given an XML string and a node name, returns the node value
*--------------------------------------------------------------------*
  DATA: lr_ixml_document TYPE REF TO if_ixml_document.

  lr_ixml_document = convert_string_to_ixmldoc( i_xml_string ).

  e_node_value = get_node_value( i_ixml_doc = lr_ixml_document
                                 i_node_name = i_node_name ).

ENDMETHOD.


METHOD show_xml_in_dialog.
*-------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 28th March 2014
* Given an XML, shows it in a dialog.
*--------------------------------------------------------------------*
  DATA: lr_xml_document  TYPE REF TO cl_xml_document.

  CREATE OBJECT lr_xml_document.
  CALL METHOD lr_xml_document->parse_string
    EXPORTING
      stream = i_xml.

  CALL METHOD lr_xml_document->display.

ENDMETHOD.


METHOD show_xxml_in_dialog.
*-------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 11th April 2014
* Given an XXML, shows it in a dialog.
*--------------------------------------------------------------------*
  DATA: lr_xml_document  TYPE REF TO cl_xml_document.

  CREATE OBJECT lr_xml_document.
  CALL METHOD lr_xml_document->parse_xstring
    EXPORTING
      stream = i_xxml.

  CALL METHOD lr_xml_document->display( ).

ENDMETHOD.
ENDCLASS.
