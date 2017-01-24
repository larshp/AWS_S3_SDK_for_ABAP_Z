class ZLNKECL_LOG definition
  public
  final
  create private .

*"* public components of class ZLNKECL_LOG
*"* do not include other source files here!!!
public section.

  constants C_LOG_MSGTYP_ERROR type ZLNKELOG_MSGTYP_DE value 'E'. "#EC NOTEXT
  constants C_LOG_MSGTYP_ABORT type ZLNKELOG_MSGTYP_DE value 'A'. "#EC NOTEXT
  constants C_LOG_MSGTYP_SUCCESS type ZLNKELOG_MSGTYP_DE value 'S'. "#EC NOTEXT
  constants C_LOG_MSGTYP_INFO type ZLNKELOG_MSGTYP_DE value 'I'. "#EC NOTEXT
  constants C_LOG_MSGTYP_WARNING type ZLNKELOG_MSGTYP_DE value 'W'. "#EC NOTEXT
  constants C_LOG_EVT_CONT_SERVER_REQ type ZLNKELOG_EVENT_DE value 'A'. "#EC NOTEXT
  constants C_LOG_EVT_REQ_TO_AWS type ZLNKELOG_EVENT_DE value 'B'. "#EC NOTEXT
  constants C_LOG_EVT_RESP_FROM_AWS type ZLNKELOG_EVENT_DE value 'C'. "#EC NOTEXT
  constants C_LOG_EVT_BUCKET_CREATE type ZLNKELOG_EVENT_DE value 'D'. "#EC NOTEXT
  constants C_LOG_EVT_BUCKET_DELETE type ZLNKELOG_EVENT_DE value 'E'. "#EC NOTEXT
  constants C_LOG_EVT_BUCKET_LIFECYCLE type ZLNKELOG_EVENT_DE value 'F'. "#EC NOTEXT
  constants C_LOG_EVT_USER_CREATED type ZLNKELOG_EVENT_DE value 'G'. "#EC NOTEXT
  constants C_LOG_EVT_USER_EDITION type ZLNKELOG_EVENT_DE value 'H'. "#EC NOTEXT
  constants C_LOG_EVT_USER_DELETED type ZLNKELOG_EVENT_DE value 'I'. "#EC NOTEXT
  constants C_LOG_EVT_BUCKET_ENCRYPT type ZLNKELOG_EVENT_DE value 'J'. "#EC NOTEXT
  constants C_LOG_EVT_AOBJ_ADD_BUCKET type ZLNKELOG_EVENT_DE value 'K'. "#EC NOTEXT
  constants C_LOG_EVT_AOBJ_REMOVE_BUCKET type ZLNKELOG_EVENT_DE value 'L'. "#EC NOTEXT
  constants C_LOG_EVT_AOBJ_EDITION type ZLNKELOG_EVENT_DE value 'M'. "#EC NOTEXT
  constants C_LOG_EVT_CONT_SERVER_CX type ZLNKELOG_EVENT_DE value 'N'. "#EC NOTEXT

  class-methods CLASS_CONSTRUCTOR .
  class-methods APPEND_LOG_CONTENT_SERVER_REQ
    importing
      !I_HTTP_REQUEST type ref to IF_HTTP_REQUEST .
  class-methods APPEND_LOG_CONTENT_SERVER_CX
    importing
      !I_EXCEPTION type ref to ZLNKECX_AWS_S3 .
  class-methods APPEND_LOG_REQ_TO_AWS
    importing
      !I_HTTP_REQUEST type ref to IF_HTTP_REQUEST
      !I_REQUEST type STRING .
  class-methods APPEND_LOG_AOBJ_ADD_BUCKET
    importing
      !I_AOBJ type OBJCT_TR01
      !I_BUCKET type ZLNKEBUCKET_DE
      !I_ARCH_LINK type ARCH_LINK
      !I_STORE_FRST type ARCH_STORE
      !I_READARCSYS type ARCH_READ
      !I_USER_NAME type UNAME default SY-UNAME .
  class-methods APPEND_LOG_AOBJ_REMOVE_BUCKET
    importing
      !I_AOBJ type OBJCT_TR01
      !I_BUCKET type ZLNKEBUCKET_DE
      !I_ARCH_LINK type ARCH_LINK
      !I_STORE_FRST type ARCH_STORE
      !I_READARCSYS type ARCH_READ
      !I_USER_NAME type UNAME default SY-UNAME .
  class-methods APPEND_LOG_AOBJ_EDITION
    importing
      !I_AOBJ type OBJCT_TR01
      !I_BUCKET_OLD type ZLNKEBUCKET_DE
      !I_BUCKET_NEW type ZLNKEBUCKET_DE
      !I_ARCH_LINK_OLD type ARCH_LINK
      !I_ARCH_LINK_NEW type ARCH_LINK
      !I_STORE_FRST_OLD type ARCH_STORE
      !I_STORE_FRST_NEW type ARCH_STORE
      !I_READARCSYS_OLD type ARCH_READ
      !I_READARCSYS_NEW type ARCH_READ
      !I_USER_NAME type UNAME default SY-UNAME .
  class-methods APPEND_LOG_USER_CREATED
    importing
      !I_USER_DATA type ZLNKEUSER .
  class-methods APPEND_LOG_USER_DELETED
    importing
      !I_USER_DATA type ZLNKEUSER .
  class-methods APPEND_LOG_USER_EDITION
    importing
      !I_USER_DATA_OLD type ZLNKEUSER
      !I_USER_DATA_NEW type ZLNKEUSER .
  class-methods APPEND_LOG_RESP_FROM_AWS
    importing
      !I_HTTP_RESPONSE type ref to IF_HTTP_RESPONSE
      !I_XRESPONSE type XSTRING optional
      !I_EXCEPTION type ref to ZLNKECX_AWS_S3 optional .
  class-methods APPEND_LOG_CREATE_BUCKET
    importing
      !I_BUCKET_NAME type STRING
      !I_BUCKET_USER_NAME type ZLNKEUSERNAME_DE
      !I_REGION type ZLNKEREGION_DE
      !I_CLIENT_SIDE_ENCRYPTION type ZLNKECLIENT_SIDE_ENCRYPTION_DE
      !I_SERVER_SIDE_ENCRYPTION type ZLNKESERVER_SIDE_ENCRYPTION_DE
      !I_ZIP type ZLNKEZIPFLAG_DE
      !I_USER_NAME type UNAME default SY-UNAME
      !I_EXCEPTION type ref to ZLNKECX_AWS_S3 optional .
  class-methods APPEND_LOG_DELETE_BUCKET
    importing
      !I_BUCKET_NAME type STRING
      !I_USER_NAME type UNAME default SY-UNAME
      !I_EXCEPTION type ref to ZLNKECX_AWS_S3 optional .
  class-methods APPEND_LOG_BUCKET_LIFECYCLE
    importing
      !I_BUCKET_NAME type STRING
      !I_USER_NAME type UNAME default SY-UNAME
      !I_LIFECYCLE type ZLNKEBUCKET_LIFECYCLE_DE
      !I_EXCEPTION type ref to ZLNKECX_AWS_S3 optional .
  class-methods APPEND_LOG_BUCKET_SERV_ENCRYPT
    importing
      !I_BUCKET_NAME type STRING
      !I_USER_NAME type UNAME default SY-UNAME
      !I_SERVER_ENCRYPT_OLD type ZLNKESERVER_SIDE_ENCRYPTION_DE
      !I_SERVER_ENCRYPT type ZLNKESERVER_SIDE_ENCRYPTION_DE .
