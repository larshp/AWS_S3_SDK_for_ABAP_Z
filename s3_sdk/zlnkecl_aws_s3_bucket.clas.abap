class ZLNKECL_AWS_S3_BUCKET definition
  public
  inheriting from ZLNKECL_AWS_S3
  final
  create public .

*"* public components of class ZLNKECL_AWS_S3_BUCKET
*"* do not include other source files here!!!
public section.

  constants C_MPART_UPLD_STATE_INPROGRESS type C value 'P'. "#EC NOTEXT
  constants C_MPART_UPLD_STATE_COMPL_OK type C value 'S'. "#EC NOTEXT
  constants C_MPART_UPLD_STATE_COMPL_ERR type C value 'E'. "#EC NOTEXT
  constants C_MPART_UPLD_STATE_ABORTED type C value 'A'. "#EC NOTEXT

  type-pools ABAP .
  methods CONSTRUCTOR
    importing
      !I_BUCKET_NAME type ZLNKEBUCKET_DE optional
      !I_CONTENT_REP type CHAR2 optional
      !I_CREATE type ABAP_BOOL default ABAP_FALSE
      !I_DBG type ABAP_BOOL default ABAP_FALSE
    raising
      ZLNKECX_AWS_S3 .
  class-methods CREATE_BUCKET
    importing
      !I_BUCKET_NAME type ZLNKEBUCKET_DE
      !I_USER_NAME type ZLNKEUSERNAME_DE optional
      !I_REGION type ZLNKEREGION_DE
      !I_CLIENT_SIDE_ENCRYPTION type ZLNKECLIENT_SIDE_ENCRYPTION_DE default ABAP_FALSE
      !I_SERVER_SIDE_ENCRYPTION type ZLNKESERVER_SIDE_ENCRYPTION_DE default ABAP_FALSE
      !I_ZIP type ZLNKEZIPFLAG_DE default ABAP_FALSE
      !I_DBG type ABAP_BOOL default ABAP_FALSE
    exporting
      !E_HTTP_STATUS type I
      !E_RESPONSE_HEADERS type TIHTTPNVP
      !E_RESPONSE_CONTENT type STRING
      !E_AWS_S3_BUCKET type ref to ZLNKECL_AWS_S3_BUCKET
    raising
      ZLNKECX_AWS_S3 .
  methods DELETE_BUCKET
    exporting
      !E_HTTP_STATUS type I
      !E_RESPONSE_HEADERS type TIHTTPNVP
      !E_RESPONSE_CONTENT type STRING
    raising
      ZLNKECX_AWS_S3 .
  methods GET_OBJECT
    importing
      !I_OBJECT_NAME type STRING
      !I_REQUEST_HEADERS type TIHTTPNVP optional
    exporting
      !E_HTTP_STATUS type I
      !E_RESPONSE_HEADERS type TIHTTPNVP
      !E_RESPONSE_XCONTENT type XSTRING
    raising
      ZLNKECX_AWS_S3 .
  methods LIST_OBJECTS_V2
    importing
      !I_PREFIX type STRING optional
      !I_CONTINUATION_TOKEN type STRING optional
      !I_MAX_KEYS type STRING optional
      !I_DELIMITER type STRING optional
      !I_START_AFTER type STRING optional
      !I_REQUEST_HEADERS type TIHTTPNVP optional
    exporting
      !E_HTTP_STATUS type I
      !E_RESPONSE_HEADERS type TIHTTPNVP
      !E_RESPONSE_CONTENT type STRING
    raising
      ZLNKECX_AWS_S3 .
  methods LIST_OBJECTS
    importing
      !I_PREFIX type STRING optional
      !I_MARKER type STRING optional
      !I_MAX_KEYS type STRING optional
      !I_REQUEST_HEADERS type TIHTTPNVP optional
    exporting
      !E_HTTP_STATUS type I
      !E_RESPONSE_HEADERS type TIHTTPNVP
      !E_RESPONSE_CONTENT type STRING
    raising
      ZLNKECX_AWS_S3 .
  methods PUT_OBJECT
    importing
      !I_OBJECT_NAME type STRING
      !I_XCONTENT type XSTRING optional
      !I_REQUEST_HEADERS type TIHTTPNVP optional
      !I_MIME_TYPE type STRING default 'application/octet-stream'
      !I_ESCAPE_URL type ABAP_BOOL default ABAP_FALSE
    exporting
      !E_HTTP_STATUS type I
      !E_RESPONSE_HEADERS type TIHTTPNVP
      !E_RESPONSE_CONTENT type STRING
    raising
      ZLNKECX_AWS_S3 .
  methods PUT_OBJECT_MULTIPART_UPLOAD
    importing
      !I_OBJECT_NAME type STRING
      !I_XCONTENT type XSTRING
      !I_REQUEST_HEADERS type TIHTTPNVP optional
      !I_MIME_TYPE type STRING default 'application/octet-stream'
      !I_PART_SIZE type I default 5242880
      !I_ESCAPE_URL type ABAP_BOOL default ABAP_FALSE
    exporting
      !E_HTTP_STATUS type I
      !E_RESPONSE_HEADERS type TIHTTPNVP
      !E_RESPONSE_CONTENT type STRING
    raising
      ZLNKECX_AWS_S3 .
  methods DELETE_OBJECT
    importing
      !I_OBJECT_NAME type STRING
      !I_ESCAPE_URL type ABAP_BOOL default ABAP_FALSE
    exporting
      !E_HTTP_STATUS type I
      !E_RESPONSE_HEADERS type TIHTTPNVP
      !E_RESPONSE_CONTENT type STRING
    raising
      ZLNKECX_AWS_S3 .
  methods HEAD_BUCKET
    importing
      !I_REQUEST_HEADERS type TIHTTPNVP optional
    exporting
      value(E_HTTP_STATUS) type I
      !E_RESPONSE_HEADERS type TIHTTPNVP
    raising
      ZLNKECX_AWS_S3 .
  methods HEAD_OBJECT
    importing
      !I_OBJECT_NAME type STRING
      !I_REQUEST_HEADERS type TIHTTPNVP optional
      !I_ESCAPE_URL type ABAP_BOOL default ABAP_FALSE
    exporting
      !E_HTTP_STATUS type I
      !E_RESPONSE_HEADERS type TIHTTPNVP
    raising
      ZLNKECX_AWS_S3 .
  methods GET_BUCKET_LOCATION
    exporting
      !E_HTTP_STATUS type I
      !E_RESPONSE_HEADERS type TIHTTPNVP
      !E_RESPONSE_CONTENT type STRING
    raising
      ZLNKECX_AWS_S3 .
  methods PUT_BUCKET_LIFECYCLE
    importing
      !I_DAYS type ZLNKEBUCKET_LIFECYCLE_DE
    exporting
      !E_HTTP_STATUS type I
      !E_RESPONSE_HEADERS type TIHTTPNVP
      !E_RESPONSE_CONTENT type STRING
    raising
      ZLNKECX_AWS_S3 .
  methods GET_BUCKET_LIFECYCLE
    exporting
      !E_HTTP_STATUS type I
      !E_RESPONSE_HEADERS type TIHTTPNVP
      !E_RESPONSE_CONTENT type STRING
    raising
      ZLNKECX_AWS_S3 .
  methods LIST_PARTS_MULTIPART_UPLOAD
    importing
      !I_OBJECT_NAME type STRING
      !I_UPLOAD_ID type STRING
    exporting
      !E_HTTP_STATUS type I
      !E_RESPONSE_HEADERS type TIHTTPNVP
      !E_RESPONSE_CONTENT type STRING
    raising
      ZLNKECX_AWS_S3 .
  methods DELETE_BUCKET_LIFECYCLE
    exporting
      !E_HTTP_STATUS type I
      !E_RESPONSE_HEADERS type TIHTTPNVP
      !E_RESPONSE_CONTENT type STRING
    raising
      ZLNKECX_AWS_S3 .
  methods GET_BUCKET_NAME_INTERNAL
    returning
      value(E_BUCKET_NAME_INTERNAL) type STRING .
  methods GET_BUCKET_NAME_EXTERNAL
    returning
      value(E_BUCKET_NAME_EXTERNAL) type ZLNKEBUCKET_DE .
  class-methods GET_KEY_SIZE_FROM_XML
    importing
      !I_XML type STRING
    exporting
      !E_KEY_SIZE type ZLNKEKEY_SIZE_TT
      !E_LAST_KEY type STRING .
  methods GET_BUCKET_SIZE
    exporting
      value(E_BUCKET_SIZE) type F
      value(E_NUMBER_OF_FILES) type I
    raising
      ZLNKECX_AWS_S3 .
