class ZLNKECL_HASH definition
  public
  final
  create private .

*"* public components of class ZLNKECL_HASH
*"* do not include other source files here!!!
public section.

  constants C_EMPTY_BODY_SHA256 type STRING value 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855'. "#EC NOTEXT

  class-methods HASH_SHA256_FOR_CHAR
    importing
      !I_STRING type STRING
    returning
      value(E_HASH) type STRING
    raising
      CX_ABAP_MESSAGE_DIGEST .
  class-methods HASH_SHA256_FOR_HEX
    importing
      !I_XSTRING type XSTRING
    returning
      value(E_HASH) type STRING
    raising
      CX_ABAP_MESSAGE_DIGEST .
  class-methods HASH_MD5_FOR_CHAR
    importing
      !I_STRING type STRING
    returning
      value(E_HASH) type STRING
    raising
      CX_ABAP_MESSAGE_DIGEST .
  class-methods HASH_MD5_FOR_HEX_BASE64
    importing
      !I_XSTRING type XSTRING
    returning
      value(E_HASH) type STRING
    raising
      CX_ABAP_MESSAGE_DIGEST .
protected section.
*"* protected components of class ZLNKECL_HASH
*"* do not include other source files here!!!
private section.
*"* private components of class ZLNKECL_HASH
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZLNKECL_HASH IMPLEMENTATION.


METHOD hash_md5_for_char.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 28th March 2014
* Calculates MD5 hash for the given string, Output Base64
*--------------------------------------------------------------------*
  CALL METHOD cl_abap_message_digest=>calculate_hash_for_char
    EXPORTING
      if_algorithm  = 'MD5'
      if_data       = i_string
    IMPORTING
      ef_hashstring = e_hash.

ENDMETHOD.


METHOD HASH_MD5_FOR_HEX_BASE64.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 28th March 2014
* Calculates MD5 hash for the given xstring, Output Base64
*--------------------------------------------------------------------*
  CALL METHOD cl_abap_message_digest=>calculate_hash_for_raw
    EXPORTING
      if_algorithm     = 'MD5'
      if_data          = i_xstring
    IMPORTING
      ef_hashb64string = e_hash.

ENDMETHOD.


METHOD hash_sha256_for_char.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 25th March 2014
* Calculates SHA-256 hash for the given text
*--------------------------------------------------------------------*
  CALL METHOD cl_abap_message_digest=>calculate_hash_for_char
    EXPORTING
      if_algorithm  = 'SHA-256'
      if_data       = i_string
    IMPORTING
      ef_hashstring = e_hash.

  TRANSLATE e_hash TO LOWER CASE.

ENDMETHOD.


METHOD hash_sha256_for_hex.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 28th March 2014
* Calculates SHA-256 hash for the given xstring
*--------------------------------------------------------------------*
  CALL METHOD cl_abap_message_digest=>calculate_hash_for_raw
    EXPORTING
      if_algorithm  = 'SHA-256'
      if_data       = i_xstring
    IMPORTING
      ef_hashstring = e_hash.

  TRANSLATE e_hash TO LOWER CASE.
ENDMETHOD.
ENDCLASS.
