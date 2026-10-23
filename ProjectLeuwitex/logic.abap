CLASS lhc_head DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR head RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR head RESULT result.
    METHODS generatepdf FOR MODIFY
      IMPORTING keys FOR ACTION head~generatepdf.
    METHODS setdefaultvalue FOR DETERMINE ON MODIFY
      IMPORTING keys FOR head~setdefaultvalue.

    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE head.

ENDCLASS.

CLASS lhc_head IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD earlynumbering_create.
    DATA(lv_user) = cl_abap_context_info=>get_user_technical_name( ).
    LOOP AT entities ASSIGNING FIELD-SYMBOL(<lfs_entities>).
      APPEND CORRESPONDING #( <lfs_entities> ) TO mapped-head
              ASSIGNING FIELD-SYMBOL(<lfs_xlhead>).
*      <lfs_xlhead>-doc_id = lv_user.
      DATA(lv_line) = 0.
      IF <lfs_xlhead>-doc_id IS INITIAL.
        TRY.
            <lfs_xlhead>-doc_id = cl_system_uuid=>create_uuid_x16_static(  ).
*            <lfs_xlhead>-line_no = <lfs_xlhead>-line_no + 10.
          CATCH cx_uuid_error.
            DATA(lv_error) = cx_uuid_error=>error.
        ENDTRY.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD generatepdf.
    "Create data XML
    DATA lo_writer        TYPE REF TO if_sxml_writer.
    DATA lo_string_writer TYPE REF TO cl_sxml_string_writer.
    DATA lv_xstring       TYPE xstring.
    DATA lv_base64        TYPE string.
    DATA lv_xml_data      TYPE string.

    TYPES : BEGIN OF lty_subitem_sorted.
              INCLUDE TYPE zlut_sd_t_003.
    TYPES :   sort_num TYPE i.
    TYPES : color_int TYPE i,
            END OF lty_subitem_sorted.
    DATA : lt_subitem_sorted TYPE TABLE OF lty_subitem_sorted.

    lo_writer = cl_sxml_string_writer=>create( ).

    DATA(lv_id) = VALUE #( keys[ 1 ]-doc_id OPTIONAL ).
    SELECT * FROM zlut_sd_t_001
    WHERE doc_id = @lv_id
    INTO TABLE @DATA(lt_header).

    DATA(ls_header) = VALUE #( lt_header[ 1 ] ).
    IF lt_header IS NOT INITIAL.
      SELECT * FROM zlut_sd_t_002
      WHERE doc_id = @lv_id
      INTO TABLE @DATA(lt_item).
      IF lt_item IS NOT INITIAL.
        SELECT * FROM zlut_sd_t_003
        WHERE doc_id = @lv_id
        INTO TABLE @DATA(lt_subitem).
      ENDIF.

      lt_subitem_sorted = VALUE #(
         FOR ls_subitem IN lt_subitem (
            VALUE #(
                BASE CORRESPONDING #( ls_subitem )
                color_int = COND #(
                    WHEN ls_subitem-color CO '0123456789'
                        THEN CONV i( ls_subitem-color )
                    ELSE 1 )
      ) ) ).

      DATA : lv_totalcol TYPE i,
             lv_totalqty TYPE zlut_sd_t_003-qty_col.

      "Create XML DATA"
      "================ Header ================"
      lo_writer->open_element( name = 'Form' ).
      lo_writer->open_element( name = 'HeaderNode' ).

      lo_writer->open_element( name = 'NoForm' ).
      lo_writer->write_value( |????| ).
      lo_writer->close_element( )."
      lo_writer->open_element( name = 'Date' ).
      lo_writer->write_value( |{ ls_header-docdate+6(2) }.{ ls_header-docdate+4(2) }.{ ls_header-docdate(4) }| ).
      lo_writer->close_element( ).
      lo_writer->open_element( name = 'Buyer' ).
      lo_writer->write_value( |{ ls_header-buyer }| ).
      lo_writer->close_element( ).
      lo_writer->open_element( name = 'Destination' ).
      lo_writer->write_value( |{ ls_header-desti }| ).
      lo_writer->close_element( ).
      lo_writer->open_element( name = 'FollowUp' ).
      lo_writer->write_value( |{ ls_header-followup }| ).
      lo_writer->close_element( ).
      lo_writer->open_element( name = 'Contract' ).
      lo_writer->write_value( |{ ls_header-connum }| ).
      lo_writer->close_element( ).
      lo_writer->open_element( name = 'Indent' ).
      lo_writer->write_value( |{ ls_header-indnum }| ).
      lo_writer->close_element( ).
      lo_writer->open_element( name = 'Shipment' ).
      lo_writer->write_value( |{ ls_header-shipment+6(2) }.{ ls_header-shipment+4(2) }.{ ls_header-shipment(4) }| ).
      lo_writer->close_element( ).
      lo_writer->open_element( name = 'Dibuat' ).
      lo_writer->write_value( |{ ls_header-create_by }| ).
      lo_writer->close_element( ).
      lo_writer->open_element( name = 'FollowUpFoot' ).
      lo_writer->write_value( |{ ls_header-followup }| ).
      lo_writer->close_element( ).
      lo_writer->open_element( name = 'Pojok' ).
      CONDENSE ls_header-zcounter.
      DATA(lv_counter) =  |{ ls_header-zcounter ALPHA = IN }|.
      lo_writer->write_value( |{ ls_header-docdate(4) }-{ lv_counter+6(4) }| ).
      lo_writer->close_element( ).

      lo_writer->open_element( name = 'ItemNode' ).

      LOOP AT lt_item INTO DATA(lw_item) WHERE doc_id = ls_header-doc_id.

        lo_writer->open_element( name = 'Item' ).
        lo_writer->open_element( name = 'OP' ).
        lo_writer->write_value( |{ ls_header-op }| ).
        lo_writer->close_element( )."
        lo_writer->open_element( name = 'Material' ).
        lo_writer->write_value( |???| ).
        lo_writer->close_element( )."
        lo_writer->open_element( name = 'Band' ).
        lo_writer->write_value( |{ lw_item-band }| ).
        lo_writer->close_element( )."
        lo_writer->open_element( name = 'Label' ).
        lo_writer->write_value( |{ lw_item-zlabel }| ).
        lo_writer->close_element( )."
        lo_writer->open_element( name = 'Hanger' ).
        lo_writer->write_value( |{ lw_item-hanger }| ).
        lo_writer->close_element( )."
        lo_writer->open_element( name = 'Face' ).
        lo_writer->write_value( |{ lw_item-face_stamp }| ).
        lo_writer->close_element( )."
        lo_writer->open_element( name = 'Selvedge' ).
        lo_writer->write_value( |{ lw_item-selvedge }| ).
        lo_writer->close_element( )."
        lo_writer->open_element( name = 'Piece' ).
        lo_writer->write_value( |{ lw_item-piece_length }| ).
        lo_writer->close_element( )."
        lo_writer->open_element( name = 'packing' ).
        lo_writer->write_value( |{ lw_item-packing }| ).
        lo_writer->close_element( )."
        lo_writer->open_element( name = 'Shipping' ).
        lo_writer->write_value( |{ lw_item-shipping }| ).
        lo_writer->close_element( )."
        lo_writer->open_element( name = 'remarks' ).
        lo_writer->write_value( |{ lw_item-remarks }| ).
        lo_writer->close_element( )."
        " { add by adrian 02.06.2026
        lo_writer->open_element( name = 'remarks01' ).
        lo_writer->write_value( |{ lw_item-remarks01 }| ).
        lo_writer->close_element( )."
        lo_writer->open_element( name = 'remarks02' ).
        lo_writer->write_value( |{ lw_item-remarks02 }| ).
        lo_writer->close_element( )."
        lo_writer->open_element( name = 'remarks03' ).
        lo_writer->write_value( |{ lw_item-remarks03 }| ).
        lo_writer->close_element( )."
        " }
        lo_writer->open_element( name = 'ShipRe' ).
        lo_writer->write_value( |{ lw_item-shipping_remarks }| ).
        lo_writer->close_element( ).

        " { add by adrian 08.06.2026
        CLEAR : lv_totalcol, lv_totalqty.
        LOOP AT lt_subitem INTO DATA(lw_sub1) WHERE doc_id = lw_item-doc_id
                                               AND line_id = lw_item-line_id.
          lv_totalcol += 1.
          lv_totalqty += lw_sub1-quantity.
        ENDLOOP.
        " }

        lo_writer->open_element( name = 'TotalCol' ).
        lo_writer->write_value( |{ lv_totalcol }| ).
        lo_writer->close_element( )."
        lo_writer->open_element( name = 'TotalQty' ).
        lo_writer->write_value( |{ lv_totalqty }| ).
        lo_writer->close_element( )."
        lo_writer->open_element( name = 'Uom' ).
        lo_writer->write_value( |{ lw_sub1-uom1 }| ).
        lo_writer->close_element( )."

        lo_writer->open_element( name = 'SubItemNode' ).
