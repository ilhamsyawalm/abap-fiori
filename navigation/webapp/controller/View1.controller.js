sap.ui.define(
  [
    "sap/ui/core/mvc/Controller",
    "sap/suite/ui/commons/ChartContainer",
    "sap/suite/ui/commons/ChartContainerContent",
    "sap/ui/vbm/AnalyticMap",
    "sap/ui/vbm/Spot",
    "sap/m/MessageToast",
    "sap/ui/Device",
    "sap/ui/model/json/JSONModel",
  ],
  function (
    Controller,
    ChartContainer,
    ChartContainerContent,
    AnalyticMap,
    Spot,
    MessageToast,
    JSONModel
  ) {
    "use strict";

    return Controller.extend("navigation.controller.View1", {
      //   onInit: function () {
      //     var oModel = new JSONModel("../model/Data.json");
      //     console.log(oModel);
      //     this.getView().setModel(oModel);
      //     this._setToggleButtonTooltip(!Device.system.desktop);
      //   },

      onAvatarPressed: function () {
        MessageToast.show("Avatar pressed!");
      },

      onLogoPressed: function () {
        MessageToast.show("Logo pressed!");
      },

      _handleMediaChange: function () {
        var rangeName = Device.media.getCurrentRange("StdExt").name;

        switch (rangeName) {
          // Shell Desktop
          case "LargeDesktop":
            this.byId("productName").setVisible(true);
            this.byId("secondTitle").setVisible(true);
            this.byId("searchField").setVisible(true);

            this.byId("searchButton").setVisible(false);
            MessageToast.show("Screen width is corresponding to Large Desktop");
            break;

          // Tablet - Landscape
          case "Desktop":
            this.byId("productName").setVisible(true);
            this.byId("secondTitle").setVisible(false);
            this.byId("searchField").setVisible(true);

            this.byId("searchButton").setVisible(false);
            MessageToast.show("Screen width is corresponding to Desktop");
            break;

          // Tablet - Portrait
          case "Tablet":
            this.byId("productName").setVisible(true);
            this.byId("secondTitle").setVisible(true);
            this.byId("searchButton").setVisible(true);
            this.byId("searchField").setVisible(false);

            MessageToast.show("Screen width is corresponding to Tablet");
            break;

          case "Phone":
            this.byId("searchButton").setVisible(true);
            this.byId("searchField").setVisible(false);

            this.byId("productName").setVisible(false);
            this.byId("secondTitle").setVisible(false);
            MessageToast.show("Screen width is corresponding to Phone");
            break;

          default:
            break;
        }
      },

      onCollapseExpandPress() {
        const oSideNavigation = this.byId("sideNavigation"),
          bExpanded = oSideNavigation.getExpanded();

        oSideNavigation.setExpanded(!bExpanded);
      },

      onHideShowWalkedPress() {
        const oNavListItem = this.byId("walked");
        oNavListItem.setVisible(!oNavListItem.getVisible());
      },

      onItemSelect: function (oEvent) {
        console.log("Ini home");
        MessageToast.show("Home pressed!");
        // var oItem = oEvent.getParameter("item");
        // this.byId("pageContainer").to(this.getView().createId(oItem.getKey()));
      },
    });
  }
);