protected section.
*"* protected components of class ZLNKECL_LOG
*"* do not include other source files here!!!
private section.
*"* private components of class ZLNKECL_LOG
*"* do not include other source files here!!!

  type-pools ABAP .
  class-data ATTR_LOG_RESPONSE_FROM_AWS type ABAP_BOOL .
  class-data ATTR_LOG_REQ_RESP_FROM_AWS type ABAP_BOOL .
  class-data ATTR_LOG_CONT_SERV_REQUEST type ABAP_BOOL .
  class-data ATTR_KEEP_DAYS type ZLNKELOG_CFG-KEEP_DAYS .
  constants C_DEFAULT_DAYS_TO_KEEP type I value 10. "#EC NOTEXT

  class-methods APPEND_LOGX
    importing
      !I_LOG_EVENT type ZLNKELOG_EVENT_DE
      !I_LOG_MSGTYP type ZLNKELOG_MSGTYP_DE
      !I_XSTRING type XSTRING .
  class-methods PURGE_LOG .
  class-methods READ_CONFIG .
ENDCLASS.



CLASS ZLNKECL_LOG IMPLEMENTATION.


METHOD append_logx.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 11th April 2014
* Appends log to ZLNKElog
*--------------------------------------------------------------------*
  DATA: l_timestampl TYPE timestampl.
  DATA: l_guid TYPE ZLNKEguid.
  DATA: ls_log TYPE ZLNKElog.

  GET TIME STAMP FIELD l_timestampl.

  CALL FUNCTION 'SYSTEM_UUID_CREATE'
    IMPORTING
      uuid = l_guid.

  ls_log-guid = l_guid.
  ls_log-timestamp = l_timestampl.
  ls_log-log_event = i_log_event.
  ls_log-log_msgtyp = i_log_msgtyp.
  ls_log-event_user = sy-uname.
  ls_log-rawdata = i_xstring.
  MODIFY ZLNKElog FROM ls_log.

ENDMETHOD.


METHOD append_log_aobj_add_bucket.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 7th May 2014
* Appends log for AOBJ Add Bucket event
*--------------------------------------------------------------------*
  DATA: l_xxml TYPE xstring.
  DATA: l_aobj_s TYPE string,
        l_bucket_s TYPE string,
        l_arch_link_s TYPE string,
        l_store_frst_s TYPE string,
        l_readarcsys_s TYPE string,
        l_user_name_s TYPE string.
  DATA: lr_ixml TYPE REF TO if_ixml.
  DATA: lr_ixml_document TYPE REF TO if_ixml_document.
  DATA: lr_elem_aobj_add_bucket TYPE REF TO if_ixml_element.

* Create iXML object
  lr_ixml = cl_ixml=>create( ).

* Create iXML document
  lr_ixml_document = lr_ixml->create_document( ).

* Element AOBJ_AddBucket
  lr_elem_aobj_add_bucket  = lr_ixml_document->create_simple_element( "#EC NOTEXT
                                             name   = 'AOBJ_AddBucket'
                                             parent = lr_ixml_document ).

* Element AOBJ
  l_aobj_s = i_aobj.
  lr_ixml_document->create_simple_element( name   = 'AOBJ'  "#EC NOTEXT
                                           parent = lr_elem_aobj_add_bucket
                                           value  = l_aobj_s ).

* Element Bucket
  l_bucket_s = i_bucket.
  lr_ixml_document->create_simple_element( name   = 'Bucket' "#EC NOTEXT
                                           parent = lr_elem_aobj_add_bucket
                                           value  = l_bucket_s ).

* Element ARCH_LINK
  IF i_arch_link = abap_true.
    l_arch_link_s = 'true'.                                 "#EC NOTEXT
  ELSE.
    l_arch_link_s = 'false'.                                "#EC NOTEXT
  ENDIF.
  lr_ixml_document->create_simple_element( name   = 'ARCH_LINK' "#EC NOTEXT
                                           parent = lr_elem_aobj_add_bucket
                                           value  = l_arch_link_s ).

* Element STORE_FRST
  IF i_store_frst = abap_true.
    l_store_frst_s = 'Store Before Deleting'.  "#EC NOTEXT
  ELSE.
    l_store_frst_s = 'Delete Before Storing'.  "#EC NOTEXT
  ENDIF.
  lr_ixml_document->create_simple_element( name   = 'STORE_FRST' "#EC NOTEXT
                                           parent = lr_elem_aobj_add_bucket
                                           value  = l_store_frst_s ).

* Element READARCSYS
  IF i_readarcsys = abap_true.
    l_readarcsys_s = 'true'.                                "#EC NOTEXT
  ELSE.
    l_readarcsys_s = 'false'.                               "#EC NOTEXT
  ENDIF.
  lr_ixml_document->create_simple_element( name   = 'STORE_FRST' "#EC NOTEXT
                                           parent = lr_elem_aobj_add_bucket
                                           value  = l_readarcsys_s ).

* Element UserName
  l_user_name_s = i_user_name.
  lr_ixml_document->create_simple_element( name   = 'UserName' "#EC NOTEXT
                                           parent = lr_elem_aobj_add_bucket
                                           value  = l_user_name_s ).

  l_xxml = ZLNKEcl_xml_utils=>convert_ixml_doc_to_xstring( lr_ixml_document ).

  CALL METHOD ZLNKEcl_log=>append_logx
    EXPORTING
      i_log_event  = c_log_evt_aobj_add_bucket
      i_log_msgtyp = c_log_msgtyp_success
      i_xstring    = l_xxml.

