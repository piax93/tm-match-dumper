/**
 * Log warning and show notification
 */
void NotifyError(const string &in msg) {
    warn(msg);
    UI::ShowNotification(
        Meta::ExecutingPlugin().Name + ": Error",
        msg,
        vec4(.9, .6, .1, .5),
        15000
    );
}


/**
 * Check MLHook and MLFeed are installed, stall if they are not
 */
void DepCheck() {
    bool depMLHook = false;
    bool depMLFeed = false;
#if DEPENDENCY_MLHOOK
    depMLHook = true;
#endif
#if DEPENDENCY_MLFEEDRACEDATA
    depMLFeed = true;
#endif
    if (!(depMLFeed && depMLHook)) {
        if (!depMLHook) {
            NotifyError("Requires MLHook");
        }
        if (!depMLFeed) {
            NotifyError("Requires MLFeed: Race Data");
        }
        while (true) sleep(10000);
    }
}
