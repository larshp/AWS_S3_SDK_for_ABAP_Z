class ZLNKECL_SSF definition
  public
  final
  create private .

*"* public components of class ZLNKECL_SSF
*"* do not include other source files here!!!
public section.

  class-methods CUSTOMIZE_DEFAULT_IF_NEEDED
    raising
      ZLNKECX_AWS_S3 .
  class-methods DEVELOPE
    importing
      !I_XSTRING_ENVELOPED type XSTRING
    returning
      value(E_XSTRING) type XSTRING
    raising
      ZLNKECX_AWS_S3 .
  class-methods ENVELOPE
    importing
      !I_XSTRING type XSTRING
    returning
      value(E_XSTRING_ENVELOPED) type XSTRING
    raising
      ZLNKECX_AWS_S3 .
  class-methods SSFBIN_TO_XSTRING
    importing
      !I_SSFBIN type ZLNKESSFBIN_TT
      !I_LENGTH type I
    exporting
      !E_XSTRING type XSTRING .
  class-methods XSTRING_TO_SSFBIN
    importing
      !I_XSTRING type XSTRING
    exporting
      !E_LENGTH type I
      !E_SSFBIN type ZLNKESSFBIN_TT .
protected section.
*"* protected components of class ZLNKECL_SSF
*"* do not include other source files here!!!
private section.
*"* private components of class ZLNKECL_SSF
*"* do not include other source files here!!!

  constants C_S4_SSF_APPLICATION type SSFARGS-APPLIC value 'ZLNKES'. "#EC NOTEXT

  class-methods CREATE_PSE
    raising
      ZLNKECX_AWS_S3 .
  class-methods SSFAPPLIC_CREATE .
  class-methods SSFARGS_CREATE .
  class-methods SSF_GET_PARAMETER
    exporting
      !E_SSFTOOLKIT type SSFPARMS-SSFTOOLKIT
      !E_STR_PAB type SSFPARMS-PAB
      !E_STR_PAB_PASSWORD type SSFPARMS-PABPW
      !E_STR_PROFILEID type SSFARGS-PROFILEID
      !E_STR_PROFILE type SSFARGS-PROFILE
      !E_STR_ENCRALG type SSFARGS-ENCRALG
    raising
      ZLNKECX_AWS_S3 .
ENDCLASS.



CLASS ZLNKECL_SSF IMPLEMENTATION.


METHOD create_pse.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 15th July 2014
* Creates PSE if it does not exist
*--------------------------------------------------------------------*
  DATA: l_str_profileid	TYPE ssfargs-profileid.
  DATA: l_dn TYPE certattrs-subject.
  DATA: l_psepath TYPE stpa-file.
  DATA: l_fname TYPE rlgrap-filename.
  DATA: l_psename TYPE ssf_pse_h-filename.
  DATA: l_id TYPE ssf_pse_h-id.
  DATA: l_msg TYPE string.                                  "#EC NEEDED

* Look for the PSE name
  SELECT SINGLE pab
           INTO l_psename
  FROM ssfargs
  WHERE applic = c_s4_ssf_application.

  IF sy-subrc <> 0.
*   Since we created register previously, this should never happen!
*   037 Program error: Register not found
    MESSAGE i037 INTO l_msg.
    ZLNKEcx_aws_s3=>raise_from_sy_msg( ).
  ENDIF.

* Checks if PSE is existing.
  SELECT SINGLE filename                                    "#EC *
       INTO l_psename
  FROM ssf_pse_h
  WHERE filename = l_psename.

  IF sy-subrc <> 0.
