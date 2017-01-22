class ZLNKECL_RFC_CONNECTIONS definition
  public
  final
  create private .

*"* public components of class ZLNKECL_RFC_CONNECTIONS
*"* do not include other source files here!!!
public section.
  type-pools ABAP .

  constants C_RFC_TYPE_HTTP_TO_EXT type RFCTYPE_D value 'G'. "#EC NOTEXT
  constants C_LIC_SERVER_ENDPOINT type RFCHOST_EXT value 'lics4.rocket-steam.com'. "#EC NOTEXT

  class-methods CREATE_HTTP_DEST_TO_EXT_REGION
    importing
      !I_REGION type ZLNKEREGION_DE
    raising
      ZLNKECX_AWS_S3 .
  class-methods DELETE_HTTP_DEST_TO_EXT_REGION
    importing
      !I_REGION type ZLNKEREGION_DE
    raising
      ZLNKECX_AWS_S3 .
  class-methods GET_HTTPDEST_BY_REGION
    importing
      !I_REGION type ZLNKEREGION_DE
    returning
      value(E_RFCDEST) type RFCDEST .
  class-methods HTTP_DEST_TO_EXT_EXISTS_REGION
    importing
      !I_REGION type ZLNKEREGION_DE
    returning
      value(E_DESTINATION_EXISTS) type ABAP_BOOL
    raising
      ZLNKECX_AWS_S3 .
  class-methods CREATE_HTTP_DEST_TO_EXT_IAM
    raising
      ZLNKECX_AWS_S3 .
  class-methods GET_HTTPSDEST_IAM
    returning
      value(E_RFCDEST) type RFCDEST .
  class-methods HTTP_DEST_EXISTS_LIC_SERVER
    returning
      value(E_DESTINATION_EXISTS) type ABAP_BOOL
    raising
      ZLNKECX_AWS_S3 .
  class-methods HTTP_DEST_TO_EXT_EXISTS_IAM
    returning
      value(E_DESTINATION_EXISTS) type ABAP_BOOL
    raising
      ZLNKECX_AWS_S3 .
  class-methods CREATE_HTTP_DEST_LIC_SERVER
    raising
      ZLNKECX_AWS_S3 .
  class-methods GET_HTTPDEST_LIC_SERVER
    returning
      value(E_RFCDEST) type RFCDEST .
protected section.
*"* protected components of class ZLNKECL_RFC_CONNECTIONS
*"* do not include other source files here!!!
private section.
*"* private components of class ZLNKECL_RFC_CONNECTIONS
*"* do not include other source files here!!!

  constants C_ACTION_DELETE type RFCDISPLAY-RFCTRACE value 'D'. "#EC NOTEXT
  constants C_ACTION_CREATE type RFCDISPLAY-RFCTRACE value 'I'. "#EC NOTEXT
  constants C_HTTP_PORT type RFCDISPLAY-RFCSYSID value '80'. "#EC NOTEXT
  constants C_HTTPS_PORT type RFCDISPLAY-RFCSYSID value '443'. "#EC NOTEXT
  constants C_HTTPDEST_PREFIX type CHAR10 value 'RS3_HTTP_'. "#EC NOTEXT
  constants C_LIC_SERVER_RFCDEST_SUFFIX type RFCDEST value 'S4_LICENSE_SERVER'. "#EC NOTEXT
ENDCLASS.



CLASS ZLNKECL_RFC_CONNECTIONS IMPLEMENTATION.


