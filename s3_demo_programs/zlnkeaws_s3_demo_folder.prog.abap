*&---------------------------------------------------------------------*
*& Report  ZLNKEAWS_S3_DEMO_FOLDER
*&
*&---------------------------------------------------------------------*
*& Company: RocketSteam
*& Author: Jordi Escoda, 8th September 2017
*& e-mail: jordi.escoda@rocket-steam.com or jordi.escoda@linkeit.com
*& This demo program shows how to use folders
*--------------------------------------------------------------------*
REPORT  zlnkeaws_s3_demo_folder.

*--------------------------------------------------------------------*
* Types
*--------------------------------------------------------------------*
TYPE-POOLS: abap.

*--------------------------------------------------------------------*
* Selection screen
*--------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
PARAMETERS: p_put RADIOBUTTON GROUP rb1 USER-COMMAND rb,
            p_delet RADIOBUTTON GROUP rb1,
            p_head RADIOBUTTON GROUP rb1.
PARAMETERS: p_dbg AS CHECKBOX.
PARAMETERS: p_bucket TYPE zlnkebucket-bucket LOWER CASE,
            p_folder TYPE string LOWER CASE.
SELECTION-SCREEN END OF BLOCK b1.

*----------------------------------------------------------------------*
*       CLASS lcl_demo_folder DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_demo_folder DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS:
      execute.

  PRIVATE SECTION.
    CLASS-METHODS:
      put_folder,
      delete_folder,
      head_folder.

ENDCLASS.                    "lcl_demo_FILE DEFINITION

*----------------------------------------------------------------------*
*       CLASS lcl_ DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_demo_folder IMPLEMENTATION.

*--------------------------------------------------------------------*
* Highest level of abstraction
*--------------------------------------------------------------------*
  METHOD execute.
    CASE abap_true.
      WHEN p_put.
        put_folder( ).
      WHEN p_delet.
        delete_folder( ).
      WHEN p_head.
        head_folder( ).
    ENDCASE.
  ENDMETHOD.                    "execute

*--------------------------------------------------------------------*
* Creates a Folder
*--------------------------------------------------------------------*
  METHOD put_folder.
    DATA: lv_folder TYPE string.
    DATA: lv_msg TYPE string.
    DATA: lv_xml TYPE string.
    DATA: lv_http_status TYPE i.
    DATA: lr_bucket TYPE REF TO zlnkecl_aws_s3_bucket.
    DATA: lr_cx_aws_s3 TYPE REF TO zlnkecx_aws_s3.

    TRY.
*       Escape for considering special characters in folder name
        lv_folder = zlnkecl_http=>escape_url( p_folder ).
        CONCATENATE lv_folder '/' INTO lv_folder.

        CREATE OBJECT lr_bucket
          EXPORTING
            i_bucket_name = p_bucket
            i_dbg         = p_dbg.

        CALL METHOD lr_bucket->put_object
          EXPORTING
            i_object_name      = lv_folder
            i_escape_url       = abap_false
          IMPORTING
            e_http_status      = lv_http_status
            e_response_content = lv_xml.

        IF lv_xml IS NOT INITIAL.
          zlnkecl_xml_utils=>show_xml_in_dialog( lv_xml ).
        ENDIF.

        IF lv_http_status = zlnkecl_http=>c_status_200_ok.
          CONCATENATE 'Folder ' lv_folder ' created successfully'
                 INTO lv_msg RESPECTING BLANKS.
        ELSE.
          CONCATENATE 'Folder ' lv_folder ' could not be created'
                 INTO lv_msg RESPECTING BLANKS.
        ENDIF.
        CONDENSE lv_msg.
        WRITE:/ lv_msg.

      CATCH zlnkecx_aws_s3 INTO lr_cx_aws_s3.
        lv_msg = lr_cx_aws_s3->get_text( ).
        WRITE:/ lv_msg.
    ENDTRY.

  ENDMETHOD.                    "put_folder

