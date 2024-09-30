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
              let type = "";
              isian = data.results[i];
              console.log(data);

              // Menambahkan data yg di butuhkan untuk geomap
              let pos = `${data.results[i].longtitude};${data.results[i].latitude};0`;

              if (data.results[i].sales >= 6600000000) {
                color = "rgb(0,255,0)";
                type = "Success";
              } else if (
                data.results[i].sales >= 3300000000 &&
                data.results[i].sales < 6600000000
              ) {
                color = "rgb(255,189,0)";
                type = "Warning";
              } else {
                color = "rgb(255,0,0)";
                type = "Error";
              }

              isian.type = type;
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
      onRegionClick: function (e) {
        MessageToast.show(e.getParameter("code"));

      },
    });
  }
);
