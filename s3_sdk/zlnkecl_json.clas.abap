class ZLNKECL_JSON definition
  public
  create public .

*"* public components of class ZLNKECL_JSON
*"* do not include other source files here!!!
public section.

  types PRETTY_NAME_MODE type CHAR1 .

  constants:
    BEGIN OF pretty_mode,
          none          TYPE char1  VALUE '',
          low_case      TYPE char1  VALUE 'L',
          camel_case    TYPE char1  VALUE 'X',
        END OF  pretty_mode .
  class-data SV_WHITE_SPACE type STRING read-only .

  class-methods CLASS_CONSTRUCTOR .
  class-methods STRING_TO_XSTRING
    importing
      !IN type STRING
    changing
      value(OUT) type ANY .
  class-methods XSTRING_TO_STRING
    importing
      !IN type ANY
    returning
      value(OUT) type STRING .
  class-methods RESTORE
    importing
      !JSON type STRING
      !PRETTY_NAME type PRETTY_NAME_MODE default PRETTY_MODE-NONE
      !LENGTH type I
    changing
      !DATA type DATA optional
      !OFFSET type I default 0
    raising
      CX_SY_MOVE_CAST_ERROR .
  class-methods RESTORE_TYPE
    importing
      !JSON type STRING
      !PRETTY_NAME type PRETTY_NAME_MODE default PRETTY_MODE-NONE
      !LENGTH type I
    changing
      !DATA type DATA optional
      !OFFSET type I default 0 .
  type-pools ABAP .
  class-methods DUMP
    importing
      !DATA type DATA
      !COMPRESS type ABAP_BOOL default ABAP_FALSE
      !TYPE_DESCR type ref to CL_ABAP_TYPEDESCR optional
      !PRETTY_NAME type PRETTY_NAME_MODE default PRETTY_MODE-NONE
    returning
      value(R_JSON) type STRING .
  class-methods DESERIALIZE
    importing
      !JSON type STRING
      !PRETTY_NAME type PRETTY_NAME_MODE default PRETTY_MODE-NONE
    changing
      !DATA type DATA .
  class-methods SERIALIZE
    importing
      !DATA type DATA
      !COMPRESS type ABAP_BOOL default ABAP_FALSE
      !NAME type STRING optional
      !PRETTY_NAME type PRETTY_NAME_MODE default PRETTY_MODE-NONE
      !TYPE_DESCR type ref to CL_ABAP_TYPEDESCR optional
    returning
      value(R_JSON) type STRING .
  class-methods DUMP_TYPE
    importing
      !DATA type DATA
      !TYPE_DESCR type ref to CL_ABAP_ELEMDESCR
    returning
      value(R_JSON) type STRING .
  class-methods DUMP_TYPE_EX
    importing
      !DATA type DATA
    returning
      value(R_JSON) type STRING .
  class-methods PRETTY_NAME
    importing
      !IN type CSEQUENCE
    returning
      value(OUT) type STRING .
  class-methods ESCAPE
    importing
      !IN type ANY
    returning
      value(OUT) type STRING .
protected section.
*"* protected components of class ZLNKECL_JSON
*"* do not include other source files here!!!

  constants MC_BOOLEAN_TYPES type STRING value `\TYPE-POOL=ABAP\TYPE=ABAP_BOOL#\TYPE=BOOLEAN#\TYPE=BOOLE_D#\TYPE=XFELD`. "#EC NOTEXT
private section.
*"* private components of class ZLNKECL_JSON
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZLNKECL_JSON IMPLEMENTATION.


METHOD class_constructor.
  sv_white_space = cl_abap_char_utilities=>get_simple_spaces_for_cur_cp( ).
ENDMETHOD.


method DESERIALIZE.
  DATA: length    TYPE i,
        unescaped LIKE json.

  IF json IS NOT INITIAL.

    unescaped = json.

    " to eliminate numeric replacement calls for every single sting value, we do
    " replacement over all JSON text, while this shall not destroy JSON structure
    REPLACE ALL OCCURRENCES OF `\r\n` IN unescaped WITH cl_abap_char_utilities=>cr_lf.
    REPLACE ALL OCCURRENCES OF `\n`   IN unescaped WITH cl_abap_char_utilities=>newline.
    REPLACE ALL OCCURRENCES OF `\t`   IN unescaped WITH cl_abap_char_utilities=>horizontal_tab.
