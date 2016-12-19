*"* use this source file for any macro definitions you need
*"* in the implementation part of the class
DEFINE escape_json_inplace.
  replace all occurrences of `\` in &1 with `\\`.
  replace all occurrences of `"` in &1 with `\"`.
END-OF-DEFINITION.

DEFINE escape_json.
  move &1 to &2.
  escape_json_inplace &2.
END-OF-DEFINITION.

DEFINE dump_type.

  case &2->type_kind.
    when cl_abap_typedescr=>typekind_float or cl_abap_typedescr=>typekind_int or cl_abap_typedescr=>typekind_int1 or
         cl_abap_typedescr=>typekind_int2 or cl_abap_typedescr=>typekind_packed or `8`. " TYPEKIND_INT8 -> '8' only from 7.40.
      if &1 is initial.
        &3 = `0`.
      else.
        move &1 to &3.
        if &1 lt 0.
          shift &3 right circular.
        else.
          condense &3.
        endif.
      endif.
    when cl_abap_typedescr=>typekind_num.
      if &1 is initial.
        &3 = `0`.
      else.
        move &1 to &3.
        shift &3 left deleting leading ` 0`.
      endif.
    when cl_abap_typedescr=>typekind_string or cl_abap_typedescr=>typekind_csequence or cl_abap_typedescr=>typekind_clike.
      if &1 is initial.
        &3 = `""`.
      else.
        escape_json &1 &3.
        concatenate `"` &3 `"` into &3.
      endif.
    when cl_abap_typedescr=>typekind_xstring or cl_abap_typedescr=>typekind_hex.
      if &1 is initial.
        &3 = `""`.
      else.
        &3 = xstring_to_string( &1 ).
        escape_json_inplace &3.
        concatenate `"` &3 `"` into &3.
      endif.
    when cl_abap_typedescr=>typekind_char.
      if &2->output_length eq 1 and mc_boolean_types cs &2->absolute_name.
        if &1 eq abap_true.
          &3 = `true`.                                      "#EC NOTEXT
        else.
          &3 = `false`.                                     "#EC NOTEXT
        endif.
      else.
        escape_json &1 &3.
        concatenate `"` &3 `"` into &3.
      endif.
    when cl_abap_typedescr=>typekind_date.
      concatenate `"` &1(4) `-` &1+4(2) `-` &1+6(2) `"` into &3.
    when cl_abap_typedescr=>typekind_time.
      concatenate `"` &1(2) `:` &1+2(2) `:` &1+4(2) `"` into &3.
    when others.
      if &1 is initial.
        &3 = `null`.                                        "#EC NOTEXT
      else.
        move &1 to &3.
      endif.
  endcase.

END-OF-DEFINITION.

DEFINE format_name.
  case &2.
    when pretty_mode-camel_case.
      &3 = pretty_name( &1 ).
    when pretty_mode-low_case.
      &3 = &1.
      translate &3 to lower case.                         "#EC SYNTCHAR
    when others.
      &3 = &1.
  endcase.
END-OF-DEFINITION.

DEFINE throw_error.
  create object excp.
  raise exception excp.
END-OF-DEFINITION.

DEFINE while_offset_cs.
*  >= 7.02 alternative
*  pos = find_any_not_of( val = json sub = &1 off = offset ).
*  if pos eq -1. offset = length.
*  else. offset = pos. endif.

* < 7.02
  while offset < length.
    find first occurrence of json+offset(1) in &1.
    if sy-subrc is not initial.
      exit.
    endif.
    offset = offset + 1.
  endwhile.
* < 7.02

END-OF-DEFINITION.


DEFINE eat_white.
  while_offset_cs sv_white_space.
END-OF-DEFINITION.

DEFINE eat_string.
  if json+offset(1) eq `"`.
    mark   = offset + 1.
    offset = mark.
    do.
      find first occurrence of `"` in section offset offset of json match offset pos.
      if sy-subrc is not initial.
        offset = length.
      else.
        offset = pos.
        pos = pos - 1.
        " if escaped search further
        while pos ge 0 and json+pos(1) eq `\`.
          pos = pos - 1.
        endwhile.
        match = ( offset - pos ) mod 2.
        if match eq 0.
          offset = offset + 1.
          continue.
        endif.
      endif.
      exit.
    enddo.
    match = offset - mark.
    &1 = json+mark(match).
    offset = offset + 1.
  else.
    throw_error.
  endif.
END-OF-DEFINITION.

DEFINE eat_number.
  mark   = offset.
  while_offset_cs `0123456789+-eE.`.                        "#EC NOTEXT
  match = offset - mark.
  &1 = json+mark(match).
END-OF-DEFINITION.

DEFINE eat_bool.
  mark   = offset.
  while_offset_cs `aeflnrstu`.                              "#EC NOTEXT
  match = offset - mark.
  if json+mark(match) eq `true`.                            "#EC NOTEXT
    &1 = abap_true.
  elseif json+mark(match) eq `false`.                       "#EC NOTEXT
    &1 = abap_false.
  endif.
END-OF-DEFINITION.

DEFINE eat_char.
  if offset < length and json+offset(1) eq &1.
    offset = offset + 1.
  else.
    throw_error.
  endif.
END-OF-DEFINITION.