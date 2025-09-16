sap.ui.define(
  ["sap/ui/core/mvc/Controller"],
  /**
   * @param {typeof sap.ui.core.mvc.Controller} Controller
   */
  function (Controller) {
    "use strict";

    return Controller.extend("testapi.controller.Testing", {
      onInit: function () {
        console.log(
          "Apakah saya harus membuat disini secara ulang semuanya ? wkwkwk"
        );
        alert("Testing 123");
        prompt("Hallo semua ?");
      },
    });
  }
);
