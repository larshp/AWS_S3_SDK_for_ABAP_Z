*&---------------------------------------------------------------------*
*& Report  ZLNKEAWS_S3_DEMO_BUCKET
*&
*&---------------------------------------------------------------------*
*& Company: RocketSteam
*& Author: Jordi Escoda, 8th September 2017
*& e-mail: jordi.escoda@rocket-steam.com or jordi.escoda@linkeit.com
*& This demo program shows how use Bucket operations
*&---------------------------------------------------------------------*
REPORT  zlnkeaws_s3_demo_bucket.

*--------------------------------------------------------------------*
* Types
*--------------------------------------------------------------------*
TYPE-POOLS: abap.

*--------------------------------------------------------------------*
* Selection screen
*--------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
PARAMETERS: p_creat RADIOBUTTON GROUP rb1 USER-COMMAND rb,
            p_delet RADIOBUTTON GROUP rb1,
            p_list RADIOBUTTON GROUP rb1,
            p_loc  RADIOBUTTON GROUP rb1,
            p_head RADIOBUTTON GROUP rb1.
PARAMETERS: p_dbg AS CHECKBOX.
PARAMETERS: p_bucket TYPE zlnkebucket-bucket LOWER CASE,
            p_iam TYPE zlnkeuser-user_name LOWER CASE,
            p_region TYPE zlnkeregion-region LOWER CASE.
PARAMETERS: p_exists AS CHECKBOX.
SELECTION-SCREEN END OF BLOCK b1.

*----------------------------------------------------------------------*
*       CLASS lcl_demo_bucket DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_demo_bucket DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS:
      execute,
      selection_screen_visibility.

  PRIVATE SECTION.
    CLASS-METHODS:
      create_bucket,
      create_bucket_only_db,
      delete_bucket,
      list_bucket,
      bucket_location,
      head_bucket.

ENDCLASS.                    "lcl_demo_bucket DEFINITION

*----------------------------------------------------------------------*
*       CLASS lcl_demo_bucket IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_demo_bucket IMPLEMENTATION.

*--------------------------------------------------------------------*
* Highest level of abstraction
*--------------------------------------------------------------------*
  METHOD execute.
    CASE abap_true.
      WHEN p_creat.
        IF p_exists = abap_false.
          create_bucket( ).
        ELSE.
          create_bucket_only_db( ).
        ENDIF.
      WHEN p_delet.
        delete_bucket( ).
      WHEN p_list.
        list_bucket( ).
      WHEN p_loc.
        bucket_location( ).
      WHEN p_head.
        head_bucket( ).
    ENDCASE.
  ENDMETHOD.                    "execute

*--------------------------------------------------------------------*
* Creates a Bucket on AWS and DB
*--------------------------------------------------------------------*
  METHOD create_bucket.
    DATA: lv_xml TYPE string.
    DATA: lv_msg TYPE string.
    DATA: lv_http_status TYPE i.
    DATA: ls_zlnkebucket TYPE zlnkebucket.
    DATA: lr_bucket TYPE REF TO zlnkecl_aws_s3_bucket.      "#EC NEEDED
    DATA: lr_cx_aws_s3 TYPE REF TO zlnkecx_aws_s3.

    TRY.
        CALL METHOD zlnkecl_aws_s3_bucket=>create_bucket
          EXPORTING
            i_bucket_name      = p_bucket
            i_user_name        = p_iam
            i_region           = p_region
            i_dbg              = p_dbg
          IMPORTING
            e_http_status      = lv_http_status
            e_response_content = lv_xml
            e_aws_s3_bucket    = lr_bucket. "Reference to the bucket created

        IF lv_xml IS NOT INITIAL.
          zlnkecl_xml_utils=>show_xml_in_dialog( lv_xml ).
        ENDIF.

        IF lv_http_status = zlnkecl_http=>c_status_200_ok.
          ls_zlnkebucket-bucket = p_bucket.
          ls_zlnkebucket-user_name = p_iam.
          ls_zlnkebucket-region = p_region.
          ls_zlnkebucket-crusr = sy-uname.
          ls_zlnkebucket-crdat = sy-datum.
          ls_zlnkebucket-crtim = sy-uzeit.
          INSERT zlnkebucket FROM ls_zlnkebucket.
          CONCATENATE 'Bucket ' p_bucket ' created successfully'
                 INTO lv_msg RESPECTING BLANKS.
        ELSE.
          CONCATENATE 'Bucket ' p_bucket ' could not be created'
                 INTO lv_msg RESPECTING BLANKS.
        ENDIF.
        CONDENSE lv_msg.
        WRITE:/ lv_msg.

      CATCH zlnkecx_aws_s3 INTO lr_cx_aws_s3.
        lv_msg = lr_cx_aws_s3->get_text( ).
        WRITE:/ lv_msg.
    ENDTRY.

  ENDMETHOD.                    "create_bucket

