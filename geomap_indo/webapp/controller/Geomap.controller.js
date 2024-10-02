sap.ui.define(
  [
    "sap/ui/vbm/AnalyticMap",
    "sap/ui/core/mvc/Controller",
    "sap/ui/model/json/JSONModel",
    "sap/ui/Device",
    "sap/m/MessageToast",
    "sap/m/Popover",
    "sap/m/Text",
    "sap/m/Button",
    "sap/m/Dialog",
  ],
  function (
    AnalyticMap,
    Controller,
    JSONModel,
    Device,
    MessageToast,
    Popover,
    Text,
    Button,
    Dialog
  ) {
    "use strict";

    AnalyticMap.GeoJSONURL =
      "https://alenkarendra.github.io/idngeojson/idngeojson.json";
    let Isi = [];

    return Controller.extend("geomapindo.controller.Geomap", {
      onInit: function () {
        this.getOwnerComponent()
          .getRouter()
          .attachRoutePatternMatched(this.geoMapCollection, this);
      },

      geoMapCollection: function () {
        let oData = this.getView().getModel();
        let x = this;

        let legend = [
          { Info: "high", warna: "rgb(56, 163, 56)" },
          { Info: "medium", warna: "rgb(249,172,60)" },
          { Info: "low", warna: "rgb(243,0,0)" },
        ];

        oData.read("/Zilham_001_idn", {
          success: function (data) {
            for (let i = 0; i < data.results.length; i++) {
              let isian = [];
              let color = "";
              let type = "";
              isian = data.results[i];
              // console.log(data);
              // Menambahkan data yg di butuhkan untuk geomap
              let pos = `${data.results[i].longtitude};${data.results[i].latitude};0`;

              if (data.results[i].sales >= 6600000000) {
                color = legend[0].warna;
                type = "Success";
              } else if (
                data.results[i].sales >= 3300000000 &&
                data.results[i].sales < 6600000000
              ) {
                color = legend[1].warna;
                type = "Warning";
              } else {
                color = legend[2].warna;
                type = "Error";
              }

              isian.type = type;
              isian.color = color;
              isian.pos = pos;
              Isi.push(isian);
            }
            console.log(Isi);
            var oModel = new sap.ui.model.json.JSONModel();

            oModel.setData({
              products: Isi,
              legends: legend,
            });

            x.getView().setModel(oModel, "productModel");
          },
        });
      },
      onRegionClick: function (e) {
        for (let i = 0; i < Isi.length; i++) {
          let id = Isi[i].id_code;
          if (id == e.getParameter("code")) {
            let hasil = Isi[i].sales / 100;
            MessageToast.show(
              `${Isi[i].city} \n
               Sales : Rp${hasil}`
            );
          }
        }
      },

      onSpotClick: function (e) {
        let resultTitle;
        let resultDetail;
        let detail = e.getSource();
        let detailTooltip = detail.getText();

        for (let i = 0; i < Isi.length; i++) {
          if (Isi[i].tooltip == detailTooltip) {
            resultTitle = Isi[i].city;
            resultDetail = `Memiliki id code : ${Isi[i].id_code} \n
                            dengan titik spot : (${Isi[i].pos}) \n
                            dan Nilai penjualan sebesar : ${
                              Isi[i].sales / 100
                            }`;
          }
        }
        if (!this.popover) {
          this.popover = new Dialog({
            title: resultTitle,
            content: new Text({ text: resultDetail }),
            beginButton: new Button({
              text: "Close",
              press: function () {
                this.popover.close();
              }.bind(this),
            }),
          });
        }
        this.getView().addDependent(this.popover);
        this.popover.setTitle(resultTitle);
        this.popover.getContent()[0].setText(resultDetail);

        this.popover.open();
      },
    });
  }
);
