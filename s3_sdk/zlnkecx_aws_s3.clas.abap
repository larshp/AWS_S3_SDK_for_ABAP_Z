class ZLNKECX_AWS_S3 definition
  public
  inheriting from CX_STATIC_CHECK
  final
  create public .

*"* public components of class ZLNKECX_AWS_S3
*"* do not include other source files here!!!
public section.

  interfaces IF_T100_MESSAGE .

  constants C_MSG_CLASS type MSGID value 'ZLNKEAWS_S3'. "#EC NOTEXT
  data STRING type STRING .

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional
      !STRING type STRING optional .
  class-methods GET_INSTANCE_SYST_T100
    returning
      value(E_ZLNKECX_AWS_S3) type ref to ZLNKECX_AWS_S3 .
  methods GET_TEXT_AS_STRING
    returning
      value(E_TEXT) type STRING .
  class-methods RAISE_FROM_SY_MSG
    importing
      !PREVIOUS like PREVIOUS optional
    raising
      ZLNKECX_AWS_S3 .
  class-methods RAISE_FROM_FM_EXCEPTION
    importing
      !I_FUNCNAME type FUNCNAME
      !I_SY_SUBRC type SY-SUBRC optional
    raising
      ZLNKECX_AWS_S3 .
  class-methods RAISE_GIVING_STRING
    importing
      !I_STRING type STRING
    raising
      ZLNKECX_AWS_S3 .

  methods IF_MESSAGE~GET_TEXT
    redefinition .
protected section.
*"* protected components of class ZLNKECX_AWS_S3
*"* do not include other source files here!!!
private section.
*"* private components of class ZLNKECX_AWS_S3
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZLNKECX_AWS_S3 IMPLEMENTATION.


method CONSTRUCTOR ##ADT_SUPPRESS_GENERATION.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
PREVIOUS = PREVIOUS
.
me->STRING = STRING .
clear me->textid.
if textid is initial and ME->IF_T100_MESSAGE~T100KEY IS INITIAL.
  IF_T100_MESSAGE~T100KEY = IF_T100_MESSAGE=>DEFAULT_TEXTID.
else.
  IF_T100_MESSAGE~T100KEY = TEXTID.
endif.
endmethod.


METHOD GET_INSTANCE_SYST_T100.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 15th April 2014
* Returns an instance of this class with populated data from sy
*--------------------------------------------------------------------*
  CREATE OBJECT e_ZLNKEcx_aws_s3.

  e_ZLNKEcx_aws_s3->if_t100_message~t100key-msgid = sy-msgid.
  e_ZLNKEcx_aws_s3->if_t100_message~t100key-msgno = sy-msgno.
  e_ZLNKEcx_aws_s3->if_t100_message~t100key-attr1 = sy-msgv1.
  e_ZLNKEcx_aws_s3->if_t100_message~t100key-attr2 = sy-msgv2.
  e_ZLNKEcx_aws_s3->if_t100_message~t100key-attr3 = sy-msgv3.
  e_ZLNKEcx_aws_s3->if_t100_message~t100key-attr4 = sy-msgv4.

ENDMETHOD.


METHOD get_text_as_string.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 15th April 2014
* Returns the text in long form (string)
*--------------------------------------------------------------------*
  DATA: l_text TYPE t100-text.

  IF string IS NOT INITIAL.
    e_text = string.
  ELSE.
    SELECT SINGLE text
             INTO l_text
    FROM t100
    WHERE sprsl = sy-langu
      AND arbgb = if_t100_message~t100key-msgid
      AND msgnr = if_t100_message~t100key-msgno.

    IF sy-subrc = 0.
      e_text = l_text.
      REPLACE '&' WITH if_t100_message~t100key-attr1 INTO e_text.
      REPLACE '&' WITH if_t100_message~t100key-attr2 INTO e_text.
      REPLACE '&' WITH if_t100_message~t100key-attr3 INTO e_text.
      REPLACE '&' WITH if_t100_message~t100key-attr4 INTO e_text.
    ENDIF.
  ENDIF.

ENDMETHOD.


METHOD if_message~get_text.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 8th March 2016
* Returns the text
*--------------------------------------------------------------------*
  IF string IS INITIAL.
    CALL METHOD super->if_message~get_text
      RECEIVING
        result = result.
    REPLACE ALL OCCURRENCES OF '&' IN result WITH space.
    CONDENSE result.
  ELSE.
    result = string.
  ENDIF.

ENDMETHOD.


METHOD raise_from_fm_exception.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 7th March 2016
* Raises exception from FM Exception
*--------------------------------------------------------------------*
  DATA: lt_dokumentation TYPE STANDARD TABLE OF funct.
  DATA: lt_exception_list TYPE STANDARD TABLE OF rsexc.
  DATA: lt_export_parameter TYPE STANDARD TABLE OF rsexp.
  DATA: lt_import_parameter TYPE STANDARD TABLE OF rsimp.
  DATA: lt_tables_parameter TYPE STANDARD TABLE OF rstbl.
  DATA: lv_exception TYPE char30.
  DATA: lv_subrc TYPE i.
  DATA: lv_msg TYPE string.                                 "#EC NEEDED

  IF i_sy_subrc IS INITIAL.
    lv_subrc = sy-subrc.
  ELSE.
    lv_subrc = i_sy_subrc.
  ENDIF.

  CALL FUNCTION 'FUNCTION_IMPORT_DOKU'
    EXPORTING
      funcname           = i_funcname
      language           = sy-langu
    TABLES
      dokumentation      = lt_dokumentation
      exception_list     = lt_exception_list
      export_parameter   = lt_export_parameter
      import_parameter   = lt_import_parameter
      tables_parameter   = lt_tables_parameter
    EXCEPTIONS
      error_message      = 1
      function_not_found = 2
      invalid_name       = 3
      OTHERS             = 4.

  IF sy-subrc = 0.
    READ TABLE lt_exception_list INTO lv_exception INDEX lv_subrc.
    IF sy-subrc = 0.
      MESSAGE e398(00) WITH 'Function Module'
                            i_funcname
                            'raised exception'
                            lv_exception INTO lv_msg.
      raise_from_sy_msg( ).
    ENDIF.
  ELSE.
    MESSAGE e398(00) WITH 'Function Module'
                          'FUNCTION_IMPORT_DOKU'
                          'raised exception'
                          sy-subrc INTO lv_msg.
    raise_from_sy_msg( ).
  ENDIF.

ENDMETHOD.


METHOD raise_from_sy_msg.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 7th March 2016
* Raises exception from SY-MSG
*--------------------------------------------------------------------*
  DATA: ls_t100key LIKE if_t100_message=>t100key.

  ls_t100key-msgid = sy-msgid.
  ls_t100key-msgno = sy-msgno.
  ls_t100key-attr1 = sy-msgv1.
  ls_t100key-attr2 = sy-msgv2.
  ls_t100key-attr3 = sy-msgv3.
  ls_t100key-attr4 = sy-msgv4.

  RAISE EXCEPTION TYPE ZLNKECX_AWS_S3
    EXPORTING
      textid      = ls_t100key
      previous    = previous.

ENDMETHOD.


METHOD raise_giving_string.

  RAISE EXCEPTION TYPE ZLNKEcx_aws_s3
  EXPORTING
    string = i_string.

ENDMETHOD.
ENDCLASS.