*   PSE is not existing. Create one.
*   Since it will be a new entry in table SSF_PSE_H there is no
*   need to lock (no call to SSFPSE_ENQUEUE).

    CALL METHOD ZLNKEcl_ssf=>ssf_get_parameter
      IMPORTING
        e_str_profileid = l_str_profileid.

    l_dn = l_str_profileid.
    CALL FUNCTION 'SSFPSE_CREATE'
      EXPORTING
        dn                = l_dn
        alg               = 'S'
        keylen            = 1024
      IMPORTING
        psepath           = l_psepath
      EXCEPTIONS
        ssf_unknown_error = 1
        OTHERS            = 2.

    IF sy-subrc <> 0.
      ZLNKEcx_aws_s3=>raise_from_sy_msg( ).
    ENDIF.

    l_id = l_str_profileid.
    l_fname = l_psepath.
    CALL FUNCTION 'SSFPSE_STORE'
      EXPORTING
        fname             = l_fname
        psename           = l_psename
        id                = l_id
        host              = ' '
        instanceid        = '00'
        type              = 'PSE'
        format            = 'RAW'
        b_cleanup         = 'X'
        b_distribute      = 'X'
      EXCEPTIONS
        file_load_failed  = 1
        storing_failed    = 2
        authority_missing = 3
        OTHERS            = 4.

    IF sy-subrc <> 0.
      ZLNKEcx_aws_s3=>raise_from_sy_msg( ).
    ENDIF.
  ENDIF.

ENDMETHOD.


METHOD customize_default_if_needed.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 15th July 2014
* Customizes for default SSF Application and PSE in case it is not done.
* This is called when a Bucket is created and is marked for
* client side encryption
*--------------------------------------------------------------------*

  ssfapplic_create( ).
  ssfargs_create( ).
  create_pse( ).

ENDMETHOD.


METHOD develope.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 14th July 2014
* Receives I_XSTRING_ENVELOPED, decrypts it and returns the result
* in E_XSTRING
*--------------------------------------------------------------------*
  DATA: lt_recipient_list TYPE STANDARD TABLE OF ssfinfo,
        ls_recipient_list TYPE ssfinfo.
  DATA: lt_ostr_enveloped_data TYPE STANDARD TABLE OF ssfbin.
  DATA: lt_ostr_output_data TYPE STANDARD TABLE OF ssfbin.
  DATA: l_enveloped_data_l TYPE ssfparms-envdatalen.
  DATA: l_ssftoolkit TYPE ssfparms-ssftoolkit.
  DATA: l_str_profileid TYPE ssfargs-profileid.
  DATA: l_str_profile TYPE ssfargs-profile.
  DATA: l_ostr_output_data_l TYPE ssfparms-outdatalen.
  DATA: l_msg TYPE string. "#EC NEEDED

* Converts enveloped xstring to ssfbin table
  CALL METHOD ZLNKEcl_ssf=>xstring_to_ssfbin
    EXPORTING
      i_xstring = i_xstring_enveloped
    IMPORTING
      e_length  = l_enveloped_data_l
      e_ssfbin  = lt_ostr_enveloped_data.

* Gets application parameters (Related Transactions: SSFA, STRUST)
  CALL METHOD ZLNKEcl_ssf=>ssf_get_parameter
    IMPORTING
      e_ssftoolkit    = l_ssftoolkit
      e_str_profileid = l_str_profileid
      e_str_profile   = l_str_profile.

* Recipient list
  ls_recipient_list-id = l_str_profileid.
  ls_recipient_list-profile = l_str_profile.
  APPEND ls_recipient_list TO lt_recipient_list.

  CALL FUNCTION 'SSF_KRN_DEVELOPE'
    EXPORTING
      ssftoolkit                   = l_ssftoolkit
      str_format                   = 'PKCS7'
      b_outdec                     = 'X'
      io_spec                      = 'T'
      ostr_enveloped_data_l        = l_enveloped_data_l
    IMPORTING
      ostr_output_data_l           = l_ostr_output_data_l
    TABLES
      ostr_enveloped_data          = lt_ostr_enveloped_data
      recipient                    = lt_recipient_list
      ostr_output_data             = lt_ostr_output_data
    EXCEPTIONS
      ssf_krn_error                = 1
      ssf_krn_noop                 = 2
      ssf_krn_nomemory             = 3
      ssf_krn_opinv                = 4
      ssf_krn_nossflib             = 5
      ssf_krn_recipient_error      = 6
      ssf_krn_input_data_error     = 7
      ssf_krn_invalid_par          = 8
      ssf_krn_invalid_parlen       = 9
      ssf_fb_input_parameter_error = 10
      OTHERS                       = 11.

  IF sy-subrc <> 0.
    ZLNKEcx_aws_s3=>raise_from_sy_msg( ).
  ENDIF.

  IF i_xstring_enveloped IS NOT INITIAL AND l_ostr_output_data_l = 0.
