/******/ (() => { // webpackBootstrap
/******/ 	"use strict";
/******/ 	var __webpack_modules__ = ({

/***/ "./srcjs/sidebar.js":
/*!**************************!*\
  !*** ./srcjs/sidebar.js ***!
  \**************************/
/***/ ((__unused_webpack_module, __webpack_exports__, __webpack_require__) => {

__webpack_require__.r(__webpack_exports__);
/* harmony export */ __webpack_require__.d(__webpack_exports__, {
/* harmony export */   "handleSidebar": () => (/* binding */ handleSidebar)
/* harmony export */ });
/* harmony import */ var jquery__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! jquery */ "jquery");
/* harmony import */ var jquery__WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(jquery__WEBPACK_IMPORTED_MODULE_0__);


const handleSidebar = () => {
  // Collapse click
  $('[data-toggle=sidebar-collapse]').on('click', (e) => {
    sidebarCollapse(e.currentTarget);
  });
}

const sidebarCollapse = (el) => {
  $('#sidebar-container').toggleClass('sidebar-expanded sidebar-collapsed');
  toggleCollapseButton(el);
  toggleCollapse();
}

const toggleCollapseButton = (el) => {
  if(isExpanded()) {
    $(el).html('<span>Collapse</span>');
    return;
  }

  $(el).html('<i class="fa fa-expand"></i>');
}

const toggleCollapse = () => {
  $('.show-expanded').toggleClass('d-none');
  $('.hide-expanded').toggleClass('d-none');
}

const isExpanded = () => {
  return $('#sidebar-container').hasClass('sidebar-expanded');
}

$(function() {
  $('[data-bs-toggle]').on('click', (e) => {
    console.log(e.currentTarget);
    $(e.currentTarget)
      .find('.toggler')
      .toggleClass('fa-chevron-down')
      .toggleClass('fa-chevron-up')
  });
});


/***/ }),

/***/ "shiny":
/*!************************!*\
  !*** external "Shiny" ***!
  \************************/
/***/ ((module) => {

module.exports = Shiny;

/***/ }),

/***/ "jquery":
/*!*************************!*\
  !*** external "jQuery" ***!
  \*************************/
/***/ ((module) => {

module.exports = jQuery;

/***/ })

/******/ 	});
/************************************************************************/
/******/ 	// The module cache
/******/ 	var __webpack_module_cache__ = {};
/******/ 	
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/ 		// Check if module is in cache
/******/ 		var cachedModule = __webpack_module_cache__[moduleId];
/******/ 		if (cachedModule !== undefined) {
/******/ 			return cachedModule.exports;
/******/ 		}
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = __webpack_module_cache__[moduleId] = {
/******/ 			// no module.id needed
/******/ 			// no module.loaded needed
/******/ 			exports: {}
/******/ 		};
/******/ 	
/******/ 		// Execute the module function
/******/ 		__webpack_modules__[moduleId](module, module.exports, __webpack_require__);
/******/ 	
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/ 	
/************************************************************************/
/******/ 	/* webpack/runtime/compat get default export */
/******/ 	(() => {
/******/ 		// getDefaultExport function for compatibility with non-harmony modules
/******/ 		__webpack_require__.n = (module) => {
/******/ 			var getter = module && module.__esModule ?
/******/ 				() => (module['default']) :
/******/ 				() => (module);
/******/ 			__webpack_require__.d(getter, { a: getter });
/******/ 			return getter;
/******/ 		};
/******/ 	})();
/******/ 	
/******/ 	/* webpack/runtime/define property getters */
/******/ 	(() => {
/******/ 		// define getter functions for harmony exports
/******/ 		__webpack_require__.d = (exports, definition) => {
/******/ 			for(var key in definition) {
/******/ 				if(__webpack_require__.o(definition, key) && !__webpack_require__.o(exports, key)) {
/******/ 					Object.defineProperty(exports, key, { enumerable: true, get: definition[key] });
/******/ 				}
/******/ 			}
/******/ 		};
/******/ 	})();
/******/ 	
/******/ 	/* webpack/runtime/hasOwnProperty shorthand */
/******/ 	(() => {
/******/ 		__webpack_require__.o = (obj, prop) => (Object.prototype.hasOwnProperty.call(obj, prop))
/******/ 	})();
/******/ 	
/******/ 	/* webpack/runtime/make namespace object */
/******/ 	(() => {
/******/ 		// define __esModule on exports
/******/ 		__webpack_require__.r = (exports) => {
/******/ 			if(typeof Symbol !== 'undefined' && Symbol.toStringTag) {
/******/ 				Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' });
/******/ 			}
/******/ 			Object.defineProperty(exports, '__esModule', { value: true });
/******/ 		};
/******/ 	})();
/******/ 	
/************************************************************************/
var __webpack_exports__ = {};
// This entry need to be wrapped in an IIFE because it need to be isolated against other modules in the chunk.
(() => {
/*!************************!*\
  !*** ./srcjs/index.js ***!
  \************************/
__webpack_require__.r(__webpack_exports__);
/* harmony import */ var shiny__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! shiny */ "shiny");
/* harmony import */ var shiny__WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(shiny__WEBPACK_IMPORTED_MODULE_0__);
/* harmony import */ var _sidebar_js__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ./sidebar.js */ "./srcjs/sidebar.js");



$(function(){
  (0,_sidebar_js__WEBPACK_IMPORTED_MODULE_1__.handleSidebar)();
});

})();