*   REPLACE ALL OCCURRENCES OF `\f`   IN r_json WITH cl_abap_char_utilities=>form_feed.
*   REPLACE ALL OCCURRENCES OF `\b`   IN r_json WITH cl_abap_char_utilities=>backspace.

    length = NUMOFCHAR( unescaped ).
    restore_type( EXPORTING json = unescaped pretty_name = pretty_name length = length CHANGING data = data ).

  ENDIF.
endmethod.


METHOD dump.
  "Get attributes of class
  DATA: lo_typedesc        TYPE REF TO cl_abap_typedescr,
        lo_elem_descr      TYPE REF TO cl_abap_elemdescr,
        lo_classdesc       TYPE REF TO cl_abap_classdescr,
        lo_structdesc      TYPE REF TO cl_abap_structdescr,
        lo_tabledescr      TYPE REF TO cl_abap_tabledescr,
        lt_symbols         TYPE cl_abap_structdescr=>symbol_table,
        lv_properties      TYPE STANDARD TABLE OF string,
        lv_fields          TYPE STANDARD TABLE OF string,
        lo_obj_ref         TYPE REF TO object,
        lo_data_ref        TYPE REF TO data,
        lv_prop_name       TYPE string,
        lv_itemval         TYPE string.

  FIELD-SYMBOLS: <attr>             LIKE LINE OF cl_abap_objectdescr=>attributes,
                 <line>             TYPE ANY,
                 <value>            TYPE ANY,
                 <data>             TYPE data,
                 <symbol_table>     LIKE LINE OF lt_symbols,
                 <table>            TYPE ANY TABLE.

  " we need here macro instead of method calls because of the performance reasons.
  " Based on SAT measurments.

  "Loop attributes of class
  CASE type_descr->kind.
    WHEN cl_abap_typedescr=>kind_ref." OBJECT or DATA REF

      IF data IS INITIAL.
        r_json = `null`.                                    "#EC NOTEXT
      ELSEIF type_descr->type_kind EQ cl_abap_typedescr=>typekind_dref.
        lo_data_ref ?= data.
        lo_typedesc = cl_abap_typedescr=>describe_by_data_ref( lo_data_ref ).
        ASSIGN lo_data_ref->* TO <data>.
        r_json = dump( data = <data> compress = compress pretty_name = pretty_name type_descr = lo_typedesc ).
      ELSE.
        lo_obj_ref ?= data.
        lo_classdesc ?= cl_abap_typedescr=>describe_by_object_ref( lo_obj_ref ).

* Begin of Jordi Escoda, 22th Sept 2016: Avoid dump in case of objects with private or protected attributes
* Standard code
* <<<Old code
*        LOOP AT lo_classdesc->attributes ASSIGNING <attr> WHERE is_constant EQ abap_false AND alias_for IS INITIAL AND
*          ( is_interface EQ abap_false OR type_kind NE cl_abap_typedescr=>typekind_oref ).
*          ASSIGN lo_obj_ref->(<attr>-name) TO <value>.
*          IF compress EQ abap_false OR <value> IS NOT INITIAL.
*            lo_typedesc = cl_abap_typedescr=>describe_by_data( <value> ).
*            lv_itemval = dump( data = <value> compress = compress pretty_name = pretty_name type_descr = lo_typedesc ).
*            format_name <attr>-name pretty_name lv_prop_name.
*            CONCATENATE `"` lv_prop_name  `":` lv_itemval INTO lv_itemval.
*            APPEND lv_itemval TO lv_properties.
*          ENDIF.
*        ENDLOOP.
* >>>New code
        LOOP AT lo_classdesc->attributes ASSIGNING <attr>
               WHERE is_constant EQ abap_false
                 AND alias_for IS INITIAL
                 AND ( is_interface EQ abap_false OR type_kind NE cl_abap_typedescr=>typekind_oref )
                 AND visibility <> cl_abap_classdescr=>protected
                 AND visibility <> cl_abap_classdescr=>private.
          ASSIGN lo_obj_ref->(<attr>-name) TO <value>.
          IF compress EQ abap_false OR <value> IS NOT INITIAL.
            lo_typedesc = cl_abap_typedescr=>describe_by_data( <value> ).
            lv_itemval = dump( data = <value> compress = compress pretty_name = pretty_name type_descr = lo_typedesc ).
            format_name <attr>-name pretty_name lv_prop_name.
            CONCATENATE `"` lv_prop_name  `":` lv_itemval INTO lv_itemval.
            APPEND lv_itemval TO lv_properties.
          ENDIF.
        ENDLOOP.
