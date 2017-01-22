*&---------------------------------------------------------------------*
*& Report  ZLNKEAWS_S3_DEMO_FILE
*&
*&---------------------------------------------------------------------*
*& Company: RocketSteam
*& Author: Jordi Escoda, 8th September 2017
*& e-mail: jordi.escoda@rocket-steam.com or jordi.escoda@linkeit.com
*& This demo program shows how to perform file operations
*&---------------------------------------------------------------------*
REPORT  zlnkeaws_s3_demo_file.

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
            p_get RADIOBUTTON GROUP rb1,
            p_head RADIOBUTTON GROUP rb1.
PARAMETERS: p_dbg AS CHECKBOX.
PARAMETERS: p_bucket TYPE zlnkebucket-bucket LOWER CASE,
            p_folder TYPE string LOWER CASE,
            p_fname TYPE string LOWER CASE.
SELECTION-SCREEN END OF BLOCK b1.

*----------------------------------------------------------------------*
*       CLASS lcl_demo_FILE DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_demo_file DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS:
      execute,
      selection_screen_visibility.

  PRIVATE SECTION.
    CLASS-METHODS:
      put_file,
      delete_file,
      get_file,
      head_file,
      select_and_get_file_bin
       EXPORTING ex_filename TYPE string
                 ex_content TYPE xstring
       RAISING zlnkecx_aws_s3,
      split_filename
       IMPORTING im_path TYPE string
       EXPORTING ex_directory TYPE string
                 ex_filename TYPE string
                 ex_file TYPE string
                 ex_extension TYPE char4.
ENDCLASS.                    "lcl_demo_FILE DEFINITION

*----------------------------------------------------------------------*
*       CLASS lcl_demo_FILE IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_demo_file IMPLEMENTATION.

*--------------------------------------------------------------------*
* Highest level of abstraction
*--------------------------------------------------------------------*
  METHOD execute.
    CASE abap_true.
      WHEN p_put.
        put_file( ).
      WHEN p_delet.
        delete_file( ).
      WHEN p_get.
        get_file( ).
      WHEN p_head.
        head_file( ).
    ENDCASE.
  ENDMETHOD.                    "execute

*--------------------------------------------------------------------*
* Shows a file select dialog and puts the file in the Bucket
*--------------------------------------------------------------------*
  METHOD put_file.
    DATA: lv_filename TYPE string,
          lv_folder TYPE string.
    DATA: lv_content TYPE xstring.
    DATA: lv_msg TYPE string.
    DATA: lv_xml TYPE string.
    DATA: lv_http_status TYPE i.
    DATA: lr_bucket TYPE REF TO zlnkecl_aws_s3_bucket.
    DATA: lr_cx_aws_s3 TYPE REF TO zlnkecx_aws_s3.

    TRY.
        select_and_get_file_bin( IMPORTING ex_filename = lv_filename
                                           ex_content  = lv_content ).

*       Escape for considering special characters in file name
        lv_filename = zlnkecl_http=>escape_url( lv_filename ).
        IF p_folder IS NOT INITIAL.
          lv_folder = zlnkecl_http=>escape_url( p_folder ).
          CONCATENATE lv_folder '/' lv_filename INTO lv_filename.
        ENDIF.

        CREATE OBJECT lr_bucket
          EXPORTING
            i_bucket_name = p_bucket
            i_dbg         = p_dbg.

        CALL METHOD lr_bucket->put_object
          EXPORTING
            i_object_name      = lv_filename
            i_xcontent         = lv_content
            i_escape_url       = abap_false
          IMPORTING
            e_http_status      = lv_http_status
            e_response_content = lv_xml.

        IF lv_xml IS NOT INITIAL.
          zlnkecl_xml_utils=>show_xml_in_dialog( lv_xml ).
        ENDIF.

        IF lv_http_status = zlnkecl_http=>c_status_200_ok.
          CONCATENATE 'File ' lv_filename ' created successfully'
                 INTO lv_msg RESPECTING BLANKS.
        ELSE.
          CONCATENATE 'File ' lv_filename ' could not be created'
                 INTO lv_msg RESPECTING BLANKS.
        ENDIF.
        CONDENSE lv_msg.
        WRITE:/ lv_msg.

      CATCH zlnkecx_aws_s3 INTO lr_cx_aws_s3.
        lv_msg = lr_cx_aws_s3->get_text( ).
        WRITE:/ lv_msg.
    ENDTRY.

  ENDMETHOD.                    "create_FILE

