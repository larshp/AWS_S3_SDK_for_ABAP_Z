class ZLNKECL_AWS_IAM definition
  public
  inheriting from ZLNKECL_AWS_INHERIT_SWITCH
  final
  create public .

*"* public components of class ZLNKECL_AWS_IAM
*"* do not include other source files here!!!
public section.

  constants C_SERVICE_NAME type STRING value 'iam'. "#EC NOTEXT
  constants C_API_VERSION type STRING value '2010-05-08'. "#EC NOTEXT

  methods CONSTRUCTOR
    importing
      !I_USER_NAME type ZLNKEUSERNAME_DE optional
      !I_ACCESS_KEY type STRING optional
      !I_SECRET_ACCESS_KEY type STRING optional
      !I_DBG type ABAP_BOOL default ABAP_FALSE .
  methods GET_USER
    exporting
      !E_HTTP_STATUS type I
      !E_RESPONSE_HEADERS type TIHTTPNVP
      !E_RESPONSE_CONTENT type STRING
    raising
      ZLNKECX_AWS_S3 .
  class-methods GET_HOST_NAME
    returning
      value(E_HOST_NAME) type STRING .
  class-methods CHECK_AWS_USER
    importing
      !I_USER_NAME type ZLNKEUSERNAME_DE
      !I_AWS_ACCOUNT_ID type ZLNKEAWS_ACCOUNT_ID_DE optional
      !I_ACCESS_KEY type ZLNKEACCKEY_DE
      !I_SECRET_ACCESS_KEY type ZLNKESECACCKEY_DE
    returning
      value(E_USER_ID) type STRING
    raising
      ZLNKECX_AWS_S3 .
protected section.
*"* protected components of class ZLNKECL_AWS_IAM
*"* do not include other source files here!!!
private section.
*"* private components of class ZLNKECL_AWS_IAM
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZLNKECL_AWS_IAM IMPLEMENTATION.


METHOD check_aws_user.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 30th April 2014
* Test AWS user
*--------------------------------------------------------------------*
  DATA: lr_ZLNKEcl_aws_iam TYPE REF TO ZLNKEcl_aws_iam.
  DATA: l_msg TYPE string.                                  "#EC NEEDED
  DATA: l_access_key_s TYPE string.
  DATA: l_secret_access_key_s TYPE string.
  DATA: l_http_status TYPE i.
  DATA: l_response_content TYPE string.
  DATA: l_err_msg TYPE string.
  DATA: l_arn TYPE string.
  DATA: l_aws_account_id TYPE string.
  DATA: lt_arn TYPE STANDARD TABLE OF string.

  l_access_key_s = i_access_key.
  l_secret_access_key_s = i_secret_access_key.

  CREATE OBJECT lr_ZLNKEcl_aws_iam
    EXPORTING
      i_user_name         = i_user_name
      i_access_key        = l_access_key_s
      i_secret_access_key = l_secret_access_key_s.

  CALL METHOD lr_ZLNKEcl_aws_iam->get_user
    IMPORTING
      e_http_status      = l_http_status
      e_response_content = l_response_content.

  IF l_http_status = ZLNKEcl_http=>c_status_200_ok.
    IF i_aws_account_id IS NOT INITIAL.
      l_arn = ZLNKEcl_xml_utils=>get_node_value_from_xmlstring( "#EC NOTEXT
                                  i_xml_string = l_response_content
                                  i_node_name = 'Arn' ).
*     ARN example: arn:aws:iam::111122223333:user/theuser
      SPLIT l_arn AT ':' INTO TABLE lt_arn.
      READ TABLE lt_arn INDEX 5 INTO l_aws_account_id.
      IF l_aws_account_id <> i_aws_account_id.
*       065	AWS Account ID does not match
        MESSAGE i065 INTO l_msg.
        ZLNKEcx_aws_s3=>raise_from_sy_msg( ).
      ENDIF.
    ENDIF.

    e_user_id = ZLNKEcl_xml_utils=>get_node_value_from_xmlstring( "#EC NOTEXT
                                i_xml_string = l_response_content
                                i_node_name = 'UserId' ).
  ELSE.
    l_err_msg = ZLNKEcl_xml_utils=>get_node_value_from_xmlstring( "#EC NOTEXT
                                i_xml_string = l_response_content
                                i_node_name = 'Message' ).
*   048	User validation failed: &
    MESSAGE i048 WITH space INTO l_msg.
    CONCATENATE l_msg l_err_msg INTO l_err_msg.
    ZLNKEcx_aws_s3=>raise_giving_string( l_err_msg ).
  ENDIF.

ENDMETHOD.


METHOD constructor.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 28th April 2014
* Object constructor
*--------------------------------------------------------------------*
  CALL METHOD super->constructor.

  attr_service_name = c_service_name.
  attr_user = i_user_name.
  attr_access_key = i_access_key.
  attr_secret_access_key = i_secret_access_key.
  attr_dbg = i_dbg.

ENDMETHOD.


METHOD get_host_name.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 17th July 2014
* Returns the hostname for IAM
*--------------------------------------------------------------------*
  CONCATENATE c_service_name
              '.'
              c_host_name
              INTO e_host_name.

ENDMETHOD.


METHOD get_user.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 28th April 2014
* Executes request to AWS get user
*--------------------------------------------------------------------*
  DATA: l_rfcddest TYPE rfcdest.
  DATA: l_request TYPE string.
  DATA: l_region_s TYPE string.
  DATA: l_response_xcontent TYPE xstring.

  l_region_s = c_default_region.
  l_rfcddest = ZLNKEcl_rfc_connections=>get_httpsdest_iam( ).

  CONCATENATE '/?Action=GetUser'
              '&UserName=' attr_user
              '&Version=' c_api_version
              INTO l_request.

  CALL METHOD rest
    EXPORTING
      i_rfcdest           = l_rfcddest
      i_region            = l_region_s
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