*        SORT lt_subitem_sorted BY code matnr design_buyer color_int.
        "change by hertian 22/07/2026
        DATA(lt_sorted_temp) = lt_subitem_sorted.

*        LOOP AT lt_sorted_temp ASSIGNING FIELD-SYMBOL(<fs_temp>).
*          " Mengambil angka setelah teks 'COL. '
*          DATA(lv_num_str) = <fs_temp>-design_buyer.
*          REPLACE ALL OCCURRENCES OF REGEX '[^0-9]' IN lv_num_str WITH ''.
*          <fs_temp>-sort_num = lv_num_str. " Field integer sementara untuk sorting
*        ENDLOOP.

* 3. Sort berdasarkan field numerik secara ASCENDING
        SORT lt_sorted_temp BY lineitem ASCENDING.

*        SORT lt_subitem_sorted BY color design_buyer DESCENDING."code sub_line_id.
        LOOP AT lt_sorted_temp INTO DATA(lw_sub)  "lt_subitem_sorted (table lama)
                                  WHERE doc_id = lw_item-doc_id
                                  AND line_id = lw_item-line_id.

          lo_writer->open_element( name = 'SubItem' ).

          lo_writer->open_element( name = 'Code' ).
          lo_writer->write_value( |{ lw_sub-code }| ).
