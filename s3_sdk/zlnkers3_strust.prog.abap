*&---------------------------------------------------------------------*
*& Report  ZLNKERS3_STRUST
*&
*&---------------------------------------------------------------------*
*& Company: RocketSteam
*& Author: Jordi Escoda, 23th March 2016
*& From time to time AWS invalidates SSL certificates. When this happens
*& is not possible to store in S3 from this system.
*& This program maintains AWS SSL certificates in STRUST.
*& Flow:
*&    For each endpoint...
*&      - by openssl get SSL certificate from AWS endpoint
*&      - Import certificate to STRUST in SSL client SSL Client (Standar
*&    Restart ICM in case certificate(s) is successfully installed
*&    so that the new certificate is taken into account
*&
*& In case flag "Create SSL Client (Standard)" is set, it creates PSE if
*& does not exist (for initial installation).
*&
*& In case flag "Remove old AWS certificates" is set, it removes p_days before
*& the expired certificates. In this way can be avoided the warning popup dialog
*& issued at logon 2 days before certification expiration.
*&
*& It is advised to schedule as a background job in a daily basis.
*&
*& Dependencies:
*&  It depends on OPENSSL
*&  In SM69 there must be an entry with:
*&    Type: Customer
*&    Command name: ZOPENSSL
*&    Op.system: Linux
*&    External program: openssl
*&    Leave empty "Parameters of external program
*&---------------------------------------------------------------------*
REPORT zlnkers3_strust.

*--------------------------------------------------------------------*
* Tables and types
*--------------------------------------------------------------------*
TABLES: zlnkeregion.

TYPE-POOLS: abap.

*--------------------------------------------------------------------*
* Selection screen
*--------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
SELECT-OPTIONS: s_endpnt FOR zlnkeregion-endpoint NO INTERVALS.
PARAMETERS: p_rmold AS CHECKBOX DEFAULT abap_true USER-COMMAND chkbox. "Remove old certs
PARAMETERS: p_days TYPE i DEFAULT 3.
SELECTION-SCREEN SKIP.
SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-002.
PARAMETERS: p_sslcr AS CHECKBOX. "Create SSL Client (Standard)
SELECTION-SCREEN END OF BLOCK b2.
SELECTION-SCREEN END OF BLOCK b1.


*----------------------------------------------------------------------*
*       CLASS lcx_ssf_krn_certexists DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcx_ssf_krn_certexists DEFINITION INHERITING FROM cx_static_check.
ENDCLASS.                    "lcx_ssf_krn_certexists DEFINITION

*----------------------------------------------------------------------*
*       CLASS lcl_ssl DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_ssl DEFINITION FINAL.
  PUBLIC SECTION.
    CLASS-METHODS:
      run,
      set_default_endpoints,
      selection_screen_output.
  PRIVATE SECTION.
    CONSTANTS: c_pse_name TYPE ssf_pse_h-filename VALUE 'SAPSSLC.pse'.
    CLASS-METHODS:
      run_certs,
      get_result_openssl
        IMPORTING im_endpoint TYPE zlnkeregion-endpoint
        RETURNING value(re_certb64) TYPE string
        RAISING zlnkecx_aws_s3,
      ssfc_base64_decode
        IMPORTING im_certb64 TYPE string
        RETURNING value(re_certificate) TYPE xstring
        RAISING zlnkecx_aws_s3,
      import_certificate
        IMPORTING im_certb64 TYPE string
        RAISING zlnkecx_aws_s3
                lcx_ssf_krn_certexists,
      ssfpse_filename
        EXPORTING ex_psename TYPE ssfpsename
                  ex_profile TYPE localfile
                  ex_psetext TYPE string
        RAISING zlnkecx_aws_s3,
      lock_ssfpse
        IMPORTING im_psename TYPE ssfpsename
        RAISING zlnkecx_aws_s3,
      unlock_ssfpse
        IMPORTING im_psename TYPE ssfpsename
        RAISING zlnkecx_aws_s3,
      restart_icm
        RAISING zlnkecx_aws_s3,
      create_ssl_client_standard
        RAISING zlnkecx_aws_s3,
      ssfpse_check
        RETURNING value(re_success) TYPE abap_bool
        RAISING zlnkecx_aws_s3,
      remove_old_certs
        RAISING zlnkecx_aws_s3,
      parse_certificate
        IMPORTING im_certificate TYPE xstring
        EXPORTING ex_subject TYPE string
                  ex_issuer TYPE string
                  ex_serialno TYPE string
                  ex_validfrom TYPE string
                  ex_validto TYPE string
                  ex_algid TYPE string
                  ex_fingerprint TYPE string
        RAISING zlnkecx_aws_s3,
      cert_is_to_remove
        IMPORTING im_subject TYPE string
                  im_serialno TYPE string
                  im_validto TYPE string
        RETURNING value(re_cert_is_to_remove) TYPE abap_bool,
      remove_cert
        IMPORTING im_subject TYPE string
                  im_issuer TYPE string
                  im_serialno TYPE string
        RAISING zlnkecx_aws_s3.

ENDCLASS.                    "lcl_ssl DEFINITION


*----------------------------------------------------------------------*
*       CLASS lcl_ssl IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_ssl IMPLEMENTATION.

*--------------------------------------------------------------------*
* Sets default endpoints
*--------------------------------------------------------------------*
  METHOD set_default_endpoints.
    DATA: lt_endpoint TYPE STANDARD TABLE OF zlnkeendpoint_de.
    DATA: lv_endpoint TYPE zlnkeendpoint_de.
    DATA: ls_endpnt LIKE LINE OF s_endpnt.

    ls_endpnt-sign = 'I'.
    ls_endpnt-option = 'EQ'.

*   Endpoint for amazon Root
    ls_endpnt-low = 'aws.amazon.com'.
    APPEND ls_endpnt TO s_endpnt.

*   Endpoints for S3
    SELECT endpoint
       INTO TABLE lt_endpoint
    FROM zlnkeregion.

    LOOP AT lt_endpoint INTO lv_endpoint.
      ls_endpnt-low = lv_endpoint.
      APPEND ls_endpnt TO s_endpnt.
    ENDLOOP.

*   Endpoint for IAM
    ls_endpnt-low = zlnkecl_aws_iam=>get_host_name( ).
    APPEND ls_endpnt TO s_endpnt.

  ENDMETHOD.                    "set_default_endpoints

*--------------------------------------------------------------------*
* Removes old cert
*--------------------------------------------------------------------*
  METHOD remove_cert.
    DATA: lv_psename TYPE ssfpsename.
    DATA: lv_profile TYPE localfile.
    DATA: lv_profile2 TYPE ssfparms-pab.
    DATA: lv_subrc TYPE sy-subrc.

*   Gets PSE and path
    ssfpse_filename( IMPORTING ex_psename = lv_psename
                               ex_profile = lv_profile ).

*   Enqueue PSE
    lock_ssfpse( lv_psename ).

    lv_profile2 = lv_profile.
    CALL FUNCTION 'SSFC_REMOVECERTIFICATE'
      EXPORTING
        profile               = lv_profile2
        subject               = im_subject
        issuer                = im_issuer
        serialno              = im_serialno
      EXCEPTIONS
        ssf_krn_error         = 1
        ssf_krn_nomemory      = 2
        ssf_krn_nossflib      = 3
        ssf_krn_invalid_par   = 4
        ssf_krn_nocertificate = 5
        OTHERS                = 6.

    IF sy-subrc <> 0.
      lv_subrc = sy-subrc.
      unlock_ssfpse( lv_psename ).
      zlnkecx_aws_s3=>raise_from_fm_exception(
                  i_funcname = 'SSFC_REMOVECERTIFICATE'
                  i_sy_subrc =  lv_subrc ).
    ENDIF.

*   Store PSE
    CALL FUNCTION 'SSFPSE_STORE'
      EXPORTING
        fname             = lv_profile
        psename           = lv_psename
      EXCEPTIONS
        file_load_failed  = 1
        storing_failed    = 2
        authority_missing = 3
        OTHERS            = 4.

    IF sy-subrc <> 0.
      lv_subrc = sy-subrc.
      unlock_ssfpse( lv_psename ).
      zlnkecx_aws_s3=>raise_from_fm_exception(
                  i_funcname = 'SSFPSE_STORE'
                  i_sy_subrc =  lv_subrc ).
    ENDIF.

*   Dequeue PSE
    unlock_ssfpse( lv_psename ).

    FORMAT COLOR COL_TOTAL.
    WRITE:/ 'Certificate with serial number',
            im_serialno,
            'has been removed'.
  ENDMETHOD.                    "remove_cert

*--------------------------------------------------------------------*
* Parses certificate
*--------------------------------------------------------------------*
  METHOD parse_certificate.

    CALL FUNCTION 'SSFC_PARSE_CERTIFICATE'
      EXPORTING
        certificate         = im_certificate
      IMPORTING
        subject             = ex_subject
        issuer              = ex_issuer
        serialno            = ex_serialno
        validfrom           = ex_validfrom
        validto             = ex_validto
        algid               = ex_algid
        fingerprint         = ex_fingerprint
      EXCEPTIONS
        ssf_krn_error       = 1
        ssf_krn_nomemory    = 2
        ssf_krn_nossflib    = 3
        ssf_krn_invalid_par = 4
        OTHERS              = 5.

    IF sy-subrc <> 0.
      zlnkecx_aws_s3=>raise_from_fm_exception( 'SSFC_PARSE_CERTIFICATE' ).
    ENDIF.

  ENDMETHOD.                    "PARSE_CERTIFICATE

*--------------------------------------------------------------------*
* Returns true if cert is from AWS and is expired
*--------------------------------------------------------------------*
  METHOD cert_is_to_remove.
    DATA: lv_timestamp TYPE timestamp.
    DATA: lv_current_timestamp TYPE timestamp.
    DATA: lv_seconds TYPE i.

    IF im_subject CS 'amazon'.
      TRY.
          lv_timestamp = im_validto(14).
          lv_seconds = p_days * 24 * 60 * 60.
          TRY.
              lv_timestamp = cl_abap_tstmp=>subtractsecs(
                                        tstmp   = lv_timestamp
                                        secs    = lv_seconds ).
            CATCH cx_parameter_invalid_range.
              lv_timestamp = im_validto(14).
            CATCH cx_parameter_invalid_type.
              lv_timestamp = im_validto(14).
          ENDTRY.

          GET TIME STAMP FIELD lv_current_timestamp.
          IF lv_current_timestamp > lv_timestamp.
            FORMAT COLOR COL_TOTAL.
            WRITE:/ 'Certificate subject',
                    im_subject,
                    'with serial number',
                    im_serialno,
                    'valid to',
                    im_validto,
                    'is to be removed'.
            re_cert_is_to_remove = abap_true.
          ENDIF.
        CATCH cx_sy_range_out_of_bounds.                "#EC NO_HANDLER
        CATCH cx_sy_conversion_no_number.               "#EC NO_HANDLER
      ENDTRY.
    ENDIF.

  ENDMETHOD.                    "cert_is_to_remove

*--------------------------------------------------------------------*
* Removes old AWS Certs
*--------------------------------------------------------------------*
  METHOD remove_old_certs.
    DATA: lt_certificatelist TYPE ssfbintab.
    DATA: lv_certificate TYPE xstring.
    DATA: lv_profile TYPE localfile.
    DATA: lv_profile2 TYPE ssfparms-pab.
    DATA: lv_subject TYPE string.
    DATA: lv_issuer TYPE string.
    DATA: lv_validto TYPE string.
    DATA: lv_serialno TYPE string.
    DATA: lv_cert_removed TYPE abap_bool.

*   Gets PSE and path
    ssfpse_filename( IMPORTING ex_profile = lv_profile ).

    lv_profile2 = lv_profile.
    CALL FUNCTION 'SSFC_GET_CERTIFICATELIST'
      EXPORTING
        profile               = lv_profile2
      IMPORTING
        certificatelist       = lt_certificatelist
      EXCEPTIONS
        ssf_krn_error         = 1
        ssf_krn_nomemory      = 2
        ssf_krn_nossflib      = 3
        ssf_krn_invalid_par   = 4
        ssf_krn_nocertificate = 5
        OTHERS                = 6.

    IF sy-subrc <> 0.
      zlnkecx_aws_s3=>raise_from_fm_exception( 'SSFC_GET_CERTIFICATELIST' ).
    ENDIF.

    LOOP AT lt_certificatelist INTO lv_certificate.
      parse_certificate( EXPORTING im_certificate = lv_certificate
                         IMPORTING ex_subject = lv_subject
                                   ex_issuer = lv_issuer
                                   ex_serialno = lv_serialno
                                   ex_validto = lv_validto ).
      IF cert_is_to_remove( im_subject = lv_subject
                            im_serialno = lv_serialno
                            im_validto = lv_validto ) = abap_true.
        remove_cert( im_subject = lv_subject
                     im_issuer = lv_issuer
                     im_serialno = lv_serialno ).
        lv_cert_removed = abap_true.
      ENDIF.
    ENDLOOP.

    IF lv_cert_removed = abap_true.
      restart_icm( ).
    ENDIF.
  ENDMETHOD.                    "remove_old_certs

*--------------------------------------------------------------------*
* Checks PSE SAPSSLC.pse
*--------------------------------------------------------------------*
  METHOD ssfpse_check.
    DATA: lv_crc TYPE ssfparms-ssfcrc.

    CALL FUNCTION 'SSFPSE_CHECK'
      EXPORTING
        psename           = c_pse_name
        b_silent          = abap_true
      IMPORTING
        crc               = lv_crc
      EXCEPTIONS
        authority_missing = 1
        OTHERS            = 2.

    IF sy-subrc <> 0.
      zlnkecx_aws_s3=>raise_from_fm_exception( 'SSFPSE_CHECK' ).
    ENDIF.

    IF lv_crc = 0.
      re_success = abap_true.
    ENDIF.

  ENDMETHOD.                    "ssfpse_check

*--------------------------------------------------------------------*
* Creates SSL Server Standard (STRUST)
*--------------------------------------------------------------------*
  METHOD create_ssl_client_standard.
    DATA: l_psepath TYPE stpa-file.
    DATA: l_fname TYPE rlgrap-filename.
    DATA: lt_server_list TYPE STANDARD TABLE OF msxxlist,
          ls_server_list TYPE                   msxxlist.
    DATA: l_dn TYPE certattrs-subject.
    DATA: l_license_number TYPE char10.
    DATA: lt_string_table TYPE string_table,
          l_string        TYPE string.
    DATA: l_ssf_pse_h_id TYPE ssf_pse_h-id.

    CONSTANTS: c_sap_ca TYPE string VALUE 'O=SAP Trust Community, C=DE'. "#EC NOTEXT
    CONSTANTS: c_sap_ou TYPE string VALUE 'OU=SAP Web AS'.

*   Get list of servers
    CALL FUNCTION 'TH_SERVER_LIST'
      TABLES
        list           = lt_server_list
      EXCEPTIONS
        no_server_list = 1
        OTHERS         = 2.
    IF sy-subrc <> 0.
      zlnkecx_aws_s3=>raise_from_fm_exception( 'TH_SERVER_LIST' ).
    ENDIF.

*   Builds DN
    CALL FUNCTION 'SLIC_GET_LICENCE_NUMBER'
      IMPORTING
        license_number = l_license_number.

*    READ TABLE lt_server_list INDEX 1 INTO ls_server_list.
*    CONCATENATE 'CN=' ls_server_list-host INTO l_string.
    l_string = 'CN=IDE SSL client SSL Client (Standard)'.
    APPEND l_string TO lt_string_table.
    CONCATENATE 'OU=I' l_license_number INTO l_string.
    APPEND l_string TO lt_string_table.
    APPEND c_sap_ou TO lt_string_table.
    APPEND c_sap_ca TO lt_string_table.

*    l_dn = concat_lines_of( table = lt_string_table sep = `, ` ).
    LOOP AT lt_string_table INTO l_string.
      IF sy-tabix = 1.
        l_dn = l_string.
      ELSE.
        CONCATENATE l_dn l_string INTO l_dn SEPARATED BY ', '.
      ENDIF.
    ENDLOOP.

*   Creates PSE temp
    CALL FUNCTION 'SSFPSE_CREATE'
      EXPORTING
        dn                = l_dn
        alg               = 'R'
        keylen            = 1024
      IMPORTING
        psepath           = l_psepath
      EXCEPTIONS
        ssf_unknown_error = 1
        OTHERS            = 2.
    IF sy-subrc <> 0.
      zlnkecx_aws_s3=>raise_from_fm_exception( 'SSFPSE_CREATE' ).
    ENDIF.

*   Saves PSE
    l_fname = l_psepath.
    l_ssf_pse_h_id = l_dn.
    CALL FUNCTION 'SSFPSE_STORE'
      EXPORTING
        fname             = l_fname
        psename           = c_pse_name
        id                = l_ssf_pse_h_id
      EXCEPTIONS
        file_load_failed  = 1
        storing_failed    = 2
        authority_missing = 3
        OTHERS            = 4.

    IF sy-subrc <> 0.
*     Cleanup
      DELETE DATASET l_psepath.
      zlnkecx_aws_s3=>raise_from_fm_exception( 'SSFPSE_STORE' ).
    ENDIF.

*   Distributes
    LOOP AT lt_server_list INTO ls_server_list.
      CALL FUNCTION 'SSFPSE_UPDATED' DESTINATION ls_server_list-name
        EXPORTING
          psename                = c_pse_name
        EXCEPTIONS
          authority_missing      = 1
          ssf_krn_nomemory       = 2
          ssf_krn_nossflib       = 3
          ssf_krn_invalid_par    = 4
          ssf_krn_invalid_parlen = 5
          ssf_krn_error          = 6
          database_failed        = 7
          unknown_error          = 8
          OTHERS                 = 9.
      IF sy-subrc <> 0.
*       Cleanup
        DELETE DATASET l_psepath.
        zlnkecx_aws_s3=>raise_from_fm_exception( 'SSFPSE_UPDATED' ).
      ENDIF.

    ENDLOOP.

*   Cleanup
    DELETE DATASET l_psepath.
  ENDMETHOD.                    "create_ssl_client_standard

*--------------------------------------------------------------------*
* Restarts ICM.
* Equivalent to SMICM / Administration / ICM / Exit Soft / Global
*--------------------------------------------------------------------*
  METHOD restart_icm.

    CALL FUNCTION 'ICM_SHUTDOWN_ICM'
      EXPORTING
        global              = 1
        how                 = 15
      EXCEPTIONS
        icm_op_failed       = 1
        icm_get_serv_failed = 2
        icm_auth_failed     = 3
        OTHERS              = 4.
    IF sy-subrc <> 0.
      zlnkecx_aws_s3=>raise_from_fm_exception( 'ICM_SHUTDOWN_ICM' ).
    ELSE.
      WRITE:/ 'ICM restarted'.
    ENDIF.

  ENDMETHOD.                    "restart_icm

*--------------------------------------------------------------------*
* Locks PSE
*--------------------------------------------------------------------*
  METHOD lock_ssfpse.
*   Enqueue PSE
    CALL FUNCTION 'SSFPSE_ENQUEUE'
      EXPORTING
        psename         = im_psename
      EXCEPTIONS
        database_failed = 1
        foreign_lock    = 2
        internal_error  = 3
        OTHERS          = 4.

    IF sy-subrc <> 0.
      zlnkecx_aws_s3=>raise_from_fm_exception( 'SSFPSE_ENQUEUE' ).
    ENDIF.
  ENDMETHOD.                    "lock_ssfpse

*--------------------------------------------------------------------*
* Unlocks PSE
*--------------------------------------------------------------------*
  METHOD unlock_ssfpse.
    CALL FUNCTION 'SSFPSE_DEQUEUE'
      EXPORTING
        psename         = im_psename
      EXCEPTIONS
        database_failed = 1
        foreign_lock    = 2
        internal_error  = 3
        OTHERS          = 4.

    IF sy-subrc <> 0.
      zlnkecx_aws_s3=>raise_from_fm_exception( 'SSFPSE_DEQUEUE' ).
    ENDIF.
  ENDMETHOD.                    "unlock_ssfpse

*--------------------------------------------------------------------*
* Returns PSE name and profile (path to file)
*--------------------------------------------------------------------*
  METHOD ssfpse_filename.
    CALL FUNCTION 'SSFPSE_FILENAME'
      EXPORTING
        mandt         = sy-mandt
        context       = 'SSLC'  "Client
        applic        = 'DFAULT'
      IMPORTING
        psename       = ex_psename
        profile       = ex_profile
        psetext       = ex_psetext
      EXCEPTIONS
        pse_not_found = 1
        OTHERS        = 2.

    IF sy-subrc <> 0.
      zlnkecx_aws_s3=>raise_from_fm_exception( 'SSFPSE_FILENAME' ).
    ENDIF.

  ENDMETHOD.                    "SSFPSE_FILENAME

*--------------------------------------------------------------------*
* Decodes certificate
*--------------------------------------------------------------------*
  METHOD ssfc_base64_decode.
    DATA: lv_certb64  TYPE string.

*   Remove Header and Footer
    FIND REGEX '-{5}.{0,}BEGIN.{0,}-{5}(.*)-{5}.{0,}END.{0,}-{5}' IN im_certb64 SUBMATCHES lv_certb64.
    CALL FUNCTION 'SSFC_BASE64_DECODE'
      EXPORTING
        b64data                  = lv_certb64
      IMPORTING
        bindata                  = re_certificate
      EXCEPTIONS
        ssf_krn_error            = 1
        ssf_krn_noop             = 2
        ssf_krn_nomemory         = 3
        ssf_krn_opinv            = 4
        ssf_krn_input_data_error = 5
        ssf_krn_invalid_par      = 6
        ssf_krn_invalid_parlen   = 7
        OTHERS                   = 8.

    IF sy-subrc <> 0.
      zlnkecx_aws_s3=>raise_from_fm_exception( 'SSFC_BASE64_DECODE' ).
    ENDIF.

  ENDMETHOD.                    "ssfc_base64_decode

*--------------------------------------------------------------------*
* Imports certificate
*--------------------------------------------------------------------*
  METHOD import_certificate.
    DATA: lv_certificate TYPE xstring.
    DATA: lv_psename TYPE ssfpsename.
    DATA: lv_profile TYPE localfile.
    DATA: lv_profile2 TYPE ssfparms-pab.
    DATA: lv_subrc TYPE sy-subrc.

*   Gets PSE and path
    ssfpse_filename( IMPORTING ex_psename = lv_psename
                               ex_profile = lv_profile ).

*   Enqueue PSE
    lock_ssfpse( lv_psename ).

*   Decode certificate
    lv_certificate = ssfc_base64_decode( im_certb64 ).

*   check certificate
    parse_certificate( lv_certificate ).

*   Put certificate
    lv_profile2 = lv_profile.
    CALL FUNCTION 'SSFC_PUT_CERTIFICATE'
      EXPORTING
        profile             = lv_profile2
        certificate         = lv_certificate
      EXCEPTIONS
        ssf_krn_error       = 1
        ssf_krn_nomemory    = 2
        ssf_krn_nossflib    = 3
        ssf_krn_invalid_par = 4
        ssf_krn_certexists  = 5
        OTHERS              = 6.

    IF sy-subrc <> 0.
      CASE sy-subrc.
        WHEN 5.
*         Certificate already exists
          unlock_ssfpse( lv_psename ).
          RAISE EXCEPTION TYPE lcx_ssf_krn_certexists.
        WHEN OTHERS.
          lv_subrc = sy-subrc.
          unlock_ssfpse( lv_psename ).
          zlnkecx_aws_s3=>raise_from_fm_exception(
                      i_funcname = 'SSFC_PUT_CERTIFICATE'
                      i_sy_subrc =  lv_subrc ).
      ENDCASE.
    ENDIF.

*   Store PSE
    CALL FUNCTION 'SSFPSE_STORE'
      EXPORTING
        fname             = lv_profile
        psename           = lv_psename
      EXCEPTIONS
        file_load_failed  = 1
        storing_failed    = 2
        authority_missing = 3
        OTHERS            = 4.

    IF sy-subrc <> 0.
      lv_subrc = sy-subrc.
      unlock_ssfpse( lv_psename ).
      zlnkecx_aws_s3=>raise_from_fm_exception(
            i_funcname = 'SSFPSE_STORE'
            i_sy_subrc =  lv_subrc ).
    ENDIF.

*   Dequeue
    unlock_ssfpse( lv_psename ).

  ENDMETHOD.                    "import_certificate

*--------------------------------------------------------------------*
* Calls to command openssl.
* In SM69 there must be an entry with:
*  Type: Customer
*  Command name: ZOPENSSL
*  Op.system: Linux
*  External program: openssl
*  Leave empty "Parameters of external program"
*--------------------------------------------------------------------*
  METHOD get_result_openssl.
    DATA: lv_commandname TYPE sxpgcolist-name.
    DATA: lv_additional_parameters TYPE sxpgcolist-parameters.
    DATA: lt_exec_protocol TYPE STANDARD TABLE OF btcxpm,
          ls_exec_protocol TYPE btcxpm.
    DATA: lt_cert TYPE string_table.
    DATA: lv_in_certificate TYPE abap_bool.
    DATA: lv_msg TYPE string.                               "#EC NEEDED

    lv_commandname = 'ZOPENSSL'.

*   Builds parameters, for example:
*   's_client -connect s3-eu-west-1.amazonaws.com:443 -showcerts'.
    lv_additional_parameters = 's_client -connect'.
    CONCATENATE lv_additional_parameters
                im_endpoint
                INTO lv_additional_parameters SEPARATED BY space.
    CONCATENATE lv_additional_parameters
                ':443 -showcerts'
                INTO lv_additional_parameters.

    CLEAR lt_exec_protocol[].
    CALL FUNCTION 'SXPG_CALL_SYSTEM'
      EXPORTING
        commandname                = lv_commandname
        additional_parameters      = lv_additional_parameters
      TABLES
        exec_protocol              = lt_exec_protocol
      EXCEPTIONS
        no_permission              = 1
        command_not_found          = 2
        parameters_too_long        = 3
        security_risk              = 4
        wrong_check_call_interface = 5
        program_start_error        = 6
        program_termination_error  = 7
        x_error                    = 8
        parameter_expected         = 9
        too_many_parameters        = 10
        illegal_command            = 11
        OTHERS                     = 12.

    IF sy-subrc <> 0.
      zlnkecx_aws_s3=>raise_from_fm_exception( 'SXPG_CALL_SYSTEM' ).
    ENDIF.

    LOOP AT lt_exec_protocol INTO ls_exec_protocol.
      IF ls_exec_protocol-message CS 'BEGIN CERTIFICATE'.
        lv_in_certificate = abap_true.
      ENDIF.
      IF lv_in_certificate = abap_true.
        APPEND ls_exec_protocol-message TO lt_cert.
        IF ls_exec_protocol-message CS 'END CERTIFICATE'.
          EXIT. "Leaves the loop.
        ENDIF.
      ENDIF.
    ENDLOOP.

    IF lv_in_certificate = abap_false.
      MESSAGE i398(00) WITH 'Certificate not found for' im_endpoint
                            space space INTO lv_msg.
      zlnkecx_aws_s3=>raise_from_sy_msg( ).
    ENDIF.

    CONCATENATE LINES OF lt_cert INTO re_certb64.

  ENDMETHOD.                    "openssl

*--------------------------------------------------------------------*
* Selects and runs for regions and for IAM
*--------------------------------------------------------------------*
  METHOD run_certs.
    DATA: ls_endpnt LIKE LINE OF s_endpnt.
    DATA: lv_endpoint TYPE zlnkeendpoint_de.
    DATA: lv_new_cert TYPE abap_bool.
    DATA: lv_certb64 TYPE string.
    DATA: lv_msg TYPE string.
    DATA: lo_zlnkecx_aws_s3 TYPE REF TO zlnkecx_aws_s3.

*   For each endpoint...
    LOOP AT s_endpnt INTO ls_endpnt.
      lv_endpoint = ls_endpnt-low.
      TRY.
          lv_certb64 = get_result_openssl( lv_endpoint ).
          import_certificate( lv_certb64 ).
          FORMAT COLOR COL_POSITIVE.
          WRITE:/ 'Certificate import success for',
                  lv_endpoint.
          lv_new_cert = abap_true.
        CATCH zlnkecx_aws_s3 INTO lo_zlnkecx_aws_s3.
          FORMAT COLOR COL_NEGATIVE.
          WRITE:/ 'Exception!:'.
          lv_msg = lo_zlnkecx_aws_s3->get_text_as_string( ).
          WRITE: lv_msg.
        CATCH lcx_ssf_krn_certexists.
*         Reach here if certificate already exists (this is based on
*         SSL serial number)
          FORMAT COLOR COL_POSITIVE.
          WRITE:/ 'Certificate already exists for:',
                  lv_endpoint.
      ENDTRY.
    ENDLOOP.

*   If new certificate imported, restart ICM
    IF lv_new_cert = abap_true.
      TRY.
          restart_icm( ).
        CATCH zlnkecx_aws_s3 INTO lo_zlnkecx_aws_s3.
          FORMAT COLOR COL_NEGATIVE.
          WRITE:/ 'Exception!:'.
          lv_msg = lo_zlnkecx_aws_s3->get_text_as_string( ).
          WRITE: lv_msg.
      ENDTRY.
    ENDIF.
  ENDMETHOD.                    "run_certs

*--------------------------------------------------------------------*
* Main execution
*--------------------------------------------------------------------*
  METHOD run.
    DATA: lv_msg TYPE string.
    DATA: lo_zlnkecx_aws_s3 TYPE REF TO zlnkecx_aws_s3.

    TRY.
        IF p_sslcr = abap_true.
          IF ssfpse_check( ) = abap_false.
            create_ssl_client_standard( ).
            FORMAT COLOR COL_POSITIVE.
            WRITE:/ 'PSE for SSL CLient (Standard) created'.
          ENDIF.
        ENDIF.

        run_certs( ).

        IF p_rmold = abap_true.
          remove_old_certs( ).
        ENDIF.
      CATCH zlnkecx_aws_s3 INTO lo_zlnkecx_aws_s3.
        FORMAT COLOR COL_NEGATIVE.
        WRITE:/ 'Exception!:'.
        lv_msg = lo_zlnkecx_aws_s3->get_text_as_string( ).
        WRITE: lv_msg.
    ENDTRY.

  ENDMETHOD.                    "run

*--------------------------------------------------------------------*
* Shows / hides selection screen elements
*--------------------------------------------------------------------*
  METHOD selection_screen_output.
    LOOP AT SCREEN.
      IF screen-name CS 'P_DAYS'.
        IF p_rmold = abap_true.
          screen-active = 1.
        ELSE.
          screen-active = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.                    "selection_screen_output

ENDCLASS.                    "lcl_ssl IMPLEMENTATION


*--------------------------------------------------------------------*
* AT SELECTION-SCREEN OUTPUT
*--------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  lcl_ssl=>selection_screen_output( ).

*--------------------------------------------------------------------*
* INITIALIZATION
*--------------------------------------------------------------------*
INITIALIZATION.
  lcl_ssl=>set_default_endpoints( ).

*--------------------------------------------------------------------*
* START-OF-SELECTION.
*--------------------------------------------------------------------*
START-OF-SELECTION.
  lcl_ssl=>run( ).