protected section.
*"* protected components of class ZLNKECL_AWS_S3_BUCKET
*"* do not include other source files here!!!
private section.
*"* private components of class ZLNKECL_AWS_S3_BUCKET
*"* do not include other source files here!!!

  data ATTR_BUCKET_NAME type STRING .
  data ATTR_REGION type STRING .
  data ATTR_CLIENT_ENCRYPT type FLAG .
  data ATTR_SERVER_ENCRYPT type FLAG .
  data ATTR_ZIP type FLAG .
  data ATTR_RFCDEST type RFCDEST .
  constants C_BUCKET_PREFIX_SEPARATOR type C value '-'. "#EC NOTEXT
  constants C_MPART_UPLD_RETRIES type I value 3. "#EC NOTEXT
  constants C_THRESHOLD_MPART type I value 10485760. "#EC NOTEXT
  constants C_MPART_SIZE type I value 5242880. "#EC NOTEXT

  methods ABORT_MULTIPART_UPLOAD
    importing
      !I_OBJECT_NAME type STRING
      !I_UPLOAD_ID type STRING
    exporting
      !E_HTTP_STATUS type I
      !E_RESPONSE_HEADERS type TIHTTPNVP
      !E_RESPONSE_CONTENT type STRING
    raising
      ZLNKECX_AWS_S3 .
  methods DELETE_BUCKET_PRIV
    exporting
      !E_HTTP_STATUS type I
      !E_RESPONSE_HEADERS type TIHTTPNVP
      !E_RESPONSE_CONTENT type STRING
    raising
      ZLNKECX_AWS_S3 .
  class-methods CREATE_BUCKET_PRIV
    importing
      !I_BUCKET_NAME type STRING
      !I_USER_NAME type ZLNKEUSERNAME_DE optional
      !I_REGION type ZLNKEREGION_DE
      !I_CLIENT_SIDE_ENCRYPTION type ZLNKECLIENT_SIDE_ENCRYPTION_DE default ABAP_FALSE
      !I_SERVER_SIDE_ENCRYPTION type ZLNKESERVER_SIDE_ENCRYPTION_DE default ABAP_FALSE
      !I_ZIP type ZLNKEZIPFLAG_DE default ABAP_FALSE
      !I_DBG type ABAP_BOOL default ABAP_FALSE
    exporting
      !E_HTTP_STATUS type I
      !E_RESPONSE_HEADERS type TIHTTPNVP
      !E_RESPONSE_CONTENT type STRING
      !E_AWS_S3_BUCKET type ref to ZLNKECL_AWS_S3_BUCKET
    raising
      ZLNKECX_AWS_S3 .
  class-methods BUCKET_NAME_IS_VALID
    importing
      !I_BUCKET_NAME type ZLNKEBUCKET_DE
    returning
      value(E_BUCKET_NAME_IS_VALID) type ABAP_BOOL .
  methods REST_GET
    importing
      !I_REQUEST type STRING
      !I_REQUEST_HEADERS type TIHTTPNVP optional
    exporting
      !E_HTTP_STATUS type I
      !E_RESPONSE_HEADERS type TIHTTPNVP
      !E_RESPONSE_XCONTENT type XSTRING
    raising
      ZLNKECX_AWS_S3 .
  methods REST_PUT
    importing
      !I_REQUEST type STRING
      !I_XCONTENT type XSTRING
      !I_REQUEST_HEADERS type TIHTTPNVP optional
    exporting
      !E_HTTP_STATUS type I
      !E_RESPONSE_HEADERS type TIHTTPNVP
      !E_RESPONSE_CONTENT type STRING
    raising
      ZLNKECX_AWS_S3 .
  methods UPLOAD_PART_MULTIPART_UPLOAD
    importing
      !I_OBJECT_NAME type STRING
      !I_PART_NUMBER type STRING
      !I_UPLOAD_ID type STRING
      !I_XCONTENT type XSTRING
      !I_REQUEST_HEADERS type TIHTTPNVP optional
      !I_MIME_TYPE type STRING default 'application/octet-stream'
    exporting
      !E_HTTP_STATUS type I
      !E_ETAG type STRING
      !E_RESPONSE_HEADERS type TIHTTPNVP
      !E_RESPONSE_CONTENT type STRING
    raising
      ZLNKECX_AWS_S3 .
  methods REST_POST
    importing
      !I_REQUEST type STRING
      !I_XCONTENT type XSTRING optional
      !I_REQUEST_HEADERS type TIHTTPNVP optional
    exporting
      !E_HTTP_STATUS type I
      !E_RESPONSE_HEADERS type TIHTTPNVP
      !E_RESPONSE_CONTENT type STRING
    raising
      ZLNKECX_AWS_S3 .
  methods REST_DELETE
    importing
      !I_REQUEST type STRING
      !I_REQUEST_HEADERS type TIHTTPNVP optional
    exporting
      !E_HTTP_STATUS type I
      !E_RESPONSE_HEADERS type TIHTTPNVP
      !E_RESPONSE_CONTENT type STRING
    raising
      ZLNKECX_AWS_S3 .
  methods REST_HEAD
    importing
      !I_REQUEST type STRING
      !I_REQUEST_HEADERS type TIHTTPNVP optional
    exporting
      !E_HTTP_STATUS type I
      !E_RESPONSE_HEADERS type TIHTTPNVP
      !E_RESPONSE_CONTENT type STRING
    raising
      ZLNKECX_AWS_S3 .
  methods GET_XML_BUCKET_LOCATION
    importing
      !I_REGION type ZLNKEREGION_DE
    returning
      value(E_XXML) type XSTRING .
  methods GET_XML_BUCKET_LIFECYCLE_DAYS
    importing
      !I_DAYS type ZLNKEBUCKET_LIFECYCLE_DE
    returning
      value(E_XXML) type XSTRING .
  class-methods GET_BUCKET_PREFIX
    returning
      value(E_BUCKET_PREFIX) type ZLNKEBUCKET_PREFIX_DE .
  class-methods GET_XML_COMPLETE_MULTIPART_UPL
    importing
      !I_T_ETAGS type ZLNKEMPART_UPLOAD_TT
    returning
      value(E_XXML) type XSTRING .
  methods LOG_MULTIPART_UPLOAD
    importing
      !I_OBJECT_NAME type STRING
      !I_UPLOAD_ID type STRING
      !I_STATE type ZLNKEMPART_UPLD_STATE_DE .
  methods ZIP_AND_ENCRYPT
    importing
      !I_XCONTENT type XSTRING
    returning
      value(E_XCONTENT) type XSTRING
    raising
      ZLNKECX_AWS_S3 .
  methods DECRYPT_AND_UNZIP
    importing
      !I_XCONTENT type XSTRING
    returning
      value(E_XCONTENT) type XSTRING
    raising
      ZLNKECX_AWS_S3 .
  methods COMPLETE_MULTIPART_UPLOAD
    importing
      !I_OBJECT_NAME type STRING
      !I_UPLOAD_ID type STRING
      !I_T_ETAGS type ZLNKEMPART_UPLOAD_TT
      !I_REQUEST_HEADERS type TIHTTPNVP optional
    exporting
      !E_HTTP_STATUS type I
      !E_RESPONSE_HEADERS type TIHTTPNVP
      !E_RESPONSE_CONTENT type STRING
    raising
      ZLNKECX_AWS_S3 .
  methods INITIATE_MULTIPART_UPLOAD
    importing
      !I_OBJECT_NAME type STRING
      !I_REQUEST_HEADERS type TIHTTPNVP optional
    exporting
      !E_HTTP_STATUS type I
      !E_RESPONSE_HEADERS type TIHTTPNVP
      !E_UPLOAD_ID type STRING
    raising
      ZLNKECX_AWS_S3 .
ENDCLASS.



CLASS ZLNKECL_AWS_S3_BUCKET IMPLEMENTATION.


METHOD abort_multipart_upload.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 24th Nov 2014
* Aborts multipart upload
*--------------------------------------------------------------------*
  DATA: l_request TYPE string.

  CONCATENATE '/'
              i_object_name
              '?uploadId='
              i_upload_id
              INTO l_request.

  CALL METHOD rest_delete
    EXPORTING
      i_request          = l_request
    IMPORTING
      e_http_status      = e_http_status
      e_response_headers = e_response_headers
      e_response_content = e_response_content.

  IF e_http_status = ZLNKEcl_http=>c_status_204_no_content.
    log_multipart_upload(
        i_object_name = i_object_name
        i_upload_id = i_upload_id
        i_state     = c_mpart_upld_state_aborted ).
  ENDIF.

ENDMETHOD.


METHOD bucket_name_is_valid.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 3rd April 2014
* Validates a Bucket name
*--------------------------------------------------------------------*
  CONSTANTS: lc_regexp TYPE char50 VALUE '[a-zA-Z0-9_.]+'.  "#EC NOTEXT
  DATA: l_strlen TYPE i.
  DATA: l_bucket_prefix TYPE ZLNKEbucket_prefix_de.
  DATA: l_bucket_name_wo_prefix TYPE ZLNKEbucket_de.
  DATA: lr_matcher TYPE REF TO cl_abap_matcher.

  e_bucket_name_is_valid = abap_true.

* Character '-' is accepted by AWS S3, but is reserved in our application
* since it is used as separator for the bucket prefix.
* Just check the bucket name entered by the user, removing prefix.
  l_bucket_prefix = get_bucket_prefix( ).
  l_strlen = STRLEN( l_bucket_prefix ) + 1.
  l_bucket_name_wo_prefix = i_bucket_name+l_strlen.

  l_strlen = STRLEN( l_bucket_name_wo_prefix ).

* Length validation
* Minimum 3 is requirement from AWS S3.
* Maximum allowed by AWS S3 is 63, but in our implementation is 50
  IF l_strlen < 3 OR l_strlen > 50.
    e_bucket_name_is_valid = abap_false.
  ENDIF.

* Not allowed consecutive dots.
  IF i_bucket_name CS '..'.
    e_bucket_name_is_valid = abap_false.
  ENDIF.

* If only contains numbers or dot, is not acceptable
  IF l_bucket_name_wo_prefix(l_strlen) CO '123456789.'.
    e_bucket_name_is_valid = abap_false.
  ENDIF.

* Only accept letters and numbers
  lr_matcher = cl_abap_matcher=>create( pattern = lc_regexp
                                        text    = l_bucket_name_wo_prefix ).
  IF lr_matcher->match( ) = abap_false.
    e_bucket_name_is_valid = abap_false.
  ENDIF.
ENDMETHOD.


METHOD complete_multipart_upload.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 25th Nov 2014
* Completes multipart upload.
*--------------------------------------------------------------------*
  DATA: l_xxml TYPE xstring.
  DATA: l_request TYPE string.
  DATA: ls_header TYPE ihttpnvp.
  DATA: lt_request_headers TYPE tihttpnvp.

  CONCATENATE '/'
             i_object_name
             '?uploadId='
             i_upload_id
             INTO l_request.

  IF i_request_headers IS NOT INITIAL.
    APPEND LINES OF i_request_headers TO lt_request_headers.
  ENDIF.

  IF attr_server_encrypt = abap_true.
    ls_header-name = 'x-amz-server-side-encryption'.
    ls_header-value = 'AES256'.
    APPEND ls_header TO lt_request_headers.
  ENDIF.

  l_xxml = ZLNKEcl_aws_s3_bucket=>get_xml_complete_multipart_upl( i_t_etags ).

  CALL METHOD rest_post
    EXPORTING
      i_request          = l_request
      i_xcontent         = l_xxml
      i_request_headers  = lt_request_headers
    IMPORTING
      e_http_status      = e_http_status
      e_response_headers = e_response_headers
      e_response_content = e_response_content.

  IF e_http_status = ZLNKEcl_http=>c_status_200_ok.
    log_multipart_upload(
        i_object_name = i_object_name
        i_upload_id = i_upload_id
        i_state     = c_mpart_upld_state_compl_ok ).
  ELSE.
    log_multipart_upload(
        i_object_name = i_object_name
        i_upload_id = i_upload_id
        i_state     = c_mpart_upld_state_compl_err ).
  ENDIF.
ENDMETHOD.


