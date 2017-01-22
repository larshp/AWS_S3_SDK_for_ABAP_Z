class ZLNKECL_AWS_INHERIT_SWITCH definition
  public
  inheriting from ZLNKECL_AWS_REST
  create public .

*"* public components of class ZLNKECL_AWS_INHERIT_SWITCH
*"* do not include other source files here!!!
public section.

  constants C_DEFAULT_REGION type STRING value 'us-east-1'. "#EC NOTEXT
  constants C_HOST_NAME type STRING value 'amazonaws.com'. "#EC NOTEXT

  methods CONSTRUCTOR .
  type-pools ABAP .
  methods RUNNING_AS_SAAS
    returning
      value(E_RUNNING_AS_SAAS) type ABAP_BOOL .
protected section.
*"* protected components of class ZLNKECL_AWS_INHERIT_SWITCH
*"* do not include other source files here!!!
private section.
*"* private components of class ZLNKECL_AWS_INHERIT_SWITCH
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZLNKECL_AWS_INHERIT_SWITCH IMPLEMENTATION.


METHOD constructor.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 13th May 2014
* Object constructor
*--------------------------------------------------------------------*
  CALL METHOD super->constructor.

ENDMETHOD.


METHOD running_as_saas.
*--------------------------------------------------------------------*
* Company: RocketSteam
* Author: Jordi Escoda, 14th May 2014
* Returns true if it is running as Software as a Service
*--------------------------------------------------------------------*
  IF class_get_name( ) = 'ZLNKECL_AWS_REST_SAAS'.
    e_running_as_saas = abap_true.
  ENDIF.

ENDMETHOD.
ENDCLASS.
