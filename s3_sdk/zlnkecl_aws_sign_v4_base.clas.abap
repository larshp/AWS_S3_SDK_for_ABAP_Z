class ZLNKECL_AWS_SIGN_V4_BASE definition
  public
  abstract
  create public .

*"* public components of class ZLNKECL_AWS_SIGN_V4_BASE
*"* do not include other source files here!!!
public section.

  constants C_EMPTY_BODY_SHA256 type STRING value 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855'. "#EC NOTEXT

  methods CONSTRUCTOR
    importing
      !I_HTTP_REQUEST type ref to IF_HTTP_REQUEST
      !I_ENDPOINT_URL type STRING
      !I_HTTP_METHOD type STRING
      !I_SERVICE_NAME type STRING
      !I_REGION type STRING .
protected section.
*"* protected components of class ZLNKECL_AWS_SIGN_V4_BASE
*"* do not include other source files here!!!

  data LR_ATTR_HTTP_REQUEST type ref to CL_HTTP_REQUEST .
  constants C_SCHEME type STRING value 'AWS4'. "#EC NOTEXT
  constants C_ALGORITHM type STRING value 'HMAC-SHA256'. "#EC NOTEXT
  constants C_TERMINATOR type STRING value 'aws4_request'. "#EC NOTEXT
  data ATTR_SERVICE_NAME type STRING .
  data ATTR_REGION type STRING .

  methods GET_CANONICALIZEHEADERNAMES
    returning
      value(E_CANONICALIZEHEADERNAMES) type STRING .
  methods GET_CANONICALIZEDHEADERSTRING
    returning
      value(E_CANONICALIZEDHEADERSTRING) type STRING .
  methods GET_CANONICALREQUEST
    importing
      !I_CANONICALIZEDQUERYPARAMETERS type STRING
      !I_CANONICALIZEDHEADERNAMES type STRING
      !I_CANONICALIZEDHEADERS type STRING
      !I_BODYHASH type STRING
    returning
      value(E_CANONICALREQUEST) type STRING .
  methods GET_CANONICALIZEDQUERYSTRING
    returning
      value(E_CANONICALIZEDQUERYSTRING) type STRING .
  methods GET_STRINGTOSIGN
    importing
      !I_SCHEME type STRING
      !I_ALGORITHM type STRING
      !I_DATETIME type STRING
      !I_SCOPE type STRING
      !I_CANONICALREQUEST type STRING
    returning
      value(E_STRINGTOSIGN) type STRING
    raising
      CX_ABAP_MESSAGE_DIGEST .
  methods HMAC_SIGN_KSTRING
    importing
      !I_STRING type STRING
      !I_KEY type STRING
      !I_ALGORITHM type STRING default 'SHA256'
    returning
      value(E_SIGNATURE) type XSTRING
    raising
      CX_ABAP_MESSAGE_DIGEST .
  methods HMAC_SIGN_KXSTRING
    importing
      !I_STRING type STRING
      !I_XKEY type XSTRING
      !I_ALGORITHM type STRING default 'SHA256'
    returning
      value(E_SIGNATURE) type XSTRING
    raising
      CX_ABAP_MESSAGE_DIGEST .
  methods GET_TSTMP_ISO8601BASICFORMAT
    importing
      !I_DATE type DATUM default SY-DATUM
      !I_TIME type UZEIT default SY-UZEIT
    preferred parameter I_DATE
    returning
      value(E_TSTMP_ISO8601BASICFORMAT) type STRING .
  methods GET_HOST
    returning
      value(E_HOST) type STRING .
  methods GET_DATE_TIME_UTC
    exporting
      !E_DATE_UTC type DATS
      !E_TIME_UTC type TIMS .
private section.
*"* private components of class ZLNKECL_AWS_SIGN_V4_BASE
*"* do not include other source files here!!!

  data ATTR_ENDPOINT_URL type STRING .
  data ATTR_HTTP_METHOD type STRING .

  methods GET_CANONICALIZEDRESOURCEPATH
    returning
      value(E_CANONICALIZEDRESOURCEPATH) type STRING .
  type-pools ABAP .
  methods GET_HEADERNAMETOBEINCLUDED
    importing
      !I_HEADER_NAME type STRING
    returning
      value(E_HEADERNAMETOINCLUDE) type ABAP_BOOL .