*--------------------------------------------------------------------*
* Creates a Bucket only on DB. Makes sense when your bucket
* is already existing on AWS.
*--------------------------------------------------------------------*
  METHOD create_bucket_only_db.
    DATA: lv_msg TYPE string.
    DATA: lv_bucket TYPE zlnkebucket-bucket.
    DATA: ls_zlnkebucket TYPE zlnkebucket.

    SELECT SINGLE bucket
             INTO lv_bucket
    FROM zlnkebucket
    WHERE bucket = p_bucket.
    IF sy-subrc <> 0.
      ls_zlnkebucket-bucket = p_bucket.
      ls_zlnkebucket-user_name = p_iam.
      ls_zlnkebucket-region = p_region.
      ls_zlnkebucket-no_prefix = abap_true.
      ls_zlnkebucket-crusr = sy-uname.
      ls_zlnkebucket-crdat = sy-datum.
      ls_zlnkebucket-crtim = sy-uzeit.
      INSERT zlnkebucket FROM ls_zlnkebucket.
      CONCATENATE 'Bucket ' p_bucket ' created successfully'
             INTO lv_msg RESPECTING BLANKS.
    ELSE.
      CONCATENATE 'Bucket ' p_bucket ' already exists in DB'
             INTO lv_msg RESPECTING BLANKS.
    ENDIF.
    CONDENSE lv_msg.
    WRITE:/ lv_msg.

  ENDMETHOD.                    "create_bucket_only_db

*--------------------------------------------------------------------*
* Deletes a Bucket (must be empty)
*--------------------------------------------------------------------*
  METHOD delete_bucket.
    DATA: lv_xml TYPE string.
    DATA: lv_msg TYPE string.
    DATA: lv_http_status TYPE i.
    DATA: lr_bucket TYPE REF TO zlnkecl_aws_s3_bucket.
    DATA: lr_cx_aws_s3 TYPE REF TO zlnkecx_aws_s3.

    TRY.
        CREATE OBJECT lr_bucket
          EXPORTING
            i_bucket_name = p_bucket
            i_dbg         = p_dbg.

        CALL METHOD lr_bucket->delete_bucket
          IMPORTING
            e_http_status      = lv_http_status
            e_response_content = lv_xml.

        IF lv_xml IS NOT INITIAL.
          zlnkecl_xml_utils=>show_xml_in_dialog( lv_xml ).
        ENDIF.

        IF lv_http_status = zlnkecl_http=>c_status_204_no_content.
          DELETE FROM zlnkebucket WHERE bucket = p_bucket.
          CONCATENATE 'Bucket ' p_bucket ' deleted successfully'
                 INTO lv_msg RESPECTING BLANKS.
        ELSE.
          CONCATENATE 'Bucket ' p_bucket ' could not be deleted'
                 INTO lv_msg RESPECTING BLANKS.
        ENDIF.
        CONDENSE lv_msg.
        WRITE:/ lv_msg.

      CATCH zlnkecx_aws_s3 INTO lr_cx_aws_s3.
        lv_msg = lr_cx_aws_s3->get_text( ).
        WRITE:/ lv_msg.
    ENDTRY.

  ENDMETHOD.                    "delete_bucket

*--------------------------------------------------------------------*
* Lists Bucket content
*--------------------------------------------------------------------*
  METHOD list_bucket.
    DATA: lv_xml TYPE string.
    DATA: lv_msg TYPE string.
    DATA: lv_http_status TYPE i.                            "#EC NEEDED
    DATA: lr_bucket TYPE REF TO zlnkecl_aws_s3_bucket.
    DATA: lr_cx_aws_s3 TYPE REF TO zlnkecx_aws_s3.

    TRY.
        CREATE OBJECT lr_bucket
          EXPORTING
            i_bucket_name = p_bucket
            i_dbg         = p_dbg.

        CALL METHOD lr_bucket->list_objects
