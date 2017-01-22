class ZLNKECL_AWS_REST definition
  public
  abstract
  create public .

*"* public components of class ZLNKECL_AWS_REST
*"* do not include other source files here!!!
public section.
protected section.
*"* protected components of class ZLNKECL_AWS_REST
*"* do not include other source files here!!!

  data ATTR_USER type STRING .
  data ATTR_ACCESS_KEY type STRING .
  data ATTR_SECRET_ACCESS_KEY type STRING .
  type-pools ABAP .
  data ATTR_DBG type ABAP_BOOL .
  data ATTR_SERVICE_NAME type STRING .
  data ATTR_AWS_ACCOUNT_ID type STRING .

  methods REST
    importing
      !I_RFCDEST type RFCDEST
      !I_BUCKET_NAME type STRING optional
      !I_REGION type STRING
      !I_HTTP_METHOD type STRING
      !I_REQUEST type STRING
      !I_BODY_HASH type STRING
      !I_XCONTENT type XSTRING optional
      !I_REQUEST_HEADERS type TIHTTPNVP optional
    exporting
      !E_HTTP_STATUS type I
      !E_RESPONSE_HEADERS type TIHTTPNVP
      !E_RESPONSE_XCONTENT type XSTRING
    raising
      ZLNKECX_AWS_S3 .
  methods REST_NO_SIGN
    importing
      !I_RFCDEST type RFCDEST
      !I_BUCKET_NAME type STRING optional
      !I_REGION type STRING
      !I_HTTP_METHOD type STRING
      !I_REQUEST type STRING
      !I_BODY_HASH type STRING
      !I_XCONTENT type XSTRING optional
      !I_REQUEST_HEADERS type TIHTTPNVP optional
    exporting
      !E_HTTP_STATUS type I
      !E_RESPONSE_HEADERS type TIHTTPNVP
      !E_RESPONSE_XCONTENT type XSTRING
    raising
      ZLNKECX_AWS_S3 .
  methods CLASS_GET_NAME
    returning
      value(E_CLASS_NAME) type STRING .
private section.
*"* private components of class ZLNKECL_AWS_REST
*"* do not include other source files here!!!

  constants C_HOST_NAME type STRING value 'amazonaws.com'. "#EC NOTEXT
  data ATTR_R_HTTP_CLIENT type ref to IF_HTTP_CLIENT .

  methods REST_PRIV
    importing
      !I_RFCDEST type RFCDEST
      !I_BUCKET_NAME type STRING optional
      !I_REGION type STRING
      !I_HTTP_METHOD type STRING
      !I_REQUEST type STRING
      !I_BODY_HASH type STRING
      !I_XCONTENT type XSTRING optional
      !I_REQUEST_HEADERS type TIHTTPNVP optional
      !I_NO_SIGN type ABAP_BOOL default ABAP_FALSE
    exporting
      !E_HTTP_STATUS type I
      !E_RESPONSE_HEADERS type TIHTTPNVP
      !E_RESPONSE_XCONTENT type XSTRING
    raising
      ZLNKECX_AWS_S3 .
  methods DBG_WRITE_REQUEST_HEADERS .
  methods DBG_WRITE_RESPONSE_HEADERS .
ENDCLASS.



CLASS ZLNKECL_AWS_REST IMPLEMENTATION.


METHOD class_get_name.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 14th May 2014
* Returns own class name
*--------------------------------------------------------------------*

  e_class_name = 'ZLNKECL_AWS_REST'.

ENDMETHOD.


METHOD dbg_write_request_headers.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 28th March 2014
* Just for development, writes request headers
*--------------------------------------------------------------------*
  DATA: lt_ihttpnvp TYPE tihttpnvp,
        ls_ihttpnvp TYPE ihttpnvp.

  CHECK attr_dbg = abap_true.

  WRITE:/ 'Request headers:'.                               "#EC NOTEXT
  attr_r_http_client->request->get_header_fields(
                      CHANGING fields =  lt_ihttpnvp ).
  LOOP AT lt_ihttpnvp INTO ls_ihttpnvp.
    WRITE:/ ls_ihttpnvp-name,
            ':',
            ls_ihttpnvp-value.
  ENDLOOP.
  WRITE:/.