ENDMETHOD.


METHOD append_log_aobj_edition.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 7th May 2014
* Appends log for AOBJ Edition event
*--------------------------------------------------------------------*
  DATA: l_xxml TYPE xstring.
  DATA: l_aobj_s TYPE string,
        l_bucket_s TYPE string,
        l_arch_link_s TYPE string,
        l_store_frst_s TYPE string,
        l_readarcsys_s TYPE string,
        l_user_name_s TYPE string.
  DATA: lr_ixml TYPE REF TO if_ixml.
  DATA: lr_ixml_document TYPE REF TO if_ixml_document.
  DATA: lr_elem_aobj_edition TYPE REF TO if_ixml_element.

* Create iXML object
  lr_ixml = cl_ixml=>create( ).

* Create iXML document
  lr_ixml_document = lr_ixml->create_document( ).

* Element AOBJ_Edition
  lr_elem_aobj_edition  = lr_ixml_document->create_simple_element( "#EC NOTEXT
                                             name   = 'AOBJ_Edition'
                                             parent = lr_ixml_document ).

* Element AOBJ
  l_aobj_s = i_aobj.
  lr_ixml_document->create_simple_element( name   = 'AOBJ'  "#EC NOTEXT
                                           parent = lr_elem_aobj_edition
                                           value  = l_aobj_s ).

  IF i_bucket_old <> i_bucket_new.
*   Element Bucket Old
    l_bucket_s = i_bucket_old.
    lr_ixml_document->create_simple_element( name   = 'Bucket_OLD' "#EC NOTEXT
                                             parent = lr_elem_aobj_edition
                                             value  = l_bucket_s ).

*   Element Bucket New
    l_bucket_s = i_bucket_new.
    lr_ixml_document->create_simple_element( name   = 'Bucket_NEW' "#EC NOTEXT
                                             parent = lr_elem_aobj_edition
                                             value  = l_bucket_s ).
  ENDIF.

  IF i_arch_link_old <> i_arch_link_new.
* Element ARCH_LINK_OLD
    IF i_arch_link_old = abap_true.
      l_arch_link_s = 'true'.                               "#EC NOTEXT
    ELSE.
      l_arch_link_s = 'false'.                              "#EC NOTEXT
    ENDIF.
    lr_ixml_document->create_simple_element( name   = 'ARCH_LINK_OLD' "#EC NOTEXT
                                             parent = lr_elem_aobj_edition
                                             value  = l_arch_link_s ).

* Element ARCH_LINK_NEW
    IF i_arch_link_new = abap_true.
      l_arch_link_s = 'true'.                               "#EC NOTEXT
    ELSE.
      l_arch_link_s = 'false'.                              "#EC NOTEXT
    ENDIF.
    lr_ixml_document->create_simple_element( name   = 'ARCH_LINK_NEW' "#EC NOTEXT
                                             parent = lr_elem_aobj_edition
                                             value  = l_arch_link_s ).
  ENDIF.

  IF i_store_frst_old <> i_store_frst_new.
*   Element STORE_FRST_OLD
    IF i_store_frst_old = abap_true.
      l_store_frst_s = 'Store Before Deleting'.             "#EC NOTEXT
    ELSE.
      l_store_frst_s = 'Delete Before Storing'.             "#EC NOTEXT
    ENDIF.
    lr_ixml_document->create_simple_element( name   = 'STORE_FRST_OLD' "#EC NOTEXT
                                             parent = lr_elem_aobj_edition
                                             value  = l_store_frst_s ).

*   Element STORE_FRST_NEW
    IF i_store_frst_new = abap_true.
      l_store_frst_s = 'Store Before Deleting'.             "#EC NOTEXT
    ELSE.
      l_store_frst_s = 'Delete Before Storing'.             "#EC NOTEXT
    ENDIF.
    lr_ixml_document->create_simple_element( name   = 'STORE_FRST_NEW' "#EC NOTEXT
                                             parent = lr_elem_aobj_edition
                                             value  = l_store_frst_s ).
  ENDIF.

  IF i_readarcsys_old <> i_readarcsys_new.
* Element READARCSYS_OLD
    IF i_readarcsys_old = abap_true.
      l_readarcsys_s = 'true'.                              "#EC NOTEXT
    ELSE.
      l_readarcsys_s = 'false'.                             "#EC NOTEXT
    ENDIF.
    lr_ixml_document->create_simple_element( name   = 'READARCSYS_OLD' "#EC NOTEXT
                                             parent = lr_elem_aobj_edition
                                             value  = l_readarcsys_s ).

* Element READARCSYS_NEW
    IF i_readarcsys_new = abap_true.
      l_readarcsys_s = 'true'.                              "#EC NOTEXT
    ELSE.
      l_readarcsys_s = 'false'.                             "#EC NOTEXT
    ENDIF.
    lr_ixml_document->create_simple_element( name   = 'READARCSYS_NEW' "#EC NOTEXT
                                             parent = lr_elem_aobj_edition
                                             value  = l_readarcsys_s ).
  ENDIF.

* Element UserName
  l_user_name_s = i_user_name.
  lr_ixml_document->create_simple_element( name   = 'UserName' "#EC NOTEXT
                                           parent = lr_elem_aobj_edition
                                           value  = l_user_name_s ).

  l_xxml = ZLNKEcl_xml_utils=>convert_ixml_doc_to_xstring( lr_ixml_document ).

  CALL METHOD ZLNKEcl_log=>append_logx
    EXPORTING
      i_log_event  = c_log_evt_aobj_edition
      i_log_msgtyp = c_log_msgtyp_success
      i_xstring    = l_xxml.

ENDMETHOD.


METHOD append_log_aobj_remove_bucket.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 7th May 2014
* Appends log for AOBJ Remove Bucket event
*--------------------------------------------------------------------*
  DATA: l_xxml TYPE xstring.
  DATA: l_aobj_s TYPE string,
        l_bucket_s TYPE string,
        l_arch_link_s TYPE string,
        l_store_frst_s TYPE string,
        l_readarcsys_s TYPE string,
        l_user_name_s TYPE string.
  DATA: lr_ixml TYPE REF TO if_ixml.
  DATA: lr_ixml_document TYPE REF TO if_ixml_document.
  DATA: lr_elem_aobj_remove_bucket TYPE REF TO if_ixml_element.

* Create iXML object
  lr_ixml = cl_ixml=>create( ).