*          EXPORTING
*            i_prefix           =
*            i_marker           =
*            i_max_keys         =
          IMPORTING
            e_http_status      = lv_http_status
            e_response_content = lv_xml.

        IF lv_xml IS NOT INITIAL.
          zlnkecl_xml_utils=>show_xml_in_dialog( lv_xml ).
        ENDIF.

      CATCH zlnkecx_aws_s3 INTO lr_cx_aws_s3.
        lv_msg = lr_cx_aws_s3->get_text( ).
        WRITE:/ lv_msg.
    ENDTRY.
  ENDMETHOD.                    "list_bucket

*--------------------------------------------------------------------*
* Shows Bucket location
*--------------------------------------------------------------------*
  METHOD bucket_location.
    DATA: lv_xml TYPE string.
    DATA: lv_msg TYPE string.
    DATA: lv_http_status TYPE i.                            "#EC NEEDED
    DATA: lr_bucket TYPE REF TO zlnkecl_aws_s3_bucket.
    DATA: lr_cx_aws_s3 TYPE REF TO zlnkecx_aws_s3.

    TRY.
        CREATE OBJECT lr_bucket
          EXPORTING
            i_bucket_name = p_bucket
            i_dbg         = p_dbg.

        CALL METHOD lr_bucket->get_bucket_location
          IMPORTING
            e_http_status      = lv_http_status
            e_response_content = lv_xml.

        IF lv_xml IS NOT INITIAL.
          zlnkecl_xml_utils=>show_xml_in_dialog( lv_xml ).
        ENDIF.

      CATCH zlnkecx_aws_s3 INTO lr_cx_aws_s3.
        lv_msg = lr_cx_aws_s3->get_text( ).
        WRITE:/ lv_msg.
    ENDTRY.

  ENDMETHOD.                    "bucket_location

*--------------------------------------------------------------------*
* Head
*--------------------------------------------------------------------*
  METHOD head_bucket.
    DATA: lv_msg TYPE string.
    DATA: lv_http_status TYPE i.
    DATA: lt_response_headers TYPE tihttpnvp.               "#EC NEEDED
    DATA: lr_bucket TYPE REF TO zlnkecl_aws_s3_bucket.
    DATA: lr_cx_aws_s3 TYPE REF TO zlnkecx_aws_s3.

    TRY.
        CREATE OBJECT lr_bucket
          EXPORTING
            i_bucket_name = p_bucket
            i_dbg         = p_dbg.

        CALL METHOD lr_bucket->head_bucket
          IMPORTING
            e_http_status      = lv_http_status
            e_response_headers = lt_response_headers.

        lv_msg = zlnkecl_http=>get_reason_by_status( lv_http_status ).
        WRITE:/ lv_http_status, lv_msg.

      CATCH zlnkecx_aws_s3 INTO lr_cx_aws_s3.
        lv_msg = lr_cx_aws_s3->get_text( ).
        WRITE:/ lv_msg.
    ENDTRY.
  ENDMETHOD.                    "head_bucket

*--------------------------------------------------------------------*
* Handles selection screen elements
*--------------------------------------------------------------------*
  METHOD selection_screen_visibility.
    LOOP AT SCREEN.
      IF screen-name CS 'P_IAM'
        OR screen-name CS 'P_REGION'
        OR screen-name CS 'P_EXISTS'.
        IF p_creat = abap_true.
          screen-active = 1.
        ELSE.
          screen-active = 0.
        ENDIF.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDMETHOD.                    "SELECTION_screen_visibility
ENDCLASS.                    "lcl_demo_bucket IMPLEMENTATION

*--------------------------------------------------------------------*
* INITIALIZATION
*--------------------------------------------------------------------*
INITIALIZATION.
  p_creat = abap_true.

*--------------------------------------------------------------------*
* AT SELECTION-SCREEN OUTPUT
*--------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  lcl_demo_bucket=>selection_screen_visibility( ).

*--------------------------------------------------------------------*
* START-OF-SELECTION
*--------------------------------------------------------------------*
START-OF-SELECTION.
  lcl_demo_bucket=>execute( ).