*          lo_writer->write_value( |{ lw_sub-code }/{ lw_sub-matnr }| ).
          lo_writer->close_element( )."
          lo_writer->open_element( name = 'Design' ).
          lo_writer->write_value( |{ lw_sub-matnr }| ).
          lo_writer->close_element( )."
          lo_writer->open_element( name = 'Buyer' ).
          lo_writer->write_value( |{ lw_sub-design_buyer }| ).
          lo_writer->close_element( )."
          lo_writer->open_element( name = 'Col' ).
          lo_writer->write_value( |{ lw_sub-color }| ).
          lo_writer->close_element( )."
          lo_writer->open_element( name = 'Uom' ).
          lo_writer->write_value( |{ lw_sub-uom1 }| ).
          lo_writer->close_element( )."

*          DATA : iv_qty_col TYPE string.
*          iv_qty_col = lw_sub-qty_col.
          lo_writer->open_element( name = 'QtyCol' ).
          lo_writer->write_value( |{ lw_sub-qty_col }| ).
*          lo_writer->write_value( |@{ lw_sub-qty_col }| ).
*          lo_writer->write_value( |@{ iv_qty_col }| ).
          lo_writer->close_element( )."
*          CLEAR iv_qty_col.
          "add by hertian 22/07/2026
          lo_writer->open_element( name = 'Qty' ).
          lo_writer->write_value( |{ lw_sub-quantity }| )."|{ lw_sub-quantity }| ).
          lo_writer->close_element( )."
          lo_writer->open_element( name = 'Scrn' ).
          lo_writer->write_value( |???| ).
          lo_writer->close_element( )."
          lo_writer->open_element( name = 'Remarks' ).
          lo_writer->write_value( |{ lw_sub-remarks }| ).
          lo_writer->close_element( )."

          lo_writer->close_element( ). " "Item"

        ENDLOOP.

        lo_writer->close_element( ). " "SubItemNode"

        lo_writer->close_element( ). " "Item"

      ENDLOOP.

      lo_writer->close_element( ). "item Node
      "================ Close Root =================
      lo_writer->close_element( ). " labelform
      lo_writer->close_element( ). " form1
      "================ Output =================
      lo_string_writer ?= lo_writer.
      lv_xstring = lo_string_writer->get_output( ).

      lv_base64 = cl_web_http_utility=>encode_x_base64( lv_xstring ).
      lv_xml_data = lv_base64.
    ELSE.
      lv_xml_data = ''.
    ENDIF.

    TRY.
        TRY.
            DATA(lo_pdf_destination) = cl_http_destination_provider=>create_by_comm_arrangement(
                 comm_scenario  = 'YY1_ADOBE_FORMS_SRV'
*                service_id     = ''
*                comm_system_id = ''
            ).

            DATA(lo_pdf_client) = cl_web_http_client_manager=>create_by_http_destination( lo_pdf_destination ).