METHOD constructor.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 28th March 2014
* Object constructor
*--------------------------------------------------------------------*
  DATA: ls_bucket TYPE ZLNKEbucket.
  DATA: l_bucket_prefix TYPE ZLNKEbucket_prefix_de.
  DATA: l_msg TYPE string.                                  "#EC NEEDED

  IF i_create = abap_false.
    IF i_bucket_name IS NOT INITIAL.
      SELECT SINGLE *
        INTO ls_bucket
      FROM ZLNKEbucket
      WHERE bucket = i_bucket_name.
    ELSEIF i_content_rep IS NOT INITIAL.
      SELECT SINGLE *                                       "#EC *
        INTO ls_bucket
      FROM ZLNKEbucket
      WHERE content_rep = i_content_rep.
    ENDIF.
    IF ls_bucket IS INITIAL.
*     025	Bucket & not found
      MESSAGE i025 WITH i_bucket_name INTO l_msg.
      ZLNKEcx_aws_s3=>raise_from_sy_msg( ).
    ENDIF.
  ENDIF.

  CALL METHOD super->constructor
    EXPORTING
      i_user_name = ls_bucket-user_name
      i_create    = i_create
      i_dbg       = i_dbg.

  IF i_create = abap_false.
*   Bucket name
    attr_bucket_name = ls_bucket-bucket.
*   Region
    attr_region = ls_bucket-region.
*   Client side encryption
    attr_client_encrypt = ls_bucket-client_encrypt.
*   Server side encryption
    attr_server_encrypt = ls_bucket-server_encrypt.
*   Zip
    attr_zip = ls_bucket-zip.
*   RFC Destination
    attr_rfcdest = ZLNKEcl_rfc_connections=>get_httpdest_by_region(
                                                ls_bucket-region ).
  ENDIF.

  IF ls_bucket-no_prefix = abap_false.
*   Bucket prefix
    l_bucket_prefix = get_bucket_prefix( ).
    IF l_bucket_prefix IS NOT INITIAL.
*   Adds the prefix to the bucket name
      CONCATENATE l_bucket_prefix
                  attr_bucket_name
                  INTO attr_bucket_name
                  SEPARATED BY c_bucket_prefix_separator.
    ENDIF.
  ENDIF.

ENDMETHOD.


METHOD create_bucket.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 2nd April 2014
* Creates a Bucket
* If HTTP to Ext destination does not exist for the region, creates it.
* Executes a PUT to AWS S3.
*--------------------------------------------------------------------*
  DATA: l_bucket_prefix TYPE ZLNKEbucket_prefix_de.
  DATA: l_bucket_name TYPE string.
  DATA: lr_ZLNKEcx_aws_s3 TYPE REF TO ZLNKEcx_aws_s3.

  l_bucket_name = i_bucket_name.

* Bucket prefix (for SaaS version)
  l_bucket_prefix = get_bucket_prefix( ).
  IF l_bucket_prefix IS NOT INITIAL.
*   Adds the prefix to the bucket name
    CONCATENATE l_bucket_prefix
                l_bucket_name
                INTO l_bucket_name
                SEPARATED BY c_bucket_prefix_separator.
  ENDIF.

  TRY.
      CALL METHOD ZLNKEcl_aws_s3_bucket=>create_bucket_priv
        EXPORTING
          i_bucket_name            = l_bucket_name
          i_user_name              = i_user_name
          i_region                 = i_region
          i_client_side_encryption = i_client_side_encryption
          i_server_side_encryption = i_server_side_encryption
          i_zip                    = i_zip
          i_dbg                    = i_dbg
        IMPORTING
          e_http_status            = e_http_status
          e_response_headers       = e_response_headers
          e_response_content       = e_response_content
          e_aws_s3_bucket          = e_aws_s3_bucket.

    CATCH ZLNKEcx_aws_s3 INTO lr_ZLNKEcx_aws_s3.

      CALL METHOD ZLNKEcl_log=>append_log_create_bucket
        EXPORTING
          i_bucket_name            = l_bucket_name
          i_bucket_user_name       = i_user_name
          i_region                 = i_region
          i_client_side_encryption = i_client_side_encryption
          i_server_side_encryption = i_server_side_encryption
          i_zip                    = i_zip
          i_exception              = lr_ZLNKEcx_aws_s3.

      RAISE EXCEPTION lr_ZLNKEcx_aws_s3.
  ENDTRY.

  CALL METHOD ZLNKEcl_log=>append_log_create_bucket
    EXPORTING
      i_bucket_name            = l_bucket_name
      i_bucket_user_name       = i_user_name
      i_region                 = i_region
      i_client_side_encryption = i_client_side_encryption
      i_server_side_encryption = i_server_side_encryption
      i_zip                    = i_zip.

ENDMETHOD.


METHOD create_bucket_priv.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 2nd April 2014
* Creates a Bucket
* If HTTP to Ext destinatio does not exist for the region, creates it.
* Executes a PUT to AWS S3.
*--------------------------------------------------------------------*
  DATA: l_bucketname_lowercase TYPE ZLNKEbucket_de.
  DATA: l_xcontent TYPE xstring.
  DATA: l_hash TYPE string.
  DATA: l_request TYPE string.
  DATA: l_response_xcontent TYPE xstring.
  DATA: l_destination_exists TYPE abap_bool.
  DATA: l_err_msg TYPE string.
  DATA: lt_request_headers TYPE tihttpnvp.
  DATA: ls_header TYPE ihttpnvp.
  DATA: l_access_key TYPE ZLNKEacckey_de,
        l_secret_access_key TYPE ZLNKEsecacckey_de.
  DATA: l_tabname TYPE tabname.
  DATA: lr_bucket TYPE REF TO ZLNKEcl_aws_s3_bucket.

  IF i_client_side_encryption = abap_true.
    ZLNKEcl_ssf=>customize_default_if_needed( ).
  ENDIF.

* Bucket names always lowercase
  l_bucketname_lowercase = i_bucket_name.
  TRANSLATE l_bucketname_lowercase TO LOWER CASE.        "#EC TRANSLANG

  IF bucket_name_is_valid( l_bucketname_lowercase ) = abap_false.
*   022  Bucket name & is not valid
    MESSAGE i022 WITH i_bucket_name INTO l_err_msg.
    ZLNKEcx_aws_s3=>raise_from_sy_msg( ).
  ENDIF.

* Checks if HTTP to Ext destination exists for the region
  CALL METHOD ZLNKEcl_rfc_connections=>http_dest_to_ext_exists_region
    EXPORTING
      i_region             = i_region
    RECEIVING
      e_destination_exists = l_destination_exists.

  IF l_destination_exists = abap_false.
*   HTTP to Ext destination does not exist, create it.
    CALL METHOD ZLNKEcl_rfc_connections=>create_http_dest_to_ext_region
      EXPORTING
        i_region = i_region.
*     HTTP to Ext destination connection consolidated
    COMMIT WORK AND WAIT.
  ENDIF.

  CREATE OBJECT lr_bucket
    EXPORTING
      i_bucket_name = l_bucketname_lowercase
      i_create      = abap_true
      i_dbg         = abap_true.

  lr_bucket->attr_bucket_name = i_bucket_name.
  lr_bucket->attr_user = i_user_name.
  lr_bucket->attr_region = i_region.
  lr_bucket->attr_client_encrypt = i_client_side_encryption.
  lr_bucket->attr_server_encrypt = i_server_side_encryption.
  lr_bucket->attr_zip = i_zip.
  lr_bucket->attr_dbg = i_dbg.
  lr_bucket->attr_rfcdest =
        ZLNKEcl_rfc_connections=>get_httpdest_by_region( i_region ).

* If running as SaaS credentials are not coming from ZLNKEuser
  IF lr_bucket->running_as_saas( ) = abap_false.
    SELECT SINGLE access_key secr_access_key aws_account_id
      INTO (lr_bucket->attr_access_key,
            lr_bucket->attr_secret_access_key,
            lr_bucket->attr_aws_account_id)
    FROM ZLNKEuser
    WHERE user_name = i_user_name.

    IF sy-subrc <> 0.
*     020	AWS S3 User & not found
      MESSAGE i020 WITH i_user_name INTO l_err_msg.
      ZLNKEcx_aws_s3=>raise_from_sy_msg( ).
    ELSE.
*     Validates the username in IAM
      l_access_key = lr_bucket->attr_access_key.
      l_secret_access_key = lr_bucket->attr_secret_access_key.
      CALL METHOD ZLNKEcl_aws_iam=>check_aws_user
        EXPORTING
          i_user_name         = i_user_name
          i_access_key        = l_access_key
          i_secret_access_key = l_secret_access_key.
    ENDIF.
  ELSE.
*   Is SaaS version
*   Avoid syntax error in case Stand-alone (table ZLNKEACTIV_CODE is not delivered)
    l_tabname = 'ZLNKEACTIV_CODE'.
    TRY.
*       Get the aws account ID
        SELECT SINGLE aws_account_id                        "#EC *
             INTO lr_bucket->attr_aws_account_id
        FROM (l_tabname).
      CATCH cx_sy_dynamic_osql_semantics.
*       Should not happen!
*       078	Table & not found
        MESSAGE i078 WITH l_tabname INTO l_err_msg.
        ZLNKEcx_aws_s3=>raise_from_sy_msg( ).
    ENDTRY.
  ENDIF.

  IF i_region <> ZLNKEcl_aws_s3=>c_default_region.
*   XML for Body request: Bucket location
    l_xcontent = lr_bucket->get_xml_bucket_location( i_region ).
*   Body Hash
    TRY.
        CALL METHOD ZLNKEcl_hash=>hash_sha256_for_hex
          EXPORTING
            i_xstring = l_xcontent
          RECEIVING
            e_hash    = l_hash.
      CATCH cx_abap_message_digest.
