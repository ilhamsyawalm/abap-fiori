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

    var ButtonType = library.ButtonType,
      PlacementType = library.PlacementType,
      NavigationListItemDesign = tntLibrary.NavigationListItemDesign;

    return Controller.extend("navigationbar.controller.Navbar", {
      onInit: function () {
        var oModel = new sap.ui.model.json.JSONModel(
          "https://ilhamsyawalm.github.io/abap-fiori/zgw_ilham/navigationbar/webapp/model/Data.json"
        );

        this.getView().setModel(oModel, "jsonModel");
      },

      adjustMyChartBox: function (oView, sChartId, sBlockId) {
        var oVizFrame = oView.byId(sChartId);
        var oChartContainerContent = new ChartContainerContent({
          content: [oVizFrame],
        });
        var oChartContainer = new ChartContainer({
          content: [oChartContainerContent],
        });

        oChartContainer.setShowFullScreen(true);
        oChartContainer.setAutoAdjustHeight(true);
        oView.byId(sBlockId).addContent(oChartContainer);
      },

      // Saat side navigation digunakan
      onItemSelect: function (oEvent) {
        var oItem = oEvent.getParameter("item");
        this.byId("pageContainer").to(this.getView().createId(oItem.getKey()));
      },

      // Memasukan button baru saat nama di click
      handleUserNamePress: function (event) {
        var oPopover = new Popover({
          showHeader: false,
          placement: PlacementType.Bottom,
          content: [
            new Button({
              text: "Feedback",
              type: ButtonType.Transparent,
            }),
            new Button({
              text: "Help",
              type: ButtonType.Transparent,
            }),
            new Button({
              text: "Logout",
              type: ButtonType.Transparent,
            }),
          ],
        }).addStyleClass("sapMOTAPopover sapTntToolHeaderPopover");

        oPopover.openBy(event.getSource());
      },

      // Alert saat user di click
      onAvatarPressed: function () {
        MessageToast.show("Hello everyone! :)");
      },

      onFixedPressed: function () {
        MessageToast.show("Fixed navigation got press! :)");
      },

      // Untuk hamburger side navigation
      onSideNavButtonPress: function () {
        var oToolPage = this.byId("toolPage");
        var bSideExpanded = oToolPage.getSideExpanded();

        this._setToggleButtonTooltip(bSideExpanded);

        oToolPage.setSideExpanded(!oToolPage.getSideExpanded());
      },

      _setToggleButtonTooltip: function (bLarge) {
        var oToggleButton = this.byId("sideNavigationToggleButton");
        if (bLarge) {
          oToggleButton.setTooltip("Large Size Navigation");
        } else {
          oToggleButton.setTooltip("Small Size Navigation");
        }
      },
    });
  }
);