* Create iXML document
  lr_ixml_document = lr_ixml->create_document( ).

* Element AOBJ_AddBucket
  lr_elem_aobj_remove_bucket  = lr_ixml_document->create_simple_element( "#EC NOTEXT
                                             name   = 'AOBJ_RemoveBucket'
                                             parent = lr_ixml_document ).

* Element AOBJ
  l_aobj_s = i_aobj.
  lr_ixml_document->create_simple_element( name   = 'AOBJ'  "#EC NOTEXT
                                           parent = lr_elem_aobj_remove_bucket
                                           value  = l_aobj_s ).

* Element Bucket
  l_bucket_s = i_bucket.
  lr_ixml_document->create_simple_element( name   = 'Bucket' "#EC NOTEXT
                                           parent = lr_elem_aobj_remove_bucket
                                           value  = l_bucket_s ).

* Element ARCH_LINK
  IF i_arch_link = abap_true.
    l_arch_link_s = 'true'.                                 "#EC NOTEXT
  ELSE.
    l_arch_link_s = 'false'.                                "#EC NOTEXT
  ENDIF.
  lr_ixml_document->create_simple_element( name   = 'ARCH_LINK' "#EC NOTEXT
                                           parent = lr_elem_aobj_remove_bucket
                                           value  = l_arch_link_s ).

* Element STORE_FRST
  IF i_store_frst = abap_true.
    l_store_frst_s = 'Store Before Deleting'.               "#EC NOTEXT
  ELSE.
    l_store_frst_s = 'Delete Before Storing'.               "#EC NOTEXT
  ENDIF.
  lr_ixml_document->create_simple_element( name   = 'STORE_FRST' "#EC NOTEXT
                                           parent = lr_elem_aobj_remove_bucket
                                           value  = l_store_frst_s ).

* Element READARCSYS
  IF i_readarcsys = abap_true.
    l_readarcsys_s = 'true'.                                "#EC NOTEXT
  ELSE.
    l_readarcsys_s = 'false'.                               "#EC NOTEXT
  ENDIF.
  lr_ixml_document->create_simple_element( name   = 'STORE_FRST' "#EC NOTEXT
                                           parent = lr_elem_aobj_remove_bucket
                                           value  = l_readarcsys_s ).

* Element UserName
  l_user_name_s = i_user_name.
  lr_ixml_document->create_simple_element( name   = 'UserName' "#EC NOTEXT
                                           parent = lr_elem_aobj_remove_bucket
                                           value  = l_user_name_s ).

  l_xxml = ZLNKEcl_xml_utils=>convert_ixml_doc_to_xstring( lr_ixml_document ).

  CALL METHOD ZLNKEcl_log=>append_logx
    EXPORTING
      i_log_event  = c_log_evt_aobj_remove_bucket
      i_log_msgtyp = c_log_msgtyp_success
      i_xstring    = l_xxml.

ENDMETHOD.


METHOD append_log_bucket_lifecycle.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 14th April 2014
* Appends log for Bucket Lifecycle event
*--------------------------------------------------------------------*
  DATA: l_xxml TYPE xstring.
  DATA: l_log_msgtyp TYPE ZLNKElog_msgtyp_de.
  DATA: l_bucket_name TYPE string,
        l_user_name TYPE string,
        l_lifecycle_s TYPE string,
        l_message_s TYPE string.
  DATA: lr_ixml TYPE REF TO if_ixml.
  DATA: lr_ixml_document TYPE REF TO if_ixml_document.
  DATA: lr_elem_bucketlifecycle TYPE REF TO if_ixml_element.

* Create iXML object
  lr_ixml = cl_ixml=>create( ).

* Create iXML document
  lr_ixml_document = lr_ixml->create_document( ).

* Element BucketLifecycle
  lr_elem_bucketlifecycle  = lr_ixml_document->create_simple_element( "#EC NOTEXT
                                           name   = 'BucketLifecycle'
                                           parent = lr_ixml_document ).

* Element ErrorMsg
  IF i_exception IS NOT INITIAL.
    l_message_s = i_exception->get_text( ).
    lr_ixml_document->create_simple_element( name   = 'ErrorMsg' "#EC NOTEXT
                                             parent = lr_elem_bucketlifecycle
                                             value  = l_message_s ).
  ENDIF.

* Element BucketName
  l_bucket_name = i_bucket_name.
  lr_ixml_document->create_simple_element( name   = 'BucketName' "#EC NOTEXT
                                           parent = lr_elem_bucketlifecycle
                                           value  = l_bucket_name ).

* Element Lifecycle
  l_lifecycle_s = i_lifecycle.
  lr_ixml_document->create_simple_element( name   = 'Lifecycle' "#EC NOTEXT
                                           parent = lr_elem_bucketlifecycle
                                           value  = l_lifecycle_s ).

* Element UserName
  l_user_name = i_user_name.
  lr_ixml_document->create_simple_element( name   = 'UserName' "#EC NOTEXT
                                           parent = lr_elem_bucketlifecycle
                                           value  = l_user_name ).

  l_xxml = ZLNKEcl_xml_utils=>convert_ixml_doc_to_xstring( lr_ixml_document ).

  IF i_exception IS INITIAL.
    l_log_msgtyp = c_log_msgtyp_success.
  ELSE.
    l_log_msgtyp = c_log_msgtyp_error.
  ENDIF.

  CALL METHOD ZLNKEcl_log=>append_logx
    EXPORTING
      i_log_event  = c_log_evt_bucket_lifecycle
      i_log_msgtyp = l_log_msgtyp
      i_xstring    = l_xxml.

ENDMETHOD.


METHOD append_log_bucket_serv_encrypt.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 5th May 2014
* Appends log for Bucket server side encrypt edition
*--------------------------------------------------------------------*
  DATA: l_xxml TYPE xstring.
  DATA: l_bucket_name TYPE string,
        l_user_name TYPE string,
        l_encrypt_s TYPE string.
  DATA: lr_ixml TYPE REF TO if_ixml.
  DATA: lr_ixml_document TYPE REF TO if_ixml_document.
  DATA: lr_elem_bucket_encrypt TYPE REF TO if_ixml_element.

* Create iXML object
  lr_ixml = cl_ixml=>create( ).

* Create iXML document
  lr_ixml_document = lr_ixml->create_document( ).

* Element BucketServerSideEncrypt
  lr_elem_bucket_encrypt  = lr_ixml_document->create_simple_element( "#EC NOTEXT
                                           name   = 'BucketServerSideEncrypt'
                                           parent = lr_ixml_document ).