*   If we come here, SSF is missconfigured. Check SSFA and STRUST.
*     Algorithm must be RSA with SHA-256.

*   071	SSF_KRN_DEVELOPE did not decrypt. Check algorithm in STRUST (Must be RSA)
    MESSAGE i071 into l_msg.
    ZLNKEcx_aws_s3=>raise_from_sy_msg( ).
  ENDIF.

* Converts from ssfbin table to xstring
  CALL METHOD ZLNKEcl_ssf=>ssfbin_to_xstring
    EXPORTING
      i_ssfbin  = lt_ostr_output_data
      i_length  = l_ostr_output_data_l
    IMPORTING
      e_xstring = e_xstring.

ENDMETHOD.


METHOD envelope.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 14th July 2014
* Receives I_XSTRING, encrypts it and returns the result
* in E_XSTRING_ENVELOPED
*--------------------------------------------------------------------*
  DATA: lt_ostr_input_data TYPE STANDARD TABLE OF ssfbin.
  DATA: l_ostr_input_data_l TYPE i.
  DATA: lt_recipient_list TYPE STANDARD TABLE OF ssfinfo,
        ls_recipient_list TYPE ssfinfo.
  DATA: l_ssftoolkit TYPE ssfparms-ssftoolkit.
  DATA: l_str_pab TYPE ssfparms-pab.
  DATA: l_str_pab_password TYPE ssfparms-pabpw.
  DATA: l_str_profileid TYPE ssfargs-profileid.
  DATA: l_str_encralg TYPE ssfargs-encralg.
  DATA: l_ostr_enveloped_data_l TYPE ssfparms-envdatalen.
  DATA: lt_ostr_enveloped_data TYPE STANDARD TABLE OF ssfbin.
  DATA: l_msg TYPE string.                                  "#EC NEEDED

* Converts xstring to ssfbin tab
  CALL METHOD ZLNKEcl_ssf=>xstring_to_ssfbin
    EXPORTING
      i_xstring = i_xstring
    IMPORTING
      e_length  = l_ostr_input_data_l
      e_ssfbin  = lt_ostr_input_data.

* Gets application parameters (Related Transactions: SSFA, STRUST)
  CALL METHOD ZLNKEcl_ssf=>ssf_get_parameter
    IMPORTING
      e_ssftoolkit       = l_ssftoolkit
      e_str_pab          = l_str_pab
      e_str_pab_password = l_str_pab_password
      e_str_profileid    = l_str_profileid
      e_str_encralg      = l_str_encralg.