*       021	Message digest error (&)
        MESSAGE i021 WITH 'SHA-256' INTO l_err_msg.
        ZLNKEcx_aws_s3=>raise_from_sy_msg( ).
    ENDTRY.
  ELSE.
    l_hash = ZLNKEcl_hash=>c_empty_body_sha256.
  ENDIF.

  ls_header-name = 'Content-Type'.                          "#EC NOTEXT
  ls_header-value = 'text/plain'.                           "#EC NOTEXT
  APPEND ls_header TO lt_request_headers.

  l_request = '/'.
  CALL METHOD lr_bucket->rest
    EXPORTING
      i_rfcdest           = lr_bucket->attr_rfcdest
      i_bucket_name       = lr_bucket->attr_bucket_name
      i_region            = lr_bucket->attr_region
      i_http_method       = ZLNKEcl_http=>c_method_put
      i_request           = l_request
      i_body_hash         = l_hash
      i_xcontent          = l_xcontent
      i_request_headers   = lt_request_headers
    IMPORTING
      e_http_status       = e_http_status
      e_response_headers  = e_response_headers
      e_response_xcontent = l_response_xcontent.

  CALL METHOD ZLNKEcl_string_conversions=>xstring_to_string
    EXPORTING
      input  = l_response_xcontent
    IMPORTING
      output = e_response_content.

  IF e_http_status <> ZLNKEcl_http=>c_status_200_ok.
*   Gets the error message
    l_err_msg = ZLNKEcl_xml_utils=>get_node_value_from_xmlstring(
                                 i_xml_string = e_response_content
                                 i_node_name = 'Message' ). "#EC NOTEXT

    ZLNKEcx_aws_s3=>raise_giving_string( l_err_msg ).
  ENDIF.

  e_aws_s3_bucket = lr_bucket.

ENDMETHOD.


METHOD decrypt_and_unzip.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 28th Nov 2014
* Unzips and or decrypts the content according to bucket options.
*--------------------------------------------------------------------*
  DATA: lr_cx_root TYPE REF TO cx_root.
  DATA: l_xcontent TYPE xstring.
  DATA: l_exception_msg TYPE string.

  IF attr_client_encrypt = abap_true.
*   If the bucket is using client side encryption, develope content (SSF)
    l_xcontent = ZLNKEcl_ssf=>develope( i_xcontent ).
  ELSE.
    l_xcontent = i_xcontent.
  ENDIF.

  IF attr_zip = abap_true.
    TRY.
*       If the bucket is using compression, decompress the content
        CALL METHOD cl_abap_gzip=>decompress_binary
          EXPORTING
            gzip_in = l_xcontent
          IMPORTING
            raw_out = e_xcontent.
      CATCH cx_root INTO lr_cx_root.                     "#EC CATCH_ALL
        l_exception_msg = lr_cx_root->get_text( ).
*       063	Exception in method &: &
        MESSAGE i063 WITH 'DECRYPT_AND_UNZIP' l_exception_msg INTO l_exception_msg.
        ZLNKEcx_aws_s3=>raise_from_sy_msg( ).
    ENDTRY.
  ELSE.
    e_xcontent = l_xcontent.
  ENDIF.

ENDMETHOD.


METHOD delete_bucket.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 31th March 2014
* Executes a DELETE request to AWS S3.
* Returns:
*  E_HTTP_STATUS = 204 and E_XML initial on success,
*  E_HTTP_STATUS = 409 and E_XML with XML if the Bucket is not empty.
*--------------------------------------------------------------------*
  DATA: lr_ZLNKEcx_aws_s3 TYPE REF TO ZLNKEcx_aws_s3.

  TRY.
      CALL METHOD delete_bucket_priv
        IMPORTING
          e_http_status      = e_http_status
          e_response_headers = e_response_headers
          e_response_content = e_response_content.
    CATCH ZLNKEcx_aws_s3 INTO lr_ZLNKEcx_aws_s3.
*     Log deletion error
      CALL METHOD ZLNKEcl_log=>append_log_delete_bucket
        EXPORTING
          i_bucket_name = attr_bucket_name
          i_exception   = lr_ZLNKEcx_aws_s3.

      RAISE EXCEPTION lr_ZLNKEcx_aws_s3.
  ENDTRY.

* Log deletion
  CALL METHOD ZLNKEcl_log=>append_log_delete_bucket
    EXPORTING
      i_bucket_name = attr_bucket_name.

ENDMETHOD.


METHOD DELETE_BUCKET_LIFECYCLE.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 10th April 2014
* Deletes Bucket Lifecycle
*--------------------------------------------------------------------*
  DATA: l_request TYPE string.

  l_request = '/?lifecycle'.

  CALL METHOD rest_delete
    EXPORTING
      i_request          = l_request
    IMPORTING
      e_http_status      = e_http_status
      e_response_headers = e_response_headers
      e_response_content = e_response_content.

ENDMETHOD.


METHOD delete_bucket_priv.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 31th March 2014
* Executes a DELETE request to AWS S3.
* Returns:
*  E_HTTP_STATUS = 204 and E_XML initial on success,
*  E_HTTP_STATUS = 409 and E_XML with XML if the Bucket is not empty.
*--------------------------------------------------------------------*
  DATA: l_request TYPE string.
  DATA: l_err_msg TYPE string.

  l_request = '/'.
  CALL METHOD rest_delete
    EXPORTING
      i_request          = l_request
    IMPORTING
      e_http_status      = e_http_status
      e_response_headers = e_response_headers
      e_response_content = e_response_content.

  IF e_http_status <> ZLNKEcl_http=>c_status_204_no_content.
*   Gets the error message
    l_err_msg = ZLNKEcl_xml_utils=>get_node_value_from_xmlstring(
                                 i_xml_string = e_response_content
                                 i_node_name = 'Message' ). "#EC NOTEXT
*   047	Error deleting Bucket &
    MESSAGE i047 WITH attr_bucket_name l_err_msg INTO l_err_msg.
    ZLNKEcx_aws_s3=>raise_from_sy_msg( ).
  ENDIF.

ENDMETHOD.


METHOD delete_object.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 22th April 2014
* Given an object name deletes it
* Notes:
*  1-To delete a Folder, give an object name ending with / for example:
*     MyFolder/
*  2-The folder will not be deleted unless it is empty.
*--------------------------------------------------------------------*
  DATA: l_request TYPE string.
  DATA: l_object_name TYPE string.

  l_object_name = i_object_name.
  IF i_escape_url = abap_true.
    l_object_name = ZLNKEcl_http=>escape_url( l_object_name ).
  ENDIF.

  CONCATENATE '/'
              l_object_name
              INTO l_request.

  CALL METHOD rest_delete
    EXPORTING
      i_request          = l_request
    IMPORTING
      e_http_status      = e_http_status
      e_response_headers = e_response_headers
      e_response_content = e_response_content.

ENDMETHOD.


METHOD get_bucket_lifecycle.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 10th April 2014
* Gets Bucket Lifecycle
*--------------------------------------------------------------------*
  DATA: l_request TYPE string.
  DATA: l_response_xcontent TYPE xstring.

  l_request = '/?lifecycle'.

  CALL METHOD rest_get
    EXPORTING
      i_request           = l_request
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


METHOD get_bucket_location.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 1st April 2014
* Returns the bucket location (region)
*--------------------------------------------------------------------*
  DATA: l_request TYPE string.
  DATA: l_response_xcontent TYPE xstring.

  l_request = '/?location'.

  CALL METHOD rest_get
    EXPORTING
      i_request           = l_request
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


METHOD get_bucket_name_external.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 21th March 2016
* Returns the Bucket name external.
*--------------------------------------------------------------------*
  DATA: l_lines TYPE i.
  DATA: lt_strings TYPE string_table.

  SPLIT attr_bucket_name AT c_bucket_prefix_separator
                         INTO TABLE lt_strings.
  l_lines = LINES( lt_strings ).
  READ TABLE lt_strings INTO e_bucket_name_external INDEX l_lines.

ENDMETHOD.


METHOD get_bucket_name_internal.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 16th May 2014
* Returns the Bucket name internal
* Bucket name internal is the same as Bucket name for Stand Alone version
* Bucket name internal is Bucket name prefix concatenated with Bucket name
* for SaaS version
*--------------------------------------------------------------------*

  e_bucket_name_internal = attr_bucket_name.

ENDMETHOD.


METHOD get_bucket_prefix.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 16th May 2014
* Returns the bucket prefix:
* For SaaS is bucket_prefix-sid-mandt
* For StandAlone is sid-mandt
*--------------------------------------------------------------------*
  DATA: l_tabname TYPE tabname.

* Bucket prefix (for SaaS version)
  TRY.
*     The table ZLNKEACTIV_CODE will not exist for Stand Alone version.
*     To avoid syntax error in case the table does not exist,
*     use dynamic selection
      l_tabname = 'ZLNKEACTIV_CODE'.
      SELECT SINGLE bucket_prefix                           "#EC *
               INTO e_bucket_prefix
      FROM (l_tabname).

      IF sy-subrc = 0.
        CONCATENATE e_bucket_prefix
                    sy-sysid
                    INTO e_bucket_prefix
                    SEPARATED BY c_bucket_prefix_separator.
      ELSE.
*       Case when table ZLNKEACTIV_CODE exists, but is empty
        e_bucket_prefix = sy-sysid.
      ENDIF.
    CATCH cx_sy_dynamic_osql_semantics.
*     This will happen for Stand alone version, where
*     the table ZLNKEACTIV_CODE does not exist
      e_bucket_prefix = sy-sysid.
  ENDTRY.

* Lower case!. In AWS bucket names must be lowercase
  TRANSLATE e_bucket_prefix TO LOWER CASE.                "#EC SYNTCHAR

ENDMETHOD.


METHOD get_bucket_size.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 12th Sept 2014
* Returns Bucket size.
* NOTE: This operation may take long time if Bucket has a large amount
* of objects. For this reason it is preferred to call it from a
* Background job.
*--------------------------------------------------------------------*
  DATA: l_last_key TYPE string.
  DATA: l_xml TYPE string.
  DATA: l_truncated TYPE string.
  DATA: l_iterate TYPE abap_bool.
  DATA: lt_key_size TYPE ZLNKEkey_size_tt.
  FIELD-SYMBOLS: <fs_key_size> TYPE ZLNKEkey_size_st.

  l_iterate = abap_true.
  WHILE l_iterate = abap_true.
    CALL METHOD list_objects
      EXPORTING
        i_marker           = l_last_key
      IMPORTING
        e_response_content = l_xml.

*   Node 'IsTruncated' will be true in case not all keys are returned
*   from the previous call.
    CALL METHOD ZLNKEcl_xml_utils=>get_node_value_from_xmlstring
      EXPORTING
        i_xml_string = l_xml
        i_node_name  = 'IsTruncated'
      RECEIVING
        e_node_value = l_truncated.

    IF l_truncated <> 'true'.
      l_iterate = abap_false.
    ENDIF.

    CALL METHOD get_key_size_from_xml
      EXPORTING
        i_xml      = l_xml
      IMPORTING
        e_key_size = lt_key_size
        e_last_key = l_last_key.

    SORT lt_key_size.
    DELETE ADJACENT DUPLICATES FROM lt_key_size.
    IF sy-subrc = 0.
