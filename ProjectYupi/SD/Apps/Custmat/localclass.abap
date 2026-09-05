CLASS lhc_zyupi_sd_i_instruction DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR insth RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR insth RESULT result.

    METHODS validatemandatory FOR VALIDATE ON SAVE
      IMPORTING keys FOR insth~validatemandatory.

*    METHODS earlynumbering_create FOR NUMBERING
*      entities FOR CREATE insth.

ENDCLASS.

CLASS lhc_zyupi_sd_i_instruction IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD validatemandatory.

    READ ENTITIES OF zyupi_sd_i_instruction IN LOCAL MODE
      ENTITY insth
      ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_data).

    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<ls_data>).

      DATA(lv_has_error) = abap_false.

      "------------------------------------------------------------
      " Customer Material
      "------------------------------------------------------------
      IF <ls_data>-custmat IS INITIAL
      OR <ls_data>-custmat = space.

        lv_has_error = abap_true.

        APPEND VALUE #(
          %tky              = <ls_data>-%tky
          %state_area       = 'VALIDATE_MANDATORY'
          %msg              = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = 'Customer Material is mandatory'
          )
          %element-custmat  = if_abap_behv=>mk-on
        ) TO reported-insth.

      ENDIF.

      "------------------------------------------------------------
      " Sales Organization
      "------------------------------------------------------------
      IF <ls_data>-salesorganization IS INITIAL
      OR <ls_data>-salesorganization = space.

        lv_has_error = abap_true.

        APPEND VALUE #(
          %tky                          = <ls_data>-%tky
          %state_area                   = 'VALIDATE_MANDATORY'
          %msg                          = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = 'Sales Organization is mandatory'
          )
          %element-salesorganization    = if_abap_behv=>mk-on
        ) TO reported-insth.

      ENDIF.

      "------------------------------------------------------------
      " Distribution Channel
      "------------------------------------------------------------
      IF <ls_data>-distributionchannel IS INITIAL
      OR <ls_data>-distributionchannel = space.

        lv_has_error = abap_true.

        APPEND VALUE #(
          %tky                          = <ls_data>-%tky
          %state_area                   = 'VALIDATE_MANDATORY'
          %msg                          = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = 'Distribution Channel is mandatory'
          )
          %element-distributionchannel  = if_abap_behv=>mk-on
        ) TO reported-insth.

      ENDIF.

      "------------------------------------------------------------
      " Customer Country
      "------------------------------------------------------------
      IF <ls_data>-customercountry IS INITIAL
      OR <ls_data>-customercountry = space.

        lv_has_error = abap_true.

        APPEND VALUE #(
          %tky                        = <ls_data>-%tky
          %state_area                 = 'VALIDATE_MANDATORY'
          %msg                        = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = 'Customer Country is mandatory'
          )
          %element-customercountry    = if_abap_behv=>mk-on
        ) TO reported-insth.

      ENDIF.

      "------------------------------------------------------------
      " Sold-To End Customer
      "------------------------------------------------------------
      IF <ls_data>-soldtoendcustomer IS INITIAL
      OR <ls_data>-soldtoendcustomer = space.

        lv_has_error = abap_true.

        APPEND VALUE #(
          %tky                          = <ls_data>-%tky
          %state_area                   = 'VALIDATE_MANDATORY'
          %msg                          = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = 'Sold-To End Customer is mandatory'
          )
          %element-soldtoendcustomer    = if_abap_behv=>mk-on
        ) TO reported-insth.

      ENDIF.

      "------------------------------------------------------------
      " Ship-To End Customer
      "------------------------------------------------------------
      IF <ls_data>-shiptoendcustomer IS INITIAL
      OR <ls_data>-shiptoendcustomer = space.

        lv_has_error = abap_true.

        APPEND VALUE #(
          %tky                          = <ls_data>-%tky
          %state_area                   = 'VALIDATE_MANDATORY'
          %msg                          = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = 'Ship-To End Customer is mandatory'
          )
          %element-shiptoendcustomer    = if_abap_behv=>mk-on
        ) TO reported-insth.

      ENDIF.

      "------------------------------------------------------------
      " Material
      "------------------------------------------------------------
      IF <ls_data>-material IS INITIAL
      OR <ls_data>-material = space.

        lv_has_error = abap_true.

        APPEND VALUE #(
          %tky              = <ls_data>-%tky
          %state_area       = 'VALIDATE_MANDATORY'
          %msg              = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = 'Material is mandatory'
          )
          %element-material = if_abap_behv=>mk-on
        ) TO reported-insth.

      ENDIF.

      "------------------------------------------------------------
      " Mark instance as failed jika ada error
      "------------------------------------------------------------
      IF lv_has_error = abap_true.
        APPEND VALUE #(
          %tky = <ls_data>-%tky
        ) TO failed-insth.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

*  METHOD earlynumbering_create.
**    LOOP AT entities ASSIGNING FIELD-SYMBOL(<lfs_entities>).
**      APPEND CORRESPONDING #( <lfs_entities> ) TO mapped-insth
**              ASSIGNING FIELD-SYMBOL(<lfs_xlhead>).
**      IF <lfs_xlhead>-draftuuid IS INITIAL.
**        TRY.
**            <lfs_xlhead>-draftuuid = cl_system_uuid=>create_uuid_x16_static(  ).
**          CATCH cx_uuid_error.
**            DATA(lv_error) = cx_uuid_error=>error.
**        ENDTRY.
**
**      ENDIF.
**
**    ENDLOOP.
*  ENDMETHOD.

ENDCLASS.