*--------------------------------------------------------------------*
* Deletes a folder (must be empty)
*--------------------------------------------------------------------*
  METHOD delete_folder.
    DATA: lv_folder TYPE string.
    DATA: lv_msg TYPE string.
    DATA: lv_xml TYPE string.
    DATA: lv_http_status TYPE i.
    DATA: lr_bucket TYPE REF TO zlnkecl_aws_s3_bucket.
    DATA: lr_cx_aws_s3 TYPE REF TO zlnkecx_aws_s3.

    TRY.
*       Escape for considering special characters in folder name
        lv_folder = zlnkecl_http=>escape_url( p_folder ).
        CONCATENATE lv_folder '/' INTO lv_folder.

        CREATE OBJECT lr_bucket
          EXPORTING
            i_bucket_name = p_bucket
            i_dbg         = p_dbg.

        CALL METHOD lr_bucket->head_object
          EXPORTING
            i_object_name = lv_folder
          IMPORTING
            e_http_status = lv_http_status.

        IF lv_http_status = zlnkecl_http=>c_status_200_ok.
          CALL METHOD lr_bucket->delete_object
            EXPORTING
              i_object_name      = lv_folder
            IMPORTING
              e_http_status      = lv_http_status
              e_response_content = lv_xml.

          IF lv_xml IS NOT INITIAL.
            zlnkecl_xml_utils=>show_xml_in_dialog( lv_xml ).
          ENDIF.

          IF lv_http_status = zlnkecl_http=>c_status_204_no_content.
            CONCATENATE 'Folder ' lv_folder ' deleted successfully'
                   INTO lv_msg RESPECTING BLANKS.
          ELSE.
            CONCATENATE 'Folder ' lv_folder ' could not be deleted'
                   INTO lv_msg RESPECTING BLANKS.
          ENDIF.
          CONDENSE lv_msg.
          WRITE:/ lv_msg.

        ELSE.
          lv_msg = zlnkecl_http=>get_reason_by_status( lv_http_status ).
          WRITE:/ lv_http_status, lv_msg.
        ENDIF.

      CATCH zlnkecx_aws_s3 INTO lr_cx_aws_s3.
        lv_msg = lr_cx_aws_s3->get_text( ).
        WRITE:/ lv_msg.
    ENDTRY.

  ENDMETHOD.                    "delete_folder

*--------------------------------------------------------------------*
* Head, to check if folder exists
*--------------------------------------------------------------------*
  METHOD head_folder.
    DATA: lv_folder TYPE string.
    DATA: lv_msg TYPE string.
    DATA: lv_xml TYPE string.
    DATA: lv_http_status TYPE i.
    DATA: lt_response_headers TYPE tihttpnvp.               "#EC NEEDED
    DATA: lr_bucket TYPE REF TO zlnkecl_aws_s3_bucket.
    DATA: lr_cx_aws_s3 TYPE REF TO zlnkecx_aws_s3.

    TRY.
*       Escape for considering special characters in folder name
        lv_folder = zlnkecl_http=>escape_url( p_folder ).
        CONCATENATE lv_folder '/' INTO lv_folder.

        CREATE OBJECT lr_bucket
          EXPORTING
            i_bucket_name = p_bucket
            i_dbg         = p_dbg.

        CALL METHOD lr_bucket->head_object
          EXPORTING
            i_object_name      = lv_folder
          IMPORTING
            e_http_status      = lv_http_status
            e_response_headers = lt_response_headers.

        lv_msg = zlnkecl_http=>get_reason_by_status( lv_http_status ).
        WRITE:/ lv_http_status, lv_msg.

        IF lv_xml IS NOT INITIAL.
          zlnkecl_xml_utils=>show_xml_in_dialog( lv_xml ).
        ENDIF.

      CATCH zlnkecx_aws_s3 INTO lr_cx_aws_s3.
        lv_msg = lr_cx_aws_s3->get_text( ).
        WRITE:/ lv_msg.
    ENDTRY.
  ENDMETHOD.                    "head_folder

ENDCLASS.                    "lcl_demo_folder IMPLEMENTATION

*--------------------------------------------------------------------*
* START-OF-SELECTION
*--------------------------------------------------------------------*
START-OF-SELECTION.
  lcl_demo_folder=>execute( ).