*     In case there are duplicated entries means we
*     are listing again from beginning. Stop iterating.
      l_iterate = abap_false.
    ENDIF.
  ENDWHILE.

  LOOP AT lt_key_size ASSIGNING <fs_key_size>.
    TRY.
        e_bucket_size = e_bucket_size + <fs_key_size>-xsize.
      CATCH cx_sy_conversion_overflow.
*       Indicates overflow
        e_bucket_size = -1.
    ENDTRY.
  ENDLOOP.

  e_number_of_files = LINES( lt_key_size ).

ENDMETHOD.


METHOD get_key_size_from_xml.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 12th Sept 2014
* Receives the XML resulting from GET Bucket (List Objects)
* Returns: A table containing key & size pairs.
*
* The XML is like:
*  <ListBucketResult xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
*  <Name>90f37fd30e-ide-testbucketsize</Name>
*  <Prefix />
*  <Marker>ProvaPut2200.txt</Marker>
*  <MaxKeys>1000</MaxKeys>
*  <IsTruncated>true</IsTruncated>
*  <Contents>
*      <Key>ProvaPut2201.txt</Key>
*      <LastModified>2014-09-08T09:34:27.000Z</LastModified>
*      <ETag>"68e109f0f40ca72a15e05cc22786f8e6"</ETag>
*      <Size>10</Size>
*      <Owner>
*          <ID>4b9360ecae476ff2b3be4258062810f687c2305fcd13c30a7d469548e7a1d730</ID>
*          <DisplayName>support</DisplayName>
*      </Owner>
*      <StorageClass>STANDARD</StorageClass>
*  </Contents>
*  <Contents>
*      <Key>ProvaPut2202.txt</Key>
*      <LastModified>2014-09-08T09:34:27.000Z</LastModified>
*      <ETag>"68e109f0f40ca72a15e05cc22786f8e6"</ETag>
*      <Size>10</Size>
*      <Owner>
*          <ID>4b9360ecae476ff2b3be4258062810f687c2305fcd13c30a7d469548e7a1d730</ID>
*          <DisplayName>support</DisplayName>
*      </Owner>
*      <StorageClass>STANDARD</StorageClass>
*  </Contents>
*  </ListBucketResult>
*--------------------------------------------------------------------*
  DATA: lr_ixml_document TYPE REF TO if_ixml_document.
  DATA: lr_node_filter   TYPE REF TO if_ixml_node_filter.
  DATA: lr_node_iterator TYPE REF TO if_ixml_node_iterator.
  DATA: lr_node          TYPE REF TO if_ixml_node.
  DATA: lr_node_list TYPE REF TO if_ixml_node_list.
  DATA: lr_node_iterator2 TYPE REF TO if_ixml_node_iterator.
  DATA: lr_node_filter2   TYPE REF TO if_ixml_node_filter.
  DATA: lr_node2          TYPE REF TO if_ixml_node.
  DATA: ls_key_size TYPE ZLNKEkey_size_st.

  lr_ixml_document = ZLNKEcl_xml_utils=>convert_string_to_ixmldoc( i_xml ).
  lr_node_filter = lr_ixml_document->create_filter_name( 'Contents' ). "#EC NOTEXT
  lr_node_iterator = lr_ixml_document->create_iterator_filtered( lr_node_filter ).
  lr_node ?= lr_node_iterator->get_next( ).
  WHILE lr_node IS NOT INITIAL.
    lr_node_list = lr_node->get_children( ).
    TRY.
        CLEAR ls_key_size.
        lr_node_filter2 = lr_ixml_document->create_filter_name( 'Key' ). "#EC NOTEXT
        lr_node_iterator2 = lr_node_list->create_iterator_filtered( lr_node_filter2 ).
        lr_node2 = lr_node_iterator2->get_next( ).
        ls_key_size-xkey = lr_node2->get_value( ).

        lr_node_filter2 = lr_ixml_document->create_filter_name( 'Size' ). "#EC NOTEXT
        lr_node_iterator2 = lr_node_list->create_iterator_filtered( lr_node_filter2 ).
        lr_node2 = lr_node_iterator2->get_next( ).
        ls_key_size-xsize = lr_node2->get_value( ).

        APPEND ls_key_size TO e_key_size.
      CATCH cx_sy_ref_is_initial.
*       Should not happen!
        CLEAR ls_key_size.
      CATCH cx_sy_conversion_no_number.
*       Should not happen!
        CLEAR ls_key_size.
    ENDTRY.

    lr_node ?= lr_node_iterator->get_next( ).
  ENDWHILE.

  e_last_key = ls_key_size-xkey.

ENDMETHOD.


METHOD get_object.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 28th March 2014
* Given an object name returns it if success in reading it from S3
* If no success in reading, returns XML with the error
*--------------------------------------------------------------------*
  DATA: l_request TYPE string.
  DATA: l_response_xcontent TYPE xstring.
  DATA: l_length TYPE i.
  DATA: l_range TYPE string.
  DATA: l_offset_froms TYPE string.
  DATA: l_offset_tos TYPE string.
  DATA: l_offset_from TYPE i.
  DATA: l_offset_to TYPE i.
  DATA: l_exception_msg TYPE string.
  DATA: lt_request_headers TYPE tihttpnvp.
  DATA: lr_cx_root TYPE REF TO cx_root.
  FIELD-SYMBOLS: <fs_ihttpnvp> TYPE ihttpnvp.

  CONCATENATE '/'
              i_object_name
              INTO l_request.

  lt_request_headers[] = i_request_headers[].

  IF attr_client_encrypt = abap_true
    OR attr_zip = abap_true.
*   In case the bucket is using Client Encrypt, the file cannot be
*   downloaded partially, since could not be possible to decrypt it.
*   Offset parameters are removed, and the file will be downloaded
*   entirely
*   The same applies in case the bucket is using zip.
    READ TABLE lt_request_headers WITH KEY name = 'Range'   "#EC NOTEXT
               ASSIGNING <fs_ihttpnvp>.
    IF sy-subrc <> 0.
      READ TABLE lt_request_headers WITH KEY name = 'range' "#EC NOTEXT
                 ASSIGNING <fs_ihttpnvp>.
    ENDIF.
    IF sy-subrc = 0.
      l_range = <fs_ihttpnvp>-value.
      DELETE lt_request_headers INDEX sy-tabix.
    ENDIF.
  ENDIF.

  CALL METHOD rest_get
    EXPORTING
      i_request           = l_request
      i_request_headers   = lt_request_headers
    IMPORTING
      e_http_status       = e_http_status
      e_response_headers  = e_response_headers
      e_response_xcontent = l_response_xcontent.

* Decrypts and/or unzips according to bucket properties
  e_response_xcontent = decrypt_and_unzip( l_response_xcontent ).

  IF l_range IS NOT INITIAL.
*   If l_range is not initial means the bucket is using Client Encrypt
*   and / or zip. In this case the entire content is downloaded, in
*   spite of the fact that the request is with range.
*   To satisfy the request we take now into account the range.
    TRY.
        CONDENSE l_range NO-GAPS.
        TRANSLATE l_range TO LOWER CASE.
        IF l_range CS 'bytes='.
          l_range = l_range+6.
          SPLIT l_range AT '-' INTO l_offset_froms l_offset_tos.
          l_offset_from = l_offset_froms.
          l_offset_to = l_offset_tos.
          IF l_offset_from < l_offset_to.
            e_response_xcontent = e_response_xcontent+l_offset_from(l_offset_to).
          ENDIF.
        ENDIF.
      CATCH cx_root INTO lr_cx_root.                     "#EC CATCH_ALL
*       063  Exception in method &: &
        l_exception_msg = lr_cx_root->get_text( ).
        MESSAGE i063 WITH 'GET_OBJECT' l_exception_msg INTO l_exception_msg.
        ZLNKEcx_aws_s3=>raise_from_sy_msg( ).
    ENDTRY.
  ENDIF.

  IF attr_client_encrypt = abap_true OR attr_zip = abap_true.
*   Re-calculate the length, to match it with the decompressed
*    / decrypted content
    l_length = XSTRLEN( e_response_xcontent ).
    READ TABLE e_response_headers WITH KEY name = 'content-length'
                        ASSIGNING <fs_ihttpnvp>.
    IF sy-subrc = 0.
      <fs_ihttpnvp>-value = l_length.
    ENDIF.
  ENDIF.

ENDMETHOD.


METHOD get_xml_bucket_lifecycle_days.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 10th April 2014
* Returns an XXML with bucket lifecycle, like:
*
*<LifecycleConfiguration>
*  <Rule>
*    <ID>archive-objects-glacier-days-after-creation</ID>
*    <Prefix>glacierobjects/</Prefix>
*    <Status>Enabled</Status>
*    <Transition>
*      <Days>0</Days>
*      <StorageClass>GLACIER</StorageClass>
*    </Transition>
*  </Rule>
*</LifecycleConfiguration>
*--------------------------------------------------------------------*
  DATA: lr_ixml TYPE REF TO if_ixml.
  DATA: lr_ixml_document TYPE REF TO if_ixml_document.
  DATA: lr_elem_lifecycleconf  TYPE REF TO if_ixml_element.
  DATA: lr_elem_rule TYPE REF TO if_ixml_element.
  DATA: lr_elem_transition TYPE REF TO if_ixml_element.
  DATA: l_days_s TYPE string.

* Create iXML object
  lr_ixml = cl_ixml=>create( ).

* Create iXML document
  lr_ixml_document = lr_ixml->create_document( ).

* Element LifecycleConfiguration
  lr_elem_lifecycleconf  = lr_ixml_document->create_simple_element( "#EC NOTEXT
                                           name   = 'LifecycleConfiguration'
                                           parent = lr_ixml_document ).

* Element Rule
  lr_elem_rule = lr_ixml_document->create_simple_element(   "#EC NOTEXT
                                           name   = 'Rule'
                                           parent = lr_elem_lifecycleconf ).

* Element ID
  lr_ixml_document->create_simple_element( name   = 'ID'    "#EC NOTEXT
                                           parent = lr_elem_rule
                   value  = 'archive-objects-glacier-days-after-creation' ).

