// Reports at most once every REPORT_EVERY ms rather than on every click. The
// input only resets an inactivity timer -- one measured in minutes -- while
// every click inside a plotly figure (pan, zoom, lasso, legend toggle) was
// buying a server round trip.
const REPORT_EVERY = 15000;

export function handleActivityTracker() {
    let last = 0;
    $(document).on("click", function(event) {
        const now = Date.now();
        if (now - last < REPORT_EVERY) return;
        last = now;
        Shiny.setInputValue("userActivity", now, {priority: "event"});
    });
}