* End of Jordi Escoda, 22th Sept 2016


        CONCATENATE LINES OF lv_properties INTO r_json SEPARATED BY `,`.
        CONCATENATE `{` r_json `}` INTO r_json.
      ENDIF.

    WHEN cl_abap_typedescr=>kind_elem. "if it is elementary type_descr add it to json
      lo_elem_descr ?= type_descr.
      "r_json = dump_type( data = data type_descr = l_elem_descr ).
      dump_type data lo_elem_descr r_json.

    WHEN cl_abap_typedescr=>kind_struct."if it`s structure loop throught the components of structure

      lo_structdesc ?= type_descr.
      lt_symbols = lo_structdesc->get_symbols( ).

      LOOP AT lt_symbols ASSIGNING <symbol_table>.
        ASSIGN COMPONENT <symbol_table>-name OF STRUCTURE data TO <value>.
        IF compress EQ abap_false OR <value> IS NOT INITIAL.
          lv_itemval = dump( data = <value> compress = compress pretty_name = pretty_name type_descr = <symbol_table>-type ).
          format_name <symbol_table>-name pretty_name lv_prop_name.
          CONCATENATE `"` lv_prop_name  `":` lv_itemval INTO lv_itemval.
          APPEND lv_itemval TO lv_properties.
        ENDIF.
      ENDLOOP.

      CONCATENATE LINES OF lv_properties INTO r_json SEPARATED BY `,`.
      CONCATENATE `{` r_json `}` INTO r_json.

    WHEN cl_abap_typedescr=>kind_table.

      lo_tabledescr ?= type_descr.
      lo_typedesc = lo_tabledescr->get_table_line_type( ).

      ASSIGN data TO <table>.

      " optimization for structured tables
      IF lo_typedesc->kind EQ cl_abap_typedescr=>kind_struct.

        TYPES: BEGIN OF t_s_column,
                header TYPE string,
                name   TYPE string,
                type   TYPE REF TO cl_abap_datadescr,
               END OF t_s_column.

        DATA: columns TYPE STANDARD TABLE OF t_s_column.
        FIELD-SYMBOLS: <column> LIKE LINE OF columns.

        lo_structdesc ?= lo_typedesc.
        lt_symbols = lo_structdesc->get_symbols( ).
        LOOP AT lt_symbols ASSIGNING <symbol_table>.
          APPEND INITIAL LINE TO columns ASSIGNING <column>.
          MOVE-CORRESPONDING <symbol_table> TO <column>.
          format_name <symbol_table>-name pretty_name <column>-header.
          CONCATENATE `"` <column>-header  `":` INTO <column>-header.
        ENDLOOP.
        LOOP AT <table> ASSIGNING <line>.
          CLEAR lv_fields.
          LOOP AT columns ASSIGNING <column>.
            ASSIGN COMPONENT <column>-name OF STRUCTURE <line> TO <value>.
            IF compress EQ abap_false OR <value> IS NOT INITIAL.
              IF <column>-type->kind EQ cl_abap_typedescr=>kind_elem.
                lo_elem_descr ?= <column>-type.
                "lv_itemval = dump_type( data = <value> type_descr = l_elem_descr ).
                dump_type <value> lo_elem_descr lv_itemval.
              ELSE.
                lv_itemval = dump( data = <value> compress = compress pretty_name = pretty_name type_descr = <column>-type ).
              ENDIF.
              CONCATENATE <column>-header lv_itemval INTO lv_itemval.
              APPEND lv_itemval TO lv_fields.
            ENDIF.
          ENDLOOP.
          CONCATENATE LINES OF lv_fields INTO lv_itemval SEPARATED BY `,`.
          CONCATENATE `{` lv_itemval `}` INTO lv_itemval.
          APPEND lv_itemval TO lv_properties.
        ENDLOOP.
      ELSE.
        LOOP AT <table> ASSIGNING <value>.
          lv_itemval = dump( data = <value> compress = compress pretty_name = pretty_name type_descr = lo_typedesc ).
          APPEND lv_itemval TO lv_properties.
        ENDLOOP.
      ENDIF.

      CONCATENATE LINES OF lv_properties INTO r_json SEPARATED BY `,`.
      CONCATENATE `[` r_json `]` INTO r_json.

  ENDCASE.