* Element Prefix
  lr_ixml_document->create_simple_element( name   = 'Prefix' "#EC NOTEXT
                                           parent = lr_elem_rule
                                           value  = 'glacierobjects/' ).

* Element Status
  lr_ixml_document->create_simple_element( name   = 'Status' "#EC NOTEXT
                                           parent = lr_elem_rule
                                           value  = 'Enabled' ).

* Element Transition
  lr_elem_transition = lr_ixml_document->create_simple_element( "#EC NOTEXT
                                           name   = 'Transition'
                                           parent = lr_elem_rule ).

* Element Days
  l_days_s = i_days.
  lr_ixml_document->create_simple_element( name   = 'Days'  "#EC NOTEXT
                                           parent = lr_elem_transition
                                           value  = l_days_s ).

* Element StorageClass
  lr_ixml_document->create_simple_element( name   = 'StorageClass' "#EC NOTEXT
                                           parent = lr_elem_transition
                                           value  = 'GLACIER' ).

* Converts iXML document to xstring
  e_xxml = ZLNKEcl_xml_utils=>convert_ixml_doc_to_xstring( lr_ixml_document ).

ENDMETHOD.


METHOD GET_XML_BUCKET_LOCATION.
*-------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 1st April 2014
* Returns XXML for bucket region, like:
*  <CreateBucketConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
*    <LocationConstraint>BucketRegion</LocationConstraint>
*  </CreateBucketConfiguration>
*--------------------------------------------------------------------*
  DATA: lr_ixml TYPE REF TO if_ixml.
  DATA: lr_ixml_document TYPE REF TO if_ixml_document.
  DATA: lr_elem_createbucketconf TYPE REF TO if_ixml_element.
  DATA: l_region_s TYPE string.

* Create iXML object
  lr_ixml = cl_ixml=>create( ).

* Create iXML document
  lr_ixml_document = lr_ixml->create_document( ).

* Element CreateBucketConfiguration
  lr_elem_createbucketconf  = lr_ixml_document->create_simple_element(
                                           name   = 'CreateBucketConfiguration'
                                           parent = lr_ixml_document ).

* Element LocationConstraint
  l_region_s = i_region.
  lr_ixml_document->create_simple_element( name   = 'LocationConstraint'
                                           parent = lr_elem_createbucketconf
                                           value  = l_region_s ).

* Converts iXML document to xstring
  e_xxml = ZLNKEcl_xml_utils=>convert_ixml_doc_to_xstring( lr_ixml_document ).

ENDMETHOD.


METHOD get_xml_complete_multipart_upl.
*-------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 25th Nov 2014
* Returns XXML for completing multipart upload
* http://docs.aws.amazon.com/AmazonS3/latest/API/mpUploadComplete.html
*
*<CompleteMultipartUpload>
*  <Part>
*    <PartNumber>PartNumber</PartNumber>
*    <ETag>ETag</ETag>
*  </Part>
*  ...
*</CompleteMultipartUpload>
*--------------------------------------------------------------------*
  DATA: lr_ixml TYPE REF TO if_ixml.
  DATA: lr_ixml_document TYPE REF TO if_ixml_document.
  DATA: lr_elem_complete_multipart_upl TYPE REF TO if_ixml_element.
  DATA: lr_elem_part TYPE REF TO if_ixml_element.
  DATA: l_part_number_s TYPE string.
  DATA: l_etag_s TYPE string.

  FIELD-SYMBOLS: <fs_mpart_upload> TYPE ZLNKEmpart_upload_st.

* Create iXML object
  lr_ixml = cl_ixml=>create( ).

* Create iXML document
  lr_ixml_document = lr_ixml->create_document( ).

* Element CompleteMultipartUpload
  lr_elem_complete_multipart_upl  = lr_ixml_document->create_simple_element(
                                           name   = 'CompleteMultipartUpload'
                                           parent = lr_ixml_document ).

  LOOP AT i_t_etags ASSIGNING <fs_mpart_upload>.
*   Element Part
    lr_elem_part = lr_ixml_document->create_simple_element(
                                           name   = 'Part'
                                           parent = lr_elem_complete_multipart_upl ).

*   Element PartNumber
    l_part_number_s = <fs_mpart_upload>-part_number.
    lr_ixml_document->create_simple_element( name   = 'PartNumber'
                                             parent = lr_elem_part
                                             value  = l_part_number_s ).

*   Element ETag
    l_etag_s = <fs_mpart_upload>-etag.
    lr_ixml_document->create_simple_element( name   = 'ETag'
                                             parent = lr_elem_part
                                             value  = l_etag_s ).
  ENDLOOP.

* Converts iXML document to xstring
  e_xxml = ZLNKEcl_xml_utils=>convert_ixml_doc_to_xstring( lr_ixml_document ).

ENDMETHOD.


METHOD HEAD_BUCKET.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 28th March 2014
* Executes a HEAD request to AWS S3.
* Returns HTTP status code. It will be 200 if the bucket exists in
* AWS S3 and there are access permissions
*--------------------------------------------------------------------*
  DATA: l_request TYPE string.

  l_request = '/'.

  CALL METHOD rest_head
    EXPORTING
      i_request            = l_request
      i_request_headers    = i_request_headers
    IMPORTING
      e_http_status        = e_http_status
      e_response_headers   = e_response_headers.

ENDMETHOD.


METHOD head_object.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 7th April 2014
* Given an object name returns executes HEAD request
*--------------------------------------------------------------------*
  DATA: l_request TYPE string.
  DATA: l_object_name TYPE string.

  l_object_name = i_object_name.
  IF i_escape_url = abap_true.
    l_object_name = ZLNKEcl_http=>escape_url( l_object_name ).
  ENDIF.

  CONCATENATE '/'
              l_object_name
              INTO l_request.

  CALL METHOD rest_head
    EXPORTING
      i_request          = l_request
      i_request_headers  = i_request_headers
    IMPORTING
      e_http_status      = e_http_status
      e_response_headers = e_response_headers.

ENDMETHOD.


METHOD initiate_multipart_upload.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 24th Nov 2014
* Initiates multipart upload. Returns Upload ID.
*--------------------------------------------------------------------*
  DATA: l_request TYPE string.
  DATA: lt_request_headers TYPE tihttpnvp.
  DATA: l_response_content TYPE string.
  data: ls_header TYPE ihttpnvp.
  DATA: lt_node_values TYPE string_table.

  CONCATENATE '/'
             i_object_name
             '?uploads'
             INTO l_request.

  IF i_request_headers IS NOT INITIAL.
    APPEND LINES OF i_request_headers TO lt_request_headers.
  ENDIF.

  IF attr_server_encrypt = abap_true.
    ls_header-name = 'x-amz-server-side-encryption'.
    ls_header-value = 'AES256'.
    APPEND ls_header TO lt_request_headers.
  ENDIF.

  CALL METHOD rest_post
    EXPORTING
      i_request          = l_request
      i_request_headers  = lt_request_headers
    IMPORTING
      e_http_status      = e_http_status
      e_response_headers = e_response_headers
      e_response_content = l_response_content.

  lt_node_values = ZLNKEcl_xml_utils=>get_node_values_from_xmlstring(
      i_xml_string  = l_response_content
      i_node_name   = 'UploadId' ).

  IF lt_node_values[] IS NOT INITIAL.
    READ TABLE lt_node_values INTO e_upload_id INDEX 1.
    log_multipart_upload(
        i_object_name = i_object_name
        i_upload_id = e_upload_id
        i_state     = c_mpart_upld_state_inprogress ).
  ENDIF.

ENDMETHOD.


METHOD list_objects.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 28th March 2014
* Returns an XML with the Bucket List (max 1000 items)
* If prefix is given, the returns all the files starting with this prefix
*--------------------------------------------------------------------*
  DATA: l_request TYPE string.
  DATA: l_response_xcontent TYPE xstring.
  DATA: l_first_parameter TYPE abap_bool.

  l_first_parameter = abap_true.

  l_request = '/'.
  IF i_prefix IS NOT INITIAL.
    CONCATENATE l_request
                '?prefix='
                i_prefix
                INTO l_request.
    l_first_parameter = abap_false.
  ENDIF.

  IF i_marker IS NOT INITIAL.
    IF l_first_parameter = abap_true.
      CONCATENATE l_request
                  '?marker='
                  i_marker
                  INTO l_request.
    ELSE.
      CONCATENATE l_request
                  '&marker='
                  i_marker
                  INTO l_request.
    ENDIF.
    l_first_parameter = abap_false.
  ENDIF.

  IF i_max_keys IS NOT INITIAL.
    IF l_first_parameter = abap_true.
      CONCATENATE l_request
                  '?max-keys='
                  i_max_keys
                  INTO l_request.
    ELSE.
      CONCATENATE l_request
                  '&max-keys='
                  i_max_keys
                  INTO l_request.
    ENDIF.
    l_first_parameter = abap_false.
  ENDIF.

  CALL METHOD rest_get
    EXPORTING
      i_request           = l_request
      i_request_headers   = i_request_headers
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


METHOD list_objects_v2.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 15th March 2016
* Implementation of GET Bucket (List Objects) V2
* Returns an XML with the Bucket List (max 1000 items)
* If prefix is given, the returns all the files starting with this prefix
*--------------------------------------------------------------------*
  DATA: l_request TYPE string.
  DATA: l_response_xcontent TYPE xstring.

  l_request = '/list-type=2'.

  IF i_prefix IS NOT INITIAL.
    CONCATENATE l_request
                '&prefix='
                i_prefix
                INTO l_request.
  ENDIF.

  IF i_continuation_token IS NOT INITIAL.
    CONCATENATE l_request
                '&continuation-token='
                i_continuation_token
                INTO l_request.
  ENDIF.

  IF i_max_keys IS NOT INITIAL.
    CONCATENATE l_request
                '&max-keys='
                i_max_keys
                INTO l_request.
  ENDIF.

  IF i_delimiter IS NOT INITIAL.
    CONCATENATE l_request
                '&delimiter='
                i_delimiter
                INTO l_request.
  ENDIF.

  IF i_start_after IS NOT INITIAL.
    CONCATENATE l_request
                '&start-after='
                i_start_after
                INTO l_request.
  ENDIF.

  CALL METHOD rest_get
    EXPORTING
      i_request           = l_request
      i_request_headers   = i_request_headers
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


