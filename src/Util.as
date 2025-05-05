/**
 * Just some 3-state flag
 */
enum Knowledge {
    UNSURE = 0,
    YEP = 1,
    NOPE = 2,
}


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


/**
 * Check if online rooms is in warmup round
 */
bool IsInWarmup(CTrackMania@ app) {
    return !(
        app.Network is null
        || app.Network.ClientManiaAppPlayground is null
        || app.Network.ClientManiaAppPlayground.UI.UIStatus != CGamePlaygroundUIConfig::EUIStatus::Warning
    );
}


/**
 * Get sum of team scores if in server
 */
uint GetTotalServerScore(CTrackMania@ app) {
    if (
        app.Network is null
        || app.Network.ClientManiaAppPlayground is null
        || !(cast<CTrackManiaNetworkServerInfo>(app.Network.ServerInfo).IsTeamMode)
    ) return 0;
    uint total = 0, scoresFound = 0;
    auto mmdata = MLFeed::GetTeamsMMData_V1();
    for(uint i = 0; i < mmdata.ClanScores.Length && scoresFound < 2; i++) {
        auto score = mmdata.ClanScores[i];
        if (score > 0) {
            scoresFound++;
            total += score;
        }
    }
    return total;
}


/**
 * Create random round identifier
 */
string GenerateRoundId() {
    return "r-" + Crypto::Random(8).ReadToHex(8);
}