ENDMETHOD.


METHOD dump_type.
  CASE type_descr->type_kind.
    WHEN cl_abap_typedescr=>typekind_float OR cl_abap_typedescr=>typekind_int OR cl_abap_typedescr=>typekind_int1 OR
         cl_abap_typedescr=>typekind_int2 OR cl_abap_typedescr=>typekind_packed OR `8`. " TYPEKIND_INT8 -> '8' only from 7.40
      IF data IS INITIAL.
        r_json = `0`.
      ELSE.
        MOVE data TO r_json.
        IF data LT 0.
          SHIFT r_json RIGHT CIRCULAR.
        ELSE.
          CONDENSE r_json.
        ENDIF.
      ENDIF.
    WHEN cl_abap_typedescr=>typekind_num.
      IF data IS INITIAL.
        r_json = `0`.
      ELSE.
        MOVE data TO r_json.
        SHIFT r_json LEFT DELETING LEADING ` 0`.
      ENDIF.
    WHEN cl_abap_typedescr=>typekind_string OR cl_abap_typedescr=>typekind_csequence OR cl_abap_typedescr=>typekind_clike.
      IF data IS INITIAL.
        r_json = `""`.
      ELSE.
        r_json = escape( data ).
        CONCATENATE `"` r_json `"` INTO r_json.
      ENDIF.
    WHEN cl_abap_typedescr=>typekind_xstring OR cl_abap_typedescr=>typekind_hex.
      IF data IS INITIAL.
        r_json = `""`.
      ELSE.
        r_json = xstring_to_string( data ).
        r_json = escape( r_json ).
        CONCATENATE `"` r_json `"` INTO r_json.
      ENDIF.
    WHEN cl_abap_typedescr=>typekind_char.
      IF type_descr->output_length EQ 1 AND mc_boolean_types CS type_descr->absolute_name.
        IF data EQ abap_true.
          r_json = `true`.                                  "#EC NOTEXT
        ELSE.
          r_json = `false`.                                 "#EC NOTEXT
        ENDIF.
      ELSE.
        r_json = escape( data ).
        CONCATENATE `"` r_json `"` INTO r_json.
      ENDIF.
    WHEN cl_abap_typedescr=>typekind_date.
      CONCATENATE `"` data(4) `-` data+4(2) `-` data+6(2) `"` INTO r_json.
    WHEN cl_abap_typedescr=>typekind_time.
      CONCATENATE `"` data(2) `:` data+2(2) `:` data+4(2) `"` INTO r_json.
    WHEN OTHERS.
      IF data IS INITIAL.
        r_json = `null`.                                    "#EC NOTEXT
      ELSE.
        MOVE data TO r_json.
      ENDIF.
  ENDCASE.
ENDMETHOD.


METHOD dump_type_ex.
  DATA: lrf_descr TYPE REF TO cl_abap_elemdescr.
  lrf_descr ?= cl_abap_typedescr=>describe_by_data( data ).
  r_json = dump_type( data = data type_descr = lrf_descr ).
ENDMETHOD.


METHOD escape.
  MOVE in TO out.

  REPLACE ALL OCCURRENCES OF `\` IN out WITH `\\`.
  REPLACE ALL OCCURRENCES OF `"` IN out WITH `\"`.
ENDMETHOD.