*--------------------------------------------------------------------*
* Deletes a file from the Bucket
*--------------------------------------------------------------------*
  METHOD delete_file.
    DATA: lv_filename TYPE string,
          lv_folder TYPE string.
    DATA: lv_msg TYPE string.
    DATA: lv_xml TYPE string.
    DATA: lv_http_status TYPE i.
    DATA: lr_bucket TYPE REF TO zlnkecl_aws_s3_bucket.
    DATA: lr_cx_aws_s3 TYPE REF TO zlnkecx_aws_s3.

    TRY.
*       Escape for considering special characters in file name
        lv_filename = zlnkecl_http=>escape_url( p_fname ).
        IF p_folder IS NOT INITIAL.
          lv_folder = zlnkecl_http=>escape_url( p_folder ).
          CONCATENATE lv_folder '/' lv_filename INTO lv_filename.
        ENDIF.

        CREATE OBJECT lr_bucket
          EXPORTING
            i_bucket_name = p_bucket
            i_dbg         = p_dbg.

        CALL METHOD lr_bucket->head_object
          EXPORTING
            i_object_name = lv_filename
          IMPORTING
            e_http_status = lv_http_status.

        IF lv_http_status = zlnkecl_http=>c_status_200_ok.
          CALL METHOD lr_bucket->delete_object
            EXPORTING
              i_object_name      = lv_filename
            IMPORTING
              e_http_status      = lv_http_status
              e_response_content = lv_xml.

          IF lv_xml IS NOT INITIAL.
            zlnkecl_xml_utils=>show_xml_in_dialog( lv_xml ).
          ENDIF.

          IF lv_http_status = zlnkecl_http=>c_status_204_no_content.
            CONCATENATE 'File ' lv_filename ' deleted successfully'
                   INTO lv_msg RESPECTING BLANKS.
          ELSE.
            CONCATENATE 'File ' lv_filename ' could not be deleted'
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

  ENDMETHOD.                    "delete_FILE

*--------------------------------------------------------------------*
* Reads a file from the Bucket
*--------------------------------------------------------------------*
  METHOD get_file.
    DATA: lv_filename TYPE string,
          lv_folder TYPE string.
    DATA: lv_msg TYPE string.
    DATA: lv_xml TYPE string.
    DATA: lv_file_content TYPE xstring.                     "#EC NEEDED
    DATA: lv_http_status TYPE i.
    DATA: lr_bucket TYPE REF TO zlnkecl_aws_s3_bucket.
    DATA: lr_cx_aws_s3 TYPE REF TO zlnkecx_aws_s3.

    TRY.