* Element BucketName
  l_bucket_name = i_bucket_name.
  lr_ixml_document->create_simple_element( name   = 'BucketName' "#EC NOTEXT
                                           parent = lr_elem_bucket_encrypt
                                           value  = l_bucket_name ).

* Element ServerSideEncryptOld
  IF i_server_encrypt_old = abap_true.
    l_encrypt_s = 'true'.                                   "#EC NOTEXT
  ELSE.
    l_encrypt_s = 'false'.                                  "#EC NOTEXT
  ENDIF.
  lr_ixml_document->create_simple_element( name   = 'ServerSideEncryptOld' "#EC NOTEXT
                                           parent = lr_elem_bucket_encrypt
                                           value  = l_encrypt_s ).

* Element ServerSideEncrypt
  IF i_server_encrypt = abap_true.
    l_encrypt_s = 'true'.                                   "#EC NOTEXT
  ELSE.
    l_encrypt_s = 'false'.                                  "#EC NOTEXT
  ENDIF.
  lr_ixml_document->create_simple_element( name   = 'ServerSideEncrypt' "#EC NOTEXT
                                           parent = lr_elem_bucket_encrypt
                                           value  = l_encrypt_s ).

* Element UserName
  l_user_name = i_user_name.
  lr_ixml_document->create_simple_element( name   = 'UserName' "#EC NOTEXT
                                           parent = lr_elem_bucket_encrypt
                                           value  = l_user_name ).

  l_xxml = ZLNKEcl_xml_utils=>convert_ixml_doc_to_xstring( lr_ixml_document ).

  CALL METHOD ZLNKEcl_log=>append_logx
    EXPORTING
      i_log_event  = c_log_evt_bucket_encrypt
      i_log_msgtyp = c_log_msgtyp_success
      i_xstring    = l_xxml.

ENDMETHOD.


METHOD append_log_content_server_cx.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 15th July 2014
* Appends log for Content Server exception
*--------------------------------------------------------------------*
  DATA: l_xxml TYPE xstring.
  DATA: l_message_s TYPE string.
  DATA: lr_ixml TYPE REF TO if_ixml.
  DATA: lr_ixml_document TYPE REF TO if_ixml_document.
  DATA: lr_elem_cont_serv_cx TYPE REF TO if_ixml_element.

* Create iXML object
  lr_ixml = cl_ixml=>create( ).

* Create iXML document
  lr_ixml_document = lr_ixml->create_document( ).

* Element Content Server Exception
  lr_elem_cont_serv_cx  = lr_ixml_document->create_simple_element( "#EC NOTEXT
                                           name   = 'ContentServerException'
                                           parent = lr_ixml_document ).
* Element ErrorMsg
  IF i_exception IS NOT INITIAL.
    l_message_s = i_exception->get_text( ).
    lr_ixml_document->create_simple_element( name   = 'ErrorMsg' "#EC NOTEXT
                                             parent = lr_elem_cont_serv_cx
                                             value  = l_message_s ).
  ENDIF.

  l_xxml = ZLNKEcl_xml_utils=>convert_ixml_doc_to_xstring( lr_ixml_document ).

  CALL METHOD ZLNKEcl_log=>append_logx
    EXPORTING
      i_log_event  = c_log_evt_cont_server_cx
      i_log_msgtyp = c_log_msgtyp_error
      i_xstring    = l_xxml.

ENDMETHOD.


METHOD append_log_content_server_req.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 11th April 2014
* Appends log for content server request
*--------------------------------------------------------------------*
  DATA: lt_headers TYPE tihttpnvp.
  DATA: l_xxml TYPE xstring.
  DATA: lr_ixml TYPE REF TO if_ixml.
  DATA: lr_ixml_document TYPE REF TO if_ixml_document.
  DATA: lr_elem_cont_serv_req TYPE REF TO if_ixml_element.
  DATA: lr_elem_headers TYPE REF TO if_ixml_element.

  FIELD-SYMBOLS: <fs_ihttpnvp> TYPE ihttpnvp.

  CHECK attr_log_cont_serv_request = abap_true.
  CHECK i_http_request IS NOT INITIAL.

  i_http_request->get_header_fields(
               CHANGING fields =  lt_headers ).

* Create iXML object
  lr_ixml = cl_ixml=>create( ).

* Create iXML document
  lr_ixml_document = lr_ixml->create_document( ).

* Element Content Server request
  lr_elem_cont_serv_req  = lr_ixml_document->create_simple_element(
                                           name   = 'ContentServerRequest'
                                           parent = lr_ixml_document ).

* Element Headers
  lr_elem_headers  = lr_ixml_document->create_simple_element(
                                           name   = 'Headers' "#EC NOTEXT
                                           parent = lr_elem_cont_serv_req ).

  LOOP AT lt_headers ASSIGNING <fs_ihttpnvp>                "#EC NOTEXT
                     WHERE name = '~request_method'
                        OR name = '~request_uri'
                        OR name = 'host'.
    REPLACE '~' INTO <fs_ihttpnvp>-name WITH space.
    CONDENSE <fs_ihttpnvp>-name NO-GAPS.

    lr_ixml_document->create_simple_element( name   = <fs_ihttpnvp>-name
                                             parent = lr_elem_headers
                                             value  = <fs_ihttpnvp>-value ).
  ENDLOOP.

  l_xxml = ZLNKEcl_xml_utils=>convert_ixml_doc_to_xstring( lr_ixml_document ).

  CALL METHOD ZLNKEcl_log=>append_logx
    EXPORTING
      i_log_event  = c_log_evt_cont_server_req
      i_log_msgtyp = c_log_msgtyp_info
      i_xstring    = l_xxml.

ENDMETHOD.


METHOD append_log_create_bucket.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 14th April 2014
* Appends log for Bucket Creation event
*--------------------------------------------------------------------*
  DATA: l_xxml TYPE xstring.
  DATA: l_log_msgtyp TYPE ZLNKElog_msgtyp_de.
  DATA: l_bucket_name TYPE string,
        l_bucket_user_name TYPE string,
        l_user_name TYPE string,
        l_region TYPE string,
        l_server_side_encryption TYPE string,
        l_client_side_encryption TYPE string,
        l_zip TYPE string,
        l_message_s TYPE string.
  DATA: lr_ixml TYPE REF TO if_ixml.
  DATA: lr_ixml_document TYPE REF TO if_ixml_document.
  DATA: lr_elem_createbucket TYPE REF TO if_ixml_element.