METHOD list_parts_multipart_upload.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 25th Nov 2014
* List parts of a multipart upload.
*--------------------------------------------------------------------*
  DATA: l_request TYPE string.
  DATA: l_response_xcontent TYPE xstring.

  CONCATENATE '/'
             i_object_name
             '?uploadId='
             i_upload_id
             INTO l_request.

  CALL METHOD rest_get
    EXPORTING
      i_request           = l_request
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


METHOD log_multipart_upload.
*-------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 25th Nov 2014
* Logs multipart upload in table ZLNKEMPART_UPLD
*--------------------------------------------------------------------*
  DATA: ls_ZLNKEmpart_upld TYPE ZLNKEmpart_upld.
  DATA: l_timestampl TYPE timestampl.
  DATA: l_guid TYPE ZLNKEguid.
  DATA: l_timestampl_c TYPE char21.
  DATA: l_datum TYPE sy-datum.

  CASE i_state.
    WHEN c_mpart_upld_state_inprogress.

      GET TIME STAMP FIELD l_timestampl.
      CALL FUNCTION 'SYSTEM_UUID_CREATE'
        IMPORTING
          uuid = l_guid.
      ls_ZLNKEmpart_upld-guid = l_guid.
      ls_ZLNKEmpart_upld-bucket = get_bucket_name_external( ).
      ls_ZLNKEmpart_upld-object_name = i_object_name.
      ls_ZLNKEmpart_upld-upload_id = i_upload_id.
      ls_ZLNKEmpart_upld-timestamp = l_timestampl.
      ls_ZLNKEmpart_upld-state = c_mpart_upld_state_inprogress.
      MODIFY ZLNKEmpart_upld FROM ls_ZLNKEmpart_upld.

    WHEN c_mpart_upld_state_compl_ok
      OR c_mpart_upld_state_compl_err
      OR c_mpart_upld_state_aborted.
      SELECT SINGLE *                                       "#EC *
          INTO ls_ZLNKEmpart_upld
      FROM ZLNKEmpart_upld
      WHERE upload_id = i_upload_id.

      IF sy-subrc = 0.
        ls_ZLNKEmpart_upld-state = i_state.
        MODIFY ZLNKEmpart_upld FROM ls_ZLNKEmpart_upld.
      ENDIF.

  ENDCASE.

* Deletes any log completed or aborted older than one day
  l_datum = sy-datum - 1.
  l_timestampl_c(8) = l_datum.
  l_timestampl_c+8(6) = sy-uzeit.
  l_timestampl = l_timestampl_c.

  DELETE FROM ZLNKEmpart_upld
  WHERE timestamp < l_timestampl
    AND state IN (c_mpart_upld_state_compl_ok,
                  c_mpart_upld_state_aborted).

ENDMETHOD.


METHOD put_bucket_lifecycle.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 10th April 2014
* Puts Bucket Lifecycle (days)
*--------------------------------------------------------------------*
  DATA: lt_request_headers TYPE tihttpnvp.
  DATA: ls_header TYPE ihttpnvp.
  DATA: l_request TYPE string.
  DATA: l_xcontent TYPE xstring.
  DATA: l_md5 TYPE string.
  DATA: l_err_msg TYPE string.
  DATA: lr_ZLNKEcx_aws_s3 TYPE REF TO ZLNKEcx_aws_s3.
  DATA: lr_abap_message_digest TYPE REF TO cx_abap_message_digest.

* Get XML
  l_xcontent = get_xml_bucket_lifecycle_days( i_days ).

* Get MD5 of XML
  TRY.
      l_md5 = ZLNKEcl_hash=>hash_md5_for_hex_base64( l_xcontent ).
    CATCH cx_abap_message_digest INTO lr_abap_message_digest.
      RAISE EXCEPTION TYPE ZLNKEcx_aws_s3
                      EXPORTING previous = lr_abap_message_digest.
  ENDTRY.

* Adds to header Content-MD5
  ls_header-name = 'Content-MD5'.                           "#EC NOTEXT
  ls_header-value = l_md5.
  APPEND ls_header TO lt_request_headers.

* Request
  l_request = '/?lifecycle'.

  TRY.
      CALL METHOD rest_put
        EXPORTING
          i_request          = l_request
          i_xcontent         = l_xcontent
          i_request_headers  = lt_request_headers
        IMPORTING
          e_http_status      = e_http_status
          e_response_headers = e_response_headers
          e_response_content = e_response_content.

      IF e_http_status <> ZLNKEcl_http=>c_status_200_ok.
        l_err_msg = ZLNKEcl_xml_utils=>get_node_value_from_xmlstring( "#EC NOTEXT
                                    i_xml_string = e_response_content
                                    i_node_name = 'Message' ).
*       067  Error editing Bucket &: &
        MESSAGE i067 WITH attr_bucket_name l_err_msg INTO l_err_msg.
        ZLNKEcx_aws_s3=>raise_from_sy_msg( ).
      ENDIF.

    CATCH ZLNKEcx_aws_s3 INTO lr_ZLNKEcx_aws_s3.

      CALL METHOD ZLNKEcl_log=>append_log_bucket_lifecycle
        EXPORTING
          i_bucket_name = attr_bucket_name
          i_lifecycle   = i_days
          i_exception   = lr_ZLNKEcx_aws_s3.

      RAISE EXCEPTION lr_ZLNKEcx_aws_s3.

  ENDTRY.

  CALL METHOD ZLNKEcl_log=>append_log_bucket_lifecycle
    EXPORTING
      i_bucket_name = attr_bucket_name
      i_lifecycle   = i_days.

ENDMETHOD.


METHOD put_object.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 28th March 2014
* Given an object name, a content and optionally MIME type puts the object
* Notes:
*  1-To create a Folder, give an object name ending with / and don't give
*    any content, for example:
*      MyFolder/
*  2-To create a File in a Folder, give the destination path. If folder
*    is not existing, it will be created first and after the file. Example:
*      MyFolder/TestFile.txt
*--------------------------------------------------------------------*
  DATA: lt_request_headers TYPE tihttpnvp,
        ls_header TYPE ihttpnvp.
  DATA: l_request TYPE string.
  DATA: l_xcontent TYPE xstring.
  DATA: l_length TYPE i.
  DATA: l_object_name TYPE string.
  DATA: lv_msg TYPE string.

  l_object_name = i_object_name.
  IF i_escape_url = abap_true.
    l_object_name = ZLNKEcl_http=>escape_url( l_object_name ).
  ENDIF.

  l_length = XSTRLEN( i_xcontent ).

*  26/4/2016 Multipart upload with server side encryption gives an error,
*  HTTP 400 Bad request, i
*  <Message>x-amz-server-side-encryption header is not supported for this operation.</Message>
*  As a work-around, disable multipart upload in case the bucket has server side encryption
*  TODO: It is pending to investigate and to solve
  IF l_length >= c_threshold_mpart
    AND attr_server_encrypt = abap_false.
*   If file size is larger than c_threshold_mpart uploads it
*   using multipart upload.
    CALL METHOD put_object_multipart_upload
      EXPORTING
        i_object_name      = l_object_name
        i_xcontent         = i_xcontent
        i_request_headers  = i_request_headers
        i_mime_type        = i_mime_type
        i_part_size        = c_mpart_size
        i_escape_url       = i_escape_url
      IMPORTING
        e_http_status      = e_http_status
        e_response_headers = e_response_headers
        e_response_content = e_response_content.
  ELSE.
    CONCATENATE '/'
               l_object_name
               INTO l_request.

    READ TABLE i_request_headers WITH KEY name = 'Content-Type' "#EC NOTEXT
                                 TRANSPORTING NO FIELDS.
    IF sy-subrc <> 0.
      ls_header-name = 'Content-Type'.                      "#EC NOTEXT
      ls_header-value = i_mime_type.
      APPEND ls_header TO lt_request_headers.
    ENDIF.
    APPEND LINES OF i_request_headers TO lt_request_headers.

    IF attr_server_encrypt = abap_true.
      ls_header-name = 'x-amz-server-side-encryption'.
      ls_header-value = 'AES256'.
      APPEND ls_header TO lt_request_headers.
    ENDIF.

    l_xcontent = zip_and_encrypt( i_xcontent ).

    CALL METHOD rest_put
      EXPORTING
        i_request          = l_request
        i_xcontent         = l_xcontent
        i_request_headers  = lt_request_headers
      IMPORTING
        e_http_status      = e_http_status
        e_response_headers = e_response_headers
        e_response_content = e_response_content.
  ENDIF.

  IF e_http_status <> ZLNKEcl_http=>c_status_200_ok.
*   082	Put object failed. HTTP_STATUS: &
    lv_msg = ZLNKEcl_http=>get_reason_by_status( e_http_status ).
    MESSAGE i082(ZLNKEaws_s3) WITH e_http_status lv_msg INTO lv_msg.
    ZLNKEcx_aws_s3=>raise_from_sy_msg( ).
  ENDIF.

ENDMETHOD.


METHOD put_object_multipart_upload.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 18th Nov 2014
* Given an object name, a content and optionally MIME type puts the
* object using multipart upload
*--------------------------------------------------------------------*
  DATA: l_xcontent TYPE xstring.
  DATA: lt_xcontent TYPE xstring_table.
  DATA: l_upload_id TYPE string.
  DATA: l_part TYPE i.
  DATA: l_part_number TYPE string.
  DATA: l_etag TYPE string.
  DATA: lt_etags TYPE ZLNKEmpart_upload_tt,
        ls_etags TYPE ZLNKEmpart_upload_st.
  DATA: l_retries TYPE i.
  DATA: l_aborted TYPE abap_bool.
  DATA: l_object_name TYPE string.

  l_object_name = i_object_name.
  IF i_escape_url = abap_true.
    l_object_name = ZLNKEcl_http=>escape_url( l_object_name ).
  ENDIF.

* Zips and or encrypts according to bucket properties
  l_xcontent = zip_and_encrypt( i_xcontent ).

* Split content in parts
  CALL METHOD ZLNKEcl_string_conversions=>xstring_to_xstring_tab
    EXPORTING
      i_xstring       = l_xcontent
      i_line_length   = i_part_size
    RECEIVING
      e_xstring_table = lt_xcontent.

* Initiate Multipart Upload
  CALL METHOD initiate_multipart_upload
    EXPORTING
      i_object_name      = l_object_name
    IMPORTING
      e_http_status      = e_http_status
      e_response_headers = e_response_headers
      e_upload_id        = l_upload_id.

  CHECK e_http_status = ZLNKEcl_http=>c_status_200_ok.