ENDMETHOD.


METHOD dbg_write_response_headers.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 28th March 2014
* Just for development, writes response headers
*--------------------------------------------------------------------*
  DATA: lt_ihttpnvp TYPE tihttpnvp,
        ls_ihttpnvp TYPE ihttpnvp.

  CHECK attr_dbg = abap_true.

  WRITE:/.
  WRITE:/ 'Response headers:'.                              "#EC NOTEXT
  attr_r_http_client->response->get_header_fields(
                      CHANGING fields =  lt_ihttpnvp ).
  LOOP AT lt_ihttpnvp INTO ls_ihttpnvp.
    WRITE:/ ls_ihttpnvp-name,
            ':',
            ls_ihttpnvp-value.
  ENDLOOP.
  WRITE:/.
ENDMETHOD.


METHOD rest.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 15th April 2014
* Executes requests to AWS S3
*--------------------------------------------------------------------*
  DATA: lr_ZLNKEcx_aws_s3 TYPE REF TO ZLNKEcx_aws_s3.

  TRY.
      CALL METHOD rest_priv
        EXPORTING
          i_rfcdest           = i_rfcdest
          i_bucket_name       = i_bucket_name
          i_region            = i_region
          i_http_method       = i_http_method
          i_request           = i_request
          i_body_hash         = i_body_hash
          i_xcontent          = i_xcontent
          i_request_headers   = i_request_headers
          i_no_sign           = abap_false
        IMPORTING
          e_http_status       = e_http_status
          e_response_headers  = e_response_headers
          e_response_xcontent = e_response_xcontent.

    CATCH ZLNKEcx_aws_s3 INTO lr_ZLNKEcx_aws_s3.

      ZLNKEcl_log=>append_log_resp_from_aws(
                         i_http_response = attr_r_http_client->response
                         i_xresponse = e_response_xcontent
                         i_exception = lr_ZLNKEcx_aws_s3 ).

      CALL METHOD attr_r_http_client->close( ).

      RAISE EXCEPTION lr_ZLNKEcx_aws_s3.
  ENDTRY.

  ZLNKEcl_log=>append_log_resp_from_aws(
                     i_http_response = attr_r_http_client->response
                     i_xresponse = e_response_xcontent ).

  CALL METHOD attr_r_http_client->close( ).

ENDMETHOD.


METHOD rest_no_sign.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 18th July 2014
* Executes requests to AWS S3 without signing
*--------------------------------------------------------------------*
  DATA: lr_ZLNKEcx_aws_s3 TYPE REF TO ZLNKEcx_aws_s3.

  TRY.
      CALL METHOD rest_priv
        EXPORTING
          i_rfcdest           = i_rfcdest
          i_bucket_name       = i_bucket_name
          i_region            = i_region
          i_http_method       = i_http_method
          i_request           = i_request
          i_body_hash         = i_body_hash
          i_xcontent          = i_xcontent
          i_request_headers   = i_request_headers
          i_no_sign           = abap_true
        IMPORTING
          e_http_status       = e_http_status
          e_response_headers  = e_response_headers
          e_response_xcontent = e_response_xcontent.

    CATCH ZLNKEcx_aws_s3 INTO lr_ZLNKEcx_aws_s3.

      ZLNKEcl_log=>append_log_resp_from_aws(
                         i_http_response = attr_r_http_client->response
                         i_xresponse = e_response_xcontent
                         i_exception = lr_ZLNKEcx_aws_s3 ).

      CALL METHOD attr_r_http_client->close( ).

      RAISE EXCEPTION lr_ZLNKEcx_aws_s3.
  ENDTRY.

  ZLNKEcl_log=>append_log_resp_from_aws(
                     i_http_response = attr_r_http_client->response
                     i_xresponse = e_response_xcontent ).

  CALL METHOD attr_r_http_client->close( ).