*       Escape for considering special characters in file name
        lv_filename = zlnkecl_http=>escape_url( p_fname ).
        IF p_folder IS NOT INITIAL.
          lv_folder = zlnkecl_http=>escape_url( p_folder ).
          CONCATENATE lv_folder '/' lv_filename INTO lv_filename.
        ENDIF.

        CREATE OBJECT lr_bucket
          EXPORTING
            i_bucket_name = p_bucket
            i_dbg         = p_dbg.

        CALL METHOD lr_bucket->get_object
          EXPORTING
            i_object_name       = lv_filename
          IMPORTING
            e_http_status       = lv_http_status
            e_response_xcontent = lv_file_content.  "File content is returned here

        IF lv_http_status = zlnkecl_http=>c_status_200_ok.
          CONCATENATE 'File ' lv_filename ' retrieved successfully'
                 INTO lv_msg RESPECTING BLANKS.
        ELSEIF lv_http_status = zlnkecl_http=>c_status_404_not_found.
          CONCATENATE 'File ' lv_filename ' not found'
                 INTO lv_msg RESPECTING BLANKS.

          zlnkecl_string_conversions=>xstring_to_string(
                          EXPORTING input  = lv_file_content
                          IMPORTING output = lv_xml ).
          IF lv_xml IS NOT INITIAL.
            zlnkecl_xml_utils=>show_xml_in_dialog( lv_xml ).
          ENDIF.
        ENDIF.
        CONDENSE lv_msg.
        WRITE:/ lv_msg.

      CATCH zlnkecx_aws_s3 INTO lr_cx_aws_s3.
        lv_msg = lr_cx_aws_s3->get_text( ).
        WRITE:/ lv_msg.
    ENDTRY.

  ENDMETHOD.                    "get_file

*--------------------------------------------------------------------*
* This shows how to get file information without retrieving file content
* File lenght comes in response headers
*--------------------------------------------------------------------*
  METHOD head_file.
    DATA: lv_filename TYPE string,
          lv_folder TYPE string.
    DATA: lv_msg TYPE string.
    DATA: lv_http_status TYPE i.
    DATA: lt_response_headers TYPE tihttpnvp.               "#EC NEEDED
    DATA: lr_bucket TYPE REF TO zlnkecl_aws_s3_bucket.
    DATA: lr_cx_aws_s3 TYPE REF TO zlnkecx_aws_s3.

    TRY.
*       Escape for considering special characters in file name
        lv_filename = zlnkecl_http=>escape_url( p_fname ).
        IF p_folder IS NOT INITIAL.
          lv_folder = zlnkecl_http=>escape_url( p_folder ).
          CONCATENATE lv_folder '/' lv_filename INTO lv_filename.
        ENDIF.

        CREATE OBJECT lr_bucket
          EXPORTING
            i_bucket_name = p_bucket
            i_dbg         = p_dbg.

        CALL METHOD lr_bucket->head_object
          EXPORTING
            i_object_name      = lv_filename
          IMPORTING
            e_http_status      = lv_http_status
            e_response_headers = lt_response_headers.

        lv_msg = zlnkecl_http=>get_reason_by_status( lv_http_status ).
        WRITE:/ lv_http_status, lv_msg.

      CATCH zlnkecx_aws_s3 INTO lr_cx_aws_s3.
        lv_msg = lr_cx_aws_s3->get_text( ).
        WRITE:/ lv_msg.
    ENDTRY.
  ENDMETHOD.                    "head_file

