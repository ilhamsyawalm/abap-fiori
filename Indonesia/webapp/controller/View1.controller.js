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

    var oModel = new JSONModel("../model/Data_Idn.json");

    let value = 0;

    return Controller.extend("indonesia.controller.App", {
      onInit: function () {
        this.getView().setModel(oModel);

        var oDeviceModel = new JSONModel(Device);
        oDeviceModel.setDefaultBindingMode("OneWay");
        this.getView().setModel(oDeviceModel, "device");

        oModel.attachRequestCompleted(function (oEvent) {
          value = oModel.getProperty("/Regions/");

          let delay = 1000;
          for (let i = 0; i < value.length; i++) {
            // Menggunakan set timeout untuk delay pemunculan data
            setTimeout(function () {
              let Netwr = oModel.getProperty("/Regions/" + i + "/Netwr");
              let Uom = oModel.getProperty("/Regions/" + i + "/Uom");
              let Total = Netwr * Uom;
              let color;

              if (Total >= 35000000) {
                color = oModel.getProperty("/Legend/4/color");
              } else if (Total >= 20000000 && Total < 35000000) {
                color = oModel.getProperty("/Legend/3/color");
              } else if (Total >= 10000000 && Total < 20000000) {
                color = oModel.getProperty("/Legend/2/color");
              } else if (Total >= 1000000 && Total < 10000000) {
                color = oModel.getProperty("/Legend/1/color");
              } else {
                color = oModel.getProperty("/Legend/0/color");
              }

              oModel.setProperty("/Regions/" + i + "/color", color);
              oModel.setProperty("/Regions/" + i + "/total", Total);
            }, delay);
            delay += 1000;
          }
        });
      },

      onRegionClick: function (e) {
        for (let i = 0; i < value.length; i++) {
          let code = oModel.getProperty("/Regions/" + i + "/code");
          if (code == e.getParameter("code")) {
            MessageToast.show(
              "Totalnya : " + oModel.getProperty("/Regions/" + i + "/total")
            );
          }
        }
      },

      onRegionContextMenu: function (e) {
        MessageToast.show("onRegionContextMenu " + e.getParameter("code"));
      },

      onClickItem: function (evt) {
        MessageToast.show("onClick");
      },

      onContextMenuItem: function (evt) {
        MessageToast.show("onContextMenu");
      },
    });
  }
);
