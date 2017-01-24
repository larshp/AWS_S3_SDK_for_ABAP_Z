class ZLNKECL_AWS_S3 definition
  public
  inheriting from ZLNKECL_AWS_INHERIT_SWITCH
  create public .

*"* public components of class ZLNKECL_AWS_S3
*"* do not include other source files here!!!
public section.

  constants C_SERVICE_NAME type STRING value 's3'. "#EC NOTEXT

  type-pools ABAP .
  methods CONSTRUCTOR
    importing
      !I_USER_NAME type ZLNKEUSERNAME_DE optional
      !I_CREATE type ABAP_BOOL default ABAP_FALSE
      !I_DBG type ABAP_BOOL default ABAP_FALSE
    raising
      ZLNKECX_AWS_S3 .
  methods GET_SERVICE
    exporting
      !E_HTTP_STATUS type I
      !E_RESPONSE_HEADERS type TIHTTPNVP
      !E_RESPONSE_CONTENT type STRING
    raising
      ZLNKECX_AWS_S3 .
  class-methods GET_HOST_NAME
    returning
      value(E_HOST_NAME) type STRING .
protected section.
*"* protected components of class ZLNKECL_AWS_S3
*"* do not include other source files here!!!
private section.
*"* private components of class ZLNKECL_AWS_S3
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZLNKECL_AWS_S3 IMPLEMENTATION.


METHOD constructor.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 9th April 2014
* Object constructor
*--------------------------------------------------------------------*
  DATA: l_destination_exists TYPE abap_bool.
  DATA: l_region TYPE ZLNKEregion_de.
  DATA: l_msg TYPE string.                                  "#EC NEEDED
  DATA: l_tabname TYPE tabname.

  CALL METHOD super->constructor.

  attr_service_name = c_service_name.

* Parameter i_create is true when bucket creation
  CHECK i_create = abap_false.

  attr_user = i_user_name.
  attr_dbg = i_dbg.

* For SaaS credentials are not coming from ZLNKEuser
  IF running_as_saas( ) = abap_false.
*   Get keys from user
    SELECT SINGLE access_key secr_access_key aws_account_id
           INTO (attr_access_key, attr_secret_access_key, attr_aws_account_id)
    FROM ZLNKEuser
    WHERE user_name = i_user_name.

    IF sy-subrc <> 0.
*     020	AWS S3 User & not found
      MESSAGE i020 WITH i_user_name INTO l_msg.
      ZLNKEcx_aws_s3=>raise_from_sy_msg( ).
    ENDIF.
  ELSE.
*   Is SaaS.
*   Avoid syntax error in case Stand-alone (table ZLNKEACTIV_CODE is not delivered)
    l_tabname = 'ZLNKEACTIV_CODE'.
    TRY.
*       Get the aws account ID
        SELECT SINGLE aws_account_id                        "#EC *
           INTO attr_aws_account_id
          FROM (l_tabname).
      CATCH cx_sy_dynamic_osql_semantics.
*       Should not happen!
*       078	Table & not found
        MESSAGE i078 WITH l_tabname INTO l_msg.
        ZLNKEcx_aws_s3=>raise_from_sy_msg( ).
    ENDTRY.
  ENDIF.

* Checks if HTTP to ext destination exists
  l_region = c_default_region.
  CALL METHOD ZLNKEcl_rfc_connections=>http_dest_to_ext_exists_region
    EXPORTING
      i_region             = l_region
    RECEIVING
      e_destination_exists = l_destination_exists.

  IF l_destination_exists = abap_false.
*   HTTP to ext destination does not exist. Create it.
    CALL METHOD ZLNKEcl_rfc_connections=>create_http_dest_to_ext_region
      EXPORTING
        i_region = l_region.
  ENDIF.

ENDMETHOD.


METHOD get_host_name.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 17th July 2014
* Returns the hostname for S3
*--------------------------------------------------------------------*
  CONCATENATE c_service_name
              '.'
              c_host_name
              INTO e_host_name.
ENDMETHOD.


METHOD get_service.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 15th April 2014
* Executes request to AWS S3 to get service
*--------------------------------------------------------------------*
  DATA: l_rfcddest TYPE rfcdest.
  DATA: l_request TYPE string.
  DATA: l_region TYPE ZLNKEregion_de.
  DATA: l_response_xcontent TYPE xstring.

  l_region = c_default_region.
  l_rfcddest = ZLNKEcl_rfc_connections=>get_httpdest_by_region(
                                                    l_region ).

  l_request = '/'.

  CALL METHOD rest
    EXPORTING
      i_rfcdest           = l_rfcddest
      i_region            = c_default_region
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
