(()=>{"use strict";Shiny,jQuery;const e=e=>{n()?$(e).html("<span>Collapse</span>"):$(e).html('<i class="fa fa-expand"></i>')},t=()=>{$(".show-expanded").toggleClass("d-none"),$(".hide-expanded").toggleClass("d-none")},n=()=>$("#sidebar-container").hasClass("sidebar-expanded");$((function(){$("[data-bs-toggle]").on("click",(e=>{$(e.currentTarget).find(".toggler").toggleClass("fa-chevron-down").toggleClass("fa-chevron-up")})),s(),$(".tab-trigger").on("click",(e=>{let t=$(e.currentTarget).data("target");a(t)}))}));const s=()=>{let e=$(".tab-trigger").first().data("target");a(e)},a=e=>{$("#big-tabs").find(".big-tab").each(((t,n)=>{i(n,e)}))},i=(e,t)=>{if($(e).data("name")==t)return $(e).removeClass("d-none"),$(e).show(),void $(e).trigger("shown");$(e).addClass("d-none"),$(e).hide(),$(e).trigger("hidden")},r=e=>{$("#settings-container").toggleClass("settings-expanded settings-collapsed"),g(),o()},o=()=>{let e=$("#settings-container").find(".settings-content");l()?e.hide():e.show()},g=()=>{let e={transform:"none","margin-top":0},t={position:"relative",top:0,right:0};l()&&(e={transform:"rotate(-90deg)","margin-top":"5rem"},t={position:"absolute",top:0,right:"1rem"}),$("#settings-container").find(".settings-label").css(e),$("#settings-container").find(".settings-icon").css(t)},l=()=>$("#settings-container").hasClass("settings-expanded");$((function(){$("[data-toggle=sidebar-collapse]").on("click",(n=>{var s;s=n.currentTarget,$("#sidebar-container").toggleClass("sidebar-expanded sidebar-collapsed"),e(s),t()})),$("[data-toggle=settings-collapse]").on("click",(e=>{r(e.currentTarget)})),$(".settings-label").on("click",(e=>{r(e.currentTarget)}))}))})();