*            DATA(lo_client) =
*              cl_web_http_client_manager=>create_by_http_destination( lo_dest ).

*            lo_pdf_client->get_http_request( )->set_header_field(
*              i_name  = 'Authorization'
*              i_value = lv_bearer ).

            lo_pdf_client->get_http_request( )->set_header_field(
              i_name  = 'Content-Type'
              i_value = 'application/json' ).

            lo_pdf_client->get_http_request( )->set_header_field(
              i_name  = 'Accept'
              i_value = 'application/json' ).

            lo_pdf_client->get_http_request( )->set_header_field(
              i_name  = 'Accept-Charset'
              i_value = 'UTF-8' ).

            "---- Request body
            TYPES: BEGIN OF ty_ads_body,
                     xdp_template       TYPE string,
                     xml_data           TYPE string,
                     form_type          TYPE string,
                     form_locale        TYPE string,
                     tagged_pdf         TYPE string,
                     embed_font         TYPE string,
                     change_not_allowed TYPE string,
                     print_not_allowed  TYPE string,
                   END OF ty_ads_body.

            DATA(ls_body) = VALUE ty_ads_body(
              xdp_template       = 'ZLUT_SD_F_INSSHEET/ZLUT_SD_T_INSSHEET'
              xml_data           = lv_xml_data
              form_type          = 'print'
              form_locale        = 'en_US'
              tagged_pdf         = '1'
              embed_font         = '0'
              change_not_allowed = 'false'
              print_not_allowed  = 'false'
            ).

            DATA(lv_json) =
              /ui2/cl_json=>serialize(
                data        = ls_body
                compress    = abap_true
                pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).

            lo_pdf_client->get_http_request( )->append_text( lv_json ).

            DATA(lo_response) =
              lo_pdf_client->execute( i_method = if_web_http_client=>post ).

            DATA(ls_status) = lo_response->get_status( ).

            DATA(lv_response) = lo_response->get_text( ).

            FIND REGEX '"fileContent":"([^"]+)"'
              IN lv_response
              SUBMATCHES DATA(lv_pdf_base64).
            "-------------------------------------------------
            " DESTINATION / COMM ARRANGEMENT ERROR
            "-------------------------------------------------
          CATCH cx_http_dest_provider_error INTO DATA(lx_dest2).
            DATA(lv_dest2) = lx_dest2->get_text( ).
            "-------------------------------------------------
            " HTTP CLIENT / EXECUTION ERROR
            "-------------------------------------------------
          CATCH cx_web_http_client_error INTO DATA(lx_http2).
            DATA(lv_http2) = lx_http2->get_text( ).
            "-------------------------------------------------
            " JSON / REGEX / UNEXPECTED ERROR
            "-------------------------------------------------
          CATCH cx_root INTO DATA(lx_root2).
            DATA(lv_root2) = lx_root2->get_text( ).
        ENDTRY.
    ENDTRY.

