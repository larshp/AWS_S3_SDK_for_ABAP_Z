*&---------------------------------------------------------------------*
*& Report  ZLNKEAWS_S3_DEMO_IAM
*&
*&---------------------------------------------------------------------*
*& Company: RocketSteam
*& Author: Jordi Escoda, 12th September 2017
*& e-mail: jordi.escoda@rocket-steam.com or jordi.escoda@linkeit.com
*& This demo program shows how to create an IAM user in S3 for SAP
*&
*& NOTE: The IAM user must exist in your AWS account, and must have
*& proper permissions for bucket operations. Create User Policy for that.
*& Permissions for Bucket:
*    {
*        "Version": "2012-10-17",
*        "Statement": [
*            {
*                "Effect": "Allow",
*                "Action": [
*                    "s3:*"
*                ],
*                "Resource": [
*                    "arn:aws:s3:::<sid>-*"
*                ]
*            }
*        ]
*    }
*
*& Permissions for IAM
*    {
*      "Version": "2012-10-17",
*      "Statement": [
*        {
*          "Effect": "Allow",
*          "Action": [
*            "iam:GetUser"
*          ],
*          "Resource": [
*            "arn:aws:iam::<aws_account_id>:user/<iam_user>"
*          ]
*        }
*      ]
*    }
*
*& Permissions for Listing all Buckets
*    {
*        "Version": "2012-10-17",
*        "Statement": [
*            {
*                "Effect": "Allow",
*                "Action": [
*                    "s3:ListAllMyBuckets"
*                ],
*                "Resource": [
*                    "arn:aws:s3:::*"
*                ]
*            }
*        ]
*    }
*
* Where <bucket_prefix> is your sid and <user> is your IAM user
*
* Examples for operating on buckets with name beginning : des-tests3
*   on AWS account 999643172801 with IAM user S3_user
*    {
*        "Version": "2012-10-17",
*        "Statement": [
*            {
*                "Sid": "PolicyGeneratedByLicenseServer",
*                "Effect": "Allow",
*                "Action": [
*                    "s3:*"
*                ],
*                "Resource": [
*                    "arn:aws:s3:::rck-*"
*                ]
*            }
*        ]
*    }
*
*    {
*      "Version": "2012-10-17",
*      "Statement": [
*        {
*          "Sid": "Stmt1404903638000",
*          "Effect": "Allow",
*          "Action": [
*            "iam:GetUser"
*          ],
*          "Resource": [
*            "arn:aws:iam::999643172801:user/S3_user"
*          ]
*        }
*      ]
*    }
*&---------------------------------------------------------------------*
REPORT  zlnkeaws_s3_demo_iam.

*--------------------------------------------------------------------*
* Types
*--------------------------------------------------------------------*
TYPE-POOLS: abap.

*--------------------------------------------------------------------*
* Selection screen
*--------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
PARAMETERS: p_aws TYPE char12.
PARAMETERS: p_iam TYPE text128 LOWER CASE.
PARAMETERS: p_key TYPE text128 LOWER CASE.
PARAMETERS: p_seckey TYPE text128 LOWER CASE.
SELECTION-SCREEN END OF BLOCK b1.

*----------------------------------------------------------------------*
*       CLASS lcl_iam_demo DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_iam_demo DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS:
      execute.

ENDCLASS.                    "lcl_iam_demo DEFINITION

*----------------------------------------------------------------------*
*       CLASS lcl_iam_demo IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_iam_demo IMPLEMENTATION.

  METHOD execute.
    DATA: lv_msg TYPE string.
    DATA: lv_user_name  TYPE zlnkeusername_de.
    DATA: lv_aws_account_id	TYPE zlnkeaws_account_id_de.
    DATA: lv_access_key	TYPE zlnkeacckey_de.
    DATA: lv_secret_access_key  TYPE zlnkesecacckey_de.
    DATA: lv_user_id TYPE string.                           "#EC NEEDED
    DATA: ls_rs3_user TYPE zlnkeuser.
    DATA: lr_cx_aws_s3 TYPE REF TO zlnkecx_aws_s3.

    TRY.
        IF zlnkecl_rfc_connections=>http_dest_to_ext_exists_iam( ) = abap_false.
          zlnkecl_rfc_connections=>create_http_dest_to_ext_iam( ).
          WRITE:/ 'Created AWS destination for IAM endpoint'.
        ENDIF.

        lv_user_name = p_iam.
        lv_aws_account_id = p_aws.
        lv_access_key = p_key.
        lv_secret_access_key = p_seckey.
        CALL METHOD zlnkecl_aws_iam=>check_aws_user
          EXPORTING
            i_user_name         = lv_user_name
            i_aws_account_id    = lv_aws_account_id
            i_access_key        = lv_access_key
            i_secret_access_key = lv_secret_access_key
          RECEIVING
            e_user_id           = lv_user_id.

        ls_rs3_user-user_name = lv_user_name.
        ls_rs3_user-access_key = lv_access_key.
        ls_rs3_user-secr_access_key = lv_secret_access_key.
        ls_rs3_user-aws_account_id = lv_aws_account_id.
        ls_rs3_user-crusr = sy-uname.
        ls_rs3_user-crdat = sy-datum.
        ls_rs3_user-crtim = sy-uzeit.
        INSERT zlnkeuser FROM ls_rs3_user.
        IF sy-subrc = 0.
          WRITE:/ 'IAM user insert success in table ZLNKEUSER'.
        ENDIF.

      CATCH zlnkecx_aws_s3 INTO lr_cx_aws_s3.
        lv_msg = lr_cx_aws_s3->get_text( ).
        WRITE:/ lv_msg.
    ENDTRY.

  ENDMETHOD.                    "execute
ENDCLASS.                    "lcl_iam_demo IMPLEMENTATION

START-OF-SELECTION.
  lcl_iam_demo=>execute( ).