* Create iXML object
  lr_ixml = cl_ixml=>create( ).

* Create iXML document
  lr_ixml_document = lr_ixml->create_document( ).

* Element CreateBucket
  lr_elem_createbucket  = lr_ixml_document->create_simple_element( "#EC NOTEXT
                                           name   = 'CreateBucket'
                                           parent = lr_ixml_document ).

* Element ErrorMsg
  IF i_exception IS NOT INITIAL.
    l_message_s = i_exception->get_text( ).
    lr_ixml_document->create_simple_element( name   = 'ErrorMsg' "#EC NOTEXT
                                             parent = lr_elem_createbucket
                                             value  = l_message_s ).
  ENDIF.

* Element BucketName
  l_bucket_name = i_bucket_name.
  lr_ixml_document->create_simple_element( name   = 'BucketName' "#EC NOTEXT
                                           parent = lr_elem_createbucket
                                           value  = l_bucket_name ).

* Element BucketUserName
  l_bucket_user_name = i_bucket_user_name.
  lr_ixml_document->create_simple_element( name   = 'BucketUserName' "#EC NOTEXT
                                           parent = lr_elem_createbucket
                                           value  = l_bucket_user_name ).

* Element Region
  l_region = i_region.
  lr_ixml_document->create_simple_element( name   = 'Region' "#EC NOTEXT
                                           parent = lr_elem_createbucket
                                           value  = l_region ).

* Element ClientSideEncryption
  IF i_client_side_encryption = abap_true.
    l_client_side_encryption = 'true'.
  ELSE.
    l_client_side_encryption = 'false'.
  ENDIF.
  lr_ixml_document->create_simple_element( name   = 'ClientSideEncryption' "#EC NOTEXT
                                           parent = lr_elem_createbucket
                                           value  = l_client_side_encryption ).

* Element ServerSideEncryption
  IF i_server_side_encryption = abap_true.
    l_server_side_encryption = 'true'.
  ELSE.
    l_server_side_encryption = 'false'.
  ENDIF.
  lr_ixml_document->create_simple_element( name   = 'ServerSideEncryption' "#EC NOTEXT
                                           parent = lr_elem_createbucket
                                           value  = l_server_side_encryption ).

* Element Zip
  IF i_zip = abap_true.
    l_zip = 'true'.
  ELSE.
    l_zip = 'false'.
  ENDIF.
  lr_ixml_document->create_simple_element( name   = 'Zip'   "#EC NOTEXT
                                           parent = lr_elem_createbucket
                                           value  = l_zip ).

* Element UserName
  l_user_name = i_user_name.
  lr_ixml_document->create_simple_element( name   = 'UserName' "#EC NOTEXT
                                           parent = lr_elem_createbucket
                                           value  = l_user_name ).

  l_xxml = ZLNKEcl_xml_utils=>convert_ixml_doc_to_xstring( lr_ixml_document ).

  IF i_exception IS INITIAL.
    l_log_msgtyp = c_log_msgtyp_success.
  ELSE.
    l_log_msgtyp = c_log_msgtyp_error.
  ENDIF.

  CALL METHOD ZLNKEcl_log=>append_logx
    EXPORTING
      i_log_event  = c_log_evt_bucket_create
      i_log_msgtyp = l_log_msgtyp
      i_xstring    = l_xxml.

ENDMETHOD.


METHOD append_log_delete_bucket.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 14th April 2014
* Appends log for Bucket Delete event
*--------------------------------------------------------------------*
  DATA: l_xxml TYPE xstring.
  DATA: l_log_msgtyp TYPE ZLNKElog_msgtyp_de.
  DATA: l_bucket_name TYPE string,
        l_user_name TYPE string,
        l_message_s TYPE string.
  DATA: lr_ixml TYPE REF TO if_ixml.
  DATA: lr_ixml_document TYPE REF TO if_ixml_document.
  DATA: lr_elem_deletebucket TYPE REF TO if_ixml_element.

* Create iXML object
  lr_ixml = cl_ixml=>create( ).

* Create iXML document
  lr_ixml_document = lr_ixml->create_document( ).

* Element DeleteBucket
  lr_elem_deletebucket  = lr_ixml_document->create_simple_element(
                                           name   = 'DeleteBucket'
                                           parent = lr_ixml_document ).

* Element ErrorMsg
  IF i_exception IS NOT INITIAL.
    l_message_s = i_exception->get_text( ).
    lr_ixml_document->create_simple_element( name   = 'ErrorMsg' "#EC NOTEXT
                                             parent = lr_elem_deletebucket
                                             value  = l_message_s ).
  ENDIF.

* Element BucketName
  l_bucket_name = i_bucket_name.
  lr_ixml_document->create_simple_element( name   = 'BucketName'
                                           parent = lr_elem_deletebucket
                                           value  = l_bucket_name ).

* Element UserName
  l_user_name = i_user_name.
  lr_ixml_document->create_simple_element( name   = 'UserName'
                                           parent = lr_elem_deletebucket
                                           value  = l_user_name ).

  l_xxml = ZLNKEcl_xml_utils=>convert_ixml_doc_to_xstring( lr_ixml_document ).

  IF i_exception IS INITIAL.
    l_log_msgtyp = c_log_msgtyp_success.
  ELSE.
    l_log_msgtyp = c_log_msgtyp_error.
  ENDIF.

  CALL METHOD ZLNKEcl_log=>append_logx
    EXPORTING
      i_log_event  = c_log_evt_bucket_delete
      i_log_msgtyp = l_log_msgtyp
      i_xstring    = l_xxml.

ENDMETHOD.


METHOD append_log_req_to_aws.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 14th April 2014
* Appends log for Request to S3
*--------------------------------------------------------------------*
  DATA: lt_headers TYPE tihttpnvp.
  DATA: l_xxml TYPE xstring.
  DATA: lr_ixml TYPE REF TO if_ixml.
  DATA: lr_ixml_document TYPE REF TO if_ixml_document.
  DATA: lr_elem_req_to_s3 TYPE REF TO if_ixml_element.
  DATA: lr_elem_headers TYPE REF TO if_ixml_element.

  FIELD-SYMBOLS: <fs_ihttpnvp> TYPE ihttpnvp.

  CHECK attr_log_req_resp_from_aws = abap_true.
  CHECK i_http_request IS NOT INITIAL.

  i_http_request->get_header_fields(
               CHANGING fields =  lt_headers ).

* Create iXML object
  lr_ixml = cl_ixml=>create( ).

