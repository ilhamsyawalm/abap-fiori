sap.ui.define(
  [
    "sap/ui/Device",
    "sap/ui/core/mvc/Controller",
    "sap/m/Popover",
    "sap/m/Button",
    "sap/m/library",
    "sap/tnt/library",
    "sap/m/MessageToast",
    "sap/suite/ui/commons/ChartContainer",
    "sap/suite/ui/commons/ChartContainerContent",
  ],
  /**
   * @param {typeof sap.ui.core.mvc.Controller} Controller
   */
  function (
    Device,
    Controller,
    Popover,
    Button,
    library,
    tntLibrary,
    MessageToast,
    ChartContainer,
    ChartContainerContent
  ) {
    "use strict";

    return Controller.extend("navigationbar.controller.Navbar", {
      onInit: function () {
        var oModel = new sap.ui.model.json.JSONModel(
          "https://ilhamsyawalm.github.io/abap-fiori/zgw_ilham/navigationbar/webapp/model/Data.json"
        );

        console.log(oModel);
        this.getView().setModel(oModel, "jsonModel");
      },
    });
  }
);
