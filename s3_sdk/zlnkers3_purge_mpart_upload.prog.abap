*&---------------------------------------------------------------------*
*& Report  ZLNKERS3_PURGE_MPART_UPLOAD
*&
*&---------------------------------------------------------------------*
*& Company: RocketSteam
*& Author: Jordi Escoda, 21th March 2016
*& Purges multipart upload
*& It deletes records from table ZLNKEMPART_UPLD for transactions
*& aborted or success
*&---------------------------------------------------------------------*
REPORT  zlnkers3_purge_mpart_upload.

*--------------------------------------------------------------------*
* Tables
*--------------------------------------------------------------------*
TABLES: zlnkempart_upld.

*--------------------------------------------------------------------*
* Selection screen
*--------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
SELECT-OPTIONS: so_bckt FOR zlnkempart_upld-bucket.
SELECT-OPTIONS: so_objnm FOR zlnkempart_upld-object_name.
SELECTION-SCREEN END OF BLOCK b1.

*----------------------------------------------------------------------*
*       CLASS lcl_main DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_main DEFINITION FINAL.
  PUBLIC SECTION.
    CLASS-METHODS:
       execute,
       f4_bucket.
ENDCLASS.                    "lcl_main DEFINITION


*----------------------------------------------------------------------*
*       CLASS lcl_main IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_main IMPLEMENTATION.
  METHOD f4_bucket.
    TYPES: BEGIN OF lty_bucket,
      bucket TYPE zlnkebucket-bucket,
      region TYPE zlnkebucket-region,
      content_rep	TYPE zlnkebucket-content_rep,
    END OF lty_bucket.
    DATA: lt_bucket TYPE STANDARD TABLE OF lty_bucket.

    SELECT bucket region content_rep
       INTO TABLE lt_bucket
    FROM zlnkebucket.

    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        retfield        = 'BUCKET'
        dynpprog        = sy-repid
        dynpnr          = sy-dynnr
        dynprofield     = 'SO_BCKT'
        value_org       = 'S'
      TABLES
        value_tab       = lt_bucket
      EXCEPTIONS
        parameter_error = 1
        no_values_found = 2
        OTHERS          = 3.

    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

  ENDMETHOD.                    "f4_bucket

  METHOD execute.
    CONSTANTS: lc_mpart_upld_state_compl_ok TYPE c
       VALUE zlnkecl_aws_s3_bucket=>c_mpart_upld_state_compl_ok.
    CONSTANTS: lc_mpart_upld_state_aborted TYPE c
       VALUE zlnkecl_aws_s3_bucket=>c_mpart_upld_state_aborted.

    DELETE
    FROM zlnkempart_upld
    WHERE bucket IN so_bckt
      AND object_name IN so_objnm
      AND state IN (lc_mpart_upld_state_compl_ok,
                    lc_mpart_upld_state_aborted).
    IF sy-subrc <> 0.
      WRITE:/ 'Nothing deleted'.
    ELSE.
      WRITE:/ 'Deleted', sy-dbcnt, 'registers'.
    ENDIF.
  ENDMETHOD.                    "execute
ENDCLASS.                    "lcl_main IMPLEMENTATION

*--------------------------------------------------------------------*
* Selection screen events
*--------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_bckt-low.
  lcl_main=>f4_bucket( ).

AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_bckt-high.
  lcl_main=>f4_bucket( ).

*--------------------------------------------------------------------*
* START-OF-SELECTION.
*--------------------------------------------------------------------*
START-OF-SELECTION.
  lcl_main=>execute( ).