* Recipient list
  ls_recipient_list-id = l_str_profileid.
  APPEND ls_recipient_list TO lt_recipient_list.

  CALL FUNCTION 'SSF_KRN_ENVELOPE'
    EXPORTING
      ssftoolkit                   = l_ssftoolkit
      str_format                   = 'PKCS7'
      b_inenc                      = 'X'
      io_spec                      = 'T'  "T: Internal Table
      ostr_input_data_l            = l_ostr_input_data_l
      str_pab                      = l_str_pab
      str_pab_password             = l_str_pab_password
      str_sym_encr_alg             = l_str_encralg
    IMPORTING
      ostr_enveloped_data_l        = l_ostr_enveloped_data_l
    TABLES
      ostr_input_data              = lt_ostr_input_data
      recipient_list               = lt_recipient_list
      ostr_enveloped_data          = lt_ostr_enveloped_data
    EXCEPTIONS
      ssf_krn_error                = 1
      ssf_krn_noop                 = 2
      ssf_krn_nomemory             = 3
      ssf_krn_opinv                = 4
      ssf_krn_nossflib             = 5
      ssf_krn_recipient_list_error = 6
      ssf_krn_input_data_error     = 7
      ssf_krn_invalid_par          = 8
      ssf_krn_invalid_parlen       = 9
      ssf_fb_input_parameter_error = 10
      OTHERS                       = 11.

  IF sy-subrc <> 0.
    ZLNKEcx_aws_s3=>raise_from_sy_msg( ).
  ENDIF.

  IF l_ostr_input_data_l > 0 AND l_ostr_enveloped_data_l = 0.
*   If we come here, SSF is missconfigured. Check SSFA and STRUST.
*     Algorithm must be RSA with SHA-256.

*   070	SSF_KRN_ENVELOPE did not encrypt. Check algorithm in STRUST (Must be RSA)
    MESSAGE i070 INTO l_msg.
    ZLNKEcx_aws_s3=>raise_from_sy_msg( ).
  ENDIF.

  READ TABLE lt_recipient_list INTO ls_recipient_list INDEX 1.
  IF ls_recipient_list-result <> 0.
*   068	SSF recipient & error. Result: &
    MESSAGE i068 WITH ls_recipient_list-id ls_recipient_list-result INTO l_msg.
    ZLNKEcx_aws_s3=>raise_from_sy_msg( ).
  ENDIF.

  CALL METHOD ZLNKEcl_ssf=>ssfbin_to_xstring
    EXPORTING
      i_ssfbin  = lt_ostr_enveloped_data
      i_length  = l_ostr_enveloped_data_l
    IMPORTING
      e_xstring = e_xstring_enveloped.

ENDMETHOD.


METHOD ssfapplic_create.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 15th July 2014
* Creates application in SSFAPPLIC if it does not exist.
*--------------------------------------------------------------------*
  DATA: ls_ssfapplic TYPE ssfapplic.
  DATA: ls_ssfapplict TYPE ssfapplict.

  SELECT SINGLE applic
       INTO ls_ssfapplic-applic
  FROM ssfapplic
  WHERE applic = c_s4_ssf_application.

  IF sy-subrc <> 0.
    ls_ssfapplic-applic = c_s4_ssf_application.
    ls_ssfapplic-b_toolkit = abap_true.
    ls_ssfapplic-b_format = abap_true.
    ls_ssfapplic-b_pab = abap_true.
    ls_ssfapplic-b_profid = abap_true.
    ls_ssfapplic-b_profile = abap_true.
    ls_ssfapplic-b_encralg = abap_true.
    MODIFY ssfapplic FROM ls_ssfapplic.

    ls_ssfapplict-sprsl = sy-langu.
    ls_ssfapplict-applic = c_s4_ssf_application.
    ls_ssfapplict-descript = 'RocketSteam S4'.              "#EC NOTEXT
    MODIFY ssfapplict FROM ls_ssfapplict.

    COMMIT WORK.
  ENDIF.

ENDMETHOD.


