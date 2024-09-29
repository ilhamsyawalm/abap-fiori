sap.ui.define(
  [
    "sap/ui/vbm/AnalyticMap",
    "sap/ui/core/mvc/Controller",
    "sap/ui/model/json/JSONModel",
    "sap/ui/Device",
    "sap/m/MessageToast",
  ],
  function (AnalyticMap, Controller, JSONModel, Device, MessageToast) {
    "use strict";

    AnalyticMap.GeoJSONURL = "../model/indonesia.json";
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

        oData.read("/Zilham_001_idn", {
          success: function (data) {
            for (let i = 0; i < data.results.length; i++) {
              let isian = [];
              let color = "";
              isian = data.results[i];

              // Menambahkan data yg di butuhkan untuk geomap
              let pos = `${data.results[i].longtitude};${data.results[i].latitude};0`;

              if (data.results[i].sales >= 66000000) {
                color = "rgb(255,0,0)";
              } else if (
                data.results[i].sales >= 33000000 &&
                data.results[i].sales < 66000000
              ) {
                color = "rgb(0,0,255)";
              } else {
                color = "rgb(0,255,0)";
              }

              isian.color = color;
              isian.pos = pos;
              Isi.push(isian);
              console.log(Isi);
            }
            var oModel = new sap.ui.model.json.JSONModel();

            // Set array data ke model
            oModel.setData({ products: Isi });

            // Mengikat model ke view
            x.getView().setModel(oModel, "productModel");
          },
        });
      },
    });
  }
);