ENDCLASS.



CLASS ZLNKECL_AWS_SIGN_V4_BASE IMPLEMENTATION.


METHOD CONSTRUCTOR.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 25th March 2014
* Object constructor
*--------------------------------------------------------------------*

  lr_attr_http_request ?= i_http_request.
  attr_endpoint_url = i_endpoint_url.
  attr_http_method = i_http_method.
  attr_service_name = i_service_name.
  attr_region = i_region.

ENDMETHOD.


METHOD GET_CANONICALIZEDHEADERSTRING.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 26th March 2014
* Returns the canonical header string
*--------------------------------------------------------------------*
  DATA: lt_ihttpnvp TYPE tihttpnvp.
  DATA: l_value_pair TYPE string.
  FIELD-SYMBOLS: <fs_ihttpnvp> TYPE ihttpnvp.

  lr_attr_http_request->get_header_fields(
       CHANGING fields =  lt_ihttpnvp ).

* Convert to lowercase the header names...
  LOOP AT lt_ihttpnvp ASSIGNING <fs_ihttpnvp>.
    TRANSLATE <fs_ihttpnvp>-name TO LOWER CASE.           "#EC SYNTCHAR
  ENDLOOP.
* ... and remove unwanted headers
  LOOP AT lt_ihttpnvp ASSIGNING <fs_ihttpnvp>.
    IF get_headernametobeincluded( <fs_ihttpnvp>-name ) = abap_false.
      DELETE lt_ihttpnvp INDEX sy-tabix.
    ENDIF.
  ENDLOOP.

* Sort header fields by name
  SORT lt_ihttpnvp BY name.

  LOOP AT lt_ihttpnvp ASSIGNING <fs_ihttpnvp>.
    CONDENSE <fs_ihttpnvp>-value.
    CONCATENATE <fs_ihttpnvp>-name
                <fs_ihttpnvp>-value
                INTO l_value_pair
                SEPARATED BY ':'.
    CONCATENATE e_canonicalizedheaderstring
                l_value_pair
                INTO e_canonicalizedheaderstring.
*   Adds LF
    CONCATENATE e_canonicalizedheaderstring
                cl_abap_char_utilities=>newline
                INTO e_canonicalizedheaderstring.
  ENDLOOP.

ENDMETHOD.


METHOD get_canonicalizedquerystring.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 26th March 2014
* Returns the canonical query string
*--------------------------------------------------------------------*
  TYPES: BEGIN OF typ_string_pair,
    name TYPE string,
    value TYPE string,
  END OF typ_string_pair.

  DATA: l_path TYPE string,                                 "#EC NEEDED
        l_parameters TYPE string.
  DATA: lt_parameters TYPE STANDARD TABLE OF string.
  DATA: lt_param_value TYPE STANDARD TABLE OF typ_string_pair,
        ls_param_value TYPE typ_string_pair.

  FIELD-SYMBOLS: <fs_parameter> TYPE string.

  SPLIT attr_endpoint_url AT '?' INTO l_path l_parameters.
  SPLIT l_parameters AT '&' INTO TABLE lt_parameters.

* Encode
  LOOP AT lt_parameters ASSIGNING <fs_parameter>.
    CLEAR ls_param_value.
    SPLIT <fs_parameter> AT '=' INTO ls_param_value-name
                                     ls_param_value-value.

    CALL METHOD cl_http_utility=>if_http_utility~escape_url
      EXPORTING
        unescaped = ls_param_value-name
      RECEIVING
        escaped   = ls_param_value-name.

    CALL METHOD cl_http_utility=>if_http_utility~escape_url
      EXPORTING
        unescaped = ls_param_value-value
      RECEIVING
        escaped   = ls_param_value-value.

    APPEND ls_param_value TO lt_param_value.
  ENDLOOP.

