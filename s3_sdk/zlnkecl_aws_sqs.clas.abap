class ZLNKECL_AWS_SQS definition
  public
  inheriting from ZLNKECL_AWS_INHERIT_SWITCH
  final
  create public .

*"* public components of class ZLNKECL_AWS_SQS
*"* do not include other source files here!!!
public section.

  constants C_SERVICE_NAME type STRING value 'sqs'. "#EC NOTEXT

  type-pools ABAP .
  methods CONSTRUCTOR
    importing
      !I_ACCESS_KEY type STRING optional
      !I_SECRET_ACCESS_KEY type STRING optional
      !I_REGION type STRING optional
      !I_AWS_ACCOUNT_ID type STRING
      !I_DBG type ABAP_BOOL default ABAP_FALSE
    preferred parameter I_REGION .
  methods SEND_MESSAGE
    exporting
      !E_HTTP_STATUS type I
      !E_RESPONSE_HEADERS type TIHTTPNVP
      !E_RESPONSE_CONTENT type STRING
    raising
      ZLNKECX_AWS_S3 .
protected section.
*"* protected components of class ZLNKECL_AWS_SQS
*"* do not include other source files here!!!
private section.
*"* private components of class ZLNKECL_AWS_SQS
*"* do not include other source files here!!!

  constants C_QUEUE_NAME type STRING value 'RocketSteamS4LicenseServer_In'. "#EC NOTEXT
  data ATTR_REGION type STRING .
ENDCLASS.



CLASS ZLNKECL_AWS_SQS IMPLEMENTATION.


METHOD constructor.

  super->constructor( ).

  attr_access_key = i_access_key.
  attr_secret_access_key = i_secret_access_key.

  attr_service_name = c_service_name.

  IF i_region IS INITIAL.
    attr_region = c_default_region.
  ELSE.
    attr_region = i_region.
  ENDIF.

  attr_aws_account_id = i_aws_account_id.
  attr_dbg = i_dbg.

ENDMETHOD.


METHOD send_message.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 18th July 2014
* Test for a public SQS
*--------------------------------------------------------------------*
  DATA: l_rfcddest TYPE rfcdest.
  DATA: l_request TYPE string.
  DATA: l_response_xcontent TYPE xstring.

  l_rfcddest = 'RS3_SQS_IN'.

  CONCATENATE '/'
              attr_aws_account_id
              '/'
              c_queue_name
              '/?Action=SendMessage'
              '&MessageBody=HelloWorld'
              INTO l_request.

  CALL METHOD rest_no_sign
    EXPORTING
      i_rfcdest           = l_rfcddest
      i_region            = attr_region
      i_http_method       = ZLNKEcl_http=>c_method_get
      i_request           = l_request
      i_body_hash         = ZLNKEcl_hash=>c_empty_body_sha256
    IMPORTING
      e_http_status       = e_http_status
      e_response_headers  = e_response_headers
      e_response_xcontent = l_response_xcontent.

  CALL METHOD ZLNKEcl_string_conversions=>xstring_to_string
    EXPORTING
      input  = l_response_xcontent
    IMPORTING
      output = e_response_content.

ENDMETHOD.
ENDCLASS.
