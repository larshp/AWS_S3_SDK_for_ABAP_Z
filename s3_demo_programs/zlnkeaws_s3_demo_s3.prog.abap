*&---------------------------------------------------------------------*
*& Report  ZLNKEAWS_S3_DEMO_S3
*&
*&---------------------------------------------------------------------*
*& Company: RocketSteam
*& Author: Jordi Escoda, 15th September 2017
*& e-mail: jordi.escoda@rocket-steam.com or jordi.escoda@linkeit.com
*& This demo program shows how use list buckets
*&---------------------------------------------------------------------*
REPORT  zlnkeaws_s3_demo_s3.

*--------------------------------------------------------------------*
* Selection screen
*--------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
PARAMETERS: p_dbg AS CHECKBOX.
PARAMETERS: p_iam TYPE zlnkeuser-user_name LOWER CASE.
SELECTION-SCREEN END OF BLOCK b1.

*----------------------------------------------------------------------*
*       CLASS lcl_demo_bucket DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_demo_s3 DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS:
      list_buckets.
ENDCLASS.                    "lcl_demo_bucket DEFINITION

*----------------------------------------------------------------------*
*       CLASS lcl_demo_bucket IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_demo_s3 IMPLEMENTATION.

  METHOD list_buckets.
    DATA: lr_s3 TYPE REF TO zlnkecl_aws_s3.
    DATA: lv_response_content TYPE string.
    DATA: lr_cx_aws_s3 TYPE REF TO zlnkecx_aws_s3.
    DATA: lv_exception_text TYPE string.
    TRY.
        CREATE OBJECT lr_s3
          EXPORTING
            i_user_name = p_iam
            i_dbg       = p_dbg.

        CALL METHOD lr_s3->get_service
          IMPORTING
            e_response_content = lv_response_content.

        CALL METHOD zlnkecl_xml_utils=>show_xml_in_dialog
          EXPORTING
            i_xml = lv_response_content.

      CATCH zlnkecx_aws_s3 INTO lr_cx_aws_s3.
        lv_exception_text = lr_cx_aws_s3->get_text( ).
        WRITE:/ lv_exception_text.
    ENDTRY.

  ENDMETHOD.                    "execute

ENDCLASS.                    "lcl_demo_bucket IMPLEMENTATION

*--------------------------------------------------------------------*
* START-OF-SELECTION
*--------------------------------------------------------------------*
START-OF-SELECTION.
  lcl_demo_s3=>list_buckets( ).
