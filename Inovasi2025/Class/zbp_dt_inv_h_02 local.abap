CLASS lsc_zr_dt_inv_h_02 DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS adjust_numbers REDEFINITION.

ENDCLASS.

CLASS lsc_zr_dt_inv_h_02 IMPLEMENTATION.

  METHOD adjust_numbers.

    SELECT FROM zr_dt_inv_h_02
    FIELDS MAX( issueid )
    INTO @DATA(ld_max_issueid).

    LOOP AT mapped-issue REFERENCE INTO DATA(lr_issue).
      ld_max_issueid += 1.
      lr_issue->issueid = ld_max_issueid.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

CLASS lhc_issue DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    CONSTANTS:
      BEGIN OF category_stat,
        project  TYPE c LENGTH 10 VALUE 'Project',
        training TYPE c LENGTH 10 VALUE 'Training',
      END OF category_stat.

    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR issue
        RESULT result,
      setdescription FOR DETERMINE ON MODIFY
        IMPORTING keys FOR issue~setdescription,

      checkpassword FOR MODIFY
        IMPORTING keys FOR ACTION issue~checkpassword RESULT result,

      get_instance_features FOR INSTANCE FEATURES
        IMPORTING keys REQUEST requested_features FOR issue RESULT result.

*      sethidefieldtrue FOR DETERMINE ON MODIFY
*            IMPORTING keys FOR issue~sethidefieldtrue.

ENDCLASS.

CLASS lhc_issue IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.


  METHOD setdescription.

    READ ENTITIES OF zr_dt_inv_h_02 IN LOCAL MODE
     ENTITY issue
       FIELDS ( description )
       WITH CORRESPONDING #( keys )
     RESULT DATA(issues)
     FAILED DATA(read_failed).
*
    MODIFY ENTITIES OF zr_dt_inv_h_02 IN LOCAL MODE
      ENTITY issue
        UPDATE SET FIELDS
        WITH VALUE #( FOR issue IN issues ( %tky   = issue-%tky
                                            description = |Title : { cl_abap_char_utilities=>newline } { cl_abap_char_utilities=>newline }Isi    : | ) )
    REPORTED DATA(update_reported).
*
*    "Set the changing parameter
    reported = CORRESPONDING #( DEEP update_reported ).

  ENDMETHOD.

  METHOD checkpassword.

    DATA : lv_temp TYPE abap_bool.

    DATA : zlo_hide TYPE REF TO ZCL_HIDEFIELD.

    create OBJECT zlo_hide.

    READ ENTITIES OF zr_dt_inv_h_02 IN LOCAL MODE
    ENTITY issue
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(hasil).

    LOOP AT hasil INTO DATA(ls_hasil).
      lv_temp = ls_hasil-hidefield.
    ENDLOOP.

    LOOP AT keys INTO DATA(key1).
      IF key1-%param-password = 'Abcde_123456789'.
        IF lv_temp = abap_false.
          MODIFY ENTITIES OF zr_dt_inv_h_02 IN LOCAL MODE
          ENTITY issue
          UPDATE
          FIELDS ( hidefield )
          WITH VALUE #( FOR key IN keys
          ( %tky     = key-%tky
          hidefield = abap_true ) )
          FAILED failed
          REPORTED reported.

        zlo_hide->commited( im_issuiid = key1-IssueID ).
        ELSE.
          MODIFY ENTITIES OF zr_dt_inv_h_02 IN LOCAL MODE
          ENTITY issue
          UPDATE
          FIELDS ( hidefield )
          WITH VALUE #( FOR key IN keys
          ( %tky     = key-%tky
          hidefield = abap_false ) )
          FAILED failed
          REPORTED reported.
        ENDIF.
      ENDIF.
    ENDLOOP.

    READ ENTITIES OF zr_dt_inv_h_02 IN LOCAL MODE
    ENTITY issue
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(results).

    result = VALUE #( FOR issue IN results
    ( %tky = issue-%tky
    %param = issue
    ) ).

  ENDMETHOD.

  METHOD get_instance_features.   "ketrigget saat button go ditekan & saat masuk ke dalemnya

    READ ENTITIES OF zr_dt_inv_h_02 IN LOCAL MODE
      ENTITY issue
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(results).


**    LOOP AT results ASSIGNING FIELD-SYMBOL(<res>).
**        <res>-hideField = abap_false.
**    ENDLOOP.
*
  ENDMETHOD.


*  METHOD setHideFieldTrue.


*     READ ENTITIES OF zr_dt_inv_h_02 IN LOCAL MODE
*     ENTITY issue
*       FIELDS ( description )
*       WITH CORRESPONDING #( keys )
*     RESULT DATA(issues)
*     FAILED DATA(read_failed).
**
*    MODIFY ENTITIES OF zr_dt_inv_h_02 IN LOCAL MODE
*      ENTITY issue
*        UPDATE SET FIELDS
*        WITH VALUE #( FOR issue IN issues ( %tky   = issue-%tky
*                                            hideField = 'X'
*                                          ) )
*    REPORTED DATA(update_reported).
**
**    "Set the changing parameter
*    reported = CORRESPONDING #( DEEP update_reported ).

*  ENDMETHOD.

ENDCLASS.