METHOD create_http_dest_lic_server.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 26th May 2014
* Creates HTTP to EXT destination for the license server endpoint
*--------------------------------------------------------------------*
  DATA: l_description TYPE  rfcdoc-rfcdoc1.
  DATA: l_rfcdest TYPE rfcdest.

  CONCATENATE c_httpdest_prefix
              c_lic_server_rfcdest_suffix
              INTO l_rfcdest.

  l_description = 'Generated RocketSteam. Endpoint for S4 License Server'. "#EC NOTEXT

  CALL FUNCTION 'RFC_MODIFY_HTTP_DEST_TO_EXT'
    EXPORTING
      destination                = l_rfcdest
      action                     = ZLNKEcl_rfc_connections=>c_action_create
      authority_check            = abap_true
      servicenr                  = c_http_port
      server                     = c_lic_server_endpoint
      description                = l_description
      ssl                        = abap_false
    EXCEPTIONS
      authority_not_available    = 1
      destination_already_exist  = 2
      destination_not_exist      = 3
      destination_enqueue_reject = 4
      information_failure        = 5
      trfc_entry_invalid         = 6
      internal_failure           = 7
      snc_information_failure    = 8
      snc_internal_failure       = 9
      destination_is_locked      = 10
      invalid_parameter          = 11
      OTHERS                     = 12.

  IF sy-subrc <> 0.
    ZLNKEcx_aws_s3=>raise_from_sy_msg( ).
  ENDIF.

ENDMETHOD.


METHOD create_http_dest_to_ext_iam.
  DATA: l_description TYPE  rfcdoc-rfcdoc1.
  DATA: l_rfcdest TYPE rfcdest.
  DATA: l_target_host TYPE rfchost_ext.

  CONCATENATE c_httpdest_prefix                             "#EC NOTEXT
              'IAM'
              INTO l_rfcdest.

  l_description = 'Generated RocketSteam. Endpoint for AWS S3 IAM'. "#EC NOTEXT

  l_target_host = ZLNKEcl_aws_iam=>get_host_name( ).

  CALL FUNCTION 'RFC_MODIFY_HTTP_DEST_TO_EXT'
    EXPORTING
      destination                = l_rfcdest
      action                     = c_action_create
      authority_check            = abap_true
      servicenr                  = c_https_port
      server                     = l_target_host
      description                = l_description
      ssl                        = abap_true
    EXCEPTIONS
      authority_not_available    = 1
      destination_already_exist  = 2
      destination_not_exist      = 3
      destination_enqueue_reject = 4
      information_failure        = 5
      trfc_entry_invalid         = 6
      internal_failure           = 7
      snc_information_failure    = 8
      snc_internal_failure       = 9
      destination_is_locked      = 10
      invalid_parameter          = 11
      OTHERS                     = 12.

  IF sy-subrc <> 0.
    ZLNKEcx_aws_s3=>raise_from_sy_msg( ).
  ENDIF.

ENDMETHOD.


METHOD create_http_dest_to_ext_region.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 27th March 2014
* Creates HTTP Destination to AWS S3
*--------------------------------------------------------------------*
  DATA: l_description TYPE  rfcdoc-rfcdoc1.
  DATA: l_rfcdest TYPE rfcdest.
  DATA: l_target_host TYPE rfchost_ext.
  DATA: ls_region TYPE ZLNKEregion.
  DATA: l_msg TYPE string.                                  "#EC NEEDED

* Get region data.
  SELECT SINGLE *
      INTO ls_region
  FROM ZLNKEregion
  WHERE region = i_region.

  IF sy-subrc <> 0.
*   016	Region & not found
    MESSAGE i016 WITH i_region INTO l_msg.
    ZLNKEcx_aws_s3=>raise_from_sy_msg( ).
  ENDIF.

  l_rfcdest = ZLNKEcl_rfc_connections=>get_httpdest_by_region(
                                                   i_region ).

  CONCATENATE 'Generated RocketSteam. Endpoint for AWS S3'  "#EC NOTEXT
              i_region
              INTO l_description SEPARATED BY space.

  l_target_host = ls_region-endpoint.

  CALL FUNCTION 'RFC_MODIFY_HTTP_DEST_TO_EXT'
    EXPORTING
      destination                = l_rfcdest
      action                     = c_action_create
      authority_check            = abap_true
      servicenr                  = c_https_port
      server                     = l_target_host
      description                = l_description
      ssl                        = abap_true
    EXCEPTIONS
      authority_not_available    = 1
      destination_already_exist  = 2
      destination_not_exist      = 3
      destination_enqueue_reject = 4
      information_failure        = 5
      trfc_entry_invalid         = 6
      internal_failure           = 7
      snc_information_failure    = 8
      snc_internal_failure       = 9
      destination_is_locked      = 10
      invalid_parameter          = 11
      OTHERS                     = 12.

  IF sy-subrc <> 0.
    ZLNKEcx_aws_s3=>raise_from_sy_msg( ).
  ENDIF.