* According to http://docs.aws.amazon.com/AmazonS3/latest/API/sig-v4-header-based-auth.html
* the sorting occurs after encoding.
  SORT lt_param_value BY name.

  LOOP AT lt_param_value INTO ls_param_value.
    IF sy-tabix > 1.
      CONCATENATE e_canonicalizedquerystring
                  '&'
                  INTO e_canonicalizedquerystring.
    ENDIF.
    CONCATENATE e_canonicalizedquerystring
                ls_param_value-name
                '='
                ls_param_value-value
                INTO e_canonicalizedquerystring.
  ENDLOOP.

* We wish to have a . instead of %2e
  REPLACE ALL OCCURRENCES OF '%2e' IN e_canonicalizedquerystring WITH '.'.

ENDMETHOD.


METHOD get_canonicalizedresourcepath.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 26th March 2014
* Returns the canonical resource path
*--------------------------------------------------------------------*
  DATA: l_endpoint_url TYPE string,
        l_host TYPE string,                                 "#EC NEEDED
        l_parameters TYPE string,                           "#EC NEEDED
        l_resource TYPE string.

  l_endpoint_url = attr_endpoint_url.
  REPLACE 'http://' WITH space INTO l_endpoint_url.
  REPLACE 'https://' WITH space INTO l_endpoint_url.
  SPLIT l_endpoint_url AT '/' INTO l_host l_resource.

  IF l_resource IS INITIAL.
    e_canonicalizedresourcepath  = '/'.
  ELSE.
    SPLIT l_resource AT '?' INTO l_resource l_parameters.
    IF l_resource IS INITIAL.
*     Arrive here when l_resource is something like ?marker=myFile
      e_canonicalizedresourcepath = '/'.
    ELSE.
      e_canonicalizedresourcepath = l_resource.
      IF e_canonicalizedresourcepath(1) <> '/'.
        CONCATENATE '/'
                    e_canonicalizedresourcepath
                    INTO e_canonicalizedresourcepath.
      ENDIF.
    ENDIF.
  ENDIF.

ENDMETHOD.


METHOD GET_CANONICALIZEHEADERNAMES.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 26th March 2014
* Returns the canonical header names
*--------------------------------------------------------------------*
  DATA: lt_ihttpnvp TYPE tihttpnvp.
  FIELD-SYMBOLS: <fs_ihttpnvp> TYPE ihttpnvp.

  lr_attr_http_request->get_header_fields(
       CHANGING fields =  lt_ihttpnvp ).

* Convert to lowercase the header names...
  LOOP AT lt_ihttpnvp ASSIGNING <fs_ihttpnvp>.
    TRANSLATE <fs_ihttpnvp>-name TO LOWER CASE.           "#EC SYNTCHAR
  ENDLOOP.
* ... and remove unwanted headers
  LOOP AT lt_ihttpnvp ASSIGNING <fs_ihttpnvp>.
    IF get_headernametobeincluded( <fs_ihttpnvp>-name ) = abap_false.
      DELETE lt_ihttpnvp INDEX sy-tabix.
    ENDIF.
  ENDLOOP.

* Sort header fields by name
  SORT lt_ihttpnvp BY name.

  LOOP AT lt_ihttpnvp ASSIGNING <fs_ihttpnvp>.
    IF sy-tabix = 1.
      e_canonicalizeheadernames = <fs_ihttpnvp>-name.
    ELSE.
      CONCATENATE e_canonicalizeheadernames
                  <fs_ihttpnvp>-name
                  INTO e_canonicalizeheadernames
                  SEPARATED BY ';'.
    ENDIF.
  ENDLOOP.

ENDMETHOD.


METHOD GET_CANONICALREQUEST.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 26th March 2014
* Returns the canonical request
*--------------------------------------------------------------------*
  DATA: l_canonicalizedresourcepath TYPE string.

  l_canonicalizedresourcepath = get_canonicalizedresourcepath( ).

  CONCATENATE attr_http_method
              cl_abap_char_utilities=>newline
              l_canonicalizedresourcepath
              cl_abap_char_utilities=>newline
              i_canonicalizedqueryparameters
              cl_abap_char_utilities=>newline
              i_canonicalizedheaders
              cl_abap_char_utilities=>newline
              i_canonicalizedheadernames
              cl_abap_char_utilities=>newline
              i_bodyhash
              INTO e_canonicalrequest.

