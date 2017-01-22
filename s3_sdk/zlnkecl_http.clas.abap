class ZLNKECL_HTTP definition
  public
  final
  create private .

*"* public components of class ZLNKECL_HTTP
*"* do not include other source files here!!!
public section.

  constants C_METHOD_GET type STRING value 'GET'. "#EC NOTEXT
  constants C_METHOD_POST type STRING value 'POST'. "#EC NOTEXT
  constants C_METHOD_HEAD type STRING value 'HEAD'. "#EC NOTEXT
  constants C_METHOD_PUT type STRING value 'PUT'. "#EC NOTEXT
  constants C_METHOD_DELETE type STRING value 'DELETE'. "#EC NOTEXT
  constants C_STATUS_200_OK type I value 200. "#EC NOTEXT
  constants C_STATUS_201_CREATED type I value 201. "#EC NOTEXT
  constants C_STATUS_204_NO_CONTENT type I value 204. "#EC NOTEXT
  constants C_STATUS_206_PARTIAL_CONTENT type I value 206. "#EC NOTEXT
  constants C_STATUS_250_MISSINGDOCCREATED type I value 250. "#EC NOTEXT
  constants C_STATUS_307_TEMP_REDIRECT type I value 307. "#EC NOTEXT
  constants C_STATUS_400_BAD_REQUEST type I value 400. "#EC NOTEXT
  constants C_STATUS_401_UNAUTHORIZED type I value 401. "#EC NOTEXT
  constants C_STATUS_403_FORBIDDEN type I value 403. "#EC NOTEXT
  constants C_STATUS_404_NOT_FOUND type I value 404. "#EC NOTEXT
  constants C_STATUS_405_METH_NOT_ALLOWED type I value 405. "#EC NOTEXT
  constants C_STATUS_406_NOT_ACCEPTABLE type I value 406. "#EC NOTEXT
  constants C_STATUS_409_CONFLICT type I value 409. "#EC NOTEXT
  constants C_STATUS_411_LENGTH_REQUIRED type I value 411. "#EC NOTEXT
  constants C_STATUS_412_PRECOND_FAILED type I value 412. "#EC NOTEXT
  constants C_STATUS_416_REQRANGENOTSATISF type I value 416. "#EC NOTEXT
  constants C_STATUS_500_INTNAL_SERVER_ERR type I value 500. "#EC NOTEXT
  constants C_STATUS_501_NOT_IMPLEMENTED type I value 501. "#EC NOTEXT
  constants C_STATUS_503_SERVICE_UNAVAILAB type I value 503. "#EC NOTEXT

  class-methods GET_REASON_BY_STATUS
    importing
      !I_HTTP_STATUS type I
    returning
      value(E_REASON) type STRING .
  class-methods ESCAPE_URL
    importing
      !I_UNESCAPED type STRING
    returning
      value(E_ESCAPED) type STRING .
  class-methods UNESCAPE_URL
    importing
      !I_ESCAPED type STRING
    returning
      value(E_UNESCAPED) type STRING .
protected section.
*"* protected components of class ZLNKECL_HTTP
*"* do not include other source files here!!!
private section.
*"* private components of class ZLNKECL_HTTP
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZLNKECL_HTTP IMPLEMENTATION.


METHOD escape_url.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 11th April 2016
*--------------------------------------------------------------------*
  DATA: lv_text(512) TYPE c.
  DATA: lv_string TYPE string.
  DATA: lt_result TYPE match_result_tab.
  FIELD-SYMBOLS: <lfs_result> TYPE match_result.

* This escapes dots. Do not wish to escape dots!. And escape are lowercase
*  CALL METHOD cl_http_utility=>if_http_utility~escape_url
*    EXPORTING
*      unescaped = i_unescaped
*      OPTIONS   = 0
*    RECEIVING
*      escaped   = lv_string.

* This does not escape dots, but returns escaped in lowercase
  CALL METHOD cl_abap_dyn_prg=>escape_xss_url
    EXPORTING
      val = i_unescaped
    RECEIVING
      out = lv_string.

  lv_text = lv_string.

* Unescape %2f -> / (needed for path)
  REPLACE ALL OCCURRENCES OF '%2f' IN lv_text WITH '/'.

* AWS does not accept escaped in lowercase. Convert to uppercase
  FIND ALL OCCURRENCES OF REGEX '%..' IN lv_text RESULTS lt_result.
  LOOP AT lt_result ASSIGNING <lfs_result>.
    TRANSLATE lv_text+<lfs_result>-offset(<lfs_result>-length) TO UPPER CASE.
  ENDLOOP.

  e_escaped = lv_text.

ENDMETHOD.


METHOD get_reason_by_status.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 26th March 2014
* Given an HTTP status code returns the reason
*--------------------------------------------------------------------*

  DATA: l_status TYPE c.

  CASE i_http_status.
    WHEN c_status_200_ok.
      e_reason = 'OK'.                                      "#EC NOTEXT
    WHEN c_status_201_created.
      e_reason = 'Created'.                                 "#EC NOTEXT
    WHEN c_status_204_no_content.
      e_reason = 'No content'.                              "#EC NOTEXT
    WHEN c_status_206_partial_content.
      e_reason = 'Partial content'.                         "#EC NOTEXT
    WHEN c_status_250_missingdoccreated.
      e_reason = 'Missing document(s) created'.             "#EC NOTEXT
    WHEN c_status_307_temp_redirect.
      e_reason = 'Temporary Redirect'.                      "#EC NOTEXT
    WHEN c_status_400_bad_request.
      e_reason = 'Bad Request'.                             "#EC NOTEXT
    WHEN c_status_401_unauthorized.
      e_reason = 'Unauthorized'.                            "#EC NOTEXT
    WHEN c_status_403_forbidden.
      e_reason = 'Forbidden'.                               "#EC NOTEXT
    WHEN c_status_404_not_found.
      e_reason = 'Not Found'.                               "#EC NOTEXT
    WHEN c_status_405_meth_not_allowed.
      e_reason = 'Method not allowed'.                      "#EC NOTEXT
    WHEN c_status_406_not_acceptable.
      e_reason = 'Not acceptable'.                          "#EC NOTEXT
    WHEN c_status_409_conflict.
      e_reason = 'Conflict'.                                "#EC NOTEXT
    WHEN c_status_411_length_required.
      e_reason = 'Length Required'.                         "#EC NOTEXT
    WHEN c_status_412_precond_failed.
      e_reason = 'Precondition Failed'.                     "#EC NOTEXT
    WHEN c_status_416_reqrangenotsatisf.
      e_reason = 'Requested Range Not Satisfiable'.         "#EC NOTEXT
    WHEN c_status_500_intnal_server_err.
      e_reason = 'Internal Server Error'.                   "#EC NOTEXT
    WHEN c_status_501_not_implemented.
      e_reason = 'Not implemented'.                         "#EC NOTEXT
    WHEN c_status_503_service_unavailab.
      e_reason = 'Service unavailable'.                     "#EC NOTEXT
    WHEN OTHERS.
      l_status = i_http_status.
      CONCATENATE 'HTTP Status' l_status INTO e_reason.     "#EC NOTEXT
  ENDCASE.

ENDMETHOD.


METHOD unescape_url.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 14th April 2016
*--------------------------------------------------------------------*

  CALL METHOD cl_http_utility=>if_http_utility~unescape_url
    EXPORTING
      escaped   = i_escaped
    RECEIVING
      unescaped = e_unescaped.

ENDMETHOD.
ENDCLASS.