* Create iXML document
  lr_ixml_document = lr_ixml->create_document( ).

* Element RequestToS3
  lr_elem_req_to_s3  = lr_ixml_document->create_simple_element( "#EC NOTEXT
                                           name   = 'RequestToS3'
                                           parent = lr_ixml_document ).

* Element Request
  lr_ixml_document->create_simple_element( name   = 'Request' "#EC NOTEXT
                                           parent = lr_elem_req_to_s3
                                           value  = i_request ).

* Element Headers
  lr_elem_headers  = lr_ixml_document->create_simple_element( "#EC NOTEXT
                                           name   = 'Headers'
                                           parent = lr_elem_req_to_s3 ).

  LOOP AT lt_headers ASSIGNING <fs_ihttpnvp>.
    REPLACE '~' INTO <fs_ihttpnvp>-name WITH space.
    CONDENSE <fs_ihttpnvp>-name NO-GAPS.

    lr_ixml_document->create_simple_element( name   = <fs_ihttpnvp>-name
                                             parent = lr_elem_headers
                                             value  = <fs_ihttpnvp>-value ).
  ENDLOOP.

  l_xxml = ZLNKEcl_xml_utils=>convert_ixml_doc_to_xstring( lr_ixml_document ).

  CALL METHOD ZLNKEcl_log=>append_logx
    EXPORTING
      i_log_event  = c_log_evt_req_to_aws
      i_log_msgtyp = c_log_msgtyp_info
      i_xstring    = l_xxml.

ENDMETHOD.


METHOD append_log_resp_from_aws.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 14th April 2014
* Appends log for Response from S3
*--------------------------------------------------------------------*
  DATA: lt_headers TYPE tihttpnvp.
  DATA: l_xxml TYPE xstring.
  DATA: l_log_msgtyp TYPE ZLNKElog_msgtyp_de.
  DATA: l_message_s TYPE string.
  DATA: l_xml TYPE string.
  DATA: l_response_is_xml TYPE abap_bool.
  DATA: lr_ixml TYPE REF TO if_ixml.
  DATA: lr_ixml_document TYPE REF TO if_ixml_document.
  DATA: lr_elem_resp_from_s3 TYPE REF TO if_ixml_element.
  DATA: lr_elem_headers TYPE REF TO if_ixml_element.

  FIELD-SYMBOLS: <fs_ihttpnvp> TYPE ihttpnvp.

  CHECK attr_log_req_resp_from_aws = abap_true.
  CHECK i_http_response IS NOT INITIAL.

  i_http_response->get_header_fields(
               CHANGING fields =  lt_headers ).

* Create iXML object
  lr_ixml = cl_ixml=>create( ).

* Create iXML document
  lr_ixml_document = lr_ixml->create_document( ).

* Element ResponseFromS3
  lr_elem_resp_from_s3  = lr_ixml_document->create_simple_element( "#EC NOTEXT
                                           name   = 'ResponseFromS3'
                                           parent = lr_ixml_document ).
* Element ErrorMsg
  IF i_exception IS NOT INITIAL.
    l_message_s = i_exception->get_text( ).
    lr_ixml_document->create_simple_element( name   = 'ErrorMsg' "#EC NOTEXT
                                             parent = lr_elem_resp_from_s3
                                             value  = l_message_s ).
  ENDIF.

* Element Headers
  lr_elem_headers  = lr_ixml_document->create_simple_element( "#EC NOTEXT
                                           name   = 'Headers'
                                           parent = lr_elem_resp_from_s3 ).

  LOOP AT lt_headers ASSIGNING <fs_ihttpnvp>.
    IF <fs_ihttpnvp>-name = 'content-type'
      AND ( <fs_ihttpnvp>-value = 'application/xml'
         OR <fs_ihttpnvp>-value = 'text/xml' ).
      l_response_is_xml = abap_true.
    ENDIF.
    REPLACE '~' INTO <fs_ihttpnvp>-name WITH space.
    CONDENSE <fs_ihttpnvp>-name NO-GAPS.

    lr_ixml_document->create_simple_element( name   = <fs_ihttpnvp>-name
                                             parent = lr_elem_headers
                                             value  = <fs_ihttpnvp>-value ).
  ENDLOOP.

* If configuration is marked to log xml response and
* the response is XML, log it...
  IF attr_log_response_from_aws = abap_true
    AND l_response_is_xml = abap_true.
    TRY.
        CALL METHOD ZLNKEcl_string_conversions=>xstring_to_string
          EXPORTING
            input  = i_xresponse
          IMPORTING
            output = l_xml.

        lr_ixml_document->create_simple_element(            "#EC NOTEXT
                              name   = 'Response'
                              parent = lr_elem_resp_from_s3
                              value =  l_xml ).
      CATCH cx_sy_no_handler.                           "#EC NO_HANDLER
*       Should not happen.
*       In this case, we don't create element Response
    ENDTRY.
  ENDIF.

  l_xxml = ZLNKEcl_xml_utils=>convert_ixml_doc_to_xstring( lr_ixml_document ).

  IF i_exception IS INITIAL.
    l_log_msgtyp = c_log_msgtyp_info.
  ELSE.
    l_log_msgtyp = c_log_msgtyp_error.
  ENDIF.

  CALL METHOD ZLNKEcl_log=>append_logx
    EXPORTING
      i_log_event  = c_log_evt_resp_from_aws
      i_log_msgtyp = l_log_msgtyp
      i_xstring    = l_xxml.

ENDMETHOD.


METHOD append_log_user_created.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 24th April 2014
* Appends log for Request to S3
*--------------------------------------------------------------------*
  DATA: l_string TYPE string.
  DATA: l_xxml TYPE xstring.
  DATA: lr_ixml TYPE REF TO if_ixml.
  DATA: lr_ixml_document TYPE REF TO if_ixml_document.
  DATA: lr_elem_user TYPE REF TO if_ixml_element.

* Create iXML object
  lr_ixml = cl_ixml=>create( ).

* Create iXML document
  lr_ixml_document = lr_ixml->create_document( ).

