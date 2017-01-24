*&---------------------------------------------------------------------*
*& Report ZLNKERS3_TABLES_INITIAL_LOAD
*&---------------------------------------------------------------------*
*& Company: RocketSteam
*& Author: Jordi Escoda, 21th December 2016
*& Initial load for tables (Run once at installation)
*&---------------------------------------------------------------------*
REPORT zlnkers3_tables_initial_load.

PARAMETERS: p_test AS CHECKBOX DEFAULT abap_true.

CLASS lcl_load DEFINITION FINAL.
  PUBLIC SECTION.
    CLASS-METHODS:
      execute.

  PRIVATE SECTION.
    CLASS-METHODS:
      load_zlnkeregion,
      load_zlnkelog_cfg.
ENDCLASS.

CLASS lcl_load IMPLEMENTATION.
  METHOD execute.
    load_zlnkeregion( ).
    load_zlnkelog_cfg( ).
  ENDMETHOD.

  METHOD load_zlnkeregion.
    DATA: ls_zlnkeregion TYPE zlnkeregion.
    DATA: lt_zlnkeregion TYPE STANDARD TABLE OF zlnkeregion.

    SELECT *
      INTO TABLE lt_zlnkeregion
    FROM zlnkeregion.

    IF sy-subrc <> 0.
      ls_zlnkeregion-region = 'ap-northeast-1'.
      ls_zlnkeregion-region_name = 'Asia Pacific (Tokyo)'.
      ls_zlnkeregion-endpoint = 's3-ap-northeast-1.amazonaws.com'.
      APPEND ls_zlnkeregion TO lt_zlnkeregion.

      ls_zlnkeregion-region = 'ap-northeast-2'.
      ls_zlnkeregion-region_name = 'Asia Pacific (Seoul)'.
      ls_zlnkeregion-endpoint = 's3-ap-northeast-2.amazonaws.com'.
      APPEND ls_zlnkeregion TO lt_zlnkeregion.

      ls_zlnkeregion-region = 'ap-south-1'.
      ls_zlnkeregion-region_name = 'Asia Pacific (Mumbai)'.
      ls_zlnkeregion-endpoint = 's3-ap-south-1.amazonaws.com'.
      APPEND ls_zlnkeregion TO lt_zlnkeregion.

      ls_zlnkeregion-region = 'ap-southeast-1'.
      ls_zlnkeregion-region_name = 'Asia Pacific (Singapore)'.
      ls_zlnkeregion-endpoint = 's3-ap-southeast-1.amazonaws.com'.
      APPEND ls_zlnkeregion TO lt_zlnkeregion.

      ls_zlnkeregion-region = 'ap-southeast-2'.
      ls_zlnkeregion-region_name = 'Asia Pacific (Sydney)'.
      ls_zlnkeregion-endpoint = 's3-ap-southeast-2.amazonaws.com'.
      APPEND ls_zlnkeregion TO lt_zlnkeregion.

      ls_zlnkeregion-region = 'ca-central-1'.
      ls_zlnkeregion-region_name = 'Canada (Central)'.
      ls_zlnkeregion-endpoint = 's3-ca-central-1.amazonaws.com'.
      APPEND ls_zlnkeregion TO lt_zlnkeregion.

      ls_zlnkeregion-region = 'eu-central-1'.
      ls_zlnkeregion-region_name = 'EU (Frankfurt)'.
      ls_zlnkeregion-endpoint = 's3.eu-central-1.amazonaws.com'.
      APPEND ls_zlnkeregion TO lt_zlnkeregion.

      ls_zlnkeregion-region = 'eu-west-1'.
      ls_zlnkeregion-region_name = 'EU (Ireland)'.
      ls_zlnkeregion-endpoint = 's3-eu-west-1.amazonaws.com'.
      APPEND ls_zlnkeregion TO lt_zlnkeregion.

      ls_zlnkeregion-region = 'eu-west-2'.
      ls_zlnkeregion-region_name = 'EU (London)'.
      ls_zlnkeregion-endpoint = 's3-eu-west-2.amazonaws.com'.
      APPEND ls_zlnkeregion TO lt_zlnkeregion.

      ls_zlnkeregion-region = 'sa-east-1'.
      ls_zlnkeregion-region_name = 'South America (Sao Paulo)'.
      ls_zlnkeregion-endpoint = 's3-sa-east-1.amazonaws.com'.
      APPEND ls_zlnkeregion TO lt_zlnkeregion.

      ls_zlnkeregion-region = 'us-east-1'.
      ls_zlnkeregion-region_name = 'US Standard *'.
      ls_zlnkeregion-endpoint = 's3.amazonaws.com'.
      APPEND ls_zlnkeregion TO lt_zlnkeregion.

      ls_zlnkeregion-region = 'us-east-2'.
      ls_zlnkeregion-region_name = 'US East (Ohio)'.
      ls_zlnkeregion-endpoint = 's3-us-east-2.amazonaws.com'.
      APPEND ls_zlnkeregion TO lt_zlnkeregion.

      ls_zlnkeregion-region = 'us-west-1'.
      ls_zlnkeregion-region_name = 'US West (Northern California)'.
      ls_zlnkeregion-endpoint = 's3-us-west-1.amazonaws.com'.
      APPEND ls_zlnkeregion TO lt_zlnkeregion.

      ls_zlnkeregion-region = 'us-west-2'.
      ls_zlnkeregion-region_name = 'US West (Oregon)'.
      ls_zlnkeregion-endpoint = 's3-us-west-2.amazonaws.com'.
      APPEND ls_zlnkeregion TO lt_zlnkeregion.

      IF p_test = abap_false.
        MODIFY zlnkeregion FROM TABLE lt_zlnkeregion.
        IF sy-subrc = 0.
          WRITE:/ 'Table LNKEREGION initial load success'.
        ELSE.
          WRITE:/ 'Table LNKEREGION initial load: Something went wrong'.
        ENDIF.
      ELSE.
        WRITE:/ 'Table LNKEREGION initial load success (Test mode)'.
      ENDIF.
    ELSE.
      WRITE:/ 'Table LNKEREGION already has data'.
    ENDIF.
  ENDMETHOD.

  METHOD load_zlnkelog_cfg.
    DATA: ls_zlnkelog_cfg TYPE zlnkelog_cfg.

    SELECT SINGLE *
             INTO ls_zlnkelog_cfg
    FROM zlnkelog_cfg
    WHERE dummyid = space.

    IF sy-subrc <> 0.
      ls_zlnkelog_cfg-keep_days = 3.
      IF p_test = abap_false.
        MODIFY zlnkelog_cfg FROM ls_zlnkelog_cfg.
        IF sy-subrc = 0.
          WRITE:/ 'Table ZLNKELOG_CFG initial load success'.
        ELSE.
          WRITE:/ 'Table ZLNKELOG_CFG initial load: Something went wrong'.
        ENDIF.
      ELSE.
        WRITE:/ 'Table ZLNKELOG_CFG initial load success (Test mode)'.
      ENDIF.
    ELSE.
      WRITE:/ 'Table ZLNKELOG_CFG already has data'.
    ENDIF.

  ENDMETHOD.
ENDCLASS.

START-OF-SELECTION.
  lcl_load=>execute( ).