*--------------------------------------------------------------------*
* Shows file select dialog and returns file content
*--------------------------------------------------------------------*
  METHOD select_and_get_file_bin.
    TYPES: BEGIN OF typ_raw,
      raw(255) TYPE x,
    END OF typ_raw.

    DATA: lv_rc TYPE i,
          lt_files TYPE filetable,
          lv_file TYPE file_table,
          lv_filename TYPE string.
    DATA: lv_msg TYPE string.                               "#EC NEEDED
    DATA: lt_raw TYPE STANDARD TABLE OF typ_raw.
    DATA: lv_filelength TYPE i.                             "#EC NEEDED

    FIELD-SYMBOLS: <fs_raw> TYPE typ_raw.

    CLEAR ex_content.

    CALL METHOD cl_gui_frontend_services=>file_open_dialog
      CHANGING
        file_table              = lt_files
        rc                      = lv_rc
      EXCEPTIONS
        file_open_dialog_failed = 1
        cntl_error              = 2
        error_no_gui            = 3
        not_supported_by_gui    = 4
        OTHERS                  = 5.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_msg.
      zlnkecx_aws_s3=>raise_from_sy_msg( ).
    ENDIF.

    READ TABLE lt_files INTO lv_file INDEX 1.
    lv_filename = lv_file.
    CALL METHOD cl_gui_frontend_services=>gui_upload
      EXPORTING
        filename                = lv_filename
        filetype                = 'BIN'
      IMPORTING
        filelength              = lv_filelength
      CHANGING
        data_tab                = lt_raw
      EXCEPTIONS
        file_open_error         = 1
        file_read_error         = 2
        no_batch                = 3
        gui_refuse_filetransfer = 4
        invalid_type            = 5
        no_authority            = 6
        unknown_error           = 7
        bad_data_format         = 8
        header_not_allowed      = 9
        separator_not_allowed   = 10
        header_too_long         = 11
        unknown_dp_error        = 12
        access_denied           = 13
        dp_out_of_memory        = 14
        disk_full               = 15
        dp_timeout              = 16
        not_supported_by_gui    = 17
        error_no_gui            = 18
        OTHERS                  = 19.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_msg.
      zlnkecx_aws_s3=>raise_from_sy_msg( ).
    ENDIF.

    LOOP AT lt_raw ASSIGNING <fs_raw>.
      CONCATENATE ex_content
                  <fs_raw>-raw
                  INTO ex_content IN BYTE MODE.
    ENDLOOP.

    split_filename( EXPORTING im_path = lv_filename
                    IMPORTING ex_filename = ex_filename ).

  ENDMETHOD.                    "select_and_get_file_bin

*--------------------------------------------------------------------*
* Splits filename
*--------------------------------------------------------------------*
  METHOD split_filename.
    DATA: lv_fullname TYPE string,
          lv_dirlen   TYPE i.
    DATA: lt_strings TYPE string_table.
    DATA: lv_lines TYPE i.
    DATA: lv_lines_minus_1 TYPE i.
    DATA: lv_string TYPE string.

    CLEAR: ex_directory,
           ex_filename,
           ex_file,
           ex_extension.

    lv_fullname = im_path.

    WHILE lv_fullname CA ':\/'.
      ADD 1 TO sy-fdpos.
      ADD sy-fdpos TO lv_dirlen.
      SHIFT lv_fullname LEFT BY sy-fdpos PLACES.
    ENDWHILE.
    ex_filename = lv_fullname.

    IF lv_dirlen > 0.
      ex_directory = im_path(lv_dirlen).
    ENDIF.

    SPLIT ex_filename AT '.' INTO TABLE lt_strings.
    lv_lines = LINES( lt_strings ).
    IF lv_lines < 2.
      ex_file = ex_filename.
    ELSE.
      lv_lines_minus_1 = lv_lines - 1.
      DO lv_lines_minus_1 TIMES.
        READ TABLE lt_strings INDEX sy-index INTO lv_string.
        CONCATENATE ex_file lv_string INTO ex_file.
      ENDDO.
      READ TABLE lt_strings INDEX lv_lines INTO ex_extension.
      TRANSLATE ex_extension TO UPPER CASE.               "#EC SYNTCHAR
    ENDIF.
  ENDMETHOD.                    "split_filename

*--------------------------------------------------------------------*
* Handles selection screen elements
*--------------------------------------------------------------------*
  METHOD selection_screen_visibility.
    LOOP AT SCREEN.
      IF screen-name CS 'P_FNAME'.
        IF p_put = abap_true.
          screen-active = 0.
        ELSE.
          screen-active = 1.
        ENDIF.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDMETHOD.                    "selection_screen_visibility

ENDCLASS.                    "lcl_demo_FILE IMPLEMENTATION

*--------------------------------------------------------------------*
* INITIALIZATION
*--------------------------------------------------------------------*
INITIALIZATION.
  p_put = abap_true.

*--------------------------------------------------------------------*
* AT SELECTION-SCREEN OUTPUT
*--------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  lcl_demo_file=>selection_screen_visibility( ).

*--------------------------------------------------------------------*
* START-OF-SELECTION
*--------------------------------------------------------------------*
START-OF-SELECTION.
  lcl_demo_file=>execute( ).