METHOD pretty_name.
  DATA: tokens TYPE TABLE OF char128.
  FIELD-SYMBOLS: <token> LIKE LINE OF tokens.

  out = in.

  TRANSLATE out TO LOWER CASE.
  TRANSLATE out USING `/_:_~_`.
  SPLIT out AT `_` INTO TABLE tokens.
  DELETE tokens WHERE table_line IS INITIAL.
  LOOP AT tokens ASSIGNING <token> FROM 2.
    TRANSLATE <token>(1) TO UPPER CASE.
  ENDLOOP.

  CONCATENATE LINES OF tokens INTO out.

ENDMETHOD.


METHOD restore.
  DATA: mark        LIKE offset,
        match       LIKE offset,
        pos         LIKE offset,
        excp        TYPE REF TO cx_sy_move_cast_error,
        name_json   TYPE string,
        name_abap   TYPE string.

  FIELD-SYMBOLS: <value> TYPE ANY.

  eat_white.
  eat_char `{`.

  WHILE offset < length AND json+offset(1) NE `}`.

    eat_white.
    eat_string name_json.
    eat_white.
    eat_char `:`.
    eat_white.
    UNASSIGN <value>.

    name_abap = name_json.
    TRANSLATE name_abap TO UPPER CASE.
    ASSIGN COMPONENT name_abap OF STRUCTURE data TO <value>.

    IF <value> IS NOT ASSIGNED AND pretty_name EQ abap_true.
      name_abap = name_json.
      REPLACE ALL OCCURRENCES OF REGEX `([a-z])([A-Z])` IN name_abap WITH `$1_$2`. "#EC NOTEXT
      TRANSLATE name_abap TO UPPER CASE.
      ASSIGN COMPONENT name_abap OF STRUCTURE data TO <value>.
    ENDIF.

    IF <value> IS ASSIGNED.
      restore_type( EXPORTING json = json length = length pretty_name = pretty_name CHANGING data = <value> offset = offset ).
    ELSE.
      restore_type( EXPORTING json = json length = length pretty_name = pretty_name CHANGING offset = offset ).
    ENDIF.

    eat_white.

    IF offset < length AND json+offset(1) NE `}`.
      eat_char `,`.
    ELSE.
      EXIT.
    ENDIF.

  ENDWHILE.

  eat_char `}`.

ENDMETHOD.