ENDMETHOD.


METHOD rest_priv.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 28th March 2014
* Executes requests to AWS S3
*--------------------------------------------------------------------*
  DATA: l_uri TYPE string.
  DATA: l_exception_text TYPE string.
  DATA: l_c_content_length TYPE string.
  DATA: l_host_name TYPE string.
  DATA: lt_request_headers TYPE tihttpnvp.
  DATA: ls_header TYPE ihttpnvp.
  DATA: lr_ZLNKEcl_aws_sign_v4_header TYPE REF TO ZLNKEcl_aws_sign_v4_header.
  DATA: lr_abap_message_digest TYPE REF TO cx_abap_message_digest.

* Creates HTTP Client
  FREE attr_r_http_client.
  CALL METHOD cl_http_client=>create_by_destination
    EXPORTING
      destination              = i_rfcdest
    IMPORTING
      client                   = attr_r_http_client
    EXCEPTIONS
      argument_not_found       = 1
      destination_not_found    = 2
      destination_no_authority = 3
      plugin_not_active        = 4
      internal_error           = 5
      OTHERS                   = 6.

  IF sy-subrc <> 0.
    ZLNKEcx_aws_s3=>raise_from_sy_msg( ).
  ENDIF.

* Sets HTTP Method
  CALL METHOD attr_r_http_client->request->set_method(
    i_http_method ).

* Builds the URI
  IF attr_service_name = ZLNKEcl_aws_s3=>c_service_name
    AND i_bucket_name IS NOT INITIAL.
    l_host_name = ZLNKEcl_aws_s3=>get_host_name( ).
    CONCATENATE 'https://'
                i_bucket_name
                '.'
                l_host_name
                i_request
                INTO l_uri.
  ELSEIF attr_service_name = ZLNKEcl_aws_s3=>c_service_name.
    l_host_name = ZLNKEcl_aws_s3=>get_host_name( ).
    CONCATENATE 'https://'
                l_host_name
                i_request
                INTO l_uri.
  ELSEIF attr_service_name = ZLNKEcl_aws_iam=>c_service_name.
    CONCATENATE 'https://'
                attr_service_name
                '.'
                c_host_name
                i_request
                INTO l_uri.
  ELSEIF attr_service_name = ZLNKEcl_aws_sqs=>c_service_name.
    CONCATENATE 'https://'
                attr_service_name
                '.'
                i_region
                '.'
                c_host_name
                i_request
                INTO l_uri.
  ENDIF.

  cl_http_utility=>set_request_uri(
                   request = attr_r_http_client->request
                   uri     = l_uri ).

* Adds request headers if they are specified in the call
  attr_r_http_client->request->get_header_fields(
                      CHANGING fields =  lt_request_headers ).
  LOOP AT i_request_headers INTO ls_header.
    READ TABLE lt_request_headers WITH KEY name = ls_header-name
                                  TRANSPORTING NO FIELDS.
    IF sy-subrc <> 0.
      attr_r_http_client->request->set_header_field( name = ls_header-name
                                                     value = ls_header-value ).
    ENDIF.
  ENDLOOP.

  IF i_no_sign = abap_false.
*   Builds Signture object
    CREATE OBJECT lr_ZLNKEcl_aws_sign_v4_header
      EXPORTING
        i_http_request = attr_r_http_client->request
        i_endpoint_url = l_uri
        i_http_method  = i_http_method
        i_service_name = attr_service_name
        i_region       = i_region.

    TRY.
*       Signs the request
        CALL METHOD lr_ZLNKEcl_aws_sign_v4_header->computesignature
          EXPORTING
            i_body_hash      = i_body_hash
            i_aws_access_key = attr_access_key
            i_aws_secret_key = attr_secret_access_key.
      CATCH cx_abap_message_digest INTO lr_abap_message_digest.
        RAISE EXCEPTION TYPE ZLNKEcx_aws_s3
                   EXPORTING previous = lr_abap_message_digest.
    ENDTRY.
  ENDIF.

* Sets data
  IF i_xcontent IS NOT INITIAL.
    attr_r_http_client->request->set_data( i_xcontent ).

*   Header Content-Length
    l_c_content_length = XSTRLEN( i_xcontent ).
    attr_r_http_client->request->set_header_field( name  = 'Content-Length' "#EC NOTEXT
                                            value = l_c_content_length ).

* Jordi, 18/9/2014.
* Comentado, no poner!. Con HTTPS daba fallo intermitente al hacer el put de ficheros.
* Cuando fallaba, AWS cortaba la conexión y daba el mensaje
* "Your socket connection to the server was not read from or written to within
*     the timeout period. Idle connections will be closed".
* El motivo era que S3 esperaba bytes que no llegaban.
*   Header Expect
*    attr_r_http_client->request->set_header_field( name  = 'Expect' "#EC NOTEXT
*                                            value = '100-continue' ).
  ENDIF.

  dbg_write_request_headers( ).
*  DATA: l_request_content TYPE string.
*  l_request_content = attr_r_http_client->request->get_cdata( ).
*  WRITE:/ l_request_content.

* Saves request to log
  ZLNKEcl_log=>append_log_req_to_aws(
              i_http_request =  attr_r_http_client->request
              i_request = i_request ).

  CALL METHOD attr_r_http_client->send
    EXCEPTIONS
      http_communication_failure = 1
      http_invalid_state         = 2
      http_processing_failed     = 3
      OTHERS                     = 4.

  IF sy-subrc <> 0.
    CLEAR l_exception_text.
    CALL METHOD attr_r_http_client->get_last_error
      IMPORTING
        message = l_exception_text.
*   Limit the length of the message
    IF STRLEN( l_exception_text ) > 255.
      l_exception_text = l_exception_text(255).
      CONCATENATE l_exception_text
                  '...'
                  INTO l_exception_text.
    ENDIF.

*   023	HTTP Send error (&amp;)
    MESSAGE i023 WITH l_exception_text INTO l_exception_text.
    ZLNKEcx_aws_s3=>raise_from_sy_msg( ).
  ENDIF.

  CALL METHOD attr_r_http_client->receive
    EXCEPTIONS
      http_communication_failure = 1
      http_invalid_state         = 2
      http_processing_failed     = 3
      OTHERS                     = 4.

  IF sy-subrc <> 0.
    CLEAR l_exception_text.
    CALL METHOD attr_r_http_client->get_last_error
      IMPORTING
        message = l_exception_text.
*   Limit the length of the message
    IF STRLEN( l_exception_text ) > 255.
      l_exception_text = l_exception_text(255).
      CONCATENATE l_exception_text
                  '...'
                  INTO l_exception_text.
    ENDIF.

*   024	HTTP Receive error (&amp;)
    MESSAGE i024 WITH l_exception_text INTO l_exception_text.
    ZLNKEcx_aws_s3=>raise_from_sy_msg( ).
  ENDIF.

* Returns response header fields
  attr_r_http_client->response->get_header_fields(
                      CHANGING fields = e_response_headers[] ).

  dbg_write_response_headers( ).

  TRY.
      e_http_status = attr_r_http_client->response->get_header_field( '~status_code' ).
    CATCH cx_sy_conversion_no_number.
*     Should never happen!
*     024	HTTP Receive error (&amp;)
      l_exception_text = 'cx_sy_conversion_no_number'.
      MESSAGE i024 WITH l_exception_text INTO l_exception_text.
      ZLNKEcx_aws_s3=>raise_from_sy_msg( ).
  ENDTRY.
  e_response_xcontent = attr_r_http_client->response->get_data( ).
ENDMETHOD.
ENDCLASS.
