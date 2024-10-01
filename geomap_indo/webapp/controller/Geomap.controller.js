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

        oData.read("/Zilham_001_idn", {
          success: function (data) {
            for (let i = 0; i < data.results.length; i++) {
              let isian = [];
              let color = "";
              let type = "";
              // let Success = rgb(255, 255, 255);
              isian = data.results[i];
              // console.log(data);

              // Menambahkan data yg di butuhkan untuk geomap
              let pos = `${data.results[i].longtitude};${data.results[i].latitude};0`;

              if (data.results[i].sales >= 6600000000) {
                color = "rgb(56, 163, 56)";
                type = "Success";
              } else if (
                data.results[i].sales >= 3300000000 &&
                data.results[i].sales < 6600000000
              ) {
                color = "rgb(249, 172, 60)";
                type = "Warning";
              } else {
                color = "rgb(243,0,0)";
                type = "Error";
              }

              isian.type = type;
              isian.color = color;
              isian.pos = pos;
              Isi.push(isian);
              // console.log(Isi);
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
    });
  }
);