METHOD restore_type.
  DATA: mark        LIKE offset,
        match       LIKE offset,
        sdummy      TYPE string,                            "#EC NEEDED
        lr_idummy   TYPE REF TO i,                          "#EC NEEDED
        lr_bdummy   TYPE REF TO abap_bool,                  "#EC NEEDED
        lr_sdummy   TYPE REF TO string,                     "#EC NEEDED
        pos         LIKE offset,
        line        TYPE REF TO data,
        elem_descr  TYPE REF TO cl_abap_elemdescr,
        type_descr  TYPE REF TO cl_abap_typedescr,
        table_descr TYPE REF TO cl_abap_tabledescr,
        excp        TYPE REF TO cx_sy_move_cast_error.

  FIELD-SYMBOLS: <line>           TYPE ANY,
                 <table>          TYPE ANY TABLE,
                 <table_sorted>   TYPE SORTED TABLE,
                 <table_hashed>   TYPE HASHED TABLE,
                 <table_standard> TYPE STANDARD TABLE.

  eat_white.

  TRY .
      CASE json+offset(1).
        WHEN `{`. " object
          IF data IS SUPPLIED.
            restore( EXPORTING json = json pretty_name = pretty_name length = length
                     CHANGING data = data offset = offset ).
          ELSE.
            restore( EXPORTING json = json pretty_name = pretty_name length = length
                     CHANGING  offset = offset ).
          ENDIF.
        WHEN `[`. " array
          eat_char `[`.
          eat_white.
          IF json+offset(1) NE `]`.
            type_descr = cl_abap_typedescr=>describe_by_data( data ).
            IF type_descr->kind EQ cl_abap_typedescr=>kind_table.
              table_descr ?= type_descr.
              ASSIGN data TO <table>.
              CREATE DATA line LIKE LINE OF <table>.
              ASSIGN line->* TO <line>.
              WHILE offset < length AND json+offset(1) NE `]`.
                CLEAR <line>.
                restore_type( EXPORTING json = json length = length pretty_name = pretty_name CHANGING data = <line> offset = offset ).
                CASE table_descr->table_kind.
                  WHEN cl_abap_tabledescr=>tablekind_sorted.
                    ASSIGN data TO <table_sorted>.
                    INSERT <line> INTO TABLE <table_sorted>.
                  WHEN cl_abap_tabledescr=>tablekind_hashed.
                    ASSIGN data TO <table_hashed>.
                    INSERT <line> INTO TABLE <table_hashed>.
                  WHEN OTHERS.
                    ASSIGN data TO <table_standard>.
                    APPEND <line> TO <table_standard>.
                ENDCASE.
                eat_white.
                IF offset < length AND json+offset(1) NE `]`.
                  eat_char `,`.
                ELSE.
                  EXIT.
                ENDIF.
              ENDWHILE.
            ELSE.
              " skip array
              WHILE offset < length AND json+offset(1) NE `}`.
                eat_white.
                restore_type( EXPORTING json = json length = length pretty_name = pretty_name CHANGING offset = offset ).
                IF offset < length AND json+offset(1) NE `]`.
                  eat_char `,`.
                ELSE.
                  EXIT.
                ENDIF.
              ENDWHILE.
            ENDIF.
          ENDIF.
          eat_char `]`.
        WHEN `"`. " string
          IF data IS SUPPLIED.
            eat_string sdummy.
            " unescape string
            IF sdummy IS NOT INITIAL.
              REPLACE ALL OCCURRENCES OF `\"` IN sdummy WITH `"`.
              REPLACE ALL OCCURRENCES OF `\\` IN sdummy WITH `\`.
              type_descr = cl_abap_typedescr=>describe_by_data( data ).
              IF type_descr->kind EQ cl_abap_typedescr=>kind_elem.
                elem_descr ?= type_descr.
                CASE elem_descr->type_kind.
                  WHEN cl_abap_typedescr=>typekind_char.
                    IF elem_descr->output_length EQ 1 AND mc_boolean_types CS elem_descr->absolute_name.
                      IF sdummy(1) EQ `X` OR sdummy(1) EQ `t` OR sdummy(1) EQ `T` OR sdummy(1) EQ `x`.
                        data = abap_true.
                      ELSE.
                        data = abap_false.
                      ENDIF.
                      RETURN.
                    ENDIF.
                  WHEN cl_abap_typedescr=>typekind_xstring OR cl_abap_typedescr=>typekind_hex.
                    string_to_xstring( EXPORTING in = sdummy CHANGING out = data ).
                    RETURN.
                  WHEN cl_abap_typedescr=>typekind_date.
                    REPLACE FIRST OCCURRENCE OF REGEX `(\d{4})-(\d{2})-(\d{2})` IN sdummy WITH `$1$2$3`.
                  WHEN cl_abap_typedescr=>typekind_time.
                    REPLACE FIRST OCCURRENCE OF REGEX `(\d{2}):(\d{2}):(\d{2})` IN sdummy WITH `$1$2$3`.
                ENDCASE.
              ELSEIF type_descr->type_kind EQ cl_abap_typedescr=>typekind_dref.
                CREATE DATA lr_sdummy TYPE string.
                MOVE sdummy TO lr_sdummy->*.
                data ?= lr_sdummy.
                RETURN.
              ELSE.
                throw_error.
              ENDIF.
            ENDIF.
            MOVE sdummy TO data. " to avoid crashes due to data type inconsistency
          ELSE.
            eat_string sdummy.
          ENDIF.
        WHEN `-`. " number
          IF data IS SUPPLIED.
            type_descr = cl_abap_typedescr=>describe_by_data( data ).
            IF type_descr->kind EQ type_descr->kind_ref AND type_descr->type_kind EQ cl_abap_typedescr=>typekind_dref.
              CREATE DATA lr_idummy TYPE i.
              eat_number lr_idummy->*.                      "#EC NOTEXT
              data ?= lr_idummy.
            ELSEIF type_descr->kind EQ type_descr->kind_ref.
              throw_error.
            ELSE.
              eat_number data.                              "#EC NOTEXT
            ENDIF.
          ELSE.
            eat_number sdummy.                              "#EC NOTEXT
          ENDIF.
        WHEN OTHERS.
          FIND FIRST OCCURRENCE OF json+offset(1) IN `0123456789`.
          IF sy-subrc IS INITIAL. " number
            IF data IS SUPPLIED.
              type_descr = cl_abap_typedescr=>describe_by_data( data ).
              IF type_descr->kind EQ type_descr->kind_ref AND type_descr->type_kind EQ cl_abap_typedescr=>typekind_dref.
                CREATE DATA lr_idummy TYPE i.
                eat_number lr_idummy->*.                    "#EC NOTEXT
                data ?= lr_idummy.
              ELSEIF type_descr->kind EQ type_descr->kind_ref.
                throw_error.
              ELSE.
                eat_number data.                            "#EC NOTEXT
              ENDIF.
            ELSE.
              eat_number sdummy.                            "#EC NOTEXT
            ENDIF.
          ELSE. " true/false/null
            IF data IS SUPPLIED.
              type_descr = cl_abap_typedescr=>describe_by_data( data ).
              IF type_descr->kind EQ type_descr->kind_ref AND type_descr->type_kind EQ cl_abap_typedescr=>typekind_dref.
                CREATE DATA lr_bdummy TYPE abap_bool.
                eat_bool lr_bdummy->*.                      "#EC NOTEXT
                data ?= lr_bdummy.
              ELSEIF type_descr->kind EQ type_descr->kind_ref.
                throw_error.
              ELSE.
                eat_bool data.                              "#EC NOTEXT
              ENDIF.
            ELSE.
              eat_bool sdummy.                              "#EC NOTEXT
            ENDIF.
          ENDIF.
      ENDCASE.
    CATCH cx_sy_move_cast_error cx_sy_conversion_no_number cx_sy_conversion_overflow.
      CLEAR data.
  ENDTRY.

ENDMETHOD.


METHOD serialize.
  DATA: lrf_descr TYPE REF TO cl_abap_typedescr.

  IF type_descr IS INITIAL.
    lrf_descr = cl_abap_typedescr=>describe_by_data( data ).
  ELSE.
    lrf_descr = type_descr.
  ENDIF.

  r_json = dump( data = data compress = compress pretty_name = pretty_name type_descr = lrf_descr ).

  " we do not do escaping of every single string value for white space characters,
  " but we do it on top, to replace multiple calls by 3 only, while we do not serialize
  " outlined/formatted JSON this shall not produce any harm
  REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>cr_lf          IN r_json WITH `\r\n`.
  REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>newline        IN r_json WITH `\n`.
  REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>horizontal_tab IN r_json WITH `\t`.
* REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>form_feed      IN r_json WITH `\f`.
* REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>backspace      IN r_json WITH `\b`.

  IF name IS NOT INITIAL AND ( compress EQ abap_false OR r_json IS NOT INITIAL ).
    CONCATENATE `"` name `":` r_json INTO r_json.
  ENDIF.
ENDMETHOD.


METHOD string_to_xstring.
  DATA: lv_xstring TYPE xstring.

  CALL FUNCTION 'SSFC_BASE64_DECODE'
    EXPORTING
      b64data = in
    IMPORTING
      bindata = lv_xstring
    EXCEPTIONS
      OTHERS  = 1.

  IF sy-subrc IS INITIAL.
    MOVE lv_xstring TO out.
  ELSE.
    MOVE in TO out.
  ENDIF.
ENDMETHOD.


METHOD xstring_to_string.
  DATA: lv_xstring TYPE xstring.

  " let us fix data conversion issues here
  lv_xstring = in.

  CALL FUNCTION 'SSFC_BASE64_ENCODE'
    EXPORTING
      bindata = lv_xstring
    IMPORTING
      b64data = out
    EXCEPTIONS
      OTHERS  = 1.

  IF sy-subrc IS NOT INITIAL.
    MOVE in TO out.
  ENDIF.
ENDMETHOD.
ENDCLASS.