ENDMETHOD.


METHOD get_date_time_utc.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 30th July 2014
* Returns date and time UTC
*--------------------------------------------------------------------*

  DATA: l_timestamp TYPE timestamp.
  DATA: l_time_zone TYPE timezone.

  GET TIME STAMP FIELD l_timestamp.

  l_time_zone = 'UTC'.
  CONVERT TIME STAMP l_timestamp
          TIME ZONE l_time_zone
          INTO DATE e_date_utc TIME e_time_utc.

ENDMETHOD.


METHOD GET_HEADERNAMETOBEINCLUDED.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 26th March 2014
* Returns true for certain header names, according to
* http://docs.aws.amazon.com/AmazonS3/latest/API/sig-v4-header-based-auth.html
*--------------------------------------------------------------------*
  e_headernametoinclude = abap_false.
  IF i_header_name = 'host'
    OR i_header_name = 'content-type'
    OR i_header_name = 'content-md5'.
    e_headernametoinclude = abap_true.
  ELSE.
    IF STRLEN( i_header_name ) >= 6.
      IF  i_header_name(6) = 'x-amz-'.
        e_headernametoinclude = abap_true.
      ENDIF.
    ENDIF.
  ENDIF.
ENDMETHOD.


METHOD GET_HOST.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 26th March 2014
* Returns the hostname
*--------------------------------------------------------------------*
  DATA: l_path TYPE string,
        l_parameters TYPE string,                           "#EC NEEDED
        l_resource TYPE string.                             "#EC NEEDED

  SPLIT attr_endpoint_url AT '?' INTO l_path l_parameters.
  REPLACE 'http://' WITH space INTO l_path.
  REPLACE 'https://' WITH space INTO l_path.
  SPLIT l_path AT '/' INTO e_host l_resource.

  CONDENSE e_host.

ENDMETHOD.


METHOD get_stringtosign.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 26th March 2014
* Returns the string to sign
*--------------------------------------------------------------------*
  DATA: l_hash_canonicalrequest TYPE string.

  l_hash_canonicalrequest = ZLNKEcl_hash=>hash_sha256_for_char(
                                           i_canonicalrequest ).

  CONCATENATE i_scheme '-' i_algorithm
              cl_abap_char_utilities=>newline
              i_datetime
              cl_abap_char_utilities=>newline
              i_scope
              cl_abap_char_utilities=>newline
              l_hash_canonicalrequest
              INTO e_stringtosign.

ENDMETHOD.


METHOD GET_TSTMP_ISO8601BASICFORMAT.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 26th March 2014
* Given a date and time returns a Timestamp in ISO8601 Basic Format
*--------------------------------------------------------------------*

  CONCATENATE i_date 'T' i_time 'Z' INTO e_tstmp_iso8601basicformat.

ENDMETHOD.


METHOD HMAC_SIGN_KSTRING.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 26th March 2014
* Calculates HMAC-SHA256 given a string and a key as string
*--------------------------------------------------------------------*
  DATA: l_xkey TYPE xstring.

  CALL METHOD cl_abap_hmac=>string_to_xstring
    EXPORTING
      if_input  = i_key
    RECEIVING
      er_output = l_xkey.

  CALL METHOD cl_abap_hmac=>calculate_hmac_for_char
    EXPORTING
      if_algorithm   = i_algorithm
      if_key         = l_xkey
      if_data        = i_string
    IMPORTING
      ef_hmacxstring = e_signature.

ENDMETHOD.


METHOD HMAC_SIGN_KXSTRING.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 26th March 2014
* Calculates HMAC-SHA256 given a string and a key as xstring
*--------------------------------------------------------------------*

  CALL METHOD cl_abap_hmac=>calculate_hmac_for_char
    EXPORTING
      if_algorithm   = i_algorithm
      if_key         = i_xkey
      if_data        = i_string
    IMPORTING
      ef_hmacxstring = e_signature.

ENDMETHOD.
ENDCLASS.
