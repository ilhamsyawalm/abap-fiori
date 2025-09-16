/*global QUnit*/

sap.ui.define([
	"testapi/controller/Testing.controller"
], function (Controller) {
	"use strict";

	QUnit.module("Testing Controller");

	QUnit.test("I should test the Testing controller", function (assert) {
		var oAppController = new Controller();
		oAppController.onInit();
		assert.ok(oAppController);
	});

});