*"===================== PDF to Attachment
    "Insert PDF to Tabel Attachment"
    IF lv_pdf_base64 IS NOT INITIAL.
      DATA: lt_update TYPE TABLE FOR UPDATE zlut_sd_r_inssheet_head\\head.

      DATA lv_pdf_xstring TYPE xstring.
      DATA lv_error TYPE string.
      TRY.
          lv_pdf_xstring = cl_web_http_utility=>decode_x_base64( lv_pdf_base64 ).
        CATCH cx_root INTO DATA(lx_root).
          lv_error = lx_root->get_text( ).
      ENDTRY.

      DATA : lv_filename TYPE string.
      lv_filename =  |{ ls_header-docnum }.pdf| .

      MODIFY ENTITIES OF zlut_sd_r_inssheet_head
        IN LOCAL MODE
        ENTITY head
        UPDATE FIELDS (  attachment mimetype filename )
        WITH VALUE #( FOR ls_keys IN keys ( %tky = ls_keys-%tky
                                            attachment =  lv_pdf_xstring
                                            mimetype = 'application/pdf'
                                            filename = lv_filename ) )
       REPORTED DATA(lt_reported).
      reported = CORRESPONDING #( DEEP lt_reported ).
    ENDIF.

  ENDMETHOD.

  METHOD setdefaultvalue.
    READ ENTITIES OF zlut_sd_r_inssheet_head
        IN LOCAL MODE
        ENTITY head
        FIELDS ( connum )
        WITH CORRESPONDING #( keys )
        RESULT DATA(lt_header).
    LOOP AT keys INTO DATA(lv_keys).
      EXIT.
    ENDLOOP.
    IF lt_header IS NOT INITIAL.

      SELECT a~contract_numb,  a~destination, a~messrs, b~businesspartnername
        FROM zlut_sd_ch AS a
        LEFT OUTER JOIN i_businesspartner AS b
        ON b~businesspartner = a~messrs
        FOR ALL ENTRIES IN @lt_header
        WHERE contract_numb = @lt_header-connum
        INTO TABLE @DATA(lt_ch).

      SELECT SINGLE doc_id, zcounter, docdate FROM zlut_sd_t_001
      WHERE doc_id = @lv_keys-doc_id
      INTO @DATA(lv_check).
      DATA : lv_count(10)  TYPE c,
             lv_docnum(60) TYPE c.

      IF lv_check-zcounter IS INITIAL.
        DATA(lv_docdate) = cl_abap_context_info=>get_system_date( ).
        DATA lv_count_padded TYPE n LENGTH 4.

        SELECT COUNT( doc_id )
        FROM zlut_sd_t_001
        INTO @DATA(lv_count1).                          "#EC CI_NOWHERE

        lv_count = lv_count1 + 1.

      ELSE.
        lv_count = lv_check-zcounter."update by  hertian
      ENDIF.

      DATA(lv_string_temp) = |{ lv_count }|.

      lv_count_padded = |{ lv_count WIDTH = 4 ALIGN = RIGHT PAD = '0' }|.

      IF lv_check-docdate IS INITIAL.
        CONCATENATE lv_docdate(4) lv_count_padded INTO lv_docnum SEPARATED BY '-'.
      ENDIF.




      IF lt_ch IS NOT INITIAL.
        READ TABLE lt_ch INTO DATA(ls_ch) INDEX 1.
        IF sy-subrc = 0.
          MODIFY ENTITIES OF zlut_sd_r_inssheet_head IN LOCAL MODE
          ENTITY head
            UPDATE FIELDS ( desti buyer zcounter docnum )
            WITH VALUE #( FOR k IN keys ( %tky = k-%tky
                                            desti = ls_ch-destination
                                            buyer = ls_ch-businesspartnername
                                            zcounter = lv_count
                                            docnum = lv_docnum ) )
              REPORTED DATA(lt_reported).
          reported = CORRESPONDING #( DEEP lt_reported ).
        ENDIF.
      ELSE.

      ENDIF.
    ENDIF.
  ENDMETHOD.

ENDCLASS.