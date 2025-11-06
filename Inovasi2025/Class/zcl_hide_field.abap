CLASS zcl_hide_field DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_sadl_exit .
    INTERFACES if_sadl_exit_calc_element_read .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_hide_field IMPLEMENTATION.


  METHOD if_sadl_exit_calc_element_read~calculate.

**    DATA lt_original_data TYPE STANDARD TABLE OF zdt_hide_h_02 WITH DEFAULT KEY.
*    DATA lt_original_data TYPE STANDARD TABLE OF zdt_inv_h_02 WITH DEFAULT KEY.
*
*    lt_original_data = CORRESPONDING #( it_original_data ).
*
*    LOOP AT lt_original_data ASSIGNING FIELD-SYMBOL(<fs_original_data>).
**      <fs_original_data>-hidefield = COND abap_boolean( WHEN <fs_original_data>-createdby = 'SOL_ABAP' THEN abap_true ELSE abap_false ).
*      <fs_original_data>-hidefield = COND abap_boolean( WHEN <fs_original_data>-Category = 'Project' THEN abap_true ELSE abap_false ).
*    ENDLOOP.
*
*    ct_calculated_data = CORRESPONDING #( lt_original_data ).

    DATA lt_original_data TYPE STANDARD TABLE OF zr_dt_inv_h_02 WITH DEFAULT KEY.

    DATA : zlo_hide TYPE REF TO ZCL_HIDEFIELD.

    create OBJECT zlo_hide.

    lt_original_data = CORRESPONDING #( it_original_data ).

    SELECT *
     FROM zr_dt_inv_h_02
     FOR ALL ENTRIES IN @lt_original_data
     WHERE issueid = @lt_original_data-issueid
     INTO TABLE @DATA(lt_data).

    IF lt_data IS NOT INITIAL.
      LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<fs>).
        IF <fs>-hidefield = abap_false.
          <fs>-hidefield = abap_true.
        ELSEIF <fs>-hidefield = abap_true.
          <fs>-hidefield = abap_false.
        ENDIF.
      ENDLOOP.
    ct_calculated_data = CORRESPONDING #( lt_data ).    "Ini udah nempel ke itab buat munculin datanya

    zlo_hide->hide(  ). "-> Disini manggil class dengan method hide untuk merubah data yg tadi ke tick, menjadi ga ke tick lagi

    ELSE.
    ct_calculated_data = CORRESPONDING #( lt_original_data ).
    ENDIF.

  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.

    LOOP AT it_requested_calc_elements ASSIGNING FIELD-SYMBOL(<fs_calc_element>).
      CASE <fs_calc_element>.
        WHEN 'hideField'.
*          APPEND 'Type' TO et_requested_orig_elements.
          APPEND 'Attachment' TO et_requested_orig_elements.
      ENDCASE.
    ENDLOOP.

  ENDMETHOD.
ENDCLASS.