ENDMETHOD.


METHOD delete_http_dest_to_ext_region.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 27th March 2014
* Deletes HTTP Destination to AWS S3
*--------------------------------------------------------------------*
  DATA: l_rfcdest TYPE rfcdest.

  l_rfcdest = ZLNKEcl_rfc_connections=>get_httpdest_by_region(
                                                    i_region ).

  CALL FUNCTION 'RFC_MODIFY_HTTP_DEST_TO_EXT'
    EXPORTING
      destination                = l_rfcdest
      action                     = c_action_delete
      authority_check            = abap_true
    EXCEPTIONS
      authority_not_available    = 1
      destination_already_exist  = 2
      destination_not_exist      = 3
      destination_enqueue_reject = 4
      information_failure        = 5
      trfc_entry_invalid         = 6
      internal_failure           = 7
      snc_information_failure    = 8
      snc_internal_failure       = 9
      destination_is_locked      = 10
      invalid_parameter          = 11
      OTHERS                     = 12.

  IF sy-subrc <> 0.
    ZLNKEcx_aws_s3=>raise_from_sy_msg( ).
  ENDIF.

ENDMETHOD.


METHOD get_httpdest_by_region.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 2nd April 2014
* Given a region returns rfcdest name
*--------------------------------------------------------------------*
  CONCATENATE c_httpdest_prefix
              i_region
              INTO e_rfcdest.
  TRANSLATE e_rfcdest TO UPPER CASE.                     "#EC TRANSLANG

ENDMETHOD.


METHOD get_httpdest_lic_server.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 26th May 2014
* Returns HTTP to EXT destination for the license server endpoint
* Returns rfcdest name for RocketSteam S4 License Server
*--------------------------------------------------------------------*

  CONCATENATE c_httpdest_prefix
              c_lic_server_rfcdest_suffix
              INTO e_rfcdest.

ENDMETHOD.


METHOD get_httpsdest_iam.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 2nd April 2014
* Returns rfcdest name for IAM (Identity and Access Management)
*--------------------------------------------------------------------*

  CONCATENATE c_httpdest_prefix                             "#EC NOTEXT
              'IAM'
              INTO e_rfcdest.

ENDMETHOD.


METHOD http_dest_exists_lic_server.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 26th May 2014
* Returns abap_true if the RFC destination for S4 License Server exists
*--------------------------------------------------------------------*
  DATA: l_rfcdest TYPE rfcdest.

  l_rfcdest = get_httpdest_lic_server( ).

  CALL FUNCTION 'RFC_READ_HTTP_DESTINATION'
    EXPORTING
      destination             = l_rfcdest
      authority_check         = abap_true
      bypass_buf              = abap_true
    EXCEPTIONS
      authority_not_available = 1
      destination_not_exist   = 2
      information_failure     = 3
      internal_failure        = 4
      no_http_destination     = 5
      OTHERS                  = 6.

  IF sy-subrc = 0.
    e_destination_exists = abap_true.
  ELSE.
*   Don't raise exception in case destination does not exist
    IF sy-subrc <> 2.
      ZLNKEcx_aws_s3=>raise_from_sy_msg( ).
    ENDIF.
  ENDIF.

ENDMETHOD.


METHOD http_dest_to_ext_exists_iam.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 28th April 2014
* Returns abap_true if the RFC destination for IAM exists
*--------------------------------------------------------------------*
  DATA: l_rfcdest TYPE rfcdest.
  DATA: l_servicenr TYPE rfcdisplay-rfcsysid.
  DATA: l_server TYPE rfcdisplay-rfchost.
  DATA: l_msg TYPE string.                                  "#EC NEEDED

  l_rfcdest = get_httpsdest_iam( ).

  CALL FUNCTION 'RFC_READ_HTTP_DESTINATION'
    EXPORTING
      destination             = l_rfcdest
      authority_check         = abap_true
      bypass_buf              = abap_true
    IMPORTING
      servicenr               = l_servicenr
      server                  = l_server
    EXCEPTIONS
      authority_not_available = 1
      destination_not_exist   = 2
      information_failure     = 3
      internal_failure        = 4
      no_http_destination     = 5
      OTHERS                  = 6.

  IF sy-subrc = 0.
    IF l_servicenr <> c_https_port.
*     038	Port in destination & is wrong
      MESSAGE i038 WITH l_rfcdest INTO l_msg.
      ZLNKEcx_aws_s3=>raise_from_sy_msg( ).
    ELSEIF l_server <> ZLNKEcl_aws_iam=>get_host_name( ).
*     039	Endpoint in destination & is wrong
      MESSAGE i039 WITH l_rfcdest INTO l_msg.
      ZLNKEcx_aws_s3=>raise_from_sy_msg( ).
    ELSE.
      e_destination_exists = abap_true.
    ENDIF.
  ELSE.
*   Don't raise exception in case destination does not exist
    IF sy-subrc <> 2.
      ZLNKEcx_aws_s3=>raise_from_sy_msg( ).
    ENDIF.
  ENDIF.

ENDMETHOD.


METHOD http_dest_to_ext_exists_region.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 27th March 2014
* Given a region returns abap_true if the RFC destination exists
*--------------------------------------------------------------------*
  DATA: l_rfcdest TYPE rfcdest.
  DATA: l_server TYPE rfcdisplay-rfchost.
  DATA: l_servicenr TYPE rfcdisplay-rfcsysid.
  DATA: ls_region TYPE ZLNKEregion.
  DATA: l_msg TYPE string.                                  "#EC NEEDED

  l_rfcdest = get_httpdest_by_region( i_region ).

  SELECT SINGLE *
      INTO ls_region
  FROM ZLNKEregion
  WHERE region = i_region.

  IF sy-subrc <> 0.
*   016	Region & not found
    MESSAGE i016 WITH i_region INTO l_msg.
    ZLNKEcx_aws_s3=>raise_from_sy_msg( ).
  ENDIF.

  CALL FUNCTION 'RFC_READ_HTTP_DESTINATION'
    EXPORTING
      destination             = l_rfcdest
      authority_check         = abap_true
      bypass_buf              = abap_true
    IMPORTING
      servicenr               = l_servicenr
      server                  = l_server
    EXCEPTIONS
      authority_not_available = 1
      destination_not_exist   = 2
      information_failure     = 3
      internal_failure        = 4
      no_http_destination     = 5
      OTHERS                  = 6.

  IF sy-subrc = 0.
    IF l_servicenr <> c_https_port.
*     018	Port in destination & is wrong for region &
      MESSAGE i018 WITH l_rfcdest i_region INTO l_msg.
      ZLNKEcx_aws_s3=>raise_from_sy_msg( ).
    ELSEIF l_server <> ls_region-endpoint.
*     017	Endpoint in destination & is wrong for region &
      MESSAGE i017 WITH l_rfcdest i_region INTO l_msg.
      ZLNKEcx_aws_s3=>raise_from_sy_msg( ).
    ELSE.
      e_destination_exists = abap_true.
    ENDIF.
  ELSE.
*   Don't raise exception in case destination does not exist
    IF sy-subrc <> 2.
      ZLNKEcx_aws_s3=>raise_from_sy_msg( ).
    ENDIF.
  ENDIF.

ENDMETHOD.
ENDCLASS.