* Element UserCreation
  lr_elem_user  = lr_ixml_document->create_simple_element(  "#EC NOTEXT
                                           name   = 'UserCreation'
                                           parent = lr_ixml_document ).


  l_string = i_user_data-user_name.
  lr_ixml_document->create_simple_element( name   = 'USER_NAME' "#EC NOTEXT
                                           parent = lr_elem_user
                                           value  = l_string ).

  l_string = i_user_data-access_key.
  lr_ixml_document->create_simple_element( name   = 'ACCESS_KEY' "#EC NOTEXT
                                           parent = lr_elem_user
                                           value  = l_string ).

  l_string = i_user_data-secr_access_key.
  lr_ixml_document->create_simple_element( name   = 'SECR_ACCESS_KEY' "#EC NOTEXT
                                           parent = lr_elem_user
                                           value  = l_string ).

  l_xxml = ZLNKEcl_xml_utils=>convert_ixml_doc_to_xstring( lr_ixml_document ).

  CALL METHOD ZLNKEcl_log=>append_logx
    EXPORTING
      i_log_event  = c_log_evt_user_created
      i_log_msgtyp = c_log_msgtyp_info
      i_xstring    = l_xxml.

ENDMETHOD.


METHOD append_log_user_deleted.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 24th April 2014
* Appends log for Request to S3
*--------------------------------------------------------------------*
  DATA: l_string TYPE string.
  DATA: l_xxml TYPE xstring.
  DATA: lr_ixml TYPE REF TO if_ixml.
  DATA: lr_ixml_document TYPE REF TO if_ixml_document.
  DATA: lr_elem_user TYPE REF TO if_ixml_element.

* Create iXML object
  lr_ixml = cl_ixml=>create( ).

* Create iXML document
  lr_ixml_document = lr_ixml->create_document( ).

* Element UserCreation
  lr_elem_user  = lr_ixml_document->create_simple_element(  "#EC NOTEXT
                                           name   = 'UserDeletion'
                                           parent = lr_ixml_document ).

  l_string = i_user_data-user_name.
  lr_ixml_document->create_simple_element( name   = 'USER_NAME' "#EC NOTEXT
                                           parent = lr_elem_user
                                           value  = l_string ).

  l_string = i_user_data-access_key.
  lr_ixml_document->create_simple_element( name   = 'ACCESS_KEY' "#EC NOTEXT
                                           parent = lr_elem_user
                                           value  = l_string ).

  l_string = i_user_data-secr_access_key.
  lr_ixml_document->create_simple_element( name   = 'SECR_ACCESS_KEY' "#EC NOTEXT
                                           parent = lr_elem_user
                                           value  = l_string ).

  l_xxml = ZLNKEcl_xml_utils=>convert_ixml_doc_to_xstring( lr_ixml_document ).

  CALL METHOD ZLNKEcl_log=>append_logx
    EXPORTING
      i_log_event  = c_log_evt_user_deleted
      i_log_msgtyp = c_log_msgtyp_info
      i_xstring    = l_xxml.

ENDMETHOD.


METHOD append_log_user_edition.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 24th April 2014
* Appends log for Request to S3
*--------------------------------------------------------------------*
  DATA: l_string TYPE string.
  DATA: l_xxml TYPE xstring.
  DATA: lr_ixml TYPE REF TO if_ixml.
  DATA: lr_ixml_document TYPE REF TO if_ixml_document.
  DATA: lr_elem_user TYPE REF TO if_ixml_element.

* Create iXML object
  lr_ixml = cl_ixml=>create( ).

* Create iXML document
  lr_ixml_document = lr_ixml->create_document( ).

* Element UserCreation
  lr_elem_user  = lr_ixml_document->create_simple_element(  "#EC NOTEXT
                                           name   = 'UserEdition'
                                           parent = lr_ixml_document ).

  l_string = i_user_data_old-user_name.
  lr_ixml_document->create_simple_element( name   = 'USER_NAME' "#EC NOTEXT
                                           parent = lr_elem_user
                                           value  = l_string ).

  l_string = i_user_data_old-access_key.
  lr_ixml_document->create_simple_element( name   = 'ACCESS_KEY_OLD' "#EC NOTEXT
                                           parent = lr_elem_user
                                           value  = l_string ).

  l_string = i_user_data_old-secr_access_key.
  lr_ixml_document->create_simple_element( name   = 'SECR_ACCESS_KEY_OLD' "#EC NOTEXT
                                           parent = lr_elem_user
                                           value  = l_string ).

  l_string = i_user_data_new-access_key.
  lr_ixml_document->create_simple_element( name   = 'ACCESS_KEY_NEW' "#EC NOTEXT
                                           parent = lr_elem_user
                                           value  = l_string ).

  l_string = i_user_data_new-secr_access_key.
  lr_ixml_document->create_simple_element( name   = 'SECR_ACCESS_KEY_NEW' "#EC NOTEXT
                                           parent = lr_elem_user
                                           value  = l_string ).

  l_xxml = ZLNKEcl_xml_utils=>convert_ixml_doc_to_xstring( lr_ixml_document ).

  CALL METHOD ZLNKEcl_log=>append_logx
    EXPORTING
      i_log_event  = c_log_evt_user_edition
      i_log_msgtyp = c_log_msgtyp_info
      i_xstring    = l_xxml.

ENDMETHOD.


METHOD class_constructor.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 14th April 2014
* Class constructor
*--------------------------------------------------------------------*

  read_config( ).
  purge_log( ).

ENDMETHOD.


METHOD purge_log.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 14th April 2014
* Deletes from log table old registers for events
*  c_log_evt_cont_server_req
*  c_log_evt_req_to_aws
*  c_log_evt_resp_from_aws
*--------------------------------------------------------------------*
  DATA: l_timestamp TYPE timestamp.
  DATA: l_timestampl_c TYPE char21.
  DATA: l_datum TYPE datum.

  l_datum = sy-datum - attr_keep_days.
  l_timestampl_c(8) = l_datum.
  l_timestampl_c+8(6) = sy-uzeit.
  l_timestamp = l_timestampl_c.

  DELETE FROM ZLNKElog
  WHERE timestamp < l_timestamp
    AND log_event IN (c_log_evt_cont_server_req,
                      c_log_evt_req_to_aws,
                      c_log_evt_resp_from_aws).

ENDMETHOD.


METHOD read_config.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 14th April 2014
* Reads configuration
*--------------------------------------------------------------------*

  SELECT SINGLE keep_days log_xml_resp_aws log_req_resp_aws log_contserv_req
           INTO (attr_keep_days, attr_log_response_from_aws,
                 attr_log_req_resp_from_aws, attr_log_cont_serv_request)
  FROM ZLNKElog_cfg
  WHERE dummyid = space.
  IF sy-subrc <> 0.
*   Value by default
    attr_keep_days = c_default_days_to_keep.
  ENDIF.

ENDMETHOD.
ENDCLASS.
