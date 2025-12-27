/*global QUnit*/

sap.ui.define([
	"navigationbar/controller/Navbar.controller"
], function (Controller) {
	"use strict";

	QUnit.module("Navbar Controller");

	QUnit.test("I should test the Navbar controller", function (assert) {
		var oAppController = new Controller();
		oAppController.onInit();
		assert.ok(oAppController);
	});

});
