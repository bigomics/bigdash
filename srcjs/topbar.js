$(document).ready(function() {
    $(".dropdown-item").on("click", function(e) {
        $(this).closest('.dropdown').find('.dropdown-toggle').dropdown('toggle');
    })
})