/******/ })()
;
//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJmaWxlIjoiYXNzZXRzL2luZGV4LmpzIiwibWFwcGluZ3MiOiI7Ozs7Ozs7Ozs7Ozs7Ozs7QUFBZ0I7O0FBRVQ7QUFDUDtBQUNBO0FBQ0E7QUFDQSxHQUFHO0FBQ0g7O0FBRUE7QUFDQTtBQUNBO0FBQ0E7QUFDQTs7QUFFQTtBQUNBO0FBQ0E7QUFDQTtBQUNBOztBQUVBO0FBQ0E7O0FBRUE7QUFDQTtBQUNBO0FBQ0E7O0FBRUE7QUFDQTtBQUNBOztBQUVBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0EsR0FBRztBQUNILENBQUM7Ozs7Ozs7Ozs7O0FDekNEOzs7Ozs7Ozs7O0FDQUE7Ozs7OztVQ0FBO1VBQ0E7O1VBRUE7VUFDQTtVQUNBO1VBQ0E7VUFDQTtVQUNBO1VBQ0E7VUFDQTtVQUNBO1VBQ0E7VUFDQTtVQUNBO1VBQ0E7O1VBRUE7VUFDQTs7VUFFQTtVQUNBO1VBQ0E7Ozs7O1dDdEJBO1dBQ0E7V0FDQTtXQUNBO1dBQ0E7V0FDQSxpQ0FBaUMsV0FBVztXQUM1QztXQUNBOzs7OztXQ1BBO1dBQ0E7V0FDQTtXQUNBO1dBQ0EseUNBQXlDLHdDQUF3QztXQUNqRjtXQUNBO1dBQ0E7Ozs7O1dDUEE7Ozs7O1dDQUE7V0FDQTtXQUNBO1dBQ0EsdURBQXVELGlCQUFpQjtXQUN4RTtXQUNBLGdEQUFnRCxhQUFhO1dBQzdEOzs7Ozs7Ozs7Ozs7OztBQ05lO0FBQzhCOztBQUU3QztBQUNBLEVBQUUsMERBQWE7QUFDZixDQUFDIiwic291cmNlcyI6WyJ3ZWJwYWNrOi8vYmlndWkvLi9zcmNqcy9zaWRlYmFyLmpzIiwid2VicGFjazovL2JpZ3VpL2V4dGVybmFsIHZhciBcIlNoaW55XCIiLCJ3ZWJwYWNrOi8vYmlndWkvZXh0ZXJuYWwgdmFyIFwialF1ZXJ5XCIiLCJ3ZWJwYWNrOi8vYmlndWkvd2VicGFjay9ib290c3RyYXAiLCJ3ZWJwYWNrOi8vYmlndWkvd2VicGFjay9ydW50aW1lL2NvbXBhdCBnZXQgZGVmYXVsdCBleHBvcnQiLCJ3ZWJwYWNrOi8vYmlndWkvd2VicGFjay9ydW50aW1lL2RlZmluZSBwcm9wZXJ0eSBnZXR0ZXJzIiwid2VicGFjazovL2JpZ3VpL3dlYnBhY2svcnVudGltZS9oYXNPd25Qcm9wZXJ0eSBzaG9ydGhhbmQiLCJ3ZWJwYWNrOi8vYmlndWkvd2VicGFjay9ydW50aW1lL21ha2UgbmFtZXNwYWNlIG9iamVjdCIsIndlYnBhY2s6Ly9iaWd1aS8uL3NyY2pzL2luZGV4LmpzIl0sInNvdXJjZXNDb250ZW50IjpbImltcG9ydCAnanF1ZXJ5JztcblxuZXhwb3J0IGNvbnN0IGhhbmRsZVNpZGViYXIgPSAoKSA9PiB7XG4gIC8vIENvbGxhcHNlIGNsaWNrXG4gICQoJ1tkYXRhLXRvZ2dsZT1zaWRlYmFyLWNvbGxhcHNlXScpLm9uKCdjbGljaycsIChlKSA9PiB7XG4gICAgc2lkZWJhckNvbGxhcHNlKGUuY3VycmVudFRhcmdldCk7XG4gIH0pO1xufVxuXG5jb25zdCBzaWRlYmFyQ29sbGFwc2UgPSAoZWwpID0+IHtcbiAgJCgnI3NpZGViYXItY29udGFpbmVyJykudG9nZ2xlQ2xhc3MoJ3NpZGViYXItZXhwYW5kZWQgc2lkZWJhci1jb2xsYXBzZWQnKTtcbiAgdG9nZ2xlQ29sbGFwc2VCdXR0b24oZWwpO1xuICB0b2dnbGVDb2xsYXBzZSgpO1xufVxuXG5jb25zdCB0b2dnbGVDb2xsYXBzZUJ1dHRvbiA9IChlbCkgPT4ge1xuICBpZihpc0V4cGFuZGVkKCkpIHtcbiAgICAkKGVsKS5odG1sKCc8c3Bhbj5Db2xsYXBzZTwvc3Bhbj4nKTtcbiAgICByZXR1cm47XG4gIH1cblxuICAkKGVsKS5odG1sKCc8aSBjbGFzcz1cImZhIGZhLWV4cGFuZFwiPjwvaT4nKTtcbn1cblxuY29uc3QgdG9nZ2xlQ29sbGFwc2UgPSAoKSA9PiB7XG4gICQoJy5zaG93LWV4cGFuZGVkJykudG9nZ2xlQ2xhc3MoJ2Qtbm9uZScpO1xuICAkKCcuaGlkZS1leHBhbmRlZCcpLnRvZ2dsZUNsYXNzKCdkLW5vbmUnKTtcbn1cblxuY29uc3QgaXNFeHBhbmRlZCA9ICgpID0+IHtcbiAgcmV0dXJuICQoJyNzaWRlYmFyLWNvbnRhaW5lcicpLmhhc0NsYXNzKCdzaWRlYmFyLWV4cGFuZGVkJyk7XG59XG5cbiQoZnVuY3Rpb24oKSB7XG4gICQoJ1tkYXRhLWJzLXRvZ2dsZV0nKS5vbignY2xpY2snLCAoZSkgPT4ge1xuICAgIGNvbnNvbGUubG9nKGUuY3VycmVudFRhcmdldCk7XG4gICAgJChlLmN1cnJlbnRUYXJnZXQpXG4gICAgICAuZmluZCgnLnRvZ2dsZXInKVxuICAgICAgLnRvZ2dsZUNsYXNzKCdmYS1jaGV2cm9uLWRvd24nKVxuICAgICAgLnRvZ2dsZUNsYXNzKCdmYS1jaGV2cm9uLXVwJylcbiAgfSk7XG59KTtcbiIsIm1vZHVsZS5leHBvcnRzID0gU2hpbnk7IiwibW9kdWxlLmV4cG9ydHMgPSBqUXVlcnk7IiwiLy8gVGhlIG1vZHVsZSBjYWNoZVxudmFyIF9fd2VicGFja19tb2R1bGVfY2FjaGVfXyA9IHt9O1xuXG4vLyBUaGUgcmVxdWlyZSBmdW5jdGlvblxuZnVuY3Rpb24gX193ZWJwYWNrX3JlcXVpcmVfXyhtb2R1bGVJZCkge1xuXHQvLyBDaGVjayBpZiBtb2R1bGUgaXMgaW4gY2FjaGVcblx0dmFyIGNhY2hlZE1vZHVsZSA9IF9fd2VicGFja19tb2R1bGVfY2FjaGVfX1ttb2R1bGVJZF07XG5cdGlmIChjYWNoZWRNb2R1bGUgIT09IHVuZGVmaW5lZCkge1xuXHRcdHJldHVybiBjYWNoZWRNb2R1bGUuZXhwb3J0cztcblx0fVxuXHQvLyBDcmVhdGUgYSBuZXcgbW9kdWxlIChhbmQgcHV0IGl0IGludG8gdGhlIGNhY2hlKVxuXHR2YXIgbW9kdWxlID0gX193ZWJwYWNrX21vZHVsZV9jYWNoZV9fW21vZHVsZUlkXSA9IHtcblx0XHQvLyBubyBtb2R1bGUuaWQgbmVlZGVkXG5cdFx0Ly8gbm8gbW9kdWxlLmxvYWRlZCBuZWVkZWRcblx0XHRleHBvcnRzOiB7fVxuXHR9O1xuXG5cdC8vIEV4ZWN1dGUgdGhlIG1vZHVsZSBmdW5jdGlvblxuXHRfX3dlYnBhY2tfbW9kdWxlc19fW21vZHVsZUlkXShtb2R1bGUsIG1vZHVsZS5leHBvcnRzLCBfX3dlYnBhY2tfcmVxdWlyZV9fKTtcblxuXHQvLyBSZXR1cm4gdGhlIGV4cG9ydHMgb2YgdGhlIG1vZHVsZVxuXHRyZXR1cm4gbW9kdWxlLmV4cG9ydHM7XG59XG5cbiIsIi8vIGdldERlZmF1bHRFeHBvcnQgZnVuY3Rpb24gZm9yIGNvbXBhdGliaWxpdHkgd2l0aCBub24taGFybW9ueSBtb2R1bGVzXG5fX3dlYnBhY2tfcmVxdWlyZV9fLm4gPSAobW9kdWxlKSA9PiB7XG5cdHZhciBnZXR0ZXIgPSBtb2R1bGUgJiYgbW9kdWxlLl9fZXNNb2R1bGUgP1xuXHRcdCgpID0+IChtb2R1bGVbJ2RlZmF1bHQnXSkgOlxuXHRcdCgpID0+IChtb2R1bGUpO1xuXHRfX3dlYnBhY2tfcmVxdWlyZV9fLmQoZ2V0dGVyLCB7IGE6IGdldHRlciB9KTtcblx0cmV0dXJuIGdldHRlcjtcbn07IiwiLy8gZGVmaW5lIGdldHRlciBmdW5jdGlvbnMgZm9yIGhhcm1vbnkgZXhwb3J0c1xuX193ZWJwYWNrX3JlcXVpcmVfXy5kID0gKGV4cG9ydHMsIGRlZmluaXRpb24pID0+IHtcblx0Zm9yKHZhciBrZXkgaW4gZGVmaW5pdGlvbikge1xuXHRcdGlmKF9fd2VicGFja19yZXF1aXJlX18ubyhkZWZpbml0aW9uLCBrZXkpICYmICFfX3dlYnBhY2tfcmVxdWlyZV9fLm8oZXhwb3J0cywga2V5KSkge1xuXHRcdFx0T2JqZWN0LmRlZmluZVByb3BlcnR5KGV4cG9ydHMsIGtleSwgeyBlbnVtZXJhYmxlOiB0cnVlLCBnZXQ6IGRlZmluaXRpb25ba2V5XSB9KTtcblx0XHR9XG5cdH1cbn07IiwiX193ZWJwYWNrX3JlcXVpcmVfXy5vID0gKG9iaiwgcHJvcCkgPT4gKE9iamVjdC5wcm90b3R5cGUuaGFzT3duUHJvcGVydHkuY2FsbChvYmosIHByb3ApKSIsIi8vIGRlZmluZSBfX2VzTW9kdWxlIG9uIGV4cG9ydHNcbl9fd2VicGFja19yZXF1aXJlX18uciA9IChleHBvcnRzKSA9PiB7XG5cdGlmKHR5cGVvZiBTeW1ib2wgIT09ICd1bmRlZmluZWQnICYmIFN5bWJvbC50b1N0cmluZ1RhZykge1xuXHRcdE9iamVjdC5kZWZpbmVQcm9wZXJ0eShleHBvcnRzLCBTeW1ib2wudG9TdHJpbmdUYWcsIHsgdmFsdWU6ICdNb2R1bGUnIH0pO1xuXHR9XG5cdE9iamVjdC5kZWZpbmVQcm9wZXJ0eShleHBvcnRzLCAnX19lc01vZHVsZScsIHsgdmFsdWU6IHRydWUgfSk7XG59OyIsImltcG9ydCAnc2hpbnknO1xuaW1wb3J0IHsgaGFuZGxlU2lkZWJhciB9IGZyb20gJy4vc2lkZWJhci5qcyc7XG5cbiQoZnVuY3Rpb24oKXtcbiAgaGFuZGxlU2lkZWJhcigpO1xufSk7XG4iXSwibmFtZXMiOltdLCJzb3VyY2VSb290IjoiIn0=