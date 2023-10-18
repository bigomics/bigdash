export function handleActivityTracker() {
    $(document).on("click", function(event) {
        Shiny.setInputValue("userActivity", Math.random(), {priority: "event"});
    });
}