* For each part, uploads it.
  LOOP AT lt_xcontent INTO l_xcontent.
    l_part = sy-tabix.
    l_part_number = l_part.

    l_retries = c_mpart_upld_retries.
    DO.
      CLEAR e_http_status.
      CLEAR e_response_headers[].
      CALL METHOD upload_part_multipart_upload
        EXPORTING
          i_object_name      = l_object_name
          i_part_number      = l_part_number
          i_upload_id        = l_upload_id
          i_xcontent         = l_xcontent
        IMPORTING
          e_http_status      = e_http_status
          e_etag             = l_etag
          e_response_headers = e_response_headers.
      IF e_http_status = ZLNKEcl_http=>c_status_200_ok.
*       Status OK, don't need to retry
        EXIT. "Leaves the loop
      ENDIF.
*     Status was not 200. Retry
      l_retries = l_retries - 1.
      IF l_retries = 0.
*       Retries done. Leave the loop.
        EXIT.
      ENDIF.
    ENDDO.

    IF e_http_status <> ZLNKEcl_http=>c_status_200_ok.
*     If we come here, abort multipart upload.
      CALL METHOD abort_multipart_upload
        EXPORTING
          i_object_name = l_object_name
          i_upload_id   = l_upload_id.
      l_aborted = abap_true.
*     Aborted, leave the loop.
      EXIT.
    ENDIF.

    ls_etags-part_number = l_part.
    ls_etags-etag = l_etag.
    APPEND ls_etags TO lt_etags.
  ENDLOOP.

  CHECK l_aborted = abap_false.

* Completes multipart upload.
  CLEAR e_http_status.
  CLEAR e_response_headers[].
  CALL METHOD complete_multipart_upload
    EXPORTING
      i_object_name      = l_object_name
      i_upload_id        = l_upload_id
      i_t_etags          = lt_etags
    IMPORTING
      e_http_status      = e_http_status
      e_response_headers = e_response_headers
      e_response_content = e_response_content.

  IF e_http_status <> ZLNKEcl_http=>c_status_200_ok.
*   If we come here, abort multipart upload.
    CALL METHOD abort_multipart_upload
      EXPORTING
        i_object_name = l_object_name
        i_upload_id   = l_upload_id.
  ENDIF.

ENDMETHOD.


METHOD rest_delete.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 28th March 2014
* Executes a HEAD request to AWS S3
*--------------------------------------------------------------------*
  DATA: l_response_xcontent TYPE xstring.

  CALL METHOD rest
    EXPORTING
      i_rfcdest           = attr_rfcdest
      i_bucket_name       = attr_bucket_name
      i_region            = attr_region
      i_http_method       = ZLNKEcl_http=>c_method_delete
      i_request           = i_request
      i_body_hash         = ZLNKEcl_hash=>c_empty_body_sha256
      i_request_headers   = i_request_headers
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


METHOD REST_GET.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 28th March 2014
* Executes a GET request to AWS S3
*--------------------------------------------------------------------*

  CALL METHOD rest
    EXPORTING
      i_rfcdest            = attr_rfcdest
      i_bucket_name        = attr_bucket_name
      i_region             = attr_region
      i_http_method        = ZLNKEcl_http=>c_method_get
      i_request            = i_request
      i_body_hash          = ZLNKEcl_hash=>c_empty_body_sha256
      i_request_headers    = i_request_headers
    IMPORTING
      e_http_status	       = e_http_status
      e_response_headers   = e_response_headers
      e_response_xcontent  = e_response_xcontent.

ENDMETHOD.


METHOD rest_head.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 28th March 2014
* Executes a HEAD request to AWS S3
*--------------------------------------------------------------------*
  DATA: l_response_xcontent TYPE xstring.

  CALL METHOD rest
    EXPORTING
      i_rfcdest           = attr_rfcdest
      i_bucket_name       = attr_bucket_name
      i_region            = attr_region
      i_http_method       = ZLNKEcl_http=>c_method_head
      i_request           = i_request
      i_body_hash         = ZLNKEcl_hash=>c_empty_body_sha256
      i_request_headers   = i_request_headers
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


METHOD rest_post.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 24th Nov 2014
* Executes a POST request to AWS S3
*--------------------------------------------------------------------*
  DATA: l_body_hash TYPE string.
  DATA: l_response_xcontent TYPE xstring.
  DATA: lr_abap_message_digest TYPE REF TO cx_abap_message_digest.
* Calculates the hash of the content
  TRY.
      CALL METHOD ZLNKEcl_hash=>hash_sha256_for_hex
        EXPORTING
          i_xstring = i_xcontent
        RECEIVING
          e_hash    = l_body_hash.
    CATCH cx_abap_message_digest INTO lr_abap_message_digest.
      RAISE EXCEPTION TYPE ZLNKEcx_aws_s3
                      EXPORTING previous = lr_abap_message_digest.
  ENDTRY.

  CALL METHOD rest
    EXPORTING
      i_rfcdest           = attr_rfcdest
      i_bucket_name       = attr_bucket_name
      i_region            = attr_region
      i_http_method       = ZLNKEcl_http=>c_method_post
      i_request           = i_request
      i_body_hash         = l_body_hash
      i_xcontent          = i_xcontent
      i_request_headers   = i_request_headers
    IMPORTING
      e_http_status	      = e_http_status
      e_response_headers  = e_response_headers
      e_response_xcontent = l_response_xcontent.

  CALL METHOD ZLNKEcl_string_conversions=>xstring_to_string
    EXPORTING
      input  = l_response_xcontent
    IMPORTING
      output = e_response_content.

ENDMETHOD.


METHOD rest_put.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 28th March 2014
* Executes a PUT request to AWS S3
*--------------------------------------------------------------------*
  DATA: l_body_hash TYPE string.
  DATA: l_response_xcontent TYPE xstring.
  DATA: lr_abap_message_digest TYPE REF TO cx_abap_message_digest.
* Calculates the hash of the content
  TRY.
      CALL METHOD ZLNKEcl_hash=>hash_sha256_for_hex
        EXPORTING
          i_xstring = i_xcontent
        RECEIVING
          e_hash    = l_body_hash.
    CATCH cx_abap_message_digest INTO lr_abap_message_digest.
      RAISE EXCEPTION TYPE ZLNKEcx_aws_s3
                      EXPORTING previous = lr_abap_message_digest.
  ENDTRY.

  CALL METHOD rest
    EXPORTING
      i_rfcdest           = attr_rfcdest
      i_bucket_name       = attr_bucket_name
      i_region            = attr_region
      i_http_method       = ZLNKEcl_http=>c_method_put
      i_request           = i_request
      i_body_hash         = l_body_hash
      i_xcontent          = i_xcontent
      i_request_headers   = i_request_headers
    IMPORTING
      e_http_status	      = e_http_status
      e_response_headers  = e_response_headers
      e_response_xcontent = l_response_xcontent.

  CALL METHOD ZLNKEcl_string_conversions=>xstring_to_string
    EXPORTING
      input  = l_response_xcontent
    IMPORTING
      output = e_response_content.

ENDMETHOD.


METHOD upload_part_multipart_upload.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 25th Nov 2014
* Given an object name, a content and optionally MIME type puts the object
* as multipart upload
*--------------------------------------------------------------------*
  DATA: lt_request_headers TYPE tihttpnvp,
        ls_header TYPE ihttpnvp.
  DATA: l_request TYPE string.

  CONCATENATE '/'
             i_object_name
             '?partNumber='
             i_part_number
             '&uploadId='
             i_upload_id
             INTO l_request.

  CONDENSE l_request NO-GAPS.

  READ TABLE i_request_headers WITH KEY name = 'Content-Type' "#EC NOTEXT
                               TRANSPORTING NO FIELDS.
  IF sy-subrc <> 0.
    ls_header-name = 'Content-Type'.                        "#EC NOTEXT
    ls_header-value = i_mime_type.
    APPEND ls_header TO lt_request_headers.
  ENDIF.
  APPEND LINES OF i_request_headers TO lt_request_headers.

  IF attr_server_encrypt = abap_true.
    ls_header-name = 'x-amz-server-side-encryption'.
    ls_header-value = 'AES256'.
    APPEND ls_header TO lt_request_headers.
  ENDIF.

  CALL METHOD rest_put
    EXPORTING
      i_request          = l_request
      i_xcontent         = i_xcontent
      i_request_headers  = lt_request_headers
    IMPORTING
      e_http_status      = e_http_status
      e_response_headers = e_response_headers
      e_response_content = e_response_content.

* Returns ETag
  READ TABLE e_response_headers WITH KEY name = 'etag'
                 INTO ls_header.
  IF sy-subrc <> 0.
    READ TABLE e_response_headers WITH KEY name = 'ETag'
                   INTO ls_header.
  ENDIF.
  IF sy-subrc = 0.
    e_etag = ls_header-value.
    REPLACE ALL  OCCURRENCES OF '"' IN e_etag WITH space.
    CONDENSE e_etag NO-GAPS.
  ENDIF.

ENDMETHOD.


METHOD zip_and_encrypt.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 28th Nov 2014
* Zips and or encrypts the content according to bucket options.
*--------------------------------------------------------------------*
  DATA: lr_cx_root TYPE REF TO cx_root.
  DATA: l_xcontent TYPE xstring.
  DATA: l_exception_msg TYPE string.

  IF attr_zip = abap_true.
    TRY.
*       If the bucket is using compression, compress the content
        CALL METHOD cl_abap_gzip=>compress_binary
          EXPORTING
            raw_in   = i_xcontent
          IMPORTING
            gzip_out = l_xcontent.
      CATCH cx_root INTO lr_cx_root.                     "#EC CATCH_ALL
        l_exception_msg = lr_cx_root->get_text( ).
*       063	Exception in method &: &
        MESSAGE i063 WITH 'ZIP_AND_ENCRYPT' l_exception_msg INTO l_exception_msg.
        ZLNKEcx_aws_s3=>raise_from_sy_msg( ).
    ENDTRY.
  ELSE.
    l_xcontent = i_xcontent.
  ENDIF.

  IF attr_client_encrypt = abap_true.
*   If the bucket is using client side encryption, envelope content (SSF)
    l_xcontent = ZLNKEcl_ssf=>envelope( l_xcontent ).
  ENDIF.

  e_xcontent = l_xcontent.

ENDMETHOD.
ENDCLASS.