METHOD ssfargs_create.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 15th July 2014
* Creates application parameters in SSFARGS if it does not exist.
*--------------------------------------------------------------------*
  DATA: ls_ssfargs TYPE ssfargs.
  DATA: l_license_number TYPE string.

  SELECT SINGLE applic
           INTO ls_ssfargs-applic
  FROM ssfargs
  WHERE applic = c_s4_ssf_application.

  IF sy-subrc <> 0.
    CALL FUNCTION 'SLIC_GET_LICENCE_NUMBER'
      IMPORTING
        license_number = l_license_number.

    ls_ssfargs-mandt = sy-mandt.
    ls_ssfargs-applic = c_s4_ssf_application.
    ls_ssfargs-ssftoolkit = 'SAPSECULIB'.
    ls_ssfargs-ssfformat = 'PKCS7'.
    ls_ssfargs-pab = 'ROCKETSTEAMS4.pse'.
    CONCATENATE 'CN=IDE SSF RocketSteam S4, OU=I'           "#EC NOTEXT
                l_license_number
                ', OU=SAP Web AS, O=SAP Trust Community, C=DE' "#EC NOTEXT
                INTO ls_ssfargs-profileid.
    ls_ssfargs-profile = 'ROCKETSTEAMS4.pse'.
    ls_ssfargs-hashalg = 'SHA1'.
    ls_ssfargs-encralg = 'DES-CBC'.
    ls_ssfargs-distrib = 'X'.
    ls_ssfargs-explicit = 'X'.
    MODIFY ssfargs FROM ls_ssfargs.
    COMMIT WORK.
  ENDIF.

ENDMETHOD.


METHOD ssfbin_to_xstring.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 14th July 2014
* Converts from Table of SSFBIN to xstring.
*--------------------------------------------------------------------*
  FIELD-SYMBOLS: <fs_ssfbin> TYPE ssfbin.
  DATA: l_length_to_output TYPE i.

  l_length_to_output = i_length.
  LOOP AT i_ssfbin ASSIGNING <fs_ssfbin>.
    IF l_length_to_output >= 255.
      CONCATENATE e_xstring
                  <fs_ssfbin>-bindata
                  INTO e_xstring IN BYTE MODE.
      l_length_to_output = l_length_to_output - 255.
    ELSEIF l_length_to_output > 0.
      CONCATENATE e_xstring
                  <fs_ssfbin>-bindata(l_length_to_output)
                  INTO e_xstring IN BYTE MODE.
      EXIT. "Output complete. Leaves the loop.
    ENDIF.
  ENDLOOP.

ENDMETHOD.


METHOD ssf_get_parameter.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 14th July 2014
* Returns SSF application parameters
*--------------------------------------------------------------------*
  DATA: l_appfound TYPE ssfargs-applic.
  DATA: l_msg TYPE string.                                  "#EC NEEDED

* Gets application parameters (Related Transactions: SSFA, STRUST)
  CALL FUNCTION 'SSF_GET_PARAMETER'
    EXPORTING
      mandt                   = sy-mandt
      application             = c_s4_ssf_application
    IMPORTING
      appfound                = l_appfound
      ssftoolkit              = e_ssftoolkit
      str_pab                 = e_str_pab
      str_pab_password        = e_str_pab_password
      str_profileid           = e_str_profileid
      str_profile             = e_str_profile
      str_encralg             = e_str_encralg
    EXCEPTIONS
      ssf_parameter_not_found = 1
      OTHERS                  = 2.

  IF sy-subrc <> 0 OR l_appfound <> c_s4_ssf_application.
*   069	SSF Application & not found. Customize SSFA
    MESSAGE i069 WITH c_s4_ssf_application INTO l_msg.
    ZLNKEcx_aws_s3=>raise_from_sy_msg( ).
  ENDIF.

ENDMETHOD.


METHOD xstring_to_ssfbin.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 14th July 2014
* Converts from XSTRING to Table of SSFBIN
*--------------------------------------------------------------------*
  DATA: l_xstring TYPE xstring.
  FIELD-SYMBOLS: <fs_ssfbin> TYPE ssfbin.

  l_xstring = i_xstring.
  e_length = XSTRLEN( l_xstring ).

  WHILE l_xstring IS NOT INITIAL.
    APPEND INITIAL LINE TO e_ssfbin ASSIGNING <fs_ssfbin>.
    <fs_ssfbin>-bindata = l_xstring.
    SHIFT l_xstring BY 255 PLACES LEFT IN BYTE MODE.
  ENDWHILE.

ENDMETHOD.
ENDCLASS.
