class ZLNKECL_AWS_SIGN_V4_HEADER definition
  public
  inheriting from ZLNKECL_AWS_SIGN_V4_BASE
  final
  create public .

*"* public components of class ZLNKECL_AWS_SIGN_V4_HEADER
*"* do not include other source files here!!!
public section.

  methods CONSTRUCTOR
    importing
      !I_HTTP_REQUEST type ref to IF_HTTP_REQUEST
      !I_ENDPOINT_URL type STRING
      !I_HTTP_METHOD type STRING
      !I_SERVICE_NAME type STRING default 's3'
      !I_REGION type STRING .
  methods COMPUTESIGNATURE
    importing
      !I_BODY_HASH type STRING
      !I_AWS_ACCESS_KEY type STRING
      !I_AWS_SECRET_KEY type STRING
    raising
      CX_ABAP_MESSAGE_DIGEST .
protected section.
*"* protected components of class ZLNKECL_AWS_SIGN_V4_HEADER
*"* do not include other source files here!!!
private section.
*"* private components of class ZLNKECL_AWS_SIGN_V4_HEADER
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZLNKECL_AWS_SIGN_V4_HEADER IMPLEMENTATION.


METHOD computesignature.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 26th March 2014
* Signs the http_request adding to the header the required data
*--------------------------------------------------------------------*
  DATA: l_date TYPE datum,
        l_time TYPE uzeit.
  DATA: l_x_amz_date TYPE string,
        l_datestmp TYPE string.
  DATA: l_host TYPE string.
  DATA: l_canonicalizedheadernames TYPE string.
  DATA: l_canonicalizedheaders TYPE string.
  DATA: l_canonicalizedqueryparameters TYPE string.
  DATA: l_canonicalrequest TYPE string.
  DATA: l_scope TYPE string.
  DATA: l_stringtosign TYPE string.
  DATA: l_ksecret TYPE string,
        l_signature TYPE string.
  DATA: l_xkdate TYPE xstring,
        l_xkregion TYPE xstring,
        l_xkservice TYPE xstring,
        l_xksigning TYPE xstring,
        l_xsignature TYPE xstring.
  DATA: l_authorizationheader TYPE string.

  lr_attr_http_request->set_header_field( name  = 'x-amz-content-sha256' "#EC NOTEXT
                                          value = i_body_hash ).

  get_date_time_utc( IMPORTING e_date_utc = l_date
                               e_time_utc = l_time ).

  l_x_amz_date = get_tstmp_iso8601basicformat(
                    i_date = l_date
                    i_time = l_time ).

  lr_attr_http_request->set_header_field( name  = 'x-amz-date' "#EC NOTEXT
                                          value = l_x_amz_date ).

  l_host = get_host( ).
  lr_attr_http_request->set_header_field( name  = 'Host'    "#EC NOTEXT
                                          value = l_host ).

  l_canonicalizedheadernames = get_canonicalizeheadernames( ).

  l_canonicalizedheaders = get_canonicalizedheaderstring( ).

  l_canonicalizedqueryparameters = get_canonicalizedquerystring( ).

*  WRITE:/ 'Canonicalized Query Parameters:'.
*  WRITE:/ l_canonicalizedqueryparameters.

  l_canonicalrequest = get_canonicalrequest(
      i_canonicalizedqueryparameters = l_canonicalizedqueryparameters
      i_canonicalizedheadernames     = l_canonicalizedheadernames
      i_canonicalizedheaders         = l_canonicalizedheaders
      i_bodyhash                     = i_body_hash ).

* Builds the scope
  CONCATENATE l_date
              attr_region
              attr_service_name
              c_terminator
              INTO l_scope SEPARATED BY '/'.

  l_stringtosign = get_stringtosign(
                       i_scheme           = c_scheme
                       i_algorithm        = c_algorithm
                       i_datetime         = l_x_amz_date
                       i_scope            = l_scope
                       i_canonicalrequest = l_canonicalrequest ).

*  WRITE:/ 'Canonical Request:'.
*  WRITE:/ l_canonicalrequest.
*  WRITE:/ 'String to sign:'.
*  WRITE:/ l_stringtosign.
*  WRITE:/.

  CONCATENATE c_scheme i_aws_secret_key INTO l_ksecret.
  l_datestmp = l_date.
  l_xkdate = hmac_sign_kstring( i_string = l_datestmp
                                i_key = l_ksecret ).
  l_xkregion = hmac_sign_kxstring( i_string = attr_region
                                   i_xkey = l_xkdate ).
  l_xkservice = hmac_sign_kxstring( i_string = attr_service_name
                                    i_xkey = l_xkregion ).
  l_xksigning = hmac_sign_kxstring( i_string = c_terminator
                                    i_xkey = l_xkservice ).
  l_xsignature = hmac_sign_kxstring( i_string = l_stringtosign
                                     i_xkey = l_xksigning ).
  l_signature = l_xsignature.
  TRANSLATE l_signature TO LOWER CASE.

  CONCATENATE c_scheme '-' c_algorithm ' '                  "#EC NOTEXT
              'Credential='
              i_aws_access_key
              '/'
              l_scope
              ', '
              'SignedHeaders='
              l_canonicalizedheadernames
              ', '
              'Signature='
              l_signature
              INTO l_authorizationheader RESPECTING BLANKS.

  lr_attr_http_request->set_header_field( name  = 'Authorization' "#EC NOTEXT
                                          value = l_authorizationheader ).

ENDMETHOD.


METHOD CONSTRUCTOR.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 26th March 2014
* Object constructor
*--------------------------------------------------------------------*
  CALL METHOD super->constructor
    EXPORTING
      i_http_request = i_http_request
      i_endpoint_url = i_endpoint_url
      i_http_method  = i_http_method
      i_service_name = i_service_name
      i_region       = i_region.

ENDMETHOD.
